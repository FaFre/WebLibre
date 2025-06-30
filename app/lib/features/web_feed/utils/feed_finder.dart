import 'package:html/dom.dart';

class FeedFinder {
  final Uri url;
  final Document document;

  late final String _base;

  FeedFinder({required this.url, required this.document}) {
    final uri = url.removeFragment();
    _base = '${uri.scheme}://${uri.authority}';
  }

  // Future<Set<String>> _verifyCandidates(Set<String> candidates) async {
  //   final results = <String>{};

  //   final client = http.Client();
  //   try {
  //     for (final candidate in candidates) {
  //       try {
  //         await client.get(Uri.parse(candidate));
  //       } catch (e) {
  //         continue;
  //       }

  //       results.add(candidate);
  //     }
  //   } finally {
  //     client.close();
  //   }

  //   return results;
  // }

  void _parseBody(Set<Uri> candidates) {
    for (final a in document.querySelectorAll('a')) {
      var href = a.attributes['href'];
      if (href != null) {
        if (href.contains('rss') ||
            href.contains('xml') ||
            href.contains('feed')) {
          // Fix relative URLs
          href = href.startsWith('/') ? _base + href : href;
          href = href.endsWith('/') ? href.substring(0, href.length - 2) : href;

          // Fix naked URLs
          href = !href.startsWith('http') ? '$_base/$href' : href;

          if (Uri.tryParse(href) case final Uri uri) {
            candidates.add(uri);
          }
        }
      }
    }
  }

  void _parseHead(Set<Uri> candidates) {
    for (final link in document.querySelectorAll("link[rel='alternate']")) {
      final type = link.attributes['type'];
      if (type != null) {
        if (type.contains('rss') || type.contains('xml')) {
          var href = link.attributes['href'];
          if (href != null) {
            // Fix relative URLs
            href = href.startsWith('/') ? _base + href : href;

            if (Uri.tryParse(href) case final Uri uri) {
              candidates.add(uri);
            }
          }
        }
      }
    }
  }

  Future<Set<Uri>> parse({
    bool parseHead = true,
    bool parseBody = true,
    // bool verifyCandidates = true,
  }) async {
    final candidates = <Uri>{};

    // Look for feed candidates in head
    if (parseHead) {
      _parseHead(candidates);
    }

    // Look for feed candidates in body
    if (parseBody) {
      _parseBody(candidates);
    }

    // Verify candidates
    // if (verifyCandidates) {
    //   return _verifyCandidates(candidates);
    // }

    return candidates;
  }
}
