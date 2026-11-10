import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

/// A background tab `old` replaced by `new`, whose opening waits on [opening]
/// so a test can change the native selection meanwhile.
class _Replacement {
  final opening = Completer<void>();
  final log = <String>[];
  String? nativeSelected = 'other';
  bool mounted = true;
  int selectionReads = 0;

  /// The selection the close goes by: native's, or with [closeSeesStale] the
  /// one Dart's debounced selection events still report, the tab selected
  /// before the replacement took over.
  bool closeSeesStale = false;
  String? _selectedBeforeTransfer;

  Future<String> run({required bool focused}) => replaceTabOpeningFirst(
    oldTabId: 'old',
    focused: focused,
    open: () async {
      await opening.future;
      log.add('opened new');
      // A focused tab's replacement opens selected.
      if (focused) nativeSelected = 'new';
      return 'new';
    },
    selectedTabId: () async {
      selectionReads++;
      return nativeSelected;
    },
    closeOld: (newTabId) async {
      // Closing the selected tab hands the selection to another one.
      final seen = closeSeesStale ? _selectedBeforeTransfer : nativeSelected;
      if (seen == 'old') {
        log.add('selected neighbor');
        nativeSelected = 'neighbor';
      }
      log.add('closed old');
    },
    select: (tabId) async {
      log.add('selected $tabId');
      _selectedBeforeTransfer ??= nativeSelected;
      nativeSelected = tabId;
    },
    isMounted: () => mounted,
  );
}

void main() {
  test('a background tab selected while its replacement opens hands the '
      'selection to the replacement before it closes', () async {
    final replacement = _Replacement();
    final done = replacement.run(focused: false);

    // The user taps the "tab opened" prompt while the replacement opens.
    replacement.nativeSelected = 'old';
    replacement.opening.complete();

    expect(await done, 'new');
    expect(replacement.log, [
      'opened new',
      'selected new',
      'closed old',
      'selected new',
    ]);
    expect(replacement.nativeSelected, 'new');
  });

  test('a close that still sees the original as selected does not take the '
      'transferred selection away', () async {
    // The original's selection reached Dart, the replacement's has not yet
    // (the events are debounced), and the close goes by Dart's: it picks a
    // next tab over the replacement.
    final replacement = _Replacement()..closeSeesStale = true;
    final done = replacement.run(focused: false);

    replacement.nativeSelected = 'old';
    replacement.opening.complete();

    await done;
    expect(replacement.log, [
      'opened new',
      'selected new',
      'selected neighbor',
      'closed old',
      'selected new',
    ]);
    expect(replacement.nativeSelected, 'new');
  });

  test(
    'a background tab left alone keeps its replacement in the background',
    () async {
      final replacement = _Replacement();
      final done = replacement.run(focused: false);
      replacement.opening.complete();

      await done;
      expect(replacement.log, ['opened new', 'closed old']);
      expect(replacement.nativeSelected, 'other');
    },
  );

  test('the selected tab selects its replacement once it is closed, without '
      'asking native again', () async {
    final replacement = _Replacement()..nativeSelected = 'old';
    final done = replacement.run(focused: true);
    replacement.opening.complete();

    await done;
    expect(replacement.log, ['opened new', 'closed old', 'selected new']);
    expect(replacement.selectionReads, 0);
  });

  test(
    'a repository disposed while the replacement opens closes nothing',
    () async {
      final replacement = _Replacement();
      final done = replacement.run(focused: false);
      replacement.nativeSelected = 'old';
      replacement.mounted = false;
      replacement.opening.complete();

      await done;
      expect(replacement.log, ['opened new']);
    },
  );
}
