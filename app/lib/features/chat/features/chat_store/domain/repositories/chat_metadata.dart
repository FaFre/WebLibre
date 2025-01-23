import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/database.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';
import 'package:lensai/features/chat/features/chat_store/data/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_metadata.g.dart';

@Riverpod()
class ChatMetadataRepository extends _$ChatMetadataRepository {
  late ChatDatabase _db;

  Future<Result<void>> updateMetadata(ChatMetadata metadata) {
    return Result.fromAsync(() {
      return _db.metadataDao.updateChatMetadata(chatId, metadata);
    });
  }

  @override
  void build(String chatId) {
    _db = ref.watch(chatDatabaseProvider);
  }
}
