import 'package:rss_dart/dart_rss.dart';

extension WebFeedJson on WebFeed {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'links': links.where((link) => link != null).toList(),
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  static WebFeed fromJson(Map<String, dynamic> json) {
    return WebFeed(
      title: json['title'] as String,
      description: json['description'] as String,
      links: (json['links'] as List).cast<String?>(),
      items:
          (json['items'] as List)
              .map(
                (item) =>
                    WebFeedItemJson.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
    );
  }
}

extension WebFeedItemJson on WebFeedItem {
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'links': links.where((link) => link != null).toList(),
      'updated': updated?.toIso8601String(),
    };
  }

  static WebFeedItem fromJson(Map<String, dynamic> json) {
    return WebFeedItem(
      title: json['title'] as String,
      body: json['body'] as String,
      links: (json['links'] as List).cast<String?>(),
      updated:
          json['updated'] != null
              ? DateTime.parse(json['updated'] as String)
              : null,
    );
  }
}
