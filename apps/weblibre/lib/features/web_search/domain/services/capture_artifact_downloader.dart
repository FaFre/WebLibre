import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_protocol/search_protocol.dart';
import 'package:search_client/search_client.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/search_credits/domain/providers.dart';
import 'package:weblibre/features/search_credits/domain/providers/proxy_client.dart';

part 'capture_artifact_downloader.g.dart';

class CaptureArtifactDownloadException implements Exception {
  final String message;
  final int? statusCode;

  CaptureArtifactDownloadException(this.message, {this.statusCode});

  @override
  String toString() =>
      'CaptureArtifactDownloadException: $message'
      '${statusCode != null ? ' (status $statusCode)' : ''}';
}

class CaptureArtifactDownloader {
  CaptureArtifactDownloader({
    required BackendEndpoints endpoints,
    required Directory storageDir,
    http.Client? client,
  }) : _endpoints = endpoints,
       _storageDir = storageDir,
       _client = client ?? http.Client();

  final BackendEndpoints _endpoints;
  final Directory _storageDir;
  final http.Client _client;

  /// Bound on the artifact download — covers connect + read combined. The
  /// download path runs through the proxy client (which may be Tor), so a
  /// stuck connection would otherwise leave the UI in `downloading` forever.
  static const _downloadTimeout = Duration(seconds: 60);

  Future<String> download(CaptureArtifactReceipt receipt) async {
    await _storageDir.create(recursive: true);

    final extension = captureFileExtension(receipt.contentType);
    if (extension == null) {
      // No on-disk extension we know how to serve back to Gecko later — the
      // loopback capture server only probes a fixed set of extensions and an
      // `.bin` artifact would be orphaned on disk. Surface the failure
      // upstream instead of silently writing a file that can never load.
      throw CaptureArtifactDownloadException(
        'unsupported capture content type: ${receipt.contentType}',
      );
    }
    final targetPath = p.join(
      _storageDir.path,
      '${receipt.captureId}$extension',
    );
    final tmpPath = '$targetPath.part';

    final target = File(targetPath);
    if (await target.exists()) {
      return targetPath;
    }

    final uri = _endpoints.captureDownload(receipt.captureId);

    final request = http.Request('GET', uri);
    request.headers[HttpHeaders.authorizationHeader] =
        'Bearer ${receipt.downloadToken}';
    final streamed = await _client.send(request).timeout(_downloadTimeout);

    if (streamed.statusCode != HttpStatus.ok) {
      throw CaptureArtifactDownloadException(
        'capture artifact download failed',
        statusCode: streamed.statusCode,
      );
    }

    final tmp = File(tmpPath);
    final sink = tmp.openWrite();
    try {
      await streamed.stream.pipe(sink).timeout(_downloadTimeout);
    } catch (e) {
      await sink.close();
      if (await tmp.exists()) {
        await tmp.delete();
      }
      rethrow;
    }

    await tmp.rename(targetPath);
    return targetPath;
  }
}

/// Directory under the app temp area where capture artifacts are stored.
Directory captureStorageDirectory() {
  return Directory(
    p.join(
      filesystem.tempDir.path,
      'web_search_captures',
      filesystem.selectedProfile.uuid,
    ),
  );
}

/// Single source of truth for the capture artifact MIME ↔ extension mapping.
///
/// The capture server's loopback handler probes for exactly these extensions
/// on disk (see [resolveCaptureExtensions]) and looks up the response
/// `Content-Type` against this list (see [captureContentTypeForExtension]),
/// so adding a new artifact format only requires editing this one table.
const _captureArtifactTypes = <({String mime, String extension})>[
  (mime: 'text/html', extension: '.html'),
  (mime: 'application/pdf', extension: '.pdf'),
  (mime: 'image/png', extension: '.png'),
  (mime: 'image/jpeg', extension: '.jpg'),
];

/// File extensions the capture server should probe when resolving a stored
/// artifact (HTML + `.jpeg` alias for `image/jpeg`).
const captureSupportedExtensions = <String>[
  '.html',
  '.pdf',
  '.png',
  '.jpg',
  '.jpeg',
];

/// Maps a capture receipt's MIME [contentType] to the on-disk extension we
/// store the artifact under. The extension is also what the loopback capture
/// server uses to pick the right `Content-Type` when serving back to Gecko.
///
/// Returns `null` for an unknown content type — the caller (downloader)
/// surfaces this as a download error rather than writing an orphan `.bin`
/// the loopback server can't serve.
String? captureFileExtension(String? contentType) {
  if (contentType == null) return null;
  final mime = contentType.split(';').first.trim().toLowerCase();
  for (final type in _captureArtifactTypes) {
    if (type.mime == mime) return type.extension;
  }
  return null;
}

/// True if [contentType] designates an HTML artifact. The sandbox-capture
/// flow (loopback redirects, retry loader, link-click interception) only
/// applies to HTML — PDF / PNG artifacts are loaded directly in a regular
/// tab so Gecko's built-in viewer renders them.
bool isHtmlCaptureContentType(String? contentType) {
  if (contentType == null) return false;
  return contentType.split(';').first.trim().toLowerCase() == 'text/html';
}

/// Snapshot of the host display, fed to the capture engines as
/// `CaptureDimensions` so PDF/PNG renders match the user's viewport.
///
/// `mobile` is always `true` so captures emulate a mobile viewport.
/// `colorScheme` follows the platform brightness so dark-mode sites render
/// correctly.
CaptureDimensions currentDisplayCaptureDimensions() {
  final view =
      PlatformDispatcher.instance.implicitView ??
      PlatformDispatcher.instance.views.first;
  final dpr = view.devicePixelRatio;
  final physical = view.physicalSize;
  final colorScheme =
      PlatformDispatcher.instance.platformBrightness == Brightness.dark
      ? 'dark'
      : 'light';
  if (dpr <= 0 || physical.width <= 0 || physical.height <= 0) {
    return CaptureDimensions(mobile: true, colorScheme: colorScheme);
  }
  final logicalWidth = (physical.width / dpr).round();
  final logicalHeight = (physical.height / dpr).round();
  return CaptureDimensions(
    width: logicalWidth,
    height: logicalHeight,
    screenWidth: logicalWidth,
    screenHeight: logicalHeight,
    dpi: dpr,
    mobile: true,
    colorScheme: colorScheme,
  );
}

/// Inverse of [captureFileExtension] — used by the loopback capture server
/// to choose a `Content-Type` header from a stored artifact's extension.
/// `.html` carries a charset; binary types don't.
String? captureContentTypeForExtension(String extension) {
  final ext = extension.toLowerCase();
  if (ext == '.jpeg') return 'image/jpeg';
  for (final type in _captureArtifactTypes) {
    if (type.extension == ext) {
      return type.mime == 'text/html' ? 'text/html; charset=utf-8' : type.mime;
    }
  }
  return null;
}

@Riverpod(keepAlive: true)
CaptureArtifactDownloader captureArtifactDownloader(Ref ref) {
  return CaptureArtifactDownloader(
    endpoints: ref.watch(searchBackendEndpointsProvider),
    storageDir: captureStorageDirectory(),
    client: ref.watch(searchProxyHttpClientProvider),
  );
}
