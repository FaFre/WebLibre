import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

part 'sync_repository_state.g.dart';

enum SyncEvent {
  started,
  completed,
  error;
}

@CopyWith()
class SyncRepositoryState with FastEquatable {
  final SyncAccountInfo account;
  final List<SyncDeviceTabs> remoteTabs;
  final List<SyncDevice> devices;
  final String? deviceName;
  final SyncEvent? lastSyncEvent;
  final String? lastSyncError;

  SyncRepositoryState({
    required this.account,
    this.remoteTabs = const <SyncDeviceTabs>[],
    this.devices = const <SyncDevice>[],
    this.deviceName,
    this.lastSyncEvent,
    this.lastSyncError,
  });

  @override
  List<Object?> get hashParameters =>
      [account, remoteTabs, devices, deviceName, lastSyncEvent, lastSyncError];
}
