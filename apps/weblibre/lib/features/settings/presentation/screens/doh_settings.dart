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
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> dohSettingsSections(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.settings_resolverSettingsSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.settings_indexDnsOverHttpsResolverTitle,
          subtitle: l10n.settings_indexDnsOverHttpsResolverSubtitle,
          keywords: settingsKeywords(
            l10n.settings_indexDnsOverHttpsResolverKeywords,
          ),
          child: const DohSettingsContent(),
        ),
      ],
    ),
  ];
}

class DohSettingsScreen extends HookConsumerWidget {
  const DohSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_dohTitle,
      subtitle: l10n.settings_dohSubtitle,
      icon: Icons.dns_outlined,
      sections: dohSettingsSections(context),
    );
  }
}
