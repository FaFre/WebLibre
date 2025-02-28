import 'package:fast_equatable/fast_equatable.dart';

sealed class Sheet with FastEquatable {}

final class ViewTabsSheet extends Sheet {
  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [null];
}

final class TabQaChatSheet extends Sheet {
  final String chatId;

  TabQaChatSheet({required this.chatId});

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [chatId];
}
