import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void select(String tabId) => state = tabId;
}

class _FakeHomeShown extends Notifier<bool> {
  @override
  bool build() => false;

  // ignore: use_setters_to_change_properties
  void set(bool shown) => state = shown;
}

final _homeShownProvider = NotifierProvider<_FakeHomeShown, bool>(
  _FakeHomeShown.new,
);

final _overrides = [
  selectedTabProvider.overrideWith(_FakeSelectedTab.new),
  shouldShowBrowserHomeProvider.overrideWith(
    (ref) => ref.watch(_homeShownProvider),
  ),
];

Intent _link(String url) => Intent(
  action: 'android.intent.action.VIEW',
  data: url,
  categories: const [],
  extra: const {},
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: _overrides);
    addTearDown(container.dispose);
    // Listened, as startup does: an unlistened provider's own listeners are
    // paused, and the cover would never hear the selection.
    container.listen(startupLaunchCoverProvider, (_, _) {});
  });

  StartupLaunchCover cover() =>
      container.read(startupLaunchCoverProvider.notifier);
  bool raised() => container.read(startupLaunchCoverProvider);
  bool claimed() => container.read(intentLaunchClaimProvider);
  void drop(Intent intent) =>
      container.read(unopenedSharingIntentsProvider).add(intent);
  void select(String tabId) =>
      (container.read(selectedTabProvider.notifier) as _FakeSelectedTab).select(
        tabId,
      );
  void showHome({required bool shown}) =>
      container.read(_homeShownProvider.notifier).set(shown);

  test('nothing to open raises nothing', () {
    cover().raiseFor(const []);

    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('a launch raises the cover and holds the claim', () {
    // The claim is what makes the startup home target wait for the launch,
    // from before the launch reaches the consumer that takes its own.
    cover().raiseFor([_link('https://example.com')]);

    expect(raised(), isTrue);
    expect(claimed(), isTrue);
  });

  test('the launch tab on screen lowers it', () {
    cover()
      ..raiseFor([_link('https://example.com')])
      ..launchTabCreated('tab');

    select('tab');
    expect(
      raised(),
      isTrue,
      reason: 'addTab has not moved the selected container over yet',
    );

    cover().launchTabOpened('tab');
    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('the launch tab selected after addTab returned lowers it', () {
    cover()
      ..raiseFor([_link('https://example.com')])
      ..launchTabCreated('tab')
      ..launchTabOpened('tab');
    expect(raised(), isTrue, reason: 'the selection has not landed yet');

    select('tab');

    expect(raised(), isFalse);
  });

  test('a restored selection does not lower it', () {
    // The restored session's selection can land after the cover went up; its
    // page is not the launch.
    cover().raiseFor([_link('https://example.com')]);

    select('restored');

    expect(raised(), isTrue);
    expect(claimed(), isTrue);
  });

  test('a tab standing in for the launch tab lowers it', () {
    // A cancelled first navigation is reopened in the site's assigned
    // container and the launch tab closed, all inside the engine's 50ms
    // selection debounce: the launch tab is never reported selected.
    cover()
      ..raiseFor([_link('https://example.com')])
      ..launchTabCreated('tab')
      ..launchTabOpened('tab');

    select('replacement');

    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('a stand-in selected before addTab returned lowers it', () {
    // The replacement can be selected while addTab is still moving the
    // selected container. What was selected then is the launch, not the
    // session it has to hide.
    cover().raiseFor([_link('https://example.com')]);
    select('restored');

    cover().launchTabCreated('tab');
    select('replacement');
    expect(raised(), isTrue, reason: 'addTab has not returned yet');

    cover().launchTabOpened('tab');
    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('the selection on screen when the launch tab was created stays '
      'hidden', () {
    cover().raiseFor([_link('https://example.com')]);
    select('restored');

    cover()
      ..launchTabCreated('tab')
      ..launchTabOpened('tab');
    expect(raised(), isTrue, reason: 'the launch tab is not selected yet');

    select('replacement');
    expect(raised(), isFalse);
  });

  test('the launch tab under home does not lower it until home goes', () {
    cover().raiseFor([_link('https://example.com')]);
    showHome(shown: true);

    cover().launchTabCreated('tab');
    select('tab');
    cover().launchTabOpened('tab');
    expect(raised(), isTrue, reason: 'home is still drawn over the tab');

    showHome(shown: false);
    expect(raised(), isFalse);
  });

  test('lowers once every awaited launch was let go of', () {
    final first = _link('https://example.com');
    final second = _link('https://example.org');
    cover().raiseFor([first, second]);

    drop(first);
    expect(raised(), isTrue, reason: 'the second launch may still open');

    // Identity, not equality: an equal intent that arrived later is not the
    // one being waited for.
    drop(_link('https://example.org'));
    expect(raised(), isTrue);

    drop(second);
    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('the consumer lowers it when no tab is coming', () {
    cover().raiseFor([_link('https://example.com')]);

    cover().lower();

    expect(raised(), isFalse);
    expect(claimed(), isFalse);
  });

  test('raises once per start', () {
    cover()
      ..raiseFor([_link('https://example.com')])
      ..lower()
      ..raiseFor([_link('https://example.org')]);

    expect(raised(), isFalse);
  });

  testWidgets('a launch lost on the way does not strand the spinner', (
    tester,
  ) async {
    // Its own container: timers must be created on the test's fake clock.
    final container = ProviderContainer(overrides: _overrides);
    addTearDown(container.dispose);
    container
      ..listen(startupLaunchCoverProvider, (_, _) {})
      ..read(
        startupLaunchCoverProvider.notifier,
      ).raiseFor([_link('https://example.com')]);

    await tester.pump(const Duration(seconds: 11));
    expect(container.read(startupLaunchCoverProvider), isTrue);

    await tester.pump(const Duration(seconds: 1));
    expect(container.read(startupLaunchCoverProvider), isFalse);
    expect(container.read(intentLaunchClaimProvider), isFalse);
  });
}
