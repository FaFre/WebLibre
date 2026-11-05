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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/settings/domain/providers/kept_when.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/presentation/utils/remembered_prompt_l10n.dart';

/// The section a prompt is listed under. A switch rather than a list per
/// section, so a new [RememberedPrompt] cannot be left off the screen.
String _sectionTitle(AppLocalizations l10n, RememberedPrompt prompt) {
  return switch (prompt) {
    RememberedPrompt.keepExternalTab ||
    RememberedPrompt.closeIsolatedTabs ||
    RememberedPrompt.closeAllTabs => l10n.settings_tabsSectionTitle,
    RememberedPrompt.startTor ||
    RememberedPrompt.startProxyConnection => l10n.settings_proxySectionTitle,
  };
}

/// The feature a prompt belongs to: its tile is grayed out while that feature
/// is hidden, unless an answer is remembered, which stays usable so it can be
/// undone (P5). A switch, so a new [RememberedPrompt] has to pick one.
FeatureId? _promptFeature(RememberedPrompt prompt) => switch (prompt) {
  RememberedPrompt.keepExternalTab || RememberedPrompt.closeAllTabs => null,
  RememberedPrompt.closeIsolatedTabs => FeatureId.tabsIsolatedUi,
  RememberedPrompt.startTor => FeatureId.connectionsTorBasic,
  RememberedPrompt.startProxyConnection => FeatureId.connectionsImportVpnProxy,
};

/// What keeps a prompt's tile usable while its feature is hidden: a
/// remembered answer ([_promptFeature]).
KeptWhen? _promptKeptWhen(RememberedPrompt prompt) => switch (prompt) {
  RememberedPrompt.keepExternalTab || RememberedPrompt.closeAllTabs => null,
  RememberedPrompt.closeIsolatedTabs => KeptWhen.closeIsolatedTabsRemembered,
  RememberedPrompt.startTor => KeptWhen.startTorRemembered,
  RememberedPrompt.startProxyConnection =>
    KeptWhen.startProxyConnectionRemembered,
};

List<SettingsSectionDefinition> confirmationSettingsSections(
  BuildContext context,
) {
  final l10n = AppLocalizations.of(context);

  final entriesBySection = <String, List<SettingsEntryDefinition>>{};
  for (final prompt in RememberedPrompt.values) {
    entriesBySection
        .putIfAbsent(_sectionTitle(l10n, prompt), () => [])
        .add(
          SettingsEntryDefinition(
            title: prompt.label(context),
            subtitle: prompt.description(context),
            keywords: settingsKeywords(prompt.keywords(context)),
            feature: _promptFeature(prompt),
            keptWhen: _promptKeptWhen(prompt),
            child: _RememberedPromptTile(prompt),
          ),
        );
  }

  return [
    for (final MapEntry(key: title, value: entries) in entriesBySection.entries)
      SettingsSectionDefinition(title: title, entries: entries),
  ];
}

/// The prompts that can be answered with "Don't ask again", and where they are
/// asked again.
class ConfirmationSettingsScreen extends StatelessWidget {
  const ConfirmationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingsDetailScaffold(
      title: l10n.settings_confirmationsSectionTitle,
      subtitle: l10n.settings_confirmationsSubtitle,
      icon: MdiIcons.messageQuestionOutline,
      sections: confirmationSettingsSections(context),
    );
  }
}

/// Where a [RememberedPrompt] answered with "Don't ask again" is asked again.
///
/// A confirmation is a switch that is on while it asks; turning it off
/// remembers the go-ahead, as ticking the box in its dialog would. A prompt
/// with a choice offers "Ask" beside each of its answers.
class _RememberedPromptTile extends HookConsumerWidget {
  final RememberedPrompt prompt;

  const _RememberedPromptTile(this.prompt);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remembered = ref.watch(
      storedGeneralSettingsProvider.select((s) => s.rememberedPrompts[prompt]),
    );

    Future<void> remember(Enum? answer) async {
      await ref
          .read(generalSettingsRepositoryProvider.notifier)
          .setRememberedAnswer(prompt, answer);
    }

    final icon = Icon(switch (prompt) {
      RememberedPrompt.keepExternalTab => Icons.open_in_new,
      RememberedPrompt.closeIsolatedTabs => MdiIcons.snowflake,
      RememberedPrompt.closeAllTabs => MdiIcons.closeCircle,
      RememberedPrompt.startTor => TorIcons.onionAlt,
      RememberedPrompt.startProxyConnection => Icons.route_outlined,
    });

    if (prompt.isConfirmation) {
      return SwitchListTile.adaptive(
        title: Text(prompt.label(context)),
        subtitle: Text(prompt.description(context)),
        secondary: icon,
        value: remembered == null,
        onChanged: (ask) async {
          await remember(ask ? null : PromptConfirmation.confirmed);
        },
      );
    }

    final l10n = AppLocalizations.of(context);
    final selected = prompt.answers.asNameMap()[remembered];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text(prompt.label(context)),
            subtitle: Text(prompt.description(context)),
            leading: icon,
            contentPadding: EdgeInsets.zero,
          ),
          Center(
            child: SegmentedButton<Enum?>(
              segments: [
                ButtonSegment(
                  value: null,
                  label: Text(l10n.rememberedPrompt_answerAsk),
                ),
                for (final answer in prompt.answers)
                  ButtonSegment(
                    value: answer,
                    label: Text(rememberedAnswerLabel(context, answer)),
                  ),
              ],
              selected: {selected},
              onSelectionChanged: (value) async {
                await remember(value.first);
              },
            ),
          ),
        ],
      ),
    );
  }
}
