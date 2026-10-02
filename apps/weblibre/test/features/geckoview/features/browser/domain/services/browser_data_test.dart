import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/services/browser_data.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';

class _FakeGeckoDeleteBrowserDataService extends GeckoDeleteBrowserDataService {
  final clearedContexts = <String>[];

  final deleted = <String>[];

  @override
  Future<void> deleteBrowsingHistory() {
    deleted.add('history');
    return Future.error(Exception('simulated native failure for history'));
  }

  @override
  Future<void> deleteCookiesAndSiteData() async => deleted.add('cookies');

  @override
  Future<void> deleteCachedFiles() async => deleted.add('cache');

  /// Contexts for which [clearDataForContext] should throw (simulating a native
  /// failure), so we can assert one failure doesn't block the remaining ones.
  final failingContexts = <String>{};

  @override
  Future<void> clearDataForContext(String contextId) async {
    clearedContexts.add(contextId);
    if (failingContexts.contains(contextId)) {
      throw Exception('simulated native failure for $contextId');
    }
  }
}

void main() {
  group('BrowserDataService.clearContainerDataOnEngineStart', () {
    test('clears only once per app start', () async {
      final gecko = _FakeGeckoDeleteBrowserDataService();
      final service = BrowserDataService(service: gecko);

      await service.clearContainerDataOnEngineStart(['ctx-1']);
      await service.clearContainerDataOnEngineStart(['ctx-2']);

      expect(gecko.clearedContexts, ['ctx-1']);
    });

    test(
      'empty context list neither clears nor consumes the one-shot run',
      () async {
        final gecko = _FakeGeckoDeleteBrowserDataService();
        final service = BrowserDataService(service: gecko);

        await service.clearContainerDataOnEngineStart(const []);
        expect(gecko.clearedContexts, isEmpty);

        await service.clearContainerDataOnEngineStart(['ctx-1']);
        expect(gecko.clearedContexts, ['ctx-1']);
      },
    );

    test(
      'a single failing context does not block the remaining ones',
      () async {
        final gecko = _FakeGeckoDeleteBrowserDataService()
          ..failingContexts.add('ctx-2');
        final service = BrowserDataService(service: gecko);

        await service.clearContainerDataOnEngineStart([
          'ctx-1',
          'ctx-2',
          'ctx-3',
        ]);

        // ctx-2 threw, but ctx-1 and ctx-3 were still attempted.
        expect(gecko.clearedContexts, ['ctx-1', 'ctx-2', 'ctx-3']);
      },
    );
  });

  group('BrowserDataService.clearContainerData (explicit Quit)', () {
    test('is not gated by the one-shot startup guard', () async {
      final gecko = _FakeGeckoDeleteBrowserDataService();
      final service = BrowserDataService(service: gecko);

      // Consume the startup one-shot guard first.
      await service.clearContainerDataOnEngineStart(['startup']);
      // Explicit Quit cleanup must still run afterwards.
      await service.clearContainerData(['ctx-1', 'ctx-2']);

      expect(gecko.clearedContexts, ['startup', 'ctx-1', 'ctx-2']);
    });

    test('logs and skips a failing context, clearing the rest', () async {
      final gecko = _FakeGeckoDeleteBrowserDataService()
        ..failingContexts.add('ctx-1');
      final service = BrowserDataService(service: gecko);

      await service.clearContainerData(['ctx-1', 'ctx-2']);

      expect(gecko.clearedContexts, ['ctx-1', 'ctx-2']);
    });
  });

  group('BrowserDataService.deleteData', () {
    test('a failing type does not skip the ones after it', () async {
      final gecko = _FakeGeckoDeleteBrowserDataService();
      final service = BrowserDataService(service: gecko);

      // On Quit, history failing used to keep the cookies and the cache.
      await expectLater(
        service.deleteData({
          DeleteBrowsingDataType.history,
          DeleteBrowsingDataType.cookies,
          DeleteBrowsingDataType.cache,
        }),
        throwsException,
      );

      expect(gecko.deleted, ['history', 'cookies', 'cache']);
    });
  });
}
