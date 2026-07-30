/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';

final _api = GeckoAppLinksApi();

/// Service for detecting and launching external applications that can handle URLs.
///
/// WebLibre-owned resolution/launch surface. Policy lives in Dart; the native side
/// owns PackageManager resolution and Intent launch. Used by the manual
/// "Open in app" entry points.
class GeckoAppLinksService {
  /// Resolve [url] to an external-app target, or null when no external app is
  /// available (or on any resolution error / always-denied scheme).
  ///
  /// [includeHttpAppLinks] when true, an app resolving an engine-supported
  /// (http(s)) URL is surfaced (e.g. the YouTube app for a youtube.com link).
  Future<AppLinkTarget?> resolveAppLink(
    Uri url, {
    bool includeHttpAppLinks = true,
  }) {
    return _api.resolveAppLink(url.toString(), includeHttpAppLinks);
  }

  /// Re-resolve [url] and launch it in an external app.
  ///
  /// Returns true if launched, false if no app is available or the launch failed.
  Future<bool> launchAppLink(Uri url) {
    return _api.launchAppLink(url.toString());
  }

  /// Push the complete app-link policy snapshot to native (last-write-wins).
  ///
  /// Throws if no profile is bound yet; the caller (replicator) retries after
  /// initialisation.
  Future<void> setAppLinkPolicy(AppLinkPolicySnapshot snapshot) {
    return _api.setAppLinkPolicy(snapshot);
  }

  /// Non-consuming query of pending prompts for [owner] (§2.6). Query on
  /// attach/resume and when the availability event fires; render idempotently by
  /// requestId.
  Future<List<AppLinkPromptRequest>> getPendingAppLinkPrompts(
    AppLinkPromptOwner owner,
  ) {
    return _api.getPendingAppLinkPrompts(owner);
  }

  /// Atomically resolve a pending prompt (§2.6). A double-resolve or stale id is
  /// a no-op returning `failureReason == "stale"`.
  Future<AppLinkResolutionResult> resolvePendingAppLink(
    int requestId,
    AppLinkDecision decision,
  ) {
    return _api.resolvePendingAppLink(requestId, decision);
  }
}
