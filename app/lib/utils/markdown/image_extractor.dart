import 'package:lensai/extensions/nullable.dart';
import 'package:markdown/markdown.dart';
import 'package:path/path.dart' as p;

List<Uri> extractImagesFromMarkdown(String markdownText) {
  final imageUrls = <Uri>[];

  final nodes = Document().parse(markdownText);

  void findImages(List<Node> nodes) {
    for (final node in nodes) {
      if (node is Element && node.tag == 'img') {
        final url = node.attributes['src'];

        if (url.mapNotNull((url) => Uri.tryParse(url)) case final Uri url) {
          if (p.extension(url.path)
              case '.png' || '.jpg' || '.jpeg' || '.webp') {
            imageUrls.add(url);
          }
        }
      }

      if (node is Element && node.children != null) {
        findImages(node.children!);
      }
    }
  }

  findImages(nodes);

  return imageUrls;
}
