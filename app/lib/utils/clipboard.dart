import 'package:flutter/services.dart';
import 'package:weblibre/utils/uri_parser.dart';

Future<Uri?> tryGetUriFromClipboard({bool eagerParsing = true}) async {
  final data = await Clipboard.getData('text/plain');
  return tryParseUrl(data?.text, eagerParsing: eagerParsing);
}
