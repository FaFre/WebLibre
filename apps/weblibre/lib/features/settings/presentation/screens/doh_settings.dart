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
import 'package:weblibre/features/settings/presentation/widgets/doh_settings_content.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

const List<SettingsSectionDefinition> dohSettingsSections = [
  SettingsSectionDefinition(
    title: 'Resolver Settings',
    entries: [
      SettingsEntryDefinition(
        title: 'DNS over HTTPS',
        subtitle: 'Protection level, provider choice, and custom resolver URL',
        keywords: ['doh', 'resolver', 'dns provider'],
        child: DohSettingsContent(),
      ),
    ],
  ),
];

class DohSettingsScreen extends HookConsumerWidget {
  const DohSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const SettingsDetailScaffold(
      title: 'DNS over HTTPS',
      subtitle: 'Encrypted DNS protection level and resolver selection.',
      icon: Icons.dns_outlined,
      sections: dohSettingsSections,
    );
  }
}
