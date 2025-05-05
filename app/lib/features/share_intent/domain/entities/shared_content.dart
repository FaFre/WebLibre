import 'package:fast_equatable/fast_equatable.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

sealed class SharedContent with FastEquatable {
  SharedContent();

  factory SharedContent.parse(String content) {
    if (uri_parser.tryParseUrl(content, eagerParsing: true)
        case final Uri uri) {
      return SharedUrl(uri);
    } else {
      return SharedText(content);
    }
  }
}

final class SharedUrl extends SharedContent {
  final Uri url;

  SharedUrl(this.url);

  @override
  String toString() => url.toString();

  @override
  List<Object?> get hashParameters => [url];
}

final class SharedText extends SharedContent {
  final String text;

  SharedText(this.text);

  @override
  String toString() => text;

  @override
  List<Object?> get hashParameters => [text];
}
