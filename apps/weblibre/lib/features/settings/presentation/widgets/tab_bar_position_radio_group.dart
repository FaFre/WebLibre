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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/tab_bar_position_setting_l10n.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The tab bar position as a radio list of every position, Automatic saying
/// what it currently resolves to. One control for the Toolbar & layout
/// editor and the onboarding's Layout step: both write through the settings
/// save controller, so in the onboarding as a settings edit of the draft, and
/// whichever was used last wins.
class TabBarPositionRadioGroup extends ConsumerWidget {
  const TabBarPositionRadioGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The raw setting drives the radio group: this control must show what
    // was *chosen*, including "decide for me". Everywhere else reads
    // displayedTabBarPositionProvider.
    final l10n = AppLocalizations.of(context);
    final tabBarPosition = ref.watch(
      storedGeneralSettingsProvider.select((s) => s.tabBarPosition),
    );
    final resolved = ref.watch(displayedTabBarPositionProvider);

    return RadioGroup(
      groupValue: tabBarPosition,
      onChanged: (TabBarPositionSetting? value) async {
        if (value != null) {
          await ref
              .read(saveGeneralSettingsControllerProvider.notifier)
              .save(
                (currentSettings) =>
                    currentSettings.copyWith.tabBarPosition(value),
              );
        }
      },
      child: Column(
        children: [
          for (final position in TabBarPositionSetting.values)
            RadioListTile.adaptive(
              value: position,
              title: Text(position.label(context)),
              // Automatic says what it currently resolves to; the fixed
              // choices already describe themselves.
              subtitle: Text(
                position == TabBarPositionSetting.auto
                    ? l10n.settings_currentlyResolvesTo(
                        position.description(context),
                        resolved.label(context),
                      )
                    : position.description(context),
              ),
            ),
        ],
      ),
    );
  }
}
