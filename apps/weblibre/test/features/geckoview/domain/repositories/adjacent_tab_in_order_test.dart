import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

void main() {
  String? step(
    List<String> order,
    String current, {
    required bool selectPrevious,
    bool loop = false,
  }) => adjacentTabIdInOrder(
    order: order,
    currentTabId: current,
    selectPrevious: selectPrevious,
    loop: loop,
  );

  group('adjacentTabIdInOrder', () {
    const order = ['a', 'b', 'c'];

    test('steps exactly one position in each direction', () {
      expect(step(order, 'b', selectPrevious: false), 'c');
      expect(step(order, 'b', selectPrevious: true), 'a');
    });

    test('stops at both ends without looping', () {
      expect(step(order, 'c', selectPrevious: false), isNull);
      expect(step(order, 'a', selectPrevious: true), isNull);
    });

    test('wraps around both ends when looping', () {
      expect(step(order, 'c', selectPrevious: false, loop: true), 'a');
      expect(step(order, 'a', selectPrevious: true, loop: true), 'c');
    });

    test('walking the whole order visits every tab once, in order', () {
      final visited = <String>['a'];
      var current = 'a';
      var next = step(order, current, selectPrevious: false);
      while (next != null) {
        visited.add(next);
        current = next;
        next = step(order, current, selectPrevious: false);
      }

      expect(visited, order);
    });

    group('current tab absent from the order', () {
      // Issue #603: this used to select the first or last tab, turning a
      // one-position swipe into a jump across the whole strip.
      test('is a no-op in both directions', () {
        expect(step(order, 'missing', selectPrevious: false), isNull);
        expect(step(order, 'missing', selectPrevious: true), isNull);
      });

      test('is a no-op even when looping is on', () {
        expect(
          step(order, 'missing', selectPrevious: false, loop: true),
          isNull,
        );
        expect(
          step(order, 'missing', selectPrevious: true, loop: true),
          isNull,
        );
      });
    });

    group('degenerate orders', () {
      test('an empty order has nothing to step to', () {
        expect(step(const [], 'a', selectPrevious: false, loop: true), isNull);
      });

      test('a single tab does not wrap onto itself', () {
        expect(
          step(const ['a'], 'a', selectPrevious: false, loop: true),
          isNull,
        );
        expect(
          step(const ['a'], 'a', selectPrevious: true, loop: true),
          isNull,
        );
      });

      test('two tabs step to each other and wrap back', () {
        expect(step(const ['a', 'b'], 'a', selectPrevious: false), 'b');
        expect(step(const ['a', 'b'], 'b', selectPrevious: false), isNull);
        expect(
          step(const ['a', 'b'], 'b', selectPrevious: false, loop: true),
          'a',
        );
      });
    });
  });
}
