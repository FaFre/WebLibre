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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/presentation/utils/component_identity_l10n.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_assessment_l10n.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// "What's new" (8.1): plain text from the signed metadata, shown as written.
/// Nothing in it is formatted or tappable; the only link is the notes URL,
/// which the codec kept only when it matches the compiled prefix.
class ReleaseNotesView extends HookWidget {
  const ReleaseNotesView({
    super.key,
    required this.assessment,
    required this.onOpenUrl,
  });

  final UpdateAssessment assessment;
  final void Function(Uri url) onOpenUrl;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final language = Localizations.localeOf(context).languageCode;
    final expandedAll = useState(false);
    final url = assessment.releaseNotesUrl;
    final blocks = [
      for (final block in assessment.releaseNotes)
        if (block.notes.summaryFor(language) case final text?)
          (block.appVersion, text),
    ];
    if (blocks.isEmpty && url == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (index, (version, text)) in blocks.indexed)
          if (index == 0 || expandedAll.value)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appUpdate_whatsNewTitle(version),
                    style: theme.textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  // Text, never Markdown: line breaks kept, nothing parsed.
                  Text(text, key: ValueKey('release-notes-$version')),
                ],
              ),
            ),
        if (blocks.length > 1)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextButton(
                onPressed: () => expandedAll.value = !expandedAll.value,
                child: Text(
                  expandedAll.value
                      ? l10n.common_showLess
                      : l10n.appUpdate_whatsNewTitle(blocks[1].$1),
                ),
              ),
            ),
          ),
        if (url != null)
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text(l10n.appUpdate_fullReleaseNotes),
            onTap: () => onOpenUrl(url),
          ),
      ],
    );
  }
}

/// "What changes": installed against offered, per component (4.3). Component
/// names are product names and stay untranslated.
class ComponentChangesList extends StatelessWidget {
  const ComponentChangesList({super.key, required this.changes});

  /// Null: "Details for this version aren't available".
  final List<ComponentChange>? changes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final list = changes;
    if (list == null) {
      return ListTile(
        leading: const Icon(Icons.info_outline),
        title: Text(l10n.appUpdate_detailsUnavailable),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            l10n.appUpdate_whatChangesTitle,
            style: theme.textTheme.titleSmall,
          ),
        ),
        for (final change in list)
          ListTile(
            dense: true,
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
                  ComponentChangeKind.upgraded => theme.colorScheme.primary,
                  ComponentChangeKind.downgraded => theme.colorScheme.error,
                  _ => theme.colorScheme.onSurfaceVariant,
                },
              ),
            ),
          ),
      ],
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
