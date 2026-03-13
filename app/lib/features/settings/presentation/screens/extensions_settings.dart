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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/install_local_addon_dialog.dart';
import 'package:weblibre/features/settings/presentation/widgets/custom_list_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';

class ExtensionsSettingsScreen extends StatelessWidget {
  const ExtensionsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extensions')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                SettingSection(name: 'Extensions'),
                _InstallLocalAddonTile(),
                _AddonCollectionTile(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InstallLocalAddonTile extends StatelessWidget {
  const _InstallLocalAddonTile();

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      title: 'Install from File',
      subtitle: 'Install an extension from a local .xpi file',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          MdiIcons.puzzle,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await showInstallLocalAddonDialog(context);
        },
        icon: const Icon(Icons.file_open),
        label: const Text('Install'),
      ),
    );
  }
}

class _AddonCollectionTile extends StatelessWidget {
  const _AddonCollectionTile();

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      title: 'Custom Collection',
      subtitle: 'Use a custom Mozilla addon collection',
      prefix: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: Icon(
          MdiIcons.folderMultiple,
          size: 24,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
      suffix: FilledButton.icon(
        onPressed: () async {
          await AddonCollectionRoute().push(context);
        },
        icon: const Icon(Icons.settings),
        label: const Text('Configure'),
      ),
    );
  }
}
