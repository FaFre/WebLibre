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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_data_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// "Site data waiting to be deleted" on the containers screen (5.5, 7.2):
/// deleted containers whose site data is not deleted yet, closed isolated
/// tabs of existing ones, and orphaned contexts, each with "Delete data". A
/// sliver; shown only while the list is not empty, and never hidden by the
/// feature policy while it has entries (P5).
class PendingSiteDataSection extends HookConsumerWidget {
  const PendingSiteDataSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSiteDataProvider).value;
    if (pending.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      sliver: SliverToBoxAdapter(
        child: Card.filled(
          margin: EdgeInsets.zero,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(MdiIcons.databaseClockOutline),
                  title: Text(
                    l10n.tabs_siteDataPendingTitle,
                    style: theme.textTheme.titleMedium,
                  ),
                  subtitle: Text(l10n.tabs_siteDataPendingExplanation),
                ),
                for (final entry in pending)
                  _PendingSiteDataTile(key: ValueKey(entry), entry: entry),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingSiteDataTile extends HookConsumerWidget {
  final PendingSiteData entry;

  const _PendingSiteDataTile({required this.entry, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final deleting = useState(false);

    Future<void> delete() async {
      deleting.value = true;
      final released = await ref
          .read(containerFreezeServiceProvider.notifier)
          .releasePendingSiteData(entry.contextIds);
      if (!context.mounted) return;
      deleting.value = false;
      if (released) {
        ui_helper.showInfoMessage(context, l10n.tabs_siteDataPendingDeleted);
      } else {
        ui_helper.showErrorMessage(context, l10n.tabs_siteDataPendingFailed);
      }
    }

    return ListTile(
      // Busy like ProfileTile: a spinner in the leading slot, which otherwise
      // keeps the title under the header's text; the count stays visible.
      leading: SizedBox.square(
        dimension: 24,
        child: deleting.value
            ? Padding(
                padding: const EdgeInsets.all(2),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  semanticsLabel: l10n.tabs_siteDataPendingDeleting,
                ),
              )
            : null,
      ),
      title: Text(switch (entry) {
        PendingSiteData(orphaned: true) => l10n.tabs_siteDataPendingOrphaned,
        PendingSiteData(ownerExists: true, :final ownerName) =>
          l10n.tabs_siteDataPendingClosedIsolatedTabs(
            containerDisplayName(l10n, ownerName),
          ),
        PendingSiteData() => l10n.tabs_siteDataPendingDeletedContainer,
      }),
      subtitle: Text(l10n.tabs_siteDataPendingCount(entry.contextIds.length)),
      trailing: TextButton(
        onPressed: deleting.value ? null : delete,
        child: Text(l10n.tabs_siteDataPendingDelete),
      ),
    );
  }
}
