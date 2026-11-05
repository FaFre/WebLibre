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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/hidden_settings.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';

part 'feature_control_inputs.g.dart';

/// What Feature Control decides a change with: the stored settings, to tell
/// which changed settings stop or start applying, and what the user has set
/// up behind a switch. In the onboarding the stored settings are the
/// draft's.
typedef FeatureControlInputs = ({
  SettingsSnapshot stored,
  bool connectionsInUse,
  bool hasContainers,
});

/// [FeatureControlInputs], for every screen that shows the visibility
/// switches (Settings > Feature Control, the onboarding's "Show or hide
/// features"). Watched before anything is tapped, so a change is decided
/// with loaded values.
@Riverpod()
FeatureControlInputs featureControlInputs(Ref ref) {
  final stored = ref.watch(storedSettingsSnapshotProvider);
  final connectionsInUse = ref.watch(connectionsInUseProvider);
  final hasContainers = ref.watch(
    watchContainersProvider.select((value) => value.value?.isNotEmpty ?? false),
  );
  return (
    stored: stored,
    connectionsInUse: connectionsInUse,
    hasContainers: hasContainers,
  );
}
