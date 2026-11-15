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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/presentation/utils/component_identity_l10n.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_assessment_l10n.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// "What's new" (8.1) as a settings section: plain text from the signed
/// metadata, shown as written. Nothing in it is formatted or tappable; the
/// only link is the notes URL, which the codec kept only when it matches the
/// compiled prefix. Each earlier version between the installed and the
/// offered one folds out from a row of its own. Null when there is nothing to
/// show.
SettingsSectionDefinition? releaseNotesSection(
  BuildContext context, {
  required UpdateAssessment assessment,
  required void Function(Uri url) onOpenUrl,
}) {
  final l10n = AppLocalizations.of(context);
  final language = Localizations.localeOf(context).languageCode;
  final url = assessment.releaseNotesUrl;
  final blocks = [
    for (final block in assessment.releaseNotes)
      if (block.notes.summaryFor(language) case final text?)
        (block.appVersion, text),
  ];
  if (blocks.isEmpty && url == null) return null;

  return SettingsSectionDefinition(
    title: switch (blocks.firstOrNull) {
      (final version, _) => l10n.appUpdate_whatsNewTitle(version),
      null => l10n.appUpdate_whatsNewSectionTitle,
    },
    entries: [
      for (final (index, (version, text)) in blocks.indexed)
        SettingsEntryDefinition(
          title: l10n.appUpdate_whatsNewTitle(version),
          child: index == 0
              ? _ReleaseNotesText(version: version, text: text)
              : _EarlierReleaseNotesTile(version: version, text: text),
        ),
      if (url != null)
        SettingsEntryDefinition(
          title: l10n.appUpdate_fullReleaseNotes,
          child: ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text(l10n.appUpdate_fullReleaseNotes),
            onTap: () => onOpenUrl(url),
          ),
        ),
    ],
  );
}

class _ReleaseNotesText extends StatelessWidget {
  const _ReleaseNotesText({required this.version, required this.text});

  final String version;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        // Text, never Markdown: line breaks kept, nothing parsed.
        child: Text(text, key: ValueKey('release-notes-$version')),
      ),
    );
  }
}

class _EarlierReleaseNotesTile extends StatelessWidget {
  const _EarlierReleaseNotesTile({required this.version, required this.text});

  final String version;
  final String text;

  @override
  Widget build(BuildContext context) {
    // The section card draws the dividers; the tile's own would double them.
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        leading: const Icon(Icons.history),
        title: Text(
          AppLocalizations.of(context).appUpdate_whatsNewTitle(version),
        ),
        expandedAlignment: AlignmentDirectional.centerStart,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [Text(text, key: ValueKey('release-notes-$version'))],
      ),
    );
  }
}

/// "What changes": installed against offered, per component (4.3), as a
/// settings section. Component names are product names and stay untranslated.
/// Null [changes]: "Details for this version aren't available".
SettingsSectionDefinition componentChangesSection(
  BuildContext context, {
  required List<ComponentChange>? changes,
}) {
  final l10n = AppLocalizations.of(context);
  final list = changes;

  return SettingsSectionDefinition(
    title: l10n.appUpdate_whatChangesTitle,
    entries: list == null
        ? [
            SettingsEntryDefinition(
              title: l10n.appUpdate_detailsUnavailable,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l10n.appUpdate_detailsUnavailable),
              ),
            ),
          ]
        : [
            for (final change in list)
              SettingsEntryDefinition(
                title: change.id.productName,
                child: _ComponentChangeTile(change: change),
              ),
          ],
  );
}

class _ComponentChangeTile extends StatelessWidget {
  const _ComponentChangeTile({required this.change});

  final ComponentChange change;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      title: Text(change.id.productName),
      subtitle: Text(
        change.kind == ComponentChangeKind.unchanged
            ? change.installed.label(context)
            : l10n.appUpdate_componentChange(
                change.installed.label(context),
                change.target.label(context),
              ),
      ),
      trailing: Text(
        change.kind.label(context),
        style: TextStyle(
          color: switch (change.kind) {
            ComponentChangeKind.upgraded => colorScheme.primary,
            ComponentChangeKind.downgraded => colorScheme.error,
            _ => colorScheme.onSurfaceVariant,
          },
        ),
      ),
    );
  }
}

/// Opens release notes in a new regular tab and goes to the browser.
Future<void> openReleaseNotes(
  BuildContext context,
  WidgetRef ref,
  Uri url,
) async {
  await ref
      .read(tabRepositoryProvider.notifier)
      .addTab(url: url, tabMode: TabMode.regular, selectTab: true);
  if (context.mounted) const BrowserRoute().go(context);
}
