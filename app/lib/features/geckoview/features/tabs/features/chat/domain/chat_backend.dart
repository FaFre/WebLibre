import 'dart:async';

import 'package:exceptions/exceptions.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/chat_metadata.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/message_types.dart';
import 'package:lensai/features/chat/features/chat_store/domain/providers.dart';
import 'package:lensai/features/chat/features/chat_store/domain/repositories/chat_message.dart';
import 'package:lensai/features/geckoview/features/tabs/features/chat/services/qa_memory_chain.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/domain/repositories/document.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_backend.g.dart';

@Riverpod()
class ChatBackend extends _$ChatBackend {
  late ChatMetadata? _metadata;

  late ChatMessageRepository _chatRepository;

  late QAMemoryChain _qaMemoryChain;

  Future<void>? _embeddingsUpdate;
  Future<void> prepareEmbeddings() {
    if (_embeddingsUpdate != null) {
      return _embeddingsUpdate!;
    }

    _embeddingsUpdate =
        ref.read(documentRepositoryProvider.notifier).updateEmbeddings(
              mainDocumentId: _metadata?.mainDocumentId,
              contextId: _metadata?.contextId,
            );

    _embeddingsUpdate!.whenComplete(() => _embeddingsUpdate = null);

    return _embeddingsUpdate!;
  }

  Future<Result<void>> processQAMessage(String input) async {
    //TODO: fix result mess

    final humanMessageResult = await _chatRepository.insertTextMessage(
      author: MessageAuthor.human,
      content: input,
    );

    await prepareEmbeddings();

    return humanMessageResult.flatMapAsync((humanMessage) async {
      await _chatRepository.setTyping(
        author: MessageAuthor.ai,
        typing: true,
      );

      final result = await _qaMemoryChain.processQuestion(humanMessage.text);
      await _chatRepository.setTyping(
        author: MessageAuthor.ai,
        typing: false,
      );

      await _chatRepository.insertTextMessage(
        author: MessageAuthor.ai,
        content: result.answer,
      );
    });
  }

  @override
  void build(String chatId) {
    _metadata = ref.watch(
      chatMetadataProvider(chatId).select((value) => value.valueOrNull),
    );

    _chatRepository = ref.watch(chatMessageRepositoryProvider(chatId).notifier);

    _qaMemoryChain = ref.watch(
      qAMemoryChainProvider(
        chatId: chatId,
        mainDocumentId: _metadata?.mainDocumentId,
        contextId: _metadata?.contextId,
      ).notifier,
    );
  }
}
