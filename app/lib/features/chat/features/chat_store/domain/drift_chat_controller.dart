import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:lensai/features/chat/features/chat_store/data/database/daos/messages.dart';
import 'package:rxdart/rxdart.dart';

class DriftChatController implements ChatController {
  final MessagesDao _dao;
  final String chatId;

  final _operationsController = StreamController<ChatOperation>.broadcast();

  late final ValueStream<List<Message>> _mergedMessagesStream;
  late final StreamSubscription<List<Message>> _mergedMessagesStreamSub;
  late final BehaviorSubject<Map<String, Message>> _intermediateMessages;

  DriftChatController(this._dao, {required this.chatId}) {
    final chatMessagesStream =
        _dao
            .chatMessages(chatId: chatId)
            .map(
              (data) => Message.fromJson(
                jsonDecode(data.messageJson) as Map<String, dynamic>,
              ),
            )
            .watch();

    _intermediateMessages = BehaviorSubject.seeded({});

    _mergedMessagesStream =
        Rx.combineLatest2(chatMessagesStream, _intermediateMessages, (a, b) {
          if (a.isNotEmpty && b.isNotEmpty) {
            return [for (final message in a) b[message.id] ?? message];
          }

          return a;
        }).shareValue();

    //Set initial messages
    unawaited(
      _mergedMessagesStream.first.then((messages) {
        if (messages.isNotEmpty) {
          _operationsController.add(ChatOperation.set());
        }
      }),
    );

    _mergedMessagesStreamSub = _mergedMessagesStream.listen(null);
  }

  @override
  List<Message> get messages => _mergedMessagesStream.valueOrNull ?? [];

  @override
  Future<void> insert(Message message, {int? index}) async {
    final insertedIndex = await _dao.insertMessage(
      chatId: chatId,
      message: message,
      index: index,
    );

    if (insertedIndex != null) {
      await _mergedMessagesStream
          .firstWhere(
            (messages) =>
                messages.length > insertedIndex &&
                messages[insertedIndex].id == message.id,
          )
          .timeout(const Duration(milliseconds: 100));

      _operationsController.add(ChatOperation.insert(message, insertedIndex));
    }
  }

  @override
  Future<void> remove(Message message) async {
    final index =
        await _dao
            .messageIndex(chatId: chatId, messageId: message.id)
            .getSingleOrNull();

    if (index != null) {
      await _dao.removeMessage(messageId: message.id);
      await _mergedMessagesStream
          .firstWhere(
            (messages) =>
                !messages.any((dbMessage) => dbMessage.id == message.id),
          )
          .timeout(const Duration(milliseconds: 100));

      _operationsController.add(ChatOperation.remove(message, index));
    }
  }

  @override
  Future<void> update(
    Message oldMessage,
    Message newMessage, {
    bool persistMessage = true,
  }) async {
    assert(oldMessage.id == newMessage.id);

    if (persistMessage) {
      final intermediateMessage = _intermediateMessages.value[newMessage.id];

      if (intermediateMessage == null && oldMessage == newMessage) {
        //nothing to update
        return;
      }

      final rows = await _dao.updateMessage(
        messageId: oldMessage.id,
        message: newMessage,
      );

      if (intermediateMessage != null) {
        _intermediateMessages.add(
          {..._intermediateMessages.value}..remove(newMessage.id),
        );
      }

      if (rows <= 0 || intermediateMessage == newMessage) {
        //Dont send event
        return;
      }
    } else if (oldMessage != newMessage) {
      _intermediateMessages.add({
        ..._intermediateMessages.value,
        newMessage.id: newMessage,
      });
    }

    await _mergedMessagesStream
        .firstWhere(
          (messages) => messages.any((message) => message == newMessage),
        )
        .timeout(const Duration(milliseconds: 100));

    _operationsController.add(ChatOperation.update(oldMessage, newMessage));
  }

  @override
  Future<void> set(List<Message> messages) async {
    await _dao.replaceChatMessages(chatId: chatId, messages: messages);
    await _mergedMessagesStream
        .firstWhere(
          (replacedMessages) =>
              const DeepCollectionEquality().equals(messages, replacedMessages),
        )
        .timeout(const Duration(milliseconds: 100));

    _operationsController.add(ChatOperation.set());
  }

  @override
  Stream<ChatOperation> get operationsStream => _operationsController.stream;

  @override
  void dispose() {
    unawaited(_intermediateMessages.close());
    unawaited(_mergedMessagesStreamSub.cancel());
    unawaited(_operationsController.close());
  }
}
