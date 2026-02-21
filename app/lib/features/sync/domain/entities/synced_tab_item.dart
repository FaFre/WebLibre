import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

class SyncedTabItem with FastEquatable {
  final String deviceId;
  final String deviceName;
  final SyncRemoteTab tab;

  SyncedTabItem({
    required this.deviceId,
    required this.deviceName,
    required this.tab,
  });

  @override
  List<Object?> get hashParameters => [deviceId, deviceName, tab];
}
