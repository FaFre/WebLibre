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
 * but WITHOUT ANY WARRANTY; without even the the implied warranty of
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
              _AppearanceDisplayTile(),
              _PrivacySecurityTile(),
              _SearchContentTile(),
              _TabsBehaviorTile(),
              _FingerprintingTile(),
              _AdvancedTile(),
            ],
          );
        },
      ),
    );
  }
}

class _AppearanceDisplayTile extends StatelessWidget {
  const _AppearanceDisplayTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).highlightColor,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Appearance & Display'),
        subtitle: const Text('Theme, tabs, toolbars, gestures'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(Icons.palette),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await AppearanceDisplaySettingsRoute().push(context);
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
      color: Theme.of(context).highlightColor,
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

class _SearchContentTile extends StatelessWidget {
  const _SearchContentTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).highlightColor,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Search & Content'),
        subtitle: const Text('Search providers, reader mode, AI'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.magnify),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await SearchContentSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _TabsBehaviorTile extends StatelessWidget {
  const _TabsBehaviorTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).highlightColor,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Tabs & Behavior'),
        subtitle: const Text('New tab defaults, link handling'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.tab),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await TabsBehaviorSettingsRoute().push(context);
        },
      ),
    );
  }
}

class _FingerprintingTile extends StatelessWidget {
  const _FingerprintingTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).highlightColor,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: const Text('Fingerprinting'),
        subtitle: const Text('Language, fingerprint protection'),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 8.0,
          horizontal: 16.0,
        ),
        leading: const Icon(MdiIcons.fingerprint),
        trailing: const Icon(Icons.chevron_right),
        onTap: () async {
          await FingerprintingSettingsRoute().push(context);
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
      color: Theme.of(context).highlightColor,
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
