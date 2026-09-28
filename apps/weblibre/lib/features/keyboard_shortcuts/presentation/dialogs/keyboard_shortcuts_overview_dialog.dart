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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/keyboard_shortcuts/domain/repositories/keyboard_shortcut_settings.dart';
import 'package:weblibre/features/keyboard_shortcuts/presentation/widgets/key_chord_label.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// A read-only list of the keys that currently run browser actions, grouped by
/// category, with a way into the settings to change them.
class KeyboardShortcutsOverviewDialog extends HookConsumerWidget {
  const KeyboardShortcutsOverviewDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(keyboardShortcutSettingsRepositoryProvider);
    final bindings = ref.watch(effectiveKeyboardShortcutsProvider);

    final byCategory = <BrowserActionCategory, List<BrowserAction>>{};
    for (final action in BrowserAction.values) {
      if (bindings.containsKey(action)) {
        byCategory.putIfAbsent(action.category, () => []).add(action);
      }
    }

    void customize() {
      final router = GoRouter.of(context);
      Navigator.of(context).pop();
      unawaited(router.push(const KeyboardShortcutSettingsRoute().location));
    }

    return AlertDialog(
      title: Text(l10n.keyboardShortcuts_title),
      content: SizedBox(
        width: 520,
        child: bindings.isEmpty
            ? Text(
                settings.enabled
                    ? l10n.keyboardShortcuts_overviewNoneAssigned
                    : l10n.keyboardShortcuts_overviewDisabled,
              )
            : ListView(
                shrinkWrap: true,
                children: [
                  for (final category in BrowserActionCategory.values)
                    if (byCategory[category] case final actions?) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 4),
                        child: Text(
                          category.label(context),
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final action in actions)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: Text(action.label(context))),
                              const SizedBox(width: 12),
                              Flexible(
                                child: Wrap(
                                  alignment: WrapAlignment.end,
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final chord in bindings[action]!)
                                      KeyChordLabel(chord),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: customize,
          child: Text(l10n.keyboardShortcuts_actionCustomize),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_close),
        ),
      ],
    );
  }
}
