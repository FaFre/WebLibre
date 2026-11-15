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
import 'package:weblibre/features/app_update/domain/services/update_surface_policy.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_surface_policy_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/features/menu/presentation/widgets/menu_card.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The update row pinned at the top of the browser menu (8.3). Drawn outside
/// the customizable menu layout, so it can't be arranged away. It can't be
/// dismissed either: it stays until the update is installed or a newer state
/// replaces it. A one-row menu card like the sections below it: the colored
/// icon and its dot carry the signal, so it doesn't read as a switched-on
/// quick toggle.
class AppUpdateMenuRow extends HookConsumerWidget {
  const AppUpdateMenuRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surface = ref.watch(appUpdateSurfaceProvider);
    final label = surface.row.label(context);
    if (label == null) return const SizedBox.shrink();

    final colorScheme = Theme.of(context).colorScheme;
    final unreadable = surface.row == UpdateMenuRow.preferencesUnreadable;
    return buildMenuCard(
      context,
      children: [
        ListTile(
          leading: Badge(
            isLabelVisible: surface.dot,
            child: Icon(
              unreadable ? Icons.update_disabled : Icons.system_update,
              color: unreadable ? colorScheme.error : colorScheme.primary,
            ),
          ),
          title: Text(label),
          subtitle: surface.row == UpdateMenuRow.downloading
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: LinearProgressIndicator(value: surface.progress),
                )
              : null,
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            Navigator.of(context).maybePop();
            await const AppUpdateSettingsRoute().push(context);
          },
        ),
      ],
    );
  }
}

/// The dot on the browser menu button: a state waiting for the user (8.3).
class AppUpdateMenuDot extends HookConsumerWidget {
  const AppUpdateMenuDot({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dot = ref.watch(appUpdateSurfaceProvider.select((s) => s.dot));
    if (!dot) return child;
    return Semantics(
      label: AppLocalizations.of(context).appUpdate_menuDotLabel,
      child: Badge(smallSize: 8, child: child),
    );
  }
}
