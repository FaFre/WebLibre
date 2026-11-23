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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'tab_sleep_policy_replication.g.dart';

/// Builds native's automatic sleep policy (5.9 of the tab lock and freeze
/// plan) from the effective settings, the "Keep awake" tabs (D30) and the
/// containers that freeze automatically (phase C2), and sends it whenever one
/// of them changes. Native keeps it process-wide and evaluates it only while
/// WebLibre is in the foreground.
///
/// Activated from main.dart, at app scope, so it keeps sending while the
/// browser view is gone (the settings screen is where it changes).
@Riverpod(keepAlive: true)
Future<void> tabSleepPolicyReplication(Ref ref) async {
  final (enabled, idleMinutes, residentLimit) = ref.watch(
    generalSettingsWithDefaultsProvider.select(
      (settings) => (
        settings.autoSleepTabs,
        settings.autoSleepIdleMinutes,
        settings.residentTabLimit,
      ),
    ),
  );
  final exempt = ref
      .watch(
        watchSleepExemptTabIdsProvider.select(
          (value) => value.hasValue ? EquatableValue(value.requireValue) : null,
        ),
      )
      ?.value;
  final containers = ref.watch(containerAutoFreezeSchedulesProvider)?.value;
  // Not before the kept-awake tabs are known: an empty list would let the
  // resident limit unload one of them. Native starts with the policy off.
  if (exempt == null || containers == null) return;

  await ref
      .watch(geckoTabLifecycleServiceProvider)
      .setSleepPolicy(
        TabSleepPolicy(
          enabled: enabled,
          idleMinutes: idleMinutes,
          residentLimit: residentLimit,
          exemptTabIds: exempt.toList()..sort(),
          containers: containers,
        ),
      );
}
