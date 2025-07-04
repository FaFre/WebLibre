import 'package:fast_equatable/fast_equatable.dart';

sealed class ContainerFilter with FastEquatable {}

class ContainerFilterById extends ContainerFilter {
  final String? containerId;

  ContainerFilterById({required this.containerId});

  @override
  List<Object?> get hashParameters => [containerId];
}

class ContainerFilterDisabled extends ContainerFilter {
  @override
  List<Object?> get hashParameters => [null];
}
