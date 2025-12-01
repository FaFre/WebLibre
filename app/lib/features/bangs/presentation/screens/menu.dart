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
import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';

class BangMenuScreen extends HookConsumerWidget {
  const BangMenuScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bangs')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(MdiIcons.accountAlert),
            title: const Text('Manage User Bangs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const UserBangsRoute().push(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.search),
            title: const Text('Search Bangs'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const BangSearchRoute().push(context);
            },
          ),
          ListTile(
            leading: const Icon(MdiIcons.fileTree),
            title: const Text('Browse Categories'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await const BangCategoriesRoute().push(context);
            },
          ),
        ],
      ),
    );
  }
}
