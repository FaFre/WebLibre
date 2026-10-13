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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/providers/blocked_trackers.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/tracking_protection.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/blocked_trackers_l10n.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_provider.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Section widget displaying the Enhanced Tracking Protection toggle and the
/// trackers it has blocked on this page.
class TrackingProtectionSection extends HookConsumerWidget {
  final String tabId;

  /// Called when the blocked-trackers list opens or closes, so the sheet can
  /// make room for it.
  final ValueChanged<bool>? onExpandedChanged;

  const TrackingProtectionSection({
    required this.tabId,
    this.onExpandedChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasExceptionAsync = ref.watch(
      hasTrackingProtectionExceptionProvider(tabId),
    );

    return hasExceptionAsync.when(
      data: (hasException) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TrackingProtectionTile(
            tabId: tabId,
            isEnabled: !hasException, // ETP enabled when NOT in exceptions
          ),
          // With protection off for the site nothing is blocked, which the
          // switch's subtitle already says.
          if (!hasException)
            _BlockedTrackers(
              tabId: tabId,
              onExpandedChanged: onExpandedChanged,
            ),
        ],
      ),
      loading: () => Skeletonizer(
        child: SwitchListTile.adaptive(
          value: false,
          onChanged: null,
          title: Text(BoneMock.title),
          subtitle: Text(BoneMock.subtitle),
          secondary: const Icon(Icons.shield_outlined),
        ),
      ),
      error: (error, stack) {
        final colorScheme = Theme.of(context).colorScheme;

        return ListTile(
          title: Text(
            AppLocalizations.of(context).browser_failedToLoadTrackingProtection,
          ),
          leading: Icon(Icons.error_outline, color: colorScheme.error),
        );
      },
    );
  }
}

class _TrackingProtectionTile extends ConsumerWidget {
  final String tabId;
  final bool isEnabled;

  const _TrackingProtectionTile({required this.tabId, required this.isEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return SwitchListTile.adaptive(
      value: isEnabled,
      onChanged: (enabled) => _toggleProtection(context, ref, enabled),
      title: Text(l10n.browser_enhancedTrackingProtection),
      subtitle: Text(
        isEnabled
            ? l10n.browser_trackersBeingBlocked
            : l10n.browser_trackersAllowed,
      ),
      secondary: Icon(
        isEnabled ? Icons.shield : Icons.shield_outlined,
        color: isEnabled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _toggleProtection(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    try {
      if (enabled) {
        // Remove exception to enable ETP
        await ref
            .read(trackingProtectionRepositoryProvider.notifier)
            .removeException(tabId);
      } else {
        // Add exception to disable ETP
        await ref
            .read(trackingProtectionRepositoryProvider.notifier)
            .addException(tabId);
      }

      // Reload tab to apply changes
      await ref.read(selectedTabSessionProvider).reload();
    } catch (e, s) {
      logger.e('Failed to toggle tracking protection', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(
          context,
          AppLocalizations.of(
            context,
          ).browser_failedToToggleTrackingProtection(e.toString()),
        );
      }
    }
  }
}

/// "N trackers blocked", opening into the categories and, under each, the
/// tracker hosts.
class _BlockedTrackers extends ConsumerWidget {
  final String tabId;
  final ValueChanged<bool>? onExpandedChanged;

  const _BlockedTrackers({required this.tabId, this.onExpandedChanged});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final trackersAsync = ref.watch(pageTrackersProvider(tabId));
    // The log is read again when a load starts or ends; keep showing the last
    // count meanwhile instead of flashing a placeholder.
    final trackers = trackersAsync.value;

    if (trackers == null) {
      // A suspended tab has no engine session, so there is no log to read.
      if (trackersAsync.hasError) return const SizedBox.shrink();

      return Skeletonizer(
        child: ListTile(
          leading: const Icon(Icons.block),
          title: Text(BoneMock.title),
        ),
      );
    }

    final count = trackers.blockedCount;
    if (count == 0) {
      return ListTile(
        leading: const Icon(MdiIcons.shieldOutline),
        title: Text(l10n.browser_noTrackersBlocked),
      );
    }

    return ExpansionTile(
      leading: const Icon(Icons.block),
      title: Text(l10n.browser_trackersBlockedCount(count)),
      shape: const Border(),
      collapsedShape: const Border(),
      onExpansionChanged: onExpandedChanged,
      children: [
        for (final MapEntry(key: category, value: hosts)
            in trackers.blocked.entries)
          ExpansionTile(
            leading: Icon(category.icon),
            title: Text(category.label(context)),
            subtitle: Text(l10n.browser_trackerCount(hosts.length)),
            shape: const Border(),
            collapsedShape: const Border(),
            children: [
              for (final host in hosts)
                ListTile(
                  dense: true,
                  // Lines the hosts up with their category's title.
                  contentPadding: const EdgeInsetsDirectional.only(
                    start: 72,
                    end: 16,
                  ),
                  title: Text(host),
                ),
            ],
          ),
      ],
    );
  }
}
