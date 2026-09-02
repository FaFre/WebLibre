import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The long-lived services `main.dart` starts during app initialization.
///
/// Each exists to keep reacting for the whole session: a replicator that pushes
/// settings to native, a repository that watches a database, a stream consumer
/// wired to the intent bus.
const _services = <String>[
  'visitContainerRecorderProvider',
  'proxySettingsReplicationProvider',
  'geckoSyncStateServiceProvider',
  'preferenceFixatorProvider',
  'engineSettingsReplicationServiceProvider',
  'webExtensionsStateProvider(WebExtensionActionType.browser)',
  'webExtensionsStateProvider(WebExtensionActionType.page)',
  'nativeIntentGatekeeperReplicatorProvider',
  'cacheRepositoryProvider',
  'searchHistoryCleanupServiceProvider',
  'localIndexSettingsSyncProvider',
  'accountCallbackHandlerProvider',
  'profileRestartRequestHandlerProvider',
  'sharingIntentStreamProvider',
  'appWidgetLaunchStreamProvider',
];

/// Guards how those services are started, because getting it wrong is silent.
///
/// `ref.read(x)` builds a provider and gives it no listener. Riverpod only
/// recomputes *active* elements — `ProviderScheduler._performRefresh` calls
/// `flush()` only `if (element.isActive)`, and `isActive` counts non-paused
/// listeners — and the inactivity is transitive, because an inactive element's
/// own `watch`/`listen` subscriptions are deactivated in turn. A service
/// started with `read` therefore builds once and then stops seeing changes,
/// with no error and nothing in the log.
///
/// In the full browser that hides: widgets watch the same upstream providers
/// and reactivate the chain. On the headless Custom Tab / PWA launch path
/// nothing does, and a cold start sat forever with the container routing gate
/// reporting all five inputs unresolved while the identical queries answered in
/// single-digit milliseconds.
///
/// A unit test cannot catch this — the provider tests activate services
/// correctly, which is exactly why they all passed while production hung — so
/// the activation site itself is what gets pinned here.
void main() {
  test('main.dart activates long-lived services with a listener', () {
    // All whitespace stripped, from both sides: the formatter wraps the longer
    // activation calls and adds a trailing comma, and this test is about which
    // call is used, not how it is laid out. Dart identifiers carry no spaces,
    // so a stripped needle still matches only the call it names.
    String strip(String text) => text.replaceAll(RegExp(r'\s+'), '');
    final source = strip(File('lib/main.dart').readAsStringSync());

    final readOnly = _services
        .where((service) => source.contains(strip('ref.read($service);')))
        .toList();

    expect(
      readOnly,
      isEmpty,
      reason:
          'These services are started with a bare `ref.read`, which leaves them '
          'and everything they watch permanently inactive:\n'
          '  ${readOnly.join('\n  ')}\n'
          'Use _activateService(ref, ...) instead.',
    );

    final missing = _services
        // Deliberately a prefix, so a wrapped call with a trailing comma still
        // matches.
        .where(
          (service) =>
              !source.contains(strip('_activateService(ref, $service')),
        )
        .toList();

    expect(
      missing,
      isEmpty,
      reason:
          'These services are no longer activated by main.dart. If that is '
          'deliberate, drop them from this list; if they moved, keep them '
          'activated with a listener:\n  ${missing.join('\n  ')}',
    );
  });
}
