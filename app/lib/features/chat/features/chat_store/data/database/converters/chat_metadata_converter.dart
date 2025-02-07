import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';

class ChatMetadataConverter extends TypeConverter<ChatMetadata, String> {
  const ChatMetadataConverter();

  @override
  ChatMetadata fromSql(String fromDb) {
    return ChatMetadata.fromJson(jsonDecode(fromDb) as Map<String, dynamic>);
  }

  @override
  String toSql(ChatMetadata value) {
    return jsonEncode(value.toJson());
  }
}
