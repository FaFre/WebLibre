import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';

void main() {
  group('TabMode value semantics', () {
    test('isolated modes with same context are equal and hash equally', () {
      final first = TabMode.isolated('iso1_same');
      final second = TabMode.isolated('iso1_same');

      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('isolated modes with different contexts are not equal', () {
      final first = TabMode.isolated('iso1_a');
      final second = TabMode.isolated('iso1_b');

      expect(first, isNot(equals(second)));
    });
  });
}
