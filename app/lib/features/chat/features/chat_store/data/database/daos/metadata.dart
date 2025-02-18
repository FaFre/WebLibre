import 'package:drift/drift.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/database.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';

part 'metadata.g.dart';

@DriftAccessor()
class MetadataDao extends DatabaseAccessor<ChatDatabase>
    with _$MetadataDaoMixin {
  MetadataDao(super.db);

  SingleOrNullSelectable<ChatMetadata> chatMetadata(String chatId) {
    final statement =
        db.chatData.selectOnly()
          ..addColumns([db.chatData.metadata])
          ..where(db.chatData.chatId.equals(chatId));

    return statement.map((row) => row.readWithConverter(db.chatData.metadata)!);
  }

  Future<void> updateChatMetadata(String chatId, ChatMetadata metadata) {
    return db.chatData.insertOne(
      ChatDataCompanion.insert(chatId: chatId, metadata: metadata),
      mode: InsertMode.insertOrReplace,
    );
  }
}
