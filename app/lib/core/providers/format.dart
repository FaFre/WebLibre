import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'format.g.dart';

@Riverpod(keepAlive: true)
class Format extends _$Format {
  String fullDateTimeWithTimezone(DateTime date) {
    final pattern = DateFormat('yMMMMd').addPattern('Hm');

    return pattern.format(date);
  }

  @override
  Future<void> build() async {
    await initializeDateFormatting();
  }
}
