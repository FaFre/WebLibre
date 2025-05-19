import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:weblibre/features/web_feed/data/models/feed_category.dart';

class FeedCategoriesConverter
    extends TypeConverter<List<FeedCategory>, String> {
  const FeedCategoriesConverter();

  @override
  List<FeedCategory> fromSql(String fromDb) {
    final categories = jsonDecode(fromDb) as List<dynamic>;
    return categories
        .map(
          (category) => FeedCategory.fromJson(category as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  String toSql(List<FeedCategory> value) {
    return jsonEncode(value.map((category) => category.toJson()).toList());
  }
}
