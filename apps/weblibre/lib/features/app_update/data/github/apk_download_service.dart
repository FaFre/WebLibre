/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:weblibre/features/app_update/data/github/allowlisted_fetcher.dart';
import 'package:weblibre/features/app_update/data/github/update_endpoints.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/services/staged_file_policy.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';

/// Streams an APK to `<stagingDir>/<sha256>.part` (plan 7.3).
///
/// The signed length decides, not `Content-Length`: the download aborts the
/// moment it would exceed it. A `.part` file is continued with `Range` when
/// the server answers 206 for exactly that offset, otherwise started over.
/// Dart writes the `.part` file and never renames it: promotion to `.apk`
/// happens natively, after every check of 7.4. The digest is one of them, so
/// resume is safe without Dart hashing the file as well; native deletes a
/// `.part` whose digest is wrong.
class ApkDownloadService {
  ApkDownloadService({
    required this.fetcher,
    required this.stagingDir,
    this.limits = const FetchLimits(),
    this.retryDelay = const Duration(seconds: 2),
    this.progressInterval = const Duration(milliseconds: 100),
  });

  final AllowlistedFetcher fetcher;
  final String stagingDir;
  final FetchLimits limits;
  final Duration retryDelay;

  /// Progress is reported at most this often, plus once at the end: one
  /// report per network chunk would be thousands for an APK.
  final Duration progressInterval;

  File partFile(String sha256) =>
      File(p.join(stagingDir, StagedFile.partName(sha256)));

  Future<int> partialLength(String sha256) async {
    final file = partFile(sha256);
    return await file.exists() ? await file.length() : 0;
  }

  Future<void> download(
    ArtifactRef artifact, {
    required void Function(int received, int total) onProgress,
    required CancelToken cancel,
  }) async {
    if (artifact.byteLength > limits.artifactHardCap) {
      throw UpdateFailure(UpdateFailureKind.downloadTooLarge);
    }

    for (var attempt = 1; ; attempt++) {
      try {
        await _attempt(artifact, onProgress: onProgress, cancel: cancel);
        return;
      } on FileSystemException catch (e) {
        if (cancel.isCancelled) throw const OperationCancelled();
        throw storageFailure(e);
      } on UpdateFailure catch (failure) {
        final transient = failure.kind == UpdateFailureKind.network;
        if (!transient || attempt >= limits.attempts || cancel.isCancelled) {
          rethrow;
        }
        await cancel.orCancelled(Future<void>.delayed(retryDelay * attempt));
      }
    }
  }

  Future<void> _attempt(
    ArtifactRef artifact, {
    required void Function(int received, int total) onProgress,
    required CancelToken cancel,
  }) async {
    final file = partFile(artifact.sha256);
    await file.parent.create(recursive: true);

    var existing = await file.exists() ? await file.length() : 0;
    if (existing > artifact.byteLength) {
      await file.delete();
      existing = 0;
    }
    if (existing == artifact.byteLength) return;

    final response = await fetcher.openArtifact(
      artifact.url,
      rangeStart: existing,
      cancel: cancel,
    );

    final resumed =
        existing > 0 &&
        response.statusCode == 206 &&
        _rangeStart(response.headers['content-range']) == existing;
    if (response.statusCode != 200 && !resumed) {
      await AllowlistedFetcher.discardBody(response);
      if (response.statusCode == 206 || response.statusCode == 416) {
        // A range we didn't ask for: start over next attempt.
        await file.delete();
      }
      throw UpdateFailure(
        UpdateFailureKind.network,
        'artifact HTTP ${response.statusCode}',
      );
    }
    if (!resumed) existing = 0;

    final sink = await file.open(
      mode: resumed ? FileMode.writeOnlyAppend : FileMode.writeOnly,
    );
    var received = existing;
    try {
      if (!resumed) await sink.truncate(0);
      onProgress(received, artifact.byteLength);
      final sinceReport = Stopwatch()..start();

      await for (final chunk in response.stream.timeout(limits.stallTimeout)) {
        if (cancel.isCancelled) throw const OperationCancelled();
        received += chunk.length;
        if (received > artifact.byteLength ||
            received > limits.artifactHardCap) {
          await sink.close();
          await file.delete();
          throw UpdateFailure(UpdateFailureKind.downloadTooLarge);
        }
        await sink.writeFrom(chunk);
        if (sinceReport.elapsed >= progressInterval) {
          sinceReport.reset();
          onProgress(received, artifact.byteLength);
        }
      }
      await sink.flush();
      onProgress(received, artifact.byteLength);
    } on UpdateFailure {
      rethrow;
    } on OperationCancelled {
      rethrow;
    } on FileSystemException {
      rethrow; // The staging file, not the network: [download] maps it.
    } catch (e) {
      throw AllowlistedFetcher.mapError(e, cancel);
    } finally {
      try {
        await sink.close();
      } catch (_) {}
    }

    if (cancel.isCancelled) throw const OperationCancelled();
    await _finish(file, artifact);
  }

  /// The signed length must match. The digest is checked natively before
  /// promotion (7.4), which deletes a file that fails it.
  Future<void> _finish(File file, ArtifactRef artifact) async {
    final length = await file.length();
    if (length != artifact.byteLength) {
      if (length > artifact.byteLength) await file.delete();
      throw UpdateFailure(
        length < artifact.byteLength
            ? UpdateFailureKind.network
            : UpdateFailureKind.downloadMismatch,
        'length $length',
      );
    }
  }

  /// Writing the staging file failed. Not retried: a full disk doesn't free
  /// itself within seconds. The staging directory is the app's cache, so
  /// whatever fails there (no space, a quota, Android clearing the cache
  /// under storage pressure) is storage, never the network.
  static UpdateFailure storageFailure(FileSystemException e) =>
      UpdateFailure(UpdateFailureKind.insufficientStorage, e.toString());

  static int? _rangeStart(String? contentRange) {
    if (contentRange == null) return null;
    final match = RegExp(
      r'^bytes (\d+)-\d+/(\d+|\*)$',
    ).firstMatch(contentRange);
    return match == null ? null : int.tryParse(match.group(1)!);
  }
}
