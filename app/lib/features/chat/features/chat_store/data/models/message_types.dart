import 'package:flutter_chat_core/flutter_chat_core.dart';

enum MessageAuthor {
  ///langchain SystemChatMessage
  system(User(id: 'system')),

  ///langchain HumanChatMessage
  human(User(id: 'human')),

  ///langchain AIChatMessage
  ai(User(id: 'ai')),

  ///langchain ToolChatMessage
  tool(User(id: 'tool')),

  ///langchain CustomChatMessage
  custom(User(id: 'custom'));

  final User user;

  const MessageAuthor(this.user);
}
