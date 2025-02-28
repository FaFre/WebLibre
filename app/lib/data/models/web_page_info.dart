import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:lensai/features/geckoview/domain/entities/browser_icon.dart';

part 'web_page_info.g.dart';

@CopyWith()
class WebPageInfo with FastEquatable {
  final Uri url;
  final String? title;
  final BrowserIcon? favicon;
  final Set<String>? feeds;

  bool get isPageInfoComplete =>
      title.isNotEmpty && favicon != null && feeds != null;

  WebPageInfo({required this.url, this.title, this.favicon, this.feeds});

  @override
  List<Object?> get hashParameters => [url, title, favicon, feeds];
}
