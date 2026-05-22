import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:path/path.dart' as p;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';

part 'capture_server.g.dart';

// Extensions kept in lock-step with [captureFileExtension] in
// capture_artifact_downloader.dart — the downloader writes the artifact under
// one of these and this server probes for the same set.

class RetryRequest {
  final String tabId;
  final String captureId;
  const RetryRequest({required this.tabId, required this.captureId});
}

/// Loopback HTTP server that exposes locally-stored capture HTML to the
/// in-app GeckoView.
///
/// Gecko rejects `content://` (PDF-only) and `file://` (blocked scheme), so
/// captures are served over `http://127.0.0.1:<port>/captures/<id>.html?t=<token>`.
/// Every published capture gets a fresh random token — other apps binding
/// to the same loopback cannot enumerate captures without guessing it.
///
/// The server also serves a zero-JS "Capturing…" loader page at
/// `/loader?tab=<tabId>&capture=<captureId>[&err=1]`. Sandbox tab navigation
/// is redirected to this loader while the capture is in flight; a
/// `meta http-equiv="refresh"` tag loops until the capture is ready, at which
/// point the loader responds with a `Refresh: 0; url=<captureUrl>` header so
/// GeckoView transitions to the real capture without JavaScript.
class _CaptureEntry {
  _CaptureEntry({required this.token});

  final String token;
  // Cached path to the resolved artifact, populated by the first probe so
  // hot paths (loader long-poll wakeups) don't keep stat'ing the FS for
  // five extensions per check.
  File? cachedFile;
}

class CaptureServer {
  CaptureServer({required Directory storageDir}) : _storageDir = storageDir;

  final Directory _storageDir;
  final Map<String, _CaptureEntry> _entriesById = {};
  final Set<String> _failedIds = {};
  // Completer per captureId, completed by publish()/markFailed() so loader
  // long-polls wake up immediately instead of busy-looping a 200ms poll.
  // Recreated after each completion so a subsequent retry can wait again.
  final Map<String, Completer<void>> _waiters = {};
  final _random = Random.secure();
  final _retryController = StreamController<RetryRequest>.broadcast();

  HttpServer? _server;
  Future<HttpServer>? _starting;

  Completer<void> _waiterFor(String captureId) {
    return _waiters.putIfAbsent(captureId, Completer<void>.new);
  }

  void _signalWaiter(String captureId) {
    final completer = _waiters.remove(captureId);
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  Stream<RetryRequest> get retryRequests => _retryController.stream;

  Future<HttpServer> _ensureStarted() async {
    final existing = _server;
    if (existing != null) return existing;
    final pending = _starting;
    if (pending != null) return pending;

    // Track success and failure: a rejected bind() must clear `_starting`,
    // otherwise the stale rejected future is handed back to every subsequent
    // caller and the server can never recover (e.g. transient EADDRINUSE).
    final future = HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _starting = future
        .then((server) {
          _server = server;
          unawaited(_serve(server));
          return server;
        })
        .whenComplete(() => _starting = null);
    return _starting!;
  }

  Future<void> _serve(HttpServer server) async {
    await for (final request in server) {
      unawaited(_handle(request));
    }
  }

  Future<void> _handle(HttpRequest request) async {
    try {
      final segments = request.uri.pathSegments;
      if (segments.isEmpty) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      switch (segments[0]) {
        case 'captures':
          if (request.method != 'GET' || segments.length != 2) {
            await _emptyResponse(request, HttpStatus.methodNotAllowed);
            return;
          }
          await _handleCapture(request, segments[1]);
          return;
        case 'loader':
          if (segments.length == 1) {
            if (request.method != 'GET') {
              await _emptyResponse(request, HttpStatus.methodNotAllowed);
              return;
            }
            await _handleLoader(request);
            return;
          }
          if (segments.length == 2 && segments[1] == 'wait') {
            if (request.method != 'GET') {
              await _emptyResponse(request, HttpStatus.methodNotAllowed);
              return;
            }
            await _handleLoaderWait(request);
            return;
          }
          if (segments.length == 2 && segments[1] == 'retry') {
            if (request.method != 'POST') {
              await _emptyResponse(request, HttpStatus.methodNotAllowed);
              return;
            }
            await _handleRetry(request);
            return;
          }
          await _emptyResponse(request, HttpStatus.notFound);
          return;
        default:
          await _emptyResponse(request, HttpStatus.notFound);
          return;
      }
    } catch (_) {
      try {
        await request.response.close();
      } catch (_) {}
    }
  }

  Future<void> _handleCapture(HttpRequest request, String lastSegment) async {
    final extIndex = lastSegment.lastIndexOf('.');
    final captureId = extIndex >= 0
        ? lastSegment.substring(0, extIndex)
        : lastSegment;
    if (!_captureIdPattern.hasMatch(captureId)) {
      await _emptyResponse(request, HttpStatus.notFound);
      return;
    }

    final entry = _entriesById[captureId];
    final token = request.uri.queryParameters['t'];
    if (entry == null || token == null || token != entry.token) {
      await _emptyResponse(request, HttpStatus.forbidden);
      return;
    }

    final file = await _resolveCaptureFile(captureId);
    if (file == null) {
      await _emptyResponse(request, HttpStatus.notFound);
      return;
    }

    final extension = p.extension(file.path).toLowerCase();
    final mime =
        captureContentTypeForExtension(extension) ?? 'application/octet-stream';
    final isHtml = extension == '.html';
    final length = await file.length();

    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..set(HttpHeaders.contentTypeHeader, mime)
      ..contentLength = length
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..set('X-Content-Type-Options', 'nosniff');
    if (isHtml) {
      // HTML is the only artifact type that can execute script or load
      // subresources — clamp it down. PDF/PNG bytes are inert; the browser's
      // built-in viewer handles them and CSP would just confuse it.
      request.response.headers.set('Content-Security-Policy', _captureCsp);
    }
    await request.response.addStream(file.openRead());
    await request.response.close();
  }

  /// Resolves the on-disk artifact for [captureId] and caches the result on
  /// the entry so subsequent lookups skip the five-extension stat loop. The
  /// cache is re-validated on every lookup via a cheap `exists()` so a file
  /// removed out-of-band (cache cleanup, manual delete) is detected and the
  /// stat loop is re-run; without this, the server would happily hand
  /// `request.response.addStream(file.openRead())` a missing file and
  /// surface as a mid-stream error rather than the expected 404.
  Future<File?> _resolveCaptureFile(String captureId) async {
    final entry = _entriesById[captureId];
    if (entry == null) return null;
    final cached = entry.cachedFile;
    if (cached != null) {
      if (await cached.exists()) return cached;
      entry.cachedFile = null;
    }
    for (final ext in captureSupportedExtensions) {
      final file = File(p.join(_storageDir.path, '$captureId$ext'));
      if (await file.exists()) {
        entry.cachedFile = file;
        return file;
      }
    }
    return null;
  }

  File? _resolveCaptureFileSync(String captureId) {
    final entry = _entriesById[captureId];
    if (entry == null) return null;
    final cached = entry.cachedFile;
    if (cached != null) {
      if (cached.existsSync()) return cached;
      entry.cachedFile = null;
    }
    for (final ext in captureSupportedExtensions) {
      final file = File(p.join(_storageDir.path, '$captureId$ext'));
      if (file.existsSync()) {
        entry.cachedFile = file;
        return file;
      }
    }
    return null;
  }

  Future<void> _handleLoader(HttpRequest request) async {
    final tabId = request.uri.queryParameters['tab'];
    final captureId = request.uri.queryParameters['capture'];
    final err = request.uri.queryParameters['err'] == '1';

    if (tabId == null ||
        captureId == null ||
        !_captureIdPattern.hasMatch(captureId)) {
      await _emptyResponse(request, HttpStatus.notFound);
      return;
    }

    // Render the loader shell immediately. Status transitions are driven
    // by an inline JS long-poll against /loader/wait — no meta-refresh,
    // no full-page reloads while the user is staring at the spinner.
    await _writeLoaderHtml(
      request,
      body: _loaderShellBody(initialError: err),
      tabId: tabId,
      captureId: captureId,
    );
  }

  /// JSON long-poll endpoint consumed by the loader shell. Holds the
  /// connection open up to ~25s, returning as soon as the capture
  /// transitions to `ready` or `failed`. Idle clients reconnect on close,
  /// so we keep timeouts well under typical proxy buffering windows.
  ///
  /// Wakes up event-driven via a per-id [Completer] signaled by
  /// [publish]/[markFailed]; the older revision busy-polled `isReady` every
  /// 200ms which burned CPU on long captures.
  Future<void> _handleLoaderWait(HttpRequest request) async {
    final captureId = request.uri.queryParameters['capture'];
    if (captureId == null || !_captureIdPattern.hasMatch(captureId)) {
      await _emptyResponse(request, HttpStatus.badRequest);
      return;
    }

    String status;
    String? captureUrl;

    if (_failedIds.contains(captureId)) {
      status = 'failed';
    } else if (isReady(captureId)) {
      status = 'ready';
    } else {
      // Race-free: register the waiter before re-checking ready/failed.
      // If publish() fires between the early returns above and here, the
      // waiter has already been completed via _signalWaiter.
      final completer = _waiterFor(captureId);
      try {
        await completer.future.timeout(const Duration(seconds: 25));
      } on TimeoutException {
        // Fall through — loader script reconnects on close.
      }
      if (_failedIds.contains(captureId)) {
        status = 'failed';
      } else if (isReady(captureId)) {
        status = 'ready';
      } else {
        status = 'pending';
      }
    }

    if (status == 'ready') {
      final server = _server;
      final entry = _entriesById[captureId];
      if (server != null && entry != null) {
        captureUrl = _buildCaptureUrl(
          server.port,
          captureId,
          entry.token,
        ).toString();
      }
    }

    final body = jsonEncode({
      'status': status,
      if (captureUrl != null) 'url': captureUrl,
    });
    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..contentType = ContentType('application', 'json', charset: 'utf-8')
      ..set(HttpHeaders.cacheControlHeader, 'no-store');
    request.response.write(body);
    await request.response.close();
  }

  Future<void> _handleRetry(HttpRequest request) async {
    final tabId = request.uri.queryParameters['tab'];
    final captureId = request.uri.queryParameters['capture'];
    if (tabId == null ||
        captureId == null ||
        !_captureIdPattern.hasMatch(captureId)) {
      await _emptyResponse(request, HttpStatus.badRequest);
      return;
    }
    _retryController.add(RetryRequest(tabId: tabId, captureId: captureId));
    // The loader script in the *current* page picks up the new state via its
    // long-poll, so a Refresh header (or full reload) would just discard the
    // tab's in-flight fetch. Reply with an empty 204 — the client doesn't
    // need the body.
    await _emptyResponse(request, HttpStatus.noContent);
  }

  Future<void> _writeLoaderHtml(
    HttpRequest request, {
    required String body,
    required String tabId,
    required String captureId,
  }) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers
      ..contentType = ContentType('text', 'html', charset: 'utf-8')
      ..set(HttpHeaders.cacheControlHeader, 'no-store')
      ..set('X-Content-Type-Options', 'nosniff')
      ..set('Content-Security-Policy', _loaderCsp);
    final tabIdJson = jsonEncode(tabId);
    final captureIdJson = jsonEncode(captureId);
    final html =
        '<!doctype html><html><head><meta charset="utf-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1">'
        '<title>Capturing…</title><style>$_loaderStyles</style>'
        '</head><body>$body'
        '<script>window.__TAB_ID__=$tabIdJson;'
        'window.__CAPTURE_ID__=$captureIdJson;</script>'
        '<script>$_loaderScript</script>'
        '</body></html>';
    request.response.write(html);
    await request.response.close();
  }

  Future<void> _emptyResponse(HttpRequest request, int status) async {
    request.response.statusCode = status;
    await request.response.close();
  }

  /// Registers a capture and returns a `http://127.0.0.1:<port>/...` URL
  /// that can be loaded in a GeckoView tab.
  Future<Uri> publish(String captureId) async {
    final server = await _ensureStarted();
    _failedIds.remove(captureId);
    final entry = _entriesById.putIfAbsent(
      captureId,
      () => _CaptureEntry(token: _generateToken()),
    );
    // Wake any in-flight long-poll for this id — the artifact is now
    // resolvable, so the poll can return `ready` immediately.
    _signalWaiter(captureId);
    return _buildCaptureUrl(server.port, captureId, entry.token);
  }

  /// Marks a capture as failed so any in-flight loader long-polls return
  /// immediately with `status: 'failed'`.
  void markFailed(String captureId) {
    _failedIds.add(captureId);
    _signalWaiter(captureId);
  }

  /// Clears any prior failed flag for the given capture id (e.g. before a
  /// retry).
  void clearFailed(String captureId) {
    _failedIds.remove(captureId);
  }

  /// Ensures the server is running and returns its port. Useful when callers
  /// need to build a loader URL before any capture has been published.
  Future<int> ensureStarted() async {
    final server = await _ensureStarted();
    return server.port;
  }

  /// Builds the loader URL for the given tab + capture. Also ensures the
  /// server is running so callers can use the returned port stably.
  Future<Uri> loaderUrl({
    required String tabId,
    required String captureId,
    bool error = false,
  }) async {
    final port = await ensureStarted();
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: port,
      pathSegments: const ['loader'],
      queryParameters: {
        'tab': tabId,
        'capture': captureId,
        if (error) 'err': '1',
      },
    );
  }

  /// True if [publish] has been called for [captureId] and the artifact file
  /// is present on disk. Used by the loader to decide between meta-refresh
  /// and redirect.
  bool isReady(String captureId) {
    final entry = _entriesById[captureId];
    if (entry == null) return false;
    return _resolveCaptureFileSync(captureId) != null;
  }

  void revoke(String captureId) {
    _entriesById.remove(captureId);
    _failedIds.remove(captureId);
    _signalWaiter(captureId);
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _starting = null;
    _entriesById.clear();
    _failedIds.clear();
    // Release every pending long-poll so the request handler can finish.
    for (final completer in _waiters.values) {
      if (!completer.isCompleted) completer.complete();
    }
    _waiters.clear();
    await server?.close(force: true);
    await _retryController.close();
  }

  Uri _buildCaptureUrl(int port, String captureId, String token) {
    // If the artifact is on disk, use its real extension so Gecko picks the
    // right viewer (e.g. PDF.js for `.pdf`). Pre-publish (no file yet) we
    // fall back to `.html`; the loader long-poll re-resolves the URL once
    // the artifact lands.
    final file = _resolveCaptureFileSync(captureId);
    final ext = file != null ? p.extension(file.path).toLowerCase() : '.html';
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: port,
      pathSegments: ['captures', '$captureId$ext'],
      queryParameters: {'t': token},
    );
  }

  String _generateToken() {
    final bytes = List<int>.generate(24, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static final _captureIdPattern = RegExp(r'^[A-Za-z0-9_-]+$');

  static const _captureCsp =
      "default-src 'none'; "
      "script-src 'none'; "
      "style-src 'unsafe-inline' data:; "
      "img-src data: blob:; "
      "font-src data:; "
      "frame-ancestors 'none'; "
      "base-uri 'none'; "
      "form-action 'none'";

  // The loader is server-controlled HTML on the loopback origin only — it
  // never loads remote subresources. Inline script/style are required for
  // the long-poll JS and the spinner CSS.
  static const _loaderCsp =
      "default-src 'none'; "
      "script-src 'unsafe-inline'; "
      "style-src 'unsafe-inline'; "
      "connect-src 'self'; "
      "img-src data:; "
      "frame-ancestors 'none'; "
      "base-uri 'none'; "
      "form-action 'self'";

  static const _loaderStyles =
      'html,body{height:100%}'
      'body{font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,'
      'sans-serif;display:flex;align-items:center;justify-content:center;'
      'min-height:100vh;margin:0;background:#0b0d10;color:#e6e8eb}'
      'main{text-align:center;max-width:480px;padding:32px;opacity:0;'
      'animation:fade .35s ease-out forwards}'
      '@keyframes fade{to{opacity:1}}'
      '.spinner{width:56px;height:56px;margin:0 auto 20px;border-radius:50%;'
      'border:3px solid rgba(255,255,255,.08);border-top-color:#7aa2f7;'
      'animation:spin 1s linear infinite}'
      '@keyframes spin{to{transform:rotate(360deg)}}'
      'h1{font-size:18px;font-weight:600;margin:0 0 8px;letter-spacing:.2px}'
      'p{margin:0;color:#9aa1a8;font-size:14px;line-height:1.5}'
      '.dots::after{display:inline-block;width:1.2em;text-align:left;'
      'animation:dots 1.4s steps(4,end) infinite;content:""}'
      '@keyframes dots{0%{content:""}25%{content:"."}50%{content:".."}'
      '75%{content:"..."}100%{content:""}}'
      '.error h1{color:#f7768e}'
      '.actions{margin-top:20px;display:flex;gap:8px;justify-content:center}'
      '.btn{padding:10px 16px;border:0;border-radius:10px;cursor:pointer;'
      'font:inherit;font-weight:600;background:#7aa2f7;color:#0b0d10}'
      '.btn.secondary{background:transparent;color:#9aa1a8;'
      'border:1px solid rgba(255,255,255,.12)}'
      '.hidden{display:none}'
      '@media(prefers-color-scheme:light){body{background:#f5f6f8;'
      'color:#1a1d22}.spinner{border-color:rgba(0,0,0,.08);'
      'border-top-color:#3b82f6}.btn{background:#3b82f6;color:white}'
      'p{color:#52606b}}';

  // Inline script for the loader shell. Reads window.__TAB_ID__ and
  // window.__CAPTURE_ID__, long-polls /loader/wait, then either redirects
  // to the ready capture or flips to the error pane.
  //
  // Network-error retries are capped (MAX_NET_ERRORS) so a tab whose capture
  // service has gone away doesn't busy-loop forever — after the cap the
  // loader gives up and shows the error pane with a Retry button (which
  // resets the counter via showPending → poll()).
  static const _loaderScript = r'''
(function(){
  var pending=document.getElementById('pending');
  var error=document.getElementById('error');
  var retryBtn=document.getElementById('retry');
  var tabId=window.__TAB_ID__;
  var captureId=window.__CAPTURE_ID__;
  var MAX_NET_ERRORS=15;
  var netErrors=0;
  function showError(){
    if(pending)pending.classList.add('hidden');
    if(error)error.classList.remove('hidden');
  }
  function showPending(){
    netErrors=0;
    if(error)error.classList.add('hidden');
    if(pending)pending.classList.remove('hidden');
  }
  async function poll(){
    try{
      var r=await fetch('/loader/wait?tab='+encodeURIComponent(tabId)+
        '&capture='+encodeURIComponent(captureId),{cache:'no-store'});
      if(!r.ok){
        if(++netErrors>=MAX_NET_ERRORS){showError();return}
        await new Promise(function(res){setTimeout(res,2000)});return poll();
      }
      netErrors=0;
      var data=await r.json();
      if(data.status==='ready'&&data.url){location.replace(data.url);return}
      if(data.status==='failed'){showError();return}
      // pending timeout — reconnect immediately.
      return poll();
    }catch(e){
      if(++netErrors>=MAX_NET_ERRORS){showError();return}
      await new Promise(function(res){setTimeout(res,2000)});
      return poll();
    }
  }
  if(retryBtn){
    retryBtn.addEventListener('click',function(){
      showPending();
      fetch('/loader/retry?tab='+encodeURIComponent(tabId)+
        '&capture='+encodeURIComponent(captureId),
        {method:'POST',cache:'no-store'}).catch(function(){});
      poll();
    });
  }
  if(error&&!error.classList.contains('hidden')){
    // Started in error mode — wait for user retry.
    return;
  }
  poll();
})();
''';

  String _loaderShellBody({required bool initialError}) {
    final pendingClass = initialError ? 'hidden' : '';
    final errorClass = initialError ? 'error' : 'error hidden';
    return '<main id="pending" class="$pendingClass">'
        '<div class="spinner"></div>'
        '<h1>Capturing page<span class="dots"></span></h1>'
        '<p>Saving an offline copy. This usually takes a few seconds.</p>'
        '</main>'
        '<main id="error" class="$errorClass">'
        '<h1>Capture failed</h1>'
        '<p>The page could not be saved. Check the notification for details.</p>'
        '<div class="actions">'
        '<button id="retry" class="btn" type="button">Retry</button>'
        '</div>'
        '</main>';
  }
}

@Riverpod(keepAlive: true)
CaptureServer captureServer(Ref ref) {
  final server = CaptureServer(storageDir: captureStorageDirectory());
  ref.onDispose(() {
    unawaited(server.stop());
  });
  return server;
}
