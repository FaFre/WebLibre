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

import 'package:weblibre/domain/feature_policy/feature_policy.dart';

/// What the user said they want on the "Your setup" summary.
///
/// A goal never changes the preset. It is one of:
/// - the visibility switches in [switches], on exactly while they are all
///   shown in the draft, so it always agrees with the switches;
/// - with [opensAfterCommit], a setup the user asked for, opening after the
///   commit, outside an onboarding that could still be cancelled. Its
///   [switches] are what that setup needs shown: selecting it shows them,
///   but showing them (a preset, a switch) does not select it;
/// - with [turnsOnLocalAi], on-device AI turned on, not only shown.
enum SetupGoal {
  /// Shows containers. Cookie Isolation is explained when the first container
  /// is created.
  keepAccountsApart(switches: [VisibilitySwitch.containers]),

  /// Opens App Lock setup for the current profile after Done
  /// (`security.app_lock_device`).
  lockBrowser(opensAfterCommit: true),

  /// Opens the connection settings after Done, and shows Connections for
  /// them. Nothing connects: the user starts a connection there.
  setUpConnections(
    switches: [VisibilitySwitch.connections],
    opensAfterCommit: true,
  ),

  /// Turns on on-device AI (`ai.local_ai`), showing its controls. Off in
  /// every preset: wanting more controls is not asking for AI processing.
  useOnDeviceAi(switches: [VisibilitySwitch.ai], turnsOnLocalAi: true),

  /// Opens Firefox Sync sign-in after Done (`sync.firefox_sync`).
  syncDevices(opensAfterCommit: true);

  const SetupGoal({
    this.switches = const [],
    this.opensAfterCommit = false,
    this.turnsOnLocalAi = false,
  });

  final List<VisibilitySwitch> switches;
  final bool opensAfterCommit;
  final bool turnsOnLocalAi;

  /// Whether the goal is nothing but its [switches] shown: then a hidden
  /// switch is offered by the goal alone, under the goal's name. A goal that
  /// also opens a setup or turns AI on means more than showing them.
  bool get onlyShowsSwitches => !opensAfterCommit && !turnsOnLocalAi;
}
