import 'package:drift/drift.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class UriConverter extends TypeConverter<Uri, String> {
  const UriConverter();

  @override
  Uri fromSql(String fromDb) {
    return uri_parser.tryParseUrl(fromDb, eagerParsing: true)!;
  }

  @override
  String toSql(Uri value) {
    return value.toString();
  }
}

class UriConverterNullable extends TypeConverter<Uri?, String?> {
  const UriConverterNullable();

  @override
  Uri? fromSql(String? fromDb) {
    return uri_parser.tryParseUrl(fromDb, eagerParsing: true);
  }

  @override
  String? toSql(Uri? value) {
    return value?.toString();
  }
}
