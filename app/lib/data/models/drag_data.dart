import 'package:fast_equatable/fast_equatable.dart';

sealed class DropTargetData with FastEquatable {}

final class ContainerDropData extends DropTargetData {
  final String tabId;

  ContainerDropData(this.tabId);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [tabId];
}

final class DeleteDropData extends DropTargetData {
  final String tabId;

  DeleteDropData(this.tabId);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [tabId];
}

sealed class DragTargetData with FastEquatable {}

final class TabDragData extends DragTargetData {
  final String tabId;

  TabDragData(this.tabId);

  @override
  bool get cacheHash => true;

  @override
  List<Object?> get hashParameters => [tabId];
}
