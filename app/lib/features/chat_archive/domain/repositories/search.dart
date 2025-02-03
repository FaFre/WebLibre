import 'dart:async';

import 'package:lensai/core/logger.dart';
import 'package:lensai/features/chat_archive/data/database/database.dart';
import 'package:lensai/features/chat_archive/data/providers.dart';
import 'package:lensai/features/chat_archive/data/services/file.dart';
import 'package:lensai/features/chat_archive/domain/entities/chat_entity.dart';
import 'package:lensai/features/chat_archive/domain/repositories/archive.dart';
import 'package:lensai/features/chat_archive/utils/markdown_to_text.dart';
import 'package:path/path.dart' as path;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:watcher/watcher.dart';

part 'search.g.dart';

@Riverpod()
class ChatArchiveSearchRepository extends _$ChatArchiveSearchRepository {
  late Completer<void> _populatedCompleter;
  late StreamController<List<ChatQueryResult>> _streamController;

  Future<ChatCompanion?> _readChat(ChatEntity chat) async {
    final contentResult = await ref
        .read(chatArchiveRepositoryProvider.notifier)
        .readChat(chat.fileName);

    return contentResult.fold(
      (content) => ChatCompanion.insert(
        fileName: chat.fileName,
        title: chat.name!,
        content: markdownToText(content),
      ),
      onFailure: (errorMessage) {
        logger.e(
          'Error reading file "${chat.fileName}": ${errorMessage.message}',
          error: errorMessage.details,
          stackTrace: errorMessage.stackTrace,
        );

        return null;
      },
    );
  }

  Future<Iterable<ChatCompanion>> _availableChats() async {
    final availableChats = await ref
        .read(chatArchiveRepositoryProvider.notifier)
        .listArchivedChats()
        .then(
          (chats) => Future.wait(
            chats.where((chat) => chat.name != null).map(_readChat),
          ),
        );

    return availableChats.nonNulls;
  }

  Future<void> search(
    String input, {
    int snippetLength = 120,
    String matchPrefix = '***',
    String matchSuffix = '***',
    String ellipsis = '…',
  }) async {
    if (input.isNotEmpty) {
      await _populatedCompleter.future;
      await ref
          .read(chatSearchDatabaseProvider)
          .searchDao
          .queryChats(
            searchString: input,
            snippetLength: snippetLength,
            matchPrefix: matchPrefix,
            matchSuffix: matchSuffix,
            ellipsis: ellipsis,
          )
          .get()
          .then(_streamController.add);
    }
  }

  @override
  Stream<List<ChatQueryResult>> build() async* {
    _populatedCompleter = Completer();
    _streamController = StreamController();

    final searchDatabase = ref.watch(chatSearchDatabaseProvider);

    // populate with initial chats
    await searchDatabase.searchDao.deleteAllChats();
    await searchDatabase.searchDao.indexChats(await _availableChats());
    _populatedCompleter.complete();

    final changeStreamSubscription =
        ref.watch(chatArchiveFileServiceProvider).listen((event) async {
      final chat = ChatEntity.fromFileName(path.basename(event.path));

      switch (event.type) {
        case ChangeType.ADD:
        case ChangeType.MODIFY:
          if (chat.name != null) {
            final companion = await _readChat(chat);
            if (companion != null) {
              await searchDatabase.searchDao.upsertChat(companion);
            }
          }
        case ChangeType.REMOVE:
          await searchDatabase.searchDao.deleteChat(chat.fileName);
      }
    });

    ref.onDispose(() async {
      await changeStreamSubscription.cancel();
      await _streamController.close();
    });

    yield* _streamController.stream;
  }
}
