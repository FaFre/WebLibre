import 'package:exceptions/exceptions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/chat/features/chat_store/data/models/chat_metadata.dart';
import 'package:weblibre/features/chat/features/chat_store/data/providers.dart';

part 'chat_metadata.g.dart';

@Riverpod()
class ChatMetadataRepository extends _$ChatMetadataRepository {
  Future<Result<void>> updateMetadata(ChatMetadata metadata) {
    return Result.fromAsync(() {
      return ref
          .read(chatDatabaseProvider)
          .metadataDao
          .updateChatMetadata(chatId, metadata);
    });
  }

  @override
  void build(String chatId) {}
}
