import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_author.dart';

class FeedAuthorsConverter extends TypeConverter<List<FeedAuthor>, String> {
  const FeedAuthorsConverter();

  @override
  List<FeedAuthor> fromSql(String fromDb) {
    final authors = jsonDecode(fromDb) as List<dynamic>;
    return authors
        .map((author) => FeedAuthor.fromJson(author as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<FeedAuthor> value) {
    return jsonEncode(value.map((author) => author.toJson()).toList());
  }
}
