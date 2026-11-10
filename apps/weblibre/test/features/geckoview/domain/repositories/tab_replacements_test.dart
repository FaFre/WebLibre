import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

void main() {
  late TabReplacements replacements;

  setUp(() => replacements = TabReplacements());

  test('a replaced tab resolves to its replacement', () {
    replacements.record('a', 'b');

    expect(replacements.has('a'), isTrue);
    expect(replacements.resolve('a', openTabIds: {'b'}), 'b');
  });

  test('a tab whose close is under way resolves to its replacement', () {
    // Recorded before the close, which can wait behind another close.
    replacements.recordClosing('a', 'b');

    // Still open natively: that is the close not being through yet, not an
    // undo, so a "Switch" tapped now reaches the replacement.
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'b');
    expect(replacements.has('a'), isTrue);

    replacements.closed('a');
    expect(replacements.resolve('a', openTabIds: {'b'}), 'b');
  });

  test(
    'a closed tab the native store still lists is not taken for restored',
    () {
      replacements.record('a', 'b');

      expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'b');
    },
  );

  test('a replaced tab restored by undo is itself again', () {
    // Moved to another container: closed, and "b" opened in its place.
    replacements.recordClosing('a', 'b');
    replacements.closed('a');
    // "Reopen closed tab" within the engine's undo window brings it back
    // under its own id.
    replacements.undone();
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'a');

    // Its alias is gone: once the restored tab is closed again, that close
    // is its own, and a selection of it does not reach "b".
    expect(replacements.has('a'), isFalse);
    expect(replacements.resolve('a', openTabIds: {'b'}), 'a');
  });

  test('an undo before a late registration still restores the tab', () {
    // A container move: the original closes first, and its replacement is
    // recorded only once the new tab has opened.
    final closedAt = replacements.undoGeneration;
    // "Reopen closed tab" while the replacement opens.
    replacements.undone();
    replacements.record('a', 'b', closedAt: closedAt);

    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'a');
    expect(replacements.has('a'), isFalse);
  });

  test('an undo before the original closed does not restore it', () {
    replacements.undone();
    final closedAt = replacements.undoGeneration;
    replacements.record('a', 'b', closedAt: closedAt);

    // Still listed natively a moment after its close.
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'b');
  });

  test('an undo that restored other tabs leaves the alias', () {
    replacements.record('a', 'b');
    replacements.undone();

    expect(replacements.resolve('a', openTabIds: {'b', 'other'}), 'b');
    expect(replacements.has('a'), isTrue);
  });

  test('an undo during the close does not restore the tab being closed', () {
    replacements.recordClosing('a', 'b');
    // Undoes an earlier close; "a" is still open only because its own close
    // has not gone through.
    replacements.undone();
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'b');

    replacements.closed('a');
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'b');
  });

  test('a failed close forgets the replacement', () {
    replacements.recordClosing('a', 'b');
    replacements.drop('a');

    expect(replacements.has('a'), isFalse);
    expect(replacements.resolve('a', openTabIds: {'a', 'b'}), 'a');
  });

  test('replacements of replacements are followed', () {
    replacements
      ..record('a', 'b')
      ..record('b', 'c');

    expect(replacements.resolve('a', openTabIds: {'c'}), 'c');
  });

  test('a restored replacement in the middle of a chain stops there', () {
    replacements
      ..record('a', 'b')
      ..record('b', 'c')
      ..undone();

    expect(replacements.resolve('a', openTabIds: {'b', 'c'}), 'b');
    expect(replacements.has('b'), isFalse);
  });

  test('a tab never replaced resolves to itself', () {
    expect(replacements.has('a'), isFalse);
    expect(replacements.resolve('a', openTabIds: const {}), 'a');
  });

  test('a cycle does not loop', () {
    replacements
      ..record('a', 'b')
      ..record('b', 'a');

    expect(replacements.resolve('a', openTabIds: const {}), 'b');
  });

  test('only the latest replacements are kept', () {
    for (var i = 0; i <= TabReplacements.limit; i++) {
      replacements.record('old$i', 'new$i');
    }

    expect(replacements.has('old0'), isFalse);
    expect(replacements.has('old${TabReplacements.limit}'), isTrue);
  });
}
