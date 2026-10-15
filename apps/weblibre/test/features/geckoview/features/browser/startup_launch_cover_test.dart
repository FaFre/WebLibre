import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/intent.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

class _FakeSelectedTab extends SelectedTab {
  @override
  String? build() => null;

  // ignore: use_setters_to_change_properties
  void select(String tabId) => state = tabId;
}

Intent _link(String url) => Intent(
  action: 'android.intent.action.VIEW',
  data: url,
  categories: const [],
  extra: const {},
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [selectedTabProvider.overrideWith(_FakeSelectedTab.new)],
    );
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

  test('the launch tab being selected lowers it', () {
    cover().raiseFor([_link('https://example.com')]);

    (container.read(selectedTabProvider.notifier) as _FakeSelectedTab).select(
      'tab',
    );

    expect(raised(), isFalse);
    expect(claimed(), isFalse);
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
    final container = ProviderContainer(
      overrides: [selectedTabProvider.overrideWith(_FakeSelectedTab.new)],
    );
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
