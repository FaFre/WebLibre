import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/restore_complete.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/controllers/home_target_controller.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

const _getSelectedTabIdChannel =
    'dev.flutter.pigeon.flutter_mozilla_components.GeckoTabsApi.getSelectedTabId';

class _RestoredSession extends BrowserRestoreComplete {
  @override
  bool build() => true;
}

/// The debounced selection event has not arrived, as at the moment restore
/// completes.
class _NoSelectionEventYet extends SelectedTab {
  @override
  String? build() => null;
}

class _FakeTabRepository extends TabRepository {
  @override
  void build() {}
}

/// The native store, answering `getSelectedTabId` only when the test says so.
class _FakeStore {
  _FakeStore() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockDecodedMessageHandler<Object?>(
          const BasicMessageChannel(
            _getSelectedTabIdChannel,
            StandardMessageCodec(),
          ),
          (_) {
            final answer = Completer<String?>();
            _questions.add(answer);
            return answer.future.then((tabId) => <Object?>[tabId]);
          },
        );
  }

  final _questions = <Completer<String?>>[];

  int get asked => _questions.length;

  void answer(String? tabId) => _questions.last.complete(tabId);

  void tearDown() => TestDefaultBinaryMessengerBinding
      .instance
      .defaultBinaryMessenger
      .setMockDecodedMessageHandler<Object?>(
        const BasicMessageChannel(
          _getSelectedTabIdChannel,
          StandardMessageCodec(),
        ),
        null,
      );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeStore store;
  late ProviderContainer container;

  setUp(() {
    store = _FakeStore();
    addTearDown(store.tearDown);

    container = ProviderContainer(
      overrides: [
        browserRestoreCompleteProvider.overrideWith(_RestoredSession.new),
        selectedTabProvider.overrideWith(_NoSelectionEventYet.new),
        tabRepositoryProvider.overrideWith(_FakeTabRepository.new),
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  bool homeForced() => container.read(forceBrowserHomeProvider);

  /// What `TabRepository.selectTab` does in one synchronous step: clears the
  /// home latch and dispatches the selection.
  void pickTab() => container.read(forceBrowserHomeProvider.notifier).clear();

  test('a session with nothing selected gets the home target', () async {
    container.read(homeTargetControllerProvider);
    await pumpEventQueue();

    store.answer(null);
    await pumpEventQueue();

    expect(homeForced(), isTrue);
  });

  test(
    'a tab picked while the store is asked is not covered by home',
    () async {
      container.read(homeTargetControllerProvider);
      await pumpEventQueue();
      expect(store.asked, 1);

      // The user's selection is dispatched after the question, so the store's
      // answer, which lands after the selection, predates it.
      pickTab();
      store.answer(null);
      await pumpEventQueue();

      expect(store.asked, 2, reason: 'the stale answer is asked again');
      store.answer('picked');
      await pumpEventQueue();

      expect(homeForced(), isFalse);
    },
  );
}
