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
            children: const [
              _GeneralTile(),
              _BrowsingTile(),
              _ToolbarLayoutTile(),
              _WebContentTile(),
              _SearchTile(),
              _PrivacySecurityTile(),
              _ExtensionsTile(),
              _SyncTile(),
              _AdvancedTile(),
            ],
          );
        },
      ),
    );
  }
}

class _GeneralTile extends StatelessWidget {
  const _GeneralTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('General'),
        subtitle: const Text('Appearance, language, downloads'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(Icons.tune),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await GeneralSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _BrowsingTile extends StatelessWidget {
  const _BrowsingTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Browsing'),
        subtitle: const Text('Tabs, navigation, external links'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.compassOutline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await BrowsingSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _ToolbarLayoutTile extends StatelessWidget {
  const _ToolbarLayoutTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Toolbar & Layout'),
        subtitle: const Text('Tab bar, toolbar, quick switcher, tab view'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.viewDashboardOutline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await ToolbarLayoutSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _PrivacySecurityTile extends StatelessWidget {
  const _PrivacySecurityTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Privacy & Security'),
        subtitle: const Text('Tracking protection, data clearing'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.shieldLock),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await PrivacySecuritySettingsRoute().push(context);
        },
      ),
    );
  }
}

class _WebContentTile extends StatelessWidget {
  const _WebContentTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Web Content'),
        subtitle: const Text('Page display, PDF, reader mode, AI'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.fileDocumentOutline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await WebContentSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _SearchTile extends StatelessWidget {
  const _SearchTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Search'),
        subtitle: const Text('Providers, bangs, search history'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.magnify),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await SearchSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _ExtensionsTile extends StatelessWidget {
  const _ExtensionsTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Extensions'),
        subtitle: const Text('Install and manage extension sources'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.puzzleOutline),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await ExtensionsSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _SyncTile extends StatelessWidget {
  const _SyncTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Firefox Sync'),
        subtitle: const Text('Account, sync now, engine selection'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(Icons.sync),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await SyncSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _AdvancedTile extends StatelessWidget {
  const _AdvancedTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Advanced'),
        subtitle: const Text('JavaScript, user agent, debugging'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(Icons.developer_mode),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await AdvancedSettingsRoute().push(context);
        },
      ),
    );
  }
}
