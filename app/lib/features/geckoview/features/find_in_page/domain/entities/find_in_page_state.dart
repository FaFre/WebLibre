import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';

part 'find_in_page_state.g.dart';

@CopyWith()
class FindInPageState with FastEquatable {
  final bool visible;
  final String? lastSearchText;

  FindInPageState({required this.visible, required this.lastSearchText});

  FindInPageState.hidden() : visible = false, lastSearchText = null;

  @override
  List<Object?> get hashParameters => [visible, lastSearchText];
}
