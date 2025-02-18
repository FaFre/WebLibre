import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/database.dart';
import 'package:lexo_rank/lexo_rank.dart';

part 'messages.g.dart';

@DriftAccessor()
class MessagesDao extends DatabaseAccessor<ChatDatabase>
    with _$MessagesDaoMixin {
  MessagesDao(super.db);

  Selectable<int> messageCount({required String chatId}) {
    return db.chatMessage.count(where: (row) => row.chatId.equals(chatId));
  }

  Selectable<ChatMessageData> chatMessages({required String chatId}) {
    return db.chatMessage.select()
      ..where((t) => t.chatId.equals(chatId))
      ..orderBy([(row) => OrderingTerm(expression: row.orderKey)]);
  }

  Selectable<bool> messageExists(String messageId) {
    final existsExpression = existsQuery(
      db.chatMessage.select()..where((row) => row.messageId.equals(messageId)),
    );

    return db
        .selectExpressions([existsExpression])
        .map((row) => row.read(existsExpression)!);
  }

  SingleOrNullSelectable<int> messageIndex({
    required String chatId,
    required String messageId,
  }) {
    return db
        .messageIndex(chatId: chatId, messageId: messageId)
        .map((rowId) => rowId - 1);
  }

  Future<int?> insertMessage({
    required String chatId,
    required Message message,
    int? index,
  }) async {
    if (await messageExists(message.id).getSingle()) {
      return null;
    }

    return db.transaction(() async {
      final String orderKey;
      if (index != null) {
        if (index <= 0) {
          orderKey =
              await db.leadingOrderKey(bucket: 0, chatId: chatId).getSingle();
        } else {
          orderKey =
              await db
                  .orderKeyBeforeIndex(chatId: chatId, rowIdx: index + 1)
                  .getSingle();
        }
      } else {
        orderKey =
            await db.trailingOrderKey(bucket: 0, chatId: chatId).getSingle();
      }

      await db.chatMessage.insertOne(
        ChatMessageCompanion.insert(
          messageId: message.id,
          chatId: chatId,
          orderKey: orderKey,
          messageJson: jsonEncode(message.toJson()),
        ),
      );

      final rowIdx =
          await db
              .messageIndex(chatId: chatId, messageId: message.id)
              .getSingle();

      return rowIdx - 1;
    });
  }

  Future<int> removeMessage({required String messageId}) {
    return db.chatMessage.deleteWhere((row) => row.messageId.equals(messageId));
  }

  Future<int> updateMessage({
    required String messageId,
    required Message message,
  }) {
    return (db.chatMessage.update()
          ..where((row) => row.messageId.equals(messageId)))
        .write(
          ChatMessageCompanion(
            messageJson: Value(jsonEncode(message.toJson())),
          ),
        );
  }

  Future<int> deleteChatMessages({required String chatId}) {
    return (db.chatMessage.delete()..where((t) => t.chatId.equals(chatId)))
        .go();
  }

  Future<void> replaceChatMessages({
    required String chatId,
    required List<Message> messages,
  }) async {
    return db.transaction(() async {
      await deleteChatMessages(chatId: chatId);

      var currentOrderKey =
          await db.leadingOrderKey(bucket: 0, chatId: chatId).getSingle();

      await db.chatMessage.insertAll(
        messages.map((message) {
          final insertable = ChatMessageCompanion.insert(
            messageId: message.id,
            chatId: chatId,
            messageJson: jsonEncode(message.toJson()),
            orderKey: currentOrderKey,
            // timestamp: DateTime.now(),
          );

          currentOrderKey = LexoRank.parse(currentOrderKey).genPrev().value;

          return insertable;
        }),
      );
    });
  }
}
