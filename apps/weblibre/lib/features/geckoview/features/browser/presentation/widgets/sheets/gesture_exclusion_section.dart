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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/utils/host_rules.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Section widget toggling whether touch gestures are enabled on the current
/// site. Mirrors the excluded-sites list managed in settings, but scoped to the
/// page currently shown in the sheet.
class GestureExclusionSection extends HookConsumerWidget {
  final Uri url;

  const GestureExclusionSection({required this.url, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final masterEnabled = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.enabled),
    );
    final excludedSites = ref.watch(
      gestureSettingsWithDefaultsProvider.select((s) => s.excludedSites),
    );

    final host = normalizeRuleHost(url.toString());
    final isExcluded = hostMatchesRule(url, excludedSites);
    // A broader entry (e.g. `example.com` while on `m.example.com`) governs this
    // page; a per-site toggle for the exact host can't override it.
    final parentRule = coveringParentRule(url, excludedSites);
    // Enabled on this site when gestures are globally on, the host is valid,
    // and the host is not in the exclusion list.
    final isEnabledHere = masterEnabled && host != null && !isExcluded;

    final String subtitle;
    if (!masterEnabled) {
      subtitle = 'Gestures are turned off globally';
    } else if (host == null) {
      subtitle = 'Gestures are unavailable on this page';
    } else if (parentRule != null) {
      subtitle = 'Disabled by a rule for $parentRule';
    } else if (isExcluded) {
      subtitle = 'Gestures are disabled on this site';
    } else {
      subtitle = 'Gestures are enabled on this site';
    }

    return SwitchListTile.adaptive(
      value: isEnabledHere,
      // Only actionable when gestures are globally enabled, we have a valid host
      // to add to / remove from the exclusion list, and no broader rule governs
      // the page (which the exact-host toggle could not override).
      onChanged: (masterEnabled && host != null && parentRule == null)
          ? (enabled) => _toggleExclusion(context, ref, host, enabled)
          : null,
      title: const Text('Gestures'),
      subtitle: Text(subtitle),
      secondary: Icon(
        isEnabledHere ? Icons.gesture : Icons.do_not_touch_outlined,
        color: isEnabledHere
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _toggleExclusion(
    BuildContext context,
    WidgetRef ref,
    String host,
    bool enabled,
  ) async {
    try {
      await ref.read(gestureSettingsRepositoryProvider.notifier).updateSettings(
        (current) {
          final next = current.excludedSites.toList();
          if (enabled) {
            // Enabling gestures here => remove the host from the exclusion list.
            next.remove(host);
          } else if (!next.contains(host)) {
            // Disabling gestures here => add the host to the exclusion list.
            next.add(host);
          }
          return current.copyWith.excludedSites(next);
        },
      );
    } catch (e, s) {
      logger.e('Failed to toggle gesture exclusion', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(context, 'Failed to toggle gestures: $e');
      }
    }
  }
}
