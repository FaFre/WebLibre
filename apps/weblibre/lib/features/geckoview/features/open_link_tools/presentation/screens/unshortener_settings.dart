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
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/extensions/uri.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/presentation/utils/open_in_custom_tab.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

List<SettingsSectionDefinition> unshortenerSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  return [
    SettingsSectionDefinition(
      title: l10n.openLinkTools_unshortenerOverviewSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_indexUnshortenerDescriptionTitle,
          subtitle: l10n.openLinkTools_indexUnshortenerDescriptionSubtitle,
          keywords: settingsKeywords(
            l10n.openLinkTools_indexUnshortenerDescriptionKeywords,
          ),
          child: const _UnshortenerDescriptionTile(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.openLinkTools_unshortenerBehaviorSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_unshortenerEnabledTitle,
          subtitle: l10n.openLinkTools_unshortenerEnabledSubtitle,
          keywords: settingsKeywords(
            l10n.openLinkTools_unshortenerEnabledKeywords,
          ),
          child: const _UnshortenerEnabledTile(),
        ),
        SettingsEntryDefinition(
          title: l10n.openLinkTools_apiTokenLabel,
          subtitle: l10n.openLinkTools_indexUnshortenerApiTokenSubtitle,
          keywords: settingsKeywords(l10n.openLinkTools_apiTokenLabelKeywords),
          child: const _UnshortenerTokenField(),
        ),
      ],
    ),
    SettingsSectionDefinition(
      title: l10n.openLinkTools_unshortenerAttributionSectionTitle,
      entries: [
        SettingsEntryDefinition(
          title: l10n.openLinkTools_indexUnshortenerAttributionTitle,
          subtitle: l10n.openLinkTools_indexUnshortenerAttributionSubtitle,
          keywords: settingsKeywords(
            l10n.openLinkTools_indexUnshortenerAttributionKeywords,
          ),
          child: const _UnshortenerAttributionTile(),
        ),
      ],
    ),
  ];
}

class UnshortenerSettingsScreen extends StatelessWidget {
  const UnshortenerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.openLinkTools_unshortenerSettingsTitle,
      subtitle: l10n.openLinkTools_unshortenerSettingsSubtitle,
      icon: MdiIcons.linkVariant,
      sections: unshortenerSettingsSections(context),
    );
  }
}

class _UnshortenerEnabledTile extends HookConsumerWidget {
  const _UnshortenerEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.unshortenerEnabled),
    );

    return SwitchListTile.adaptive(
      title: Text(l10n.openLinkTools_unshortenerEnabledTitle),
      subtitle: Text(l10n.openLinkTools_unshortenerEnabledSubtitle),
      secondary: const Icon(MdiIcons.linkVariant),
      value: enabled,
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((current) => current.copyWith(unshortenerEnabled: value));
      },
    );
  }
}

class _UnshortenerDescriptionTile extends StatelessWidget {
  const _UnshortenerDescriptionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.linkVariant),
      title: Text(l10n.openLinkTools_descriptionLabel),
      subtitle: Text(l10n.openLinkTools_unshortenerDescriptionBody),
    );
  }
}

class _UnshortenerAttributionTile extends StatelessWidget {
  const _UnshortenerAttributionTile();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(MdiIcons.informationOutline),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.openLinkTools_unshortenerRateLimitNotice,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _AttributionLinkRow(
              label: l10n.openLinkTools_attributionServiceLabel,
              url: 'https://unshorten.me/',
            ),
            const SizedBox(height: 8),
            _AttributionLinkRow(
              label: l10n.openLinkTools_attributionPrivacyPolicyLabel,
              url: 'https://unshorten.me/privacy-policy',
            ),
          ],
        ),
      ),
    );
  }
}

class _UnshortenerTokenField extends HookConsumerWidget {
  const _UnshortenerTokenField();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final token = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.unshortenerToken),
    );
    final controller = useTextEditingController(text: token);
    final focusNode = useFocusNode();

    Future<void> saveToken() async {
      final value = controller.text;
      if (value == token) return;
      await ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((current) => current.copyWith(unshortenerToken: value));
    }

    useOnListenableChange(focusNode, () {
      if (!focusNode.hasFocus) unawaited(saveToken());
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: InputDecoration(
          labelText: l10n.openLinkTools_apiTokenLabel,
          hintText: l10n.openLinkTools_apiTokenHint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        obscureText: true,
        onSubmitted: (_) => saveToken(),
      ),
    );
  }
}

class _AttributionLinkRow extends StatelessWidget {
  final String label;
  final String url;

  const _AttributionLinkRow({required this.label, required this.url});

  @override
  Widget build(BuildContext context) {
    final linkStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Theme.of(context).colorScheme.primary,
      decoration: TextDecoration.underline,
      decorationColor: Theme.of(context).colorScheme.primary,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () {
        unawaited(openInPrivateCustomTab(context, url));
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 96,
              child: Text(label, style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(child: Text(url.uriDisplayString, style: linkStyle)),
            const SizedBox(width: 8),
            Icon(
              Icons.open_in_new,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}
