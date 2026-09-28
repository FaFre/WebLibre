import 'package:flutter_test/flutter_test.dart';

import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

void main() {
  test('splits a localized keyword message into trimmed terms', () {
    expect(settingsKeywords('top, bottom ,side rail'), [
      'top',
      'bottom',
      'side rail',
    ]);
  });

  test('ignores empty terms a translator may leave behind', () {
    expect(settingsKeywords(' , swipe,, '), ['swipe']);
    expect(settingsKeywords(''), isEmpty);
  });
}
