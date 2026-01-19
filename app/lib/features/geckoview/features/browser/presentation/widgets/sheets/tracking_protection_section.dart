/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/tracking_protection.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/tracking_protection_provider.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Section widget displaying Enhanced Tracking Protection toggle
class TrackingProtectionSection extends HookConsumerWidget {
  final String tabId;

  const TrackingProtectionSection({required this.tabId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasExceptionAsync = ref.watch(
      hasTrackingProtectionExceptionProvider(tabId),
    );

    return hasExceptionAsync.when(
      data: (hasException) => _TrackingProtectionTile(
        tabId: tabId,
        isEnabled: !hasException, // ETP enabled when NOT in exceptions
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
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _TrackingProtectionTile extends ConsumerWidget {
  final String tabId;
  final bool isEnabled;

  const _TrackingProtectionTile({required this.tabId, required this.isEnabled});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SwitchListTile.adaptive(
      value: isEnabled,
      onChanged: (enabled) => _toggleProtection(context, ref, enabled),
      title: const Text('Enhanced Tracking Protection'),
      subtitle: Text(
        isEnabled
            ? 'Trackers on this site are being blocked'
            : 'Trackers on this site are allowed',
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
    } catch (e) {
      if (context.mounted) {
        showErrorMessage(context, 'Failed to toggle tracking protection: $e');
      }
    }
  }
}
