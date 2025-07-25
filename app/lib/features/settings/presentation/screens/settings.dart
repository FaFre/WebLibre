/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: FadingScroll(
        fadingSize: 25,
        builder: (context, controller) {
          return ListView(
            controller: controller,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            children: [
              Card(
                color: Theme.of(context).highlightColor,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: const Text('General'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  leading: const Icon(Icons.settings),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await GeneralSettingsRoute().push(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).highlightColor,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: const Text('Web Engine'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  leading: const Icon(MdiIcons.web),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await WebEngineSettingsRoute().push(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).highlightColor,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: const Text('Bangs'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  leading: const Icon(MdiIcons.exclamationThick),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await BangSettingsRoute().push(context);
                  },
                ),
              ),
              const SizedBox(height: 8),
              Card(
                color: Theme.of(context).highlightColor,
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  title: const Text('Developer'),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 8.0,
                    horizontal: 16.0,
                  ),
                  leading: const Icon(Icons.developer_mode),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await DeveloperSettingsRoute().push(context);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
