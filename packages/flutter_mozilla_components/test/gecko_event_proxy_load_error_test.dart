/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProxyLoadError error(String tabId, String url) => ProxyLoadError(
    tabId: tabId,
    contextId: null,
    url: url,
    errorType: 'ERROR_PROXY_CONNECTION_REFUSED',
  );

  test(
    'an error fired before anyone listens reaches the first subscriber',
    () async {
      final service = GeckoEventService.setUp();
      addTearDown(service.dispose);

      // The cold-start shape: routing is not installed yet, the load fails, and
      // the browser screen has not been built to subscribe.
      service.onProxyLoadError(1, error('tab-1', 'https://example.org/'));

      await expectLater(
        service.proxyLoadErrorEvents,
        emits(isA<ProxyLoadError>().having((e) => e.tabId, 'tabId', 'tab-1')),
      );
    },
  );

  test('only the newest buffered error per tab is delivered', () async {
    final service = GeckoEventService.setUp();
    addTearDown(service.dispose);

    service.onProxyLoadError(1, error('tab-1', 'https://example.org/'));
    service.onProxyLoadError(2, error('tab-1', 'https://example.com/'));
    service.onProxyLoadError(3, error('tab-2', 'https://example.net/'));

    await expectLater(
      service.proxyLoadErrorEvents,
      emitsInOrder(<Matcher>[
        isA<ProxyLoadError>().having(
          (e) => e.url,
          'url',
          'https://example.com/',
        ),
        isA<ProxyLoadError>().having(
          (e) => e.url,
          'url',
          'https://example.net/',
        ),
      ]),
    );
  });

  test('a late-delivered older error does not displace the newest', () async {
    final service = GeckoEventService.setUp();
    addTearDown(service.dispose);

    // Nothing promises platform-channel delivery order, which is what the
    // sequence is for: 10 arrives after 11 and describes an older load.
    service.onProxyLoadError(11, error('tab-1', 'https://example.com/'));
    service.onProxyLoadError(10, error('tab-1', 'https://example.org/'));

    await expectLater(
      service.proxyLoadErrorEvents,
      emits(
        isA<ProxyLoadError>().having(
          (e) => e.url,
          'url',
          'https://example.com/',
        ),
      ),
    );
  });

  test('errors are not held once something has subscribed', () async {
    final service = GeckoEventService.setUp();
    addTearDown(service.dispose);

    final firstRun = <ProxyLoadError>[];
    final subscription = service.proxyLoadErrorEvents.listen(firstRun.add);
    await pumpEventQueue();

    // Nobody is displaying tabs any more. An error that arrives now is stale by
    // the time a later screen subscribes, and replaying it would reload a page
    // that has long since loaded fine.
    await subscription.cancel();
    service.onProxyLoadError(1, error('tab-1', 'https://example.org/'));

    final secondRun = <ProxyLoadError>[];
    final resubscription = service.proxyLoadErrorEvents.listen(secondRun.add);
    addTearDown(resubscription.cancel);
    await pumpEventQueue();

    expect(firstRun, isEmpty);
    expect(secondRun, isEmpty);
  });
}
