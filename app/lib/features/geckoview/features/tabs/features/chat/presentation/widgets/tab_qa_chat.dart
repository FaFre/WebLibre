import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/chat/features/chat_store/data/models/message_types.dart';
import 'package:lensai/features/chat/features/chat_store/domain/providers.dart';
import 'package:lensai/features/geckoview/features/tabs/features/chat/domain/chat_backend.dart';
import 'package:lensai/features/geckoview/features/tabs/features/chat/presentation/widgets/chat_text_message.dart';
import 'package:lensai/features/geckoview/features/tabs/features/chat/presentation/widgets/qa_chat_input.dart';
import 'package:lensai/presentation/hooks/on_initialization.dart';

class TabQaChat extends HookConsumerWidget {
  final String chatId;
  final ScrollController? scrollController;

  const TabQaChat({required this.chatId, this.scrollController, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatBackend = ref.watch(chatBackendProvider(chatId).notifier);
    final chatController = ref.watch(chatControllerProvider(chatId));

    // final crossCache = useMemoized(() => CrossCache());
    final chatScrollController = scrollController ?? useScrollController();

    useOnInitialization(() async {
      await chatBackend.prepareEmbeddings();
    });

    return Chat(
      darkTheme: ChatTheme.dark(
        backgroundColor: Theme.of(context).colorScheme.surface,
        inputTheme: InputTheme(
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      ),
      theme: ChatTheme.light(
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      builders: Builders(
        textMessageBuilder:
            (context, message, index) =>
                ChatTextMessage(message: message, index: index),
        customMessageBuilder:
            (context, message, index) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF0F0F0),
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const IsTypingIndicator(),
            ),
        inputBuilder: (context) => const QaChatInput(attachmentIcon: null),
      ),
      chatController: chatController,
      // crossCache: crossCache,
      scrollController: chatScrollController,
      onMessageSend: (text) async {
        await chatBackend.processQAMessage(text);
      },
      currentUserId: MessageAuthor.human.user.id,
      resolveUser:
          (id) => Future.value(
            MessageAuthor.values
                .firstWhereOrNull((user) => user.user.id == id)
                ?.user,
          ),
    );
  }
}
