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
import 'package:weblibre/features/settings/presentation/widgets/sections.dart';

class FingerprintingSettingsScreen extends StatelessWidget {
  const FingerprintingSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fingerprinting')),
      body: SafeArea(
        child: FadingScroll(
          fadingSize: 25,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              children: const [
                _MainProtectionSection(),
                _IdentitySection(),
                _AdvancedSection(),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MainProtectionSection extends StatelessWidget {
  const _MainProtectionSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Main Protection'),
        _FingerprintProtectionTile(),
      ],
    );
  }
}

class _IdentitySection extends StatelessWidget {
  const _IdentitySection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Identity'),
        _BrowserLanguagesTile(),
      ],
    );
  }
}

class _AdvancedSection extends StatelessWidget {
  const _AdvancedSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SettingSection(name: 'Advanced'),
        _ResistFingerprintingTile(),
      ],
    );
  }
}

class _BrowserLanguagesTile extends StatelessWidget {
  const _BrowserLanguagesTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Browser Languages'),
      subtitle: const Text('Configure language preferences'),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.translate),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await LocaleSettingsRoute().push(context);
      },
    );
  }
}

class _FingerprintProtectionTile extends StatelessWidget {
  const _FingerprintProtectionTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Fingerprint Protection'),
      subtitle: const Text('Granular control over browser fingerprinting'),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.fingerprint),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await FingerprintSettingsRoute().push(context);
      },
    );
  }
}

class _ResistFingerprintingTile extends StatelessWidget {
  const _ResistFingerprintingTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Resist Fingerprinting'),
      subtitle: const Text('Advanced fingerprinting protection hardening'),
      contentPadding: const EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      leading: const Icon(MdiIcons.shieldLock),
      trailing: const Icon(Icons.chevron_right),
      onTap: () async {
        await const WebEngineHardeningGroupRoute(
          group: 'Resist Fingerprinting',
        ).push(context);
      },
    );
  }
}
