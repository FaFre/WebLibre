import 'package:fast_equatable/fast_equatable.dart';

sealed class ContainerFilter with FastEquatable {
  ContainerFilter();

  factory ContainerFilter.from(String? containerId) {
    return (containerId != null)
        ? ContainerFilterById(containerId: containerId)
        : ContainerFilterDisabled();
  }
}

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
