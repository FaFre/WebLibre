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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/contextmenu/extensions/hit_result.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/ui_helper.dart';

class OpenInNewTab extends HookConsumerWidget {
  final HitResult hitResult;

  const OpenInNewTab({super.key, required this.hitResult});

  static bool isSupported(HitResult hitResult) {
    return hitResult.isHttpLink();
  }

  Future<void> _openInNewTab(
    BuildContext context,
    WidgetRef ref,
    TabMode tabMode,
  ) async {
    final currentTab = ref.read(selectedTabStateProvider);

    final tabId = await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(
          url: hitResult.tryGetLink(),
          parentId: currentTab?.id,
          selectTab: false,
          tabMode: tabMode,
        );

    if (context.mounted) {
      //save reference before pop `ref` gets disposed
      final repo = ref.read(tabRepositoryProvider.notifier);

      showTabSwitchMessage(
        context,
        onSwitch: () async {
          await repo.selectTab(tabId);
        },
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final currentTab = ref.watch(selectedTabStateProvider);

    final currentTabMode =
        currentTab?.tabMode ??
        TabMode.fromTabType(settings.effectiveDefaultCreateTabType);

    // Alternative tab types the user can explicitly choose, excluding the type
    // that the main tile action already opens (the current tab's type).
    final alternativeTypes =
        <TabType>[
          TabType.regular,
          TabType.private,
          if (settings.showIsolatedTabUi) TabType.isolated,
        ]..remove(currentTabMode.toTabType());

    return ListTile(
      leading: const Icon(MdiIcons.tabPlus),
      title: const Text('Open in new tab'),
      trailing: alternativeTypes.isEmpty
          ? null
          : MenuAnchor(
              menuChildren: [
                for (final type in alternativeTypes)
                  MenuItemButton(
                    onPressed: () =>
                        _openInNewTab(context, ref, TabMode.fromTabType(type)),
                    leadingIcon: Icon(
                      _iconFor(type),
                      color: _colorFor(context, type),
                    ),
                    child: Text(_labelFor(type)),
                  ),
              ],
              builder: (context, controller, child) => IconButton(
                icon: const Icon(Icons.expand_more),
                tooltip: 'Open in a different tab type',
                onPressed: () =>
                    controller.isOpen ? controller.close() : controller.open(),
              ),
            ),
      onTap: () => _openInNewTab(context, ref, currentTabMode),
    );
  }
}

IconData _iconFor(TabType type) => switch (type) {
  TabType.private => MdiIcons.dominoMask,
  TabType.isolated => MdiIcons.snowflake,
  _ => MdiIcons.tab,
};

Color? _colorFor(BuildContext context, TabType type) => switch (type) {
  TabType.private => AppColors.of(context).privateTabPurple,
  TabType.isolated => AppColors.of(context).isolatedTabTeal,
  _ => null,
};

String _labelFor(TabType type) => switch (type) {
  TabType.private => 'New private tab',
  TabType.isolated => 'New isolated tab',
  _ => 'New regular tab',
};
