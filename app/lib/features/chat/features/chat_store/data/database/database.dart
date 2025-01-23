import 'package:lensai/features/chat/features/chat_store/data/database/converters/chat_metadata_converter.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/daos/messages.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/daos/metadata.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';

import 'package:drift/drift.dart';

part 'database.g.dart';

@DriftDatabase(include: {'database.drift'}, daos: [MessagesDao, MetadataDao])
class ChatDatabase extends _$ChatDatabase {
  ChatDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
