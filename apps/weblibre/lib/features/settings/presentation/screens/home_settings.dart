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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/home_target.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

const List<SettingsSectionDefinition> homeSettingsSections = [
  SettingsSectionDefinition(
    title: 'Startup',
    keywords: ['startup', 'home', 'resume', 'last tab', 'custom url'],
    entries: [
      SettingsEntryDefinition(
        title: 'When there is no tab to show',
        subtitle: 'On startup, and after closing the last tab',
        keywords: ['startup', 'resume', 'last tab', 'custom url', 'homepage'],
        child: _HomeTargetTile(),
      ),
      SettingsEntryDefinition(
        title: 'Apply when the last tab closes',
        subtitle: 'Otherwise a tab from another container is opened instead',
        keywords: ['close', 'last tab', 'container'],
        child: _HomeTargetOnLastTabClosedTile(),
      ),
    ],
  ),
  SettingsSectionDefinition(
    title: 'Layout',
    keywords: ['home', 'new tab', 'sections', 'modules', 'layout'],
    entries: [
      SettingsEntryDefinition(
        title: 'Search bar position',
        subtitle: 'Where the home page offers its search field',
        keywords: [
          'search',
          'bar',
          'position',
          'address',
          'url',
          'top',
          'bottom',
          'tab bar',
          'home',
        ],
        child: _HomeSearchBarPlacementTile(),
      ),
      SettingsEntryDefinition(
        title: 'Customize home sections',
        subtitle: 'Choose and order what the home page shows',
        keywords: [
          'home',
          'sections',
          'shortcuts',
          'quote',
          'quick actions',
          'reorder',
        ],
        child: _CustomizeHomeSectionsTile(),
      ),
      SettingsEntryDefinition(
        title: 'Customize new tab sections',
        subtitle: 'Choose and order what the new tab page shows',
        keywords: ['new tab', 'sections', 'shortcuts', 'reorder'],
        child: _CustomizeNewTabSectionsTile(),
      ),
    ],
  ),
];

class HomeSettingsScreen extends StatelessWidget {
  const HomeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsDetailScaffold(
      title: 'Home & New Tab',
      subtitle: 'What the home and new tab pages show',
      icon: MdiIcons.homeOutline,
      sections: homeSettingsSections,
    );
  }
}

class _HomeTargetTile extends HookConsumerWidget {
  const _HomeTargetTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);

    Future<void> save(GeneralSettings Function(GeneralSettings) update) {
      return ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save(update);
    }

    final urlController = useTextEditingController(
      text: settings.homeTargetUrl ?? '',
    );

    // Persist on focus loss as well as on submit. Settings screens have no
    // save button, so a user who types an address and taps back would
    // otherwise lose it silently.
    Future<void> saveUrlIfChanged() async {
      final text = urlController.text.trim();
      if (text == (settings.homeTargetUrl ?? '')) return;
      if (text.isNotEmpty && uri_parser.tryParseUrl(text) == null) return;

      await save((s) => s.copyWith.homeTargetUrl(text));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RadioGroup<HomeTarget>(
          groupValue: settings.homeTarget,
          onChanged: (value) async {
            if (value != null) {
              await save((s) => s.copyWith.homeTarget(value));
            }
          },
          child: Column(
            children: [
              for (final target in HomeTarget.values)
                RadioListTile<HomeTarget>(
                  value: target,
                  title: Text(target.label),
                  subtitle: Text(target.description),
                ),
            ],
          ),
        ),
        if (settings.homeTarget == HomeTarget.customUrl)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Focus(
              onFocusChange: (hasFocus) {
                if (!hasFocus) unawaited(saveUrlIfChanged());
              },
              child: TextFormField(
                controller: urlController,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'Enter an address, or the home page is shown instead';
                  }
                  if (uri_parser.tryParseUrl(text) == null) {
                    return 'Not a valid address';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => unawaited(saveUrlIfChanged()),
              ),
            ),
          ),
      ],
    );
  }
}

class _HomeTargetOnLastTabClosedTile extends ConsumerWidget {
  const _HomeTargetOnLastTabClosedTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.homeTargetOnLastTabClosed,
      ),
    );

    return SwitchListTile.adaptive(
      value: enabled,
      title: const Text('Apply when the last tab closes'),
      subtitle: const Text(
        'Closing the last tab in a container stays there instead of opening a '
        'tab from somewhere else',
      ),
      secondary: const Icon(Icons.tab_unselected),
      onChanged: (value) async {
        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((s) => s.copyWith.homeTargetOnLastTabClosed(value));
      },
    );
  }
}

/// Where the home surface's search entry sits.
///
/// A placement, not a visibility toggle: the home surface has no address field
/// of its own, so one of the two positions always holds it. There is no "off".
class _HomeSearchBarPlacementTile extends ConsumerWidget {
  const _HomeSearchBarPlacementTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final resolved = settings.effectiveHomeSearchBarPlacement();

    return RadioGroup<HomeSearchBarPlacement>(
      groupValue: settings.homeSearchBarPlacement,
      onChanged: (value) async {
        if (value == null) return;

        await ref
            .read(saveGeneralSettingsControllerProvider.notifier)
            .save((s) => s.copyWith.homeSearchBarPlacement(value));
      },
      child: Column(
        children: [
          for (final placement in HomeSearchBarPlacement.values)
            RadioListTile<HomeSearchBarPlacement>(
              value: placement,
              title: Text(placement.label),
              // Auto says what it currently resolves to; the fixed choices
              // already describe themselves.
              subtitle: Text(
                placement == HomeSearchBarPlacement.auto
                    ? 'Currently: ${resolved.label.toLowerCase()}'
                    : placement.description,
              ),
            ),
        ],
      ),
    );
  }
}

class _CustomizeHomeSectionsTile extends ConsumerWidget {
  const _CustomizeHomeSectionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.homeOutline),
      title: const Text('Customize home sections'),
      subtitle: const Text('Choose and order what the home page shows'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const HomeModulesSettingsRoute().push(context),
    );
  }
}

class _CustomizeNewTabSectionsTile extends ConsumerWidget {
  const _CustomizeNewTabSectionsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: const Icon(MdiIcons.tabPlus),
      title: const Text('Customize new tab sections'),
      subtitle: const Text('Choose and order what the new tab page shows'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => const NewTabModulesSettingsRoute().push(context),
    );
  }
}
