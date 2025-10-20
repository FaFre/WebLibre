import 'dart:ui' as ui;

import 'package:intl/locale.dart' as intl;

extension LocaleFormat on intl.Locale {
  String rawToString(String separator) {
    final StringBuffer out = StringBuffer(languageCode);
    if (scriptCode != null && scriptCode!.isNotEmpty) {
      out.write('$separator$scriptCode');
    }
    final String? countryCode = this.countryCode;
    if (countryCode != null && countryCode.isNotEmpty) {
      out.write('$separator${this.countryCode}');
    }
    return out.toString();
  }
}

extension LocaleConverter on ui.Locale {
  intl.Locale toIntlLocale() {
    return intl.Locale.fromSubtags(
      languageCode: languageCode,
      countryCode: countryCode,
      scriptCode: scriptCode,
    );
  }
}
