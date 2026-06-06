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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers/desktop_mode.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/utils/host_rules.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Section widget toggling whether the current site should always load in
/// desktop mode. Adds/removes the current host from the persisted rule list and
/// immediately reflects the change on the current tab.
class DesktopModeSection extends HookConsumerWidget {
  final String tabId;
  final Uri url;

  const DesktopModeSection({required this.tabId, required this.url, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final desktopModeSites = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.desktopModeSites),
    );

    final host = normalizeRuleHost(url.toString());
    final isRuled = hostMatchesRule(url, desktopModeSites);
    // A broader entry (e.g. `example.com` while on `m.example.com`) governs this
    // page; a per-site toggle for the exact host can't override it.
    final parentRule = coveringParentRule(url, desktopModeSites);

    return SwitchListTile.adaptive(
      value: isRuled,
      // Disabled when no valid host, or when a broader rule governs the page
      // (which the exact-host toggle could not override).
      onChanged: (host != null && parentRule == null)
          ? (enabled) => _toggleRule(context, ref, host, enabled)
          : null,
      title: const Text('Always use desktop site'),
      subtitle: Text(
        host == null
            ? 'Unavailable on this page'
            : parentRule != null
            ? 'Set by a rule for $parentRule'
            : isRuled
            ? 'This site always loads in desktop mode'
            : 'This site follows the default mode',
      ),
      secondary: Icon(
        MdiIcons.monitor,
        color: isRuled
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Future<void> _toggleRule(
    BuildContext context,
    WidgetRef ref,
    String host,
    bool enabled,
  ) async {
    try {
      await ref.read(generalSettingsRepositoryProvider.notifier).updateSettings(
        (current) {
          final next = current.desktopModeSites.toList();
          if (enabled) {
            if (!next.contains(host)) next.add(host);
          } else {
            next.remove(host);
          }
          return current.copyWith.desktopModeSites(next);
        },
      );

      // Adding/removing a rule does not change the tab's host, so the
      // host-change listener in DesktopMode won't fire. Apply the resolved
      // state to the current tab directly: a new rule forces desktop on, while
      // removing it reverts to the browser-wide default.
      final globalDesktopMode = ref
          .read(generalSettingsWithDefaultsProvider)
          .globalDesktopMode;
      ref
          .read(desktopModeProvider(tabId).notifier)
          .enabled(enabled || globalDesktopMode);
    } catch (e, s) {
      logger.e('Failed to toggle desktop mode rule', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(context, 'Failed to toggle desktop mode: $e');
      }
    }
  }
}
