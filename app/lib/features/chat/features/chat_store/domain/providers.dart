import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';
import 'package:lensai/features/chat/features/chat_store/data/providers.dart';
import 'package:lensai/features/chat/features/chat_store/domain/controllers/drift_chat_controller.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod()
DriftChatController chatController(Ref ref, String chatId) {
  final db = ref.watch(chatDatabaseProvider);
  final controller = DriftChatController(db.messagesDao, chatId: chatId);

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
}

@Riverpod()
Stream<ChatMetadata?> chatMetadata(Ref ref, String chatId) {
  final db = ref.watch(chatDatabaseProvider);
  return db.metadataDao.getChatMetadata(chatId).watchSingleOrNull();
}
