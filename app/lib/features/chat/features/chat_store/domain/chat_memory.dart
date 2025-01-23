// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:langchain/langchain.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/message_types.dart';

class ChatMemory implements BaseMemory {
  final ChatController _controller;

  /// Max number of tokens to use.
  final int maxTokenLimit;

  /// Language model to use for counting tokens.
  final BaseLanguageModel llm;

  /// The memory key to use for the chat history.
  /// This will be passed as input variable to the prompt.
  final String memoryKey;

  /// If true, when [loadMemoryVariables] is called, it will return
  /// [ChatMessage] objects. If false, it will return a String representation
  /// of the messages.
  ///
  /// Set this to true when you are using a Chat model like `ChatOpenAI`.
  /// Set this to false when you are use a text LLM like `OpenAI`.
  final bool returnMessages;

  /// The prefix to use for system messages if [returnMessages] is false.
  final String systemPrefix;

  /// The prefix to use for human messages if [returnMessages] is false.
  final String humanPrefix;

  /// The prefix to use for AI messages if [returnMessages] is false.
  final String aiPrefix;

  /// The prefix to use for tool messages if [returnMessages] is false.
  final String toolPrefix;

  ChatMemory(
    this._controller, {
    required this.returnMessages,
    this.maxTokenLimit = 2000,
    required this.llm,
    this.memoryKey = BaseMemory.defaultMemoryKey,
    this.systemPrefix = SystemChatMessage.defaultPrefix,
    this.humanPrefix = HumanChatMessage.defaultPrefix,
    this.aiPrefix = AIChatMessage.defaultPrefix,
    this.toolPrefix = ToolChatMessage.defaultPrefix,
  });

  @override
  Set<String> get memoryKeys => {memoryKey};

  @override
  Future<MemoryVariables> loadMemoryVariables([
    MemoryInputValues values = const {},
  ]) async {
    final messages = _controller.messages
        .whereNot(
          (message) => message.metadata?['hideFromModelChatHistory'] == true,
        )
        .map(
          (message) => switch (message) {
            TextMessage(
              authorId: final authorId,
              text: final text,
              metadata: final metadata,
            ) =>
              () {
                if (authorId == MessageAuthor.system.user.id) {
                  return SystemChatMessage(content: text);
                }
                if (authorId == MessageAuthor.human.user.id) {
                  return HumanChatMessage(
                    content: ChatMessageContent.text(text),
                  );
                }
                if (authorId == MessageAuthor.ai.user.id) {
                  final toolsRaw = metadata?['toolCalls'];
                  if (toolsRaw is String) {
                    return AIChatMessage(
                      content: text,
                      toolCalls: _deserializeToolCalls(toolsRaw),
                    );
                  }
                  return AIChatMessage(content: text);
                }
                throw UnimplementedError();
              }(),
            ImageMessage() => throw UnimplementedError(),
            CustomMessage() => throw UnimplementedError(),
            UnsupportedMessage() => throw UnimplementedError()
          },
        )
        .toList();

    int currentBufferLength = await llm.countTokens(PromptValue.chat(messages));
    // Prune buffer if it exceeds max token limit
    if (currentBufferLength > maxTokenLimit) {
      while (currentBufferLength > maxTokenLimit) {
        //remove oldest entry
        messages.removeAt(0);
        currentBufferLength = await llm.countTokens(PromptValue.chat(messages));
      }
    }

    if (returnMessages) {
      return {memoryKey: messages};
    }

    return {
      memoryKey: messages.toBufferString(
        systemPrefix: systemPrefix,
        humanPrefix: humanPrefix,
        aiPrefix: aiPrefix,
        toolPrefix: toolPrefix,
      ),
    };
  }

  List<AIChatMessageToolCall> _deserializeToolCalls(String toolsRaw) {
    final decoded = jsonDecode(toolsRaw) as List<dynamic>;
    final tools = decoded
        .map(
          (tool) => AIChatMessageToolCall(
            id: tool['id'] as String,
            name: tool['name'] as String,
            arguments: tool['arguments'] as Map<String, dynamic>,
            argumentsRaw: tool['argumentsRaw'] as String,
          ),
        )
        .toList();
    return tools;
  }

  @override
  Future<void> saveContext({
    required MemoryInputValues inputValues,
    required MemoryOutputValues outputValues,
  }) {
    throw UnimplementedError('This is a read only memory');
  }

  @override
  Future<void> clear() {
    throw UnimplementedError('This is a read only memory');
  }
}
