import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart'
    as fmc;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:search_client/search_client.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/domain/entities/tab_container_selection.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/capture_tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    show CaptureTabData;
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/search_credits/domain/controllers/search_token_issuance_controller.dart';
import 'package:weblibre/features/search_credits/domain/providers.dart';
import 'package:weblibre/features/search_credits/domain/providers/proxy_client.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';
import 'package:weblibre/features/user/domain/repositories/cache.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';
import 'package:weblibre/features/web_search/domain/services/capture_server.dart';
import 'package:weblibre/features/web_search/domain/services/sandbox_capture_store.dart';

part 'sandbox_capture_controller.g.dart';

enum SandboxCaptureErrorKind {
  /// Stash is empty AND user has zero credits — needs to buy more.
  insufficientCredits,

  /// Stash is empty, credits are available, but issuance failed
  /// (network/auth/server). Retrying may succeed.
  tokenIssuanceFailed,

  fetchPolicyRejected,
  captureFailed,
  downloadFailed,
  unknown,
}

class SandboxCaptureError {
  final SandboxCaptureErrorKind kind;
  final Uri targetUrl;
  final String? detail;
  const SandboxCaptureError({
    required this.kind,
    required this.targetUrl,
    this.detail,
  });
}

@Riverpod(keepAlive: true)
OneShotCaptureClient oneShotCaptureClient(Ref ref) {
  return OneShotCaptureClient(
    endpoints: ref.watch(searchBackendEndpointsProvider),
    logger: ref.watch(searchClientLoggerProvider),
    httpClient: ref.watch(searchProxyHttpClientProvider),
  );
}

/// Streams capture-tab rows keyed by tabId. Watched by the address bar so
/// the UI can show the canonical source URL (instead of the loopback
/// loader/capture URL) and a sandbox indicator.
@Riverpod(keepAlive: true)
Stream<Map<String, CaptureTabData>> sandboxCaptureMap(Ref ref) {
  final dao = ref.watch(tabDatabaseProvider).captureTabDao;
  return dao.watchAll().map((rows) => {for (final row in rows) row.tabId: row});
}

@Riverpod()
CaptureTabData? sandboxCaptureForTab(Ref ref, {required String? tabId}) {
  if (tabId == null) return null;
  final map = ref.watch(sandboxCaptureMapProvider).value;
  return map?[tabId];
}

/// The canonical source URL of a sandbox-captured tab, or `null` when the
/// tab is not a sandbox capture (the regular `tabState.url` should be used in
/// that case).
@Riverpod()
Uri? sandboxSourceUriForTab(Ref ref, {required String? tabId}) {
  final row = ref.watch(sandboxCaptureForTabProvider(tabId: tabId));
  return parseSandboxSource(row);
}

Uri? parseSandboxSource(CaptureTabData? row) {
  if (row == null) return null;
  final raw = row.sourceUrl;
  if (raw.isEmpty) return null;
  return Uri.tryParse(raw);
}

/// Search/edit text to pre-fill when the user taps the address bar of
/// [tabState]. Sandbox-captured tabs surface their source URL so editing
/// doesn't strip the user back to the loopback loader.
String searchTextForTab(TabState tabState, [Uri? sandboxSourceUri]) {
  if (sandboxSourceUri != null) {
    return sandboxSourceUri.toString();
  }

  final searchText = tabState.url.scheme == 'about'
      ? ''
      : tabState.url.toString();

  return searchText.isEmpty ? SearchRoute.emptySearchText : searchText;
}

@Riverpod(keepAlive: true)
SandboxCaptureStore sandboxCaptureStore(Ref ref) => SandboxCaptureStore();

@Riverpod(keepAlive: true)
Stream<SandboxCaptureError> sandboxCaptureErrors(Ref ref) {
  final ctrl = ref.watch(sandboxCaptureControllerProvider.notifier);
  return ctrl.errorStream();
}

/// Orchestrates sandbox capture browsing:
///
/// 1. Listens for dispatch events from Kotlin (`onSandboxLinkClick`,
///    `onSandboxNewTab`) and runs the capture pipeline.
/// 2. Keeps the native `SandboxCaptureRegistry` and the on-disk JSON mirror
///    in sync with the `capture_tab` table via a DAO subscription.
/// 3. Listens on `CaptureServer.retryRequests` and re-runs failed captures.
///
/// This provider is kept alive for the lifetime of the app; `build()` wires
/// up the subscriptions and returns nothing interesting.
@Riverpod(keepAlive: true)
class SandboxCaptureController extends _$SandboxCaptureController {
  final _errors = StreamController<SandboxCaptureError>.broadcast();
  // Keyed by (tabId, url) so two concurrent navigations in the same tab to
  // different URLs don't dedupe each other, and the same URL across tabs
  // doesn't either. Records compare structurally so this is safer than the
  // earlier "tabId|url" string concat.
  final _inFlight = <(String, Uri)>{};
  final _hostEvents = _SandboxHostEventsHandler();

  /// In-memory record of the (method, variant) used to capture each sandbox
  /// tab. Children opened via link-click inherit their parent's mode so a
  /// PDF sandbox tab spawns more PDFs, a singlefile tab spawns more
  /// singlefile, etc. Lost across app restarts (capture_tab schema doesn't
  /// store these yet) — children fall back to singlefile/balanced in that
  /// case.
  final _tabCaptureMode = <String, ({String method, String variant})>{};

  static const _defaultMethod = 'singlefile';
  static const _defaultVariant = 'balanced';

  Stream<SandboxCaptureError> errorStream() => _errors.stream;

  @override
  void build() {
    _hostEvents.controller = this;
    fmc.SandboxCaptureHostEvents.setUp(_hostEvents);

    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    final captureTabSub = dao.watchAll().listen(_onCaptureTabChange);

    final retrySub = ref
        .read(captureServerProvider)
        .retryRequests
        .listen(_onRetryRequest);

    ref.onDispose(() {
      // Cancel inbound subscriptions first so no more events can land on
      // this controller. Only after that is it safe to detach the host
      // event handler, drop the back-reference, and close the error
      // stream — otherwise an in-flight Pigeon event or DAO emit could
      // race with handler cleanup, or _markFailed could try to add to a
      // closed _errors sink.
      unawaited(captureTabSub.cancel());
      unawaited(retrySub.cancel());
      fmc.SandboxCaptureHostEvents.setUp(null);
      _hostEvents.controller = null;
      unawaited(_errors.close());
    });
  }

  // Entry point: search-results flow opened a root capture tab.
  Future<void> registerRootCapture({
    required String tabId,
    required CapturedPageReceiptLike receipt,
    String? method,
    String? variant,
  }) async {
    final server = ref.read(captureServerProvider);
    await server.publish(receipt.captureId);
    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    await dao.upsert(
      tabId: tabId,
      captureId: receipt.captureId,
      sourceUrl: receipt.sourceUrl.toString(),
      status: CaptureTabStatus.ready,
    );
    _tabCaptureMode[tabId] = (
      method: method ?? _defaultMethod,
      variant: variant ?? _defaultVariant,
    );
    await _pushRegistry();
  }

  // Called from Kotlin via pigeon when a sandbox tab tried to navigate to a
  // non-loopback URL. We open a fresh private tab and run the capture
  // pipeline into it.
  Future<void> captureIntoNewTab({
    required String parentTabId,
    required Uri targetUrl,
  }) async {
    if (_inFlight.contains((parentTabId, targetUrl))) return;

    final parent = ref.read(tabStatesProvider)[parentTabId];
    final parentTabMode =
        parent?.tabMode ??
        await ref
            .read(tabDatabaseProvider)
            .tabDao
            .getTabMode(parentTabId)
            .getSingleOrNull() ??
        TabMode.private;
    final parentContainer = await ref
        .read(tabDatabaseProvider)
        .tabDao
        .getTabContainerData(parentTabId)
        .getSingleOrNull();
    final containerSelection = parentContainer == null
        ? const TabContainerSelection.unassigned()
        : TabContainerSelection.specific(parentContainer);

    // Create the tab without an initial URL — we'll load the loopback
    // loader URL in _runCapture. Never seed the tab with the real
    // targetUrl: Gecko's app-link resolution would fire on load/restore
    // (e.g. github.com → "Open in GitHub app?" dialog) before the
    // interceptor can redirect.
    final newTabId = await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          tabMode: parentTabMode,
          selectTab: true,
          parentId: parentTabId,
          containerSelection: containerSelection,
          startLoading: false,
        );

    await _runCapture(
      parentTabId: parentTabId,
      newTabId: newTabId,
      targetUrl: targetUrl,
      triggerInitialLoad: true,
    );
  }

  // Called from Kotlin middleware when GeckoView created a new tab inside a
  // sandbox parent. The new tab is already at about:blank.
  Future<void> captureIntoExistingTab({
    required String parentTabId,
    required String newTabId,
    required Uri targetUrl,
  }) async {
    await _runCapture(
      parentTabId: parentTabId,
      newTabId: newTabId,
      targetUrl: targetUrl,
      triggerInitialLoad: true,
    );
  }

  /// Resolve the (method, variant) for a child capture. Children inherit
  /// the parent tab's capture mode so a PDF sandbox spawns more PDFs, etc.
  /// Falls back to singlefile/balanced when the parent's mode is unknown
  /// (e.g. after an app restart — `_tabCaptureMode` is in-memory only).
  ({String method, String variant}) _resolveCaptureMode(String parentTabId) {
    return _tabCaptureMode[parentTabId] ??
        (method: _defaultMethod, variant: _defaultVariant);
  }

  Future<void> _runCapture({
    required String parentTabId,
    required String newTabId,
    required Uri targetUrl,
    required bool triggerInitialLoad,
    String? existingCaptureId,
  }) async {
    final key = (newTabId, targetUrl);
    if (!_inFlight.add(key)) return;

    final server = ref.read(captureServerProvider);
    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    final logger = ref.read(searchClientLoggerProvider);
    final mode = _resolveCaptureMode(parentTabId);
    // For retries, reuse the existing placeholder id so the tab's loader
    // URL stays valid and its in-flight long-poll picks up the new state.
    final placeholderId =
        existingCaptureId ??
        'pending-${DateTime.now().microsecondsSinceEpoch}-$newTabId';

    final stash = ref.read(searchTokenStashProvider);
    ReservedStashToken? heldReservation;

    try {
      server.clearFailed(placeholderId);
      await dao.upsert(
        tabId: newTabId,
        captureId: placeholderId,
        sourceUrl: targetUrl.toString(),
        status: CaptureTabStatus.pending,
      );
      _tabCaptureMode[newTabId] = mode;
      await _pushRegistry();

      if (triggerInitialLoad) {
        final loaderUri = await server.loaderUrl(
          tabId: newTabId,
          captureId: placeholderId,
        );
        await ref
            .read(tabSessionProvider(tabId: newTabId).notifier)
            .loadUrl(url: loaderUri);
      }

      var reserved = await stash.reserveOne();
      if (reserved == null) {
        // Stash empty — try to top up with the same 10-token batch we use
        // on the search submit path, then retry the reservation once.
        logger.i(
          'Sandbox capture: stash empty, attempting auto-issuance '
          '(tabId=$newTabId, host=${targetUrl.host})',
        );
        final outcome = await ref.read(searchTokenAvailabilityProvider).topUp();
        if (outcome == TokenTopUpOutcome.issued) {
          reserved = await stash.reserveOne();
        }
        if (reserved == null) {
          final kind = outcome == TokenTopUpOutcome.noCredits
              ? SandboxCaptureErrorKind.insufficientCredits
              : SandboxCaptureErrorKind.tokenIssuanceFailed;
          final detail = outcome == TokenTopUpOutcome.noCredits
              ? 'You have no search credits left. Purchase more to continue.'
              : 'Could not issue new search tokens. Check your connection and try again.';
          logger.w(
            'Sandbox capture: auto-issuance did not yield a token '
            '(outcome=$outcome, host=${targetUrl.host})',
          );
          await _markFailed(
            tabId: newTabId,
            captureId: placeholderId,
            url: targetUrl,
            kind: kind,
            detail: detail,
          );
          return;
        }
        logger.i(
          'Sandbox capture: auto-issuance succeeded, retrying capture '
          '(tabId=$newTabId)',
        );
      }

      heldReservation = reserved;
      final reservation = reserved;
      logger.d(
        'Sandbox capture: reserved token #${reservation.id}, requesting '
        'capture (tabId=$newTabId, host=${targetUrl.host}, '
        'method=${mode.method}, variant=${mode.variant})',
      );

      final CaptureArtifactReceipt receipt;
      try {
        // Inherit the parent tab's capture mode: a PDF sandbox tab spawns
        // more PDFs, a singlefile tab spawns more singlefile, etc. The
        // capture server happily serves PDF/PNG artifacts on the loopback
        // origin, and the loader/redirect machinery is content-type
        // agnostic.
        final result = await ref
            .read(oneShotCaptureClientProvider)
            .capture(
              targetUrl,
              method: mode.method,
              variant: mode.variant,
              token: reservation.token,
              dimensions: currentDisplayCaptureDimensions(),
            );
        receipt = result.receipt;

        // Server accepted and consumed the token — drop it permanently.
        await stash.commitReserved(reservation.id);
        heldReservation = null;

        if (result.faviconBytes != null) {
          unawaited(
            ref
                .read(cacheRepositoryProvider.notifier)
                .cacheIconIfAbsent(receipt.url, result.faviconBytes!),
          );
        }
      } on OneShotCaptureException catch (e) {
        // Token-affecting failure modes:
        //   - fetch_not_allowed / invalid_url : server rejected before
        //     redeem → safe to release.
        //   - token_invalid / token_redeemed  : server saw the token but
        //     did not honor it → must commit (do not double-spend).
        //   - any other 4xx/5xx after redemption attempt: ambiguous → commit.
        final preRedemption =
            e.code == 'fetch_not_allowed' ||
            e.code == 'invalid_url' ||
            e.code == 'invalid_request';
        if (preRedemption) {
          await stash.releaseReserved(reservation.id);
          logger.i(
            'Sandbox capture: released token #${reservation.id} '
            '(server rejected request before redemption: ${e.code})',
          );
        } else {
          await stash.commitReserved(reservation.id);
          logger.w(
            'Sandbox capture: committed token #${reservation.id} after '
            'ambiguous server failure (${e.code}) to avoid double-spend',
          );
        }
        heldReservation = null;
        final kind = e.code == 'fetch_not_allowed'
            ? SandboxCaptureErrorKind.fetchPolicyRejected
            : SandboxCaptureErrorKind.captureFailed;
        await _markFailed(
          tabId: newTabId,
          captureId: placeholderId,
          url: targetUrl,
          kind: kind,
          detail: e.message,
        );
        return;
      } catch (e, s) {
        // Network/transport failure — we don't know whether the server
        // saw the token. Commit defensively to prevent double-spend on
        // retry. Stale reservations also get cleaned up on app start.
        await stash.commitReserved(reservation.id);
        heldReservation = null;
        logger.e(
          'Sandbox capture failed (committed token #${reservation.id} '
          'defensively)',
          error: e,
          stackTrace: s,
        );
        await _markFailed(
          tabId: newTabId,
          captureId: placeholderId,
          url: targetUrl,
          kind: SandboxCaptureErrorKind.unknown,
          detail: e.toString(),
        );
        return;
      }

      try {
        await ref.read(captureArtifactDownloaderProvider).download(receipt);
      } catch (e, s) {
        logger.e('Sandbox capture download failed', error: e, stackTrace: s);
        await _markFailed(
          tabId: newTabId,
          captureId: placeholderId,
          url: targetUrl,
          kind: SandboxCaptureErrorKind.downloadFailed,
          detail: e.toString(),
        );
        return;
      }

      final captureUri = await server.publish(receipt.captureId);
      await dao.upsert(
        tabId: newTabId,
        captureId: receipt.captureId,
        sourceUrl: targetUrl.toString(),
        status: CaptureTabStatus.ready,
      );
      _tabCaptureMode[newTabId] = mode;
      await _pushRegistry();

      // Navigate directly to the loopback capture URL. Never bounce
      // through the real targetUrl — Gecko's app-link resolution fires
      // before the interceptor can redirect.
      await ref
          .read(tabSessionProvider(tabId: newTabId).notifier)
          .loadUrl(url: captureUri);
    } catch (e, s) {
      // Safety net: anything that escaped the inner blocks (e.g. DAO
      // failure, navigation error, exception while we held a reservation
      // outside the inner try) — make sure we don't strand the tab in
      // pending and don't leak the reservation. Commit defensively if a
      // reservation is still held: we may have already sent the token to
      // the server.
      logger.e('Sandbox capture: unexpected error', error: e, stackTrace: s);
      if (heldReservation != null) {
        try {
          await stash.commitReserved(heldReservation.id);
        } catch (commitError, commitStack) {
          logger.w(
            'Sandbox capture: failed to commit reservation '
            '#${heldReservation.id} during error cleanup',
            error: commitError,
            stackTrace: commitStack,
          );
        }
      }
      try {
        await _markFailed(
          tabId: newTabId,
          captureId: placeholderId,
          url: targetUrl,
          kind: SandboxCaptureErrorKind.unknown,
          detail: e.toString(),
        );
      } catch (markError, markStack) {
        logger.w(
          'Sandbox capture: failed to mark tab as failed during error '
          'cleanup',
          error: markError,
          stackTrace: markStack,
        );
      }
    } finally {
      _inFlight.remove(key);
    }
  }

  Future<void> _markFailed({
    required String tabId,
    required String captureId,
    required Uri url,
    required SandboxCaptureErrorKind kind,
    required String detail,
  }) async {
    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    await dao.updateStatus(tabId, CaptureTabStatus.failed);
    // Resolve any in-flight loader long-poll for this capture so the tab
    // flips to the error UI immediately instead of waiting for the poll
    // window to expire.
    ref.read(captureServerProvider).markFailed(captureId);
    await _pushRegistry();
    if (!_errors.isClosed) {
      _errors.add(
        SandboxCaptureError(kind: kind, targetUrl: url, detail: detail),
      );
    }
  }

  Future<void> _onRetryRequest(RetryRequest request) async {
    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    final row = await dao.findByTabId(request.tabId);
    if (row == null) return;
    final sourceUrl = Uri.tryParse(row.sourceUrl);
    if (sourceUrl == null) return;
    // Re-enter the capture pipeline as if the user clicked the link again.
    // Reuse the existing capture id so the tab's loader URL (and its
    // in-flight long-poll) stays addressable.
    await _runCapture(
      parentTabId: row.tabId, // we don't persist parent; use self as parent
      newTabId: row.tabId,
      targetUrl: sourceUrl,
      triggerInitialLoad: false,
      existingCaptureId: row.captureId,
    );
  }

  Future<void> _onCaptureTabChange(List<CaptureTabData> rows) async {
    final store = ref.read(sandboxCaptureStoreProvider);
    await store.write(await _rowsForPersistentMirror(rows));
    // Drop in-memory mode entries for tabs the DAO no longer knows about so
    // a recycled tabId doesn't accidentally inherit a stale mode.
    final liveTabIds = rows.map((r) => r.tabId).toSet();
    _tabCaptureMode.removeWhere((tabId, _) => !liveTabIds.contains(tabId));
    await _pushRegistry(rows: rows);
  }

  Future<List<CaptureTabData>> _rowsForPersistentMirror(
    List<CaptureTabData> rows,
  ) async {
    final tabDao = ref.read(tabDatabaseProvider).tabDao;
    final tabStates = ref.read(tabStatesProvider);
    final persistedRows = <CaptureTabData>[];

    for (final row in rows) {
      final tabMode =
          tabStates[row.tabId]?.tabMode ??
          await tabDao.getTabMode(row.tabId).getSingleOrNull();
      if (tabMode is PrivateTabMode) {
        continue;
      }
      persistedRows.add(row);
    }

    return persistedRows;
  }

  Future<void> _pushRegistry({List<CaptureTabData>? rows}) async {
    final dao = ref.read(tabDatabaseProvider).captureTabDao;
    final server = ref.read(captureServerProvider);
    final all = rows ?? await dao.findAll();
    // Resolve redirect URLs in parallel. Each `_redirectUrlFor` awaits a
    // server publish/loaderUrl call; serializing was O(N) round-trips on
    // every DAO emit, which got noticeable with many sandbox tabs open.
    final redirectUrls = await Future.wait([
      for (final row in all) _redirectUrlFor(row, server),
    ]);
    final entries = <fmc.SandboxCaptureEntry>[
      for (var i = 0; i < all.length; i++)
        fmc.SandboxCaptureEntry(
          tabId: all[i].tabId,
          captureId: all[i].captureId,
          sourceUrl: all[i].sourceUrl,
          redirectUrl: redirectUrls[i],
          status: all[i].status,
        ),
    ];
    await fmc.SandboxCaptureApi().resetAll(entries);
  }

  Future<String> _redirectUrlFor(
    CaptureTabData row,
    CaptureServer server,
  ) async {
    switch (row.status) {
      case 'ready':
        final uri = await server.publish(row.captureId);
        return uri.toString();
      case 'failed':
        final uri = await server.loaderUrl(
          tabId: row.tabId,
          captureId: row.captureId,
          error: true,
        );
        return uri.toString();
      case 'pending':
      default:
        final uri = await server.loaderUrl(
          tabId: row.tabId,
          captureId: row.captureId,
        );
        return uri.toString();
    }
  }
}

class _SandboxHostEventsHandler implements fmc.SandboxCaptureHostEvents {
  SandboxCaptureController? controller;

  @override
  void onSandboxLinkClick(int sequence, String parentTabId, String targetUrl) {
    final uri = Uri.tryParse(targetUrl);
    final c = controller;
    if (uri == null || c == null) return;
    unawaited(c.captureIntoNewTab(parentTabId: parentTabId, targetUrl: uri));
  }

  @override
  void onSandboxNewTab(
    int sequence,
    String parentTabId,
    String newTabId,
    String targetUrl,
  ) {
    final uri = Uri.tryParse(targetUrl);
    final c = controller;
    if (uri == null || c == null) return;
    unawaited(
      c.captureIntoExistingTab(
        parentTabId: parentTabId,
        newTabId: newTabId,
        targetUrl: uri,
      ),
    );
  }
}

/// Minimal receipt-like type for registerRootCapture — avoids a direct
/// dependency on the capture_artifact_receipt pigeon in this file when the
/// caller already has the right pieces to hand.
class CapturedPageReceiptLike {
  final String captureId;
  final Uri sourceUrl;
  const CapturedPageReceiptLike({
    required this.captureId,
    required this.sourceUrl,
  });
}
