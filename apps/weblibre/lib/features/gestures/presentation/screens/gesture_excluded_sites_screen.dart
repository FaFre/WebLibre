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
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/string_list_settings_screen.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/host_rules.dart';

/// Manages the list of sites on which gestures are disabled.
class GestureExcludedSitesScreen extends HookConsumerWidget {
  const GestureExcludedSitesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final excludedSites = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.excludedSites),
    );

    return StringListSettingsScreen(
      title: l10n.gestures_excludedSitesTitle,
      description: l10n.gestures_excludedSitesDescription,
      values: excludedSites,
      hintText: 'example.com',
      itemIcon: Icons.public_off,
      emptyLabel: l10n.gestures_noSitesExcludedMessage,
      normalize: normalizeRuleHost,
      onChanged: (next) async {
        await ref
            .read(gestureSettingsRepositoryProvider.notifier)
            .updateSettings((current) => current.copyWith.excludedSites(next));
      },
    );
  }
}
