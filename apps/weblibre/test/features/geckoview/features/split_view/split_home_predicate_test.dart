import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';

class _SelectedTab extends SelectedTab {
  _SelectedTab(this.id);

  final String? id;

  @override
  String? build() => id;
}

class _SelectedContainer extends SelectedContainer {
  _SelectedContainer(this.id);

  final String? id;

  @override
  String? build() => id;
}

/// Tab `b` (container B) is selected, paired with `a` (container A).
bool showsHome({
  required String? selectedContainer,
  required bool paired,
  AsyncValue<Set<String?>> pairContainers = const AsyncData({'A', 'B'}),
}) {
  final pair = SplitPair(pairId: 'p', firstTabId: 'a', secondTabId: 'b');
  final container = ProviderContainer(
    overrides: [
      selectedTabProvider.overrideWith(() => _SelectedTab('b')),
      selectedContainerProvider.overrideWith(
        () => _SelectedContainer(selectedContainer),
      ),
      selectedTabContainerIdProvider.overrideWithValue(const AsyncData('B')),
      activeSplitPairProvider.overrideWithValue(paired ? pair : null),
      splitPairContainerIdsProvider.overrideWithValue(pairContainers),
    ],
  );
  addTearDown(container.dispose);
  return container.read(shouldShowBrowserHomeProvider);
}

void main() {
  group('shouldShowBrowserHome with a split pair', () {
    test('focus moved to the other pane before the selected container '
        'followed: no home over the pair', () {
      expect(showsHome(selectedContainer: 'A', paired: true), isFalse);
    });

    test('the selected container caught up: no home', () {
      expect(showsHome(selectedContainer: 'B', paired: true), isFalse);
    });

    test('an explicit switch to a third container shows home', () {
      expect(showsHome(selectedContainer: 'C', paired: true), isTrue);
    });

    test('without a pair, another container shows home as before', () {
      expect(showsHome(selectedContainer: 'A', paired: false), isTrue);
    });
  });
}
