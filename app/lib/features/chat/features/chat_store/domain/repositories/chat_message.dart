import 'package:exceptions/exceptions.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:langchain/langchain.dart';
import 'package:lensai/core/uuid.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/message_types.dart';
import 'package:lensai/features/chat/features/chat_store/domain/drift_chat_controller.dart';
import 'package:lensai/features/chat/features/chat_store/domain/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_message.g.dart';

@Riverpod()
class ChatMessageRepository extends _$ChatMessageRepository {
  late DriftChatController _controller;

  final _isTyping = <MessageAuthor>{};

  bool isTyping(MessageAuthor author) => _isTyping.contains(author);

  Future<void> setTyping({
    required MessageAuthor author,
    required bool typing,
  }) async {
    if (isTyping(author) == typing) {
      return;
    }

    if (typing) {
      await _controller.insert(
        CustomMessage(
          id: uuid.v4(),
          authorId: author.user.id,
          createdAt: DateTime.now().toUtc(),
          metadata: {
            'type': 'typing',
          },
        ),
      );

      _isTyping.add(author);
    } else {
      final typingMessages = _controller.messages.where(
        (message) =>
            message.authorId == author.user.id &&
            message.metadata?['type'] == 'typing',
      );

      await Future.wait(
        typingMessages.map((message) => _controller.remove(message)),
      );

      _isTyping.remove(author);
    }
  }

  Future<Result<TextMessage>> insertTextMessage({
    required MessageAuthor author,
    required String content,
    List<AIChatMessageToolCall>? toolCalls,
    bool hideFromModelChatHistory = false,
  }) async {
    final message = TextMessage(
      id: uuid.v4(),
      authorId: author.user.id,
      createdAt: DateTime.now().toUtc(),
      text: content,
      isOnlyEmoji: isOnlyEmoji(content),
      metadata: (hideFromModelChatHistory || (toolCalls?.isNotEmpty ?? false))
          ? {
              'toolCalls': toolCalls?.map((tool) => tool.toMap()).toList(),
              if (hideFromModelChatHistory) 'hideFromModelChatHistory': true,
            }
          : null,
    );

    return Result.fromAsync(() async {
      await _controller.insert(message);
      return message;
    });
  }

  @override
  void build(String chatId) {
    _controller = ref.watch(chatControllerProvider(chatId));
  }
}
