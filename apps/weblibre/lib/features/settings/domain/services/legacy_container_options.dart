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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'legacy_container_options.g.dart';

/// Whether a profile that hid the container UI before visibility switches
/// existed would lose a container option in use by upgrading.
///
/// Such a profile inherits "hidden" for Containers while the switch is
/// unwritten. Hiding the container UI never suspended strict mode or a
/// container's own app link settings; a hidden feature's settings do not
/// apply now. Turning the switch on keeps them applying, and shows the
/// container controls again so they can be seen and hidden deliberately,
/// with the warning that lists what stops applying.
///
/// Only while the switch is unwritten: once anything writes it, it is the
/// user's choice. [LegacyContainerOptions.keepApplying] writes it either way,
/// so this runs at most once per profile.
bool shouldShowContainersForLegacyOptions(
  GeneralSettings settings,
  Iterable<ContainerMetadata> containers,
) {
  if (settings.visibilitySwitches.containsKey(VisibilitySwitch.containers)) {
    return false;
  }
  if (settings.isVisibilitySwitchShown(VisibilitySwitch.containers)) {
    return false;
  }
  return containers.any(
    (metadata) => metadata.strictMode || metadata.isolatedAppLinkSettings,
  );
}

@Riverpod(keepAlive: true)
class LegacyContainerOptions extends _$LegacyContainerOptions {
  @override
  void build() {}

  /// Applies [shouldShowContainersForLegacyOptions] to this profile, read
  /// from [stored]. Returns whether the switch turned on. Reads the
  /// containers only for a profile that could need it, and then writes the
  /// switch either way: off is the value it inherits, so nothing changes,
  /// but the next start skips the container scan.
  Future<bool> keepApplying(GeneralSettings stored) async {
    if (stored.visibilitySwitches.containsKey(VisibilitySwitch.containers) ||
        stored.isVisibilitySwitchShown(VisibilitySwitch.containers)) {
      return false;
    }

    final containers = await ref
        .read(containerRepositoryProvider.notifier)
        .getAllContainersWithCount();
    final show = shouldShowContainersForLegacyOptions(
      stored,
      containers.map((container) => container.metadata),
    );

    await ref
        .read(generalSettingsRepositoryProvider.notifier)
        .updateSettings(
          (current) =>
              // Written meanwhile (onboarding, Feature Control): theirs.
              current.visibilitySwitches.containsKey(
                VisibilitySwitch.containers,
              )
              ? current
              : current.withVisibilitySwitch(
                  VisibilitySwitch.containers,
                  enabled: show,
                ),
        );
    return show;
  }
}
