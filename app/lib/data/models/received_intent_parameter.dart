import 'package:fast_equatable/fast_equatable.dart';

class ReceivedIntentParameter with FastEquatable {
  final String? content;
  final String? tool;

  ReceivedIntentParameter(this.content, this.tool);

  @override
  List<Object?> get hashParameters => [content, tool];
}
