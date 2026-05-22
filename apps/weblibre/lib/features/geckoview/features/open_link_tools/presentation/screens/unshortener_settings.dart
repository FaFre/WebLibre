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

const List<SettingsSectionDefinition> unshortenerSettingsSections = [
  SettingsSectionDefinition(
    title: 'Overview',
    entries: [
      SettingsEntryDefinition(
        title: 'Description',
        subtitle: 'Resolve shortened URLs using the unshorten.me service',
        keywords: ['short links', 'redirects'],
        child: _UnshortenerDescriptionTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Behavior',
    entries: [
      SettingsEntryDefinition(
        title: 'Enable Unshortener',
        subtitle: 'Resolve shortened URLs to their destination',
        keywords: ['short links'],
        child: _UnshortenerEnabledTile(),
      ),
      SettingsEntryDefinition(
        title: 'API Token',
        subtitle: 'Optional token for higher request limits',
        keywords: ['token'],
        child: _UnshortenerTokenField(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Attribution',
    entries: [
      SettingsEntryDefinition(
        title: 'Service attribution',
        subtitle: 'Rate limits, service homepage, and privacy policy',
        keywords: ['privacy policy', 'rate limit'],
        child: _UnshortenerAttributionTile(),
      ),
    ],
  ),
];

class UnshortenerSettingsScreen extends StatelessWidget {
  const UnshortenerSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Unshortener',
      subtitle:
          'Short-link resolution behavior, token configuration, and attribution.',
      icon: MdiIcons.linkVariant,
      sections: unshortenerSettingsSections,
    );
  }
}

class _UnshortenerEnabledTile extends HookConsumerWidget {
  const _UnshortenerEnabledTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.unshortenerEnabled),
    );

    return SwitchListTile.adaptive(
      title: const Text('Enable Unshortener'),
      subtitle: const Text('Resolve shortened URLs to their destination'),
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
    return const ListTile(
      leading: Icon(MdiIcons.linkVariant),
      title: Text('Description'),
      subtitle: Text(
        'This module will unshort links by sending them to unshorten.me, '
        'which evaluates them on their servers and saves the redirection for future requests. '
        'Avoid unshortening links with private or sensitive data.',
      ),
    );
  }
}

class _UnshortenerAttributionTile extends StatelessWidget {
  const _UnshortenerAttributionTile();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(MdiIcons.informationOutline),
      title: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The free API is rate limited to 10 requests per hour for new checks.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const _AttributionLinkRow(
              label: 'Service',
              url: 'https://unshorten.me/',
            ),
            const SizedBox(height: 8),
            const _AttributionLinkRow(
              label: 'Privacy policy',
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
        decoration: const InputDecoration(
          labelText: 'API Token',
          hintText: 'Optional token for higher limits',
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
