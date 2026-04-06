/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

part 'sync_repository_state.g.dart';

enum SyncEvent { started, completed, error }

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
  List<Object?> get hashParameters => [
    account,
    remoteTabs,
    devices,
    deviceName,
    lastSyncEvent,
    lastSyncError,
  ];
}
