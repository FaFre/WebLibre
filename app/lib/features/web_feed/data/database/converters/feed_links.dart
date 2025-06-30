import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_link.dart';

class FeedLinksConverter extends TypeConverter<List<FeedLink>, String> {
  const FeedLinksConverter();

  @override
  List<FeedLink> fromSql(String fromDb) {
    final links = jsonDecode(fromDb) as List<dynamic>;
    return links
        .map((link) => FeedLink.fromJson(link as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<FeedLink> value) {
    return jsonEncode(value.map((link) => link.toJson()).toList());
  }
}
