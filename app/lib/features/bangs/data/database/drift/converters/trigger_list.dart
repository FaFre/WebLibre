import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nullability/nullability.dart';

class TriggerListConverter extends TypeConverter<Set<String>?, String?> {
  const TriggerListConverter();

  @override
  Set<String>? fromSql(String? fromDb) {
    return fromDb.mapNotNull(
      (value) => (jsonDecode(value) as List).cast<String>().toSet(),
    );
  }

  @override
  String? toSql(Set<String>? value) {
    return value.mapNotNull((value) => jsonEncode(value.toList()));
  }
}
