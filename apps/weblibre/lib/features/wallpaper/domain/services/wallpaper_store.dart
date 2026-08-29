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
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/logger.dart';

/// Directory name, under the profile's `files/`, that holds imported
/// wallpapers.
///
/// Inside the profile on purpose: everything under it except `cache` and the
/// read-only asset databases is packed into a profile backup (see
/// `BackupExclusions`), so a wallpaper travels with the profile it belongs to
/// rather than being silently lost on restore.
const wallpaperDirName = 'wallpapers';

/// Sources larger than this are refused outright. Well past any photo a camera
/// produces; what it stops is a multi-hundred-megabyte file being copied into
/// the profile (and from there into every backup archive) by accident.
const _maxSourceBytes = 48 * 1024 * 1024;

/// A source is re-encoded rather than stored verbatim once it is longer than
/// this on either edge. No display is anywhere near it, so the extra pixels are
/// decode cost and archive weight for nothing.
const _maxStoredEdge = 2560;

/// A wallpaper the store refuses to take.
///
/// Carries a message written for the user, because every caller is a picker
/// that has to say why the image did not stick.
class WallpaperImportException implements Exception {
  final String message;

  const WallpaperImportException(this.message);

  @override
  String toString() => 'WallpaperImportException: $message';
}

/// Imported wallpapers on disk.
///
/// Files are addressed by an opaque name, never by path: profile directories
/// move between installs and restores, so a stored absolute path is a broken
/// reference waiting to happen. A fresh name per import is also what evicts the
/// previous picture from Flutter's image cache when a wallpaper is replaced —
/// same path, new bytes would keep showing the old one.
///
/// Nothing here deletes on replacement. The store has several writers (the
/// settings screen, the container editor — which stages an import that may
/// never be saved) and no way to know which references still stand, so
/// reclaiming is done in one pass by [deleteUnreferenced] instead.
class WallpaperStore {
  final Directory Function() _profileDir;

  /// [profileDir] is a callback rather than a directory so the store can be
  /// constructed before a profile is activated — `filesystem.selectedProfileDir`
  /// throws until the process has committed to one.
  const WallpaperStore({required Directory Function() profileDir})
    : _profileDir = profileDir;

  Directory get directory =>
      Directory(p.join(_profileDir().path, 'files', wallpaperDirName));

  /// The file [fileName] names. Not guaranteed to exist — a wallpaper can go
  /// missing when a profile is restored from an archive written before it was
  /// set, and callers render the plain backdrop in that case rather than
  /// treating it as an error.
  File resolve(String fileName) => File(p.join(directory.path, fileName));

  /// Copies [sourcePath] into the store and returns the name it was given.
  ///
  /// Throws [WallpaperImportException] when the source is unreadable, too
  /// large, or not an image.
  Future<String> import(String sourcePath) async {
    final source = File(sourcePath);

    final int length;
    try {
      length = await source.length();
    } on FileSystemException catch (e, s) {
      logger.w('Wallpaper source unreadable', error: e, stackTrace: s);
      throw const WallpaperImportException('That file could not be read');
    }

    if (length > _maxSourceBytes) {
      throw const WallpaperImportException('That image is too large');
    }

    final bytes = await source.readAsBytes();

    final mimeType = lookupMimeType(sourcePath, headerBytes: bytes);
    if (mimeType == null || !mimeType.startsWith('image/')) {
      throw const WallpaperImportException('That file is not an image');
    }

    final _PreparedWallpaper prepared;
    try {
      prepared = await _prepareOffIsolate(bytes, mimeType);
    } catch (e, s) {
      logger.w('Wallpaper could not be decoded', error: e, stackTrace: s);
      throw const WallpaperImportException('That image could not be read');
    }

    final fileName = '${const Uuid().v7()}.${prepared.extension}';
    final target = resolve(fileName);
    await target.parent.create(recursive: true);

    // Written aside and renamed so a crash mid-write cannot leave a truncated
    // file under a name the settings already point at.
    final part = File('${target.path}.part');
    await part.writeAsBytes(prepared.bytes, flush: true);
    await part.rename(target.path);

    return fileName;
  }

  Future<void> delete(String fileName) async {
    // Only ever a bare name from our own settings; refuse anything that could
    // walk out of the directory.
    if (p.basename(fileName) != fileName) return;

    try {
      await resolve(fileName).delete();
    } on FileSystemException {
      // Already gone is the state we wanted.
    }
  }

  /// Deletes every stored wallpaper that is not in [referenced], and returns
  /// how many went.
  ///
  /// This is the only thing that reclaims space: replaced images, imports from
  /// a container edit the user then cancelled, wallpapers of deleted
  /// containers, and anything an archive restored that the restored settings do
  /// not point at. It is deliberately driven by the live references rather than
  /// by hooks on each of those paths, because a missed hook leaks a file
  /// forever while a missed sweep only defers one.
  Future<int> deleteUnreferenced(Set<String> referenced) async {
    final dir = directory;
    if (!await dir.exists()) return 0;

    var deleted = 0;

    await for (final entity in dir.list(followLinks: false)) {
      if (entity is! File) continue;

      final name = p.basename(entity.path);
      // `.part` files are either an import in flight or the remains of one that
      // crashed; neither is ever referenced, so both are collected here.
      if (referenced.contains(name)) continue;

      try {
        await entity.delete();
        deleted++;
      } on FileSystemException catch (e, s) {
        logger.w('Could not delete wallpaper', error: e, stackTrace: s);
      }
    }

    return deleted;
  }
}

class _PreparedWallpaper {
  final Uint8List bytes;
  final String extension;

  const _PreparedWallpaper({required this.bytes, required this.extension});
}

/// Same fallback shape as `encodeScreenshotAsPng`: dart:ui's codecs work in a
/// background isolate, and doing this inline would stall the frame the picker
/// is animating out on.
Future<_PreparedWallpaper> _prepareOffIsolate(
  Uint8List bytes,
  String mimeType,
) async {
  try {
    return await Isolate.run(() => _prepare(bytes, mimeType));
  } catch (e, s) {
    logger.w(
      'Wallpaper preparation failed in background isolate, retrying inline',
      error: e,
      stackTrace: s,
    );

    return _prepare(bytes, mimeType);
  }
}

/// Decides whether [bytes] can be stored as they are, and downscales them if
/// not.
///
/// Storing the source verbatim is the common case and the better one: dart:ui
/// can only re-encode as PNG, which for a photograph is several times the size
/// of the JPEG it came from. Re-encoding happens only when the image is larger
/// than any display needs, or when it is animated — an animated wallpaper is
/// out of scope, and flattening it to its first frame here is what keeps a GIF
/// from quietly becoming one.
Future<_PreparedWallpaper> _prepare(Uint8List bytes, String mimeType) async {
  final buffer = await ImmutableBuffer.fromUint8List(bytes);
  final descriptor = await ImageDescriptor.encoded(buffer);

  try {
    final longestEdge = max(descriptor.width, descriptor.height);
    final oversized = longestEdge > _maxStoredEdge;
    final scale = oversized ? _maxStoredEdge / longestEdge : 1.0;

    final codec = await descriptor.instantiateCodec(
      targetWidth: oversized ? (descriptor.width * scale).round() : null,
      targetHeight: oversized ? (descriptor.height * scale).round() : null,
    );

    try {
      if (!oversized && codec.frameCount <= 1) {
        return _PreparedWallpaper(
          bytes: bytes,
          extension: extensionFromMime(mimeType) ?? 'img',
        );
      }

      final frame = await codec.getNextFrame();

      try {
        final png = await frame.image.toByteData(format: ImageByteFormat.png);
        if (png == null) {
          throw StateError('Wallpaper re-encode produced no bytes');
        }

        return _PreparedWallpaper(
          bytes: png.buffer.asUint8List(),
          extension: 'png',
        );
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  } finally {
    descriptor.dispose();
    buffer.dispose();
  }
}
