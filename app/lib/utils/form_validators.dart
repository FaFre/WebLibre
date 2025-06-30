import 'package:nullability/nullability.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

String? validateUrl(
  String? value, {
  bool requireAuthority = true,
  bool eagerParsing = true,
  bool onlyHttpProtocol = false,
  bool required = true,
}) {
  if (value.isEmpty) {
    if (required) {
      return 'URL must be provided';
    } else {
      return null;
    }
  }

  if (uri_parser.tryParseUrl(value, eagerParsing: eagerParsing)
      case final Uri url) {
    if (!requireAuthority || url.authority.isNotEmpty) {
      if (!onlyHttpProtocol ||
          (url.isScheme('https') || url.isScheme('http'))) {
        return null;
      }
    }
  }

  return 'Inavlid URL';
}
