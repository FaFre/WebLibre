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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_surface_policy_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Settings → General → Updates → App updates. Its section is only built
/// while [appUpdaterAvailableProvider] holds.
class AppUpdatesSettingsTile extends HookConsumerWidget {
  const AppUpdatesSettingsTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Not progress: the tile doesn't draw it, and it ticks during a download.
    final row = ref.watch(appUpdateSurfaceProvider.select((s) => s.row));
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: Badge(
        isLabelVisible: row.dot,
        child: const Icon(Icons.system_update),
      ),
      title: Text(l10n.appUpdate_appUpdates),
      subtitle: Text(row.label(context) ?? l10n.appUpdate_settingsTileSubtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const AppUpdateSettingsRoute().push(context),
    );
  }
}
