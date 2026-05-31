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
import 'package:weblibre/features/gestures/data/models/gesture_action.dart';

/// Shows a modal bottom sheet listing every [GestureAction] grouped by category,
/// each with its icon, title and description, and returns the chosen action (or
/// null if dismissed). Mirrors the icon + subtitle selection sheets used
/// elsewhere in the app (e.g. the contextual toolbar pickers).
Future<GestureAction?> showGestureActionPicker(
  BuildContext context, {
  required GestureAction selected,
}) {
  return showModalBottomSheet<GestureAction>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _GestureActionPicker(selected: selected),
  );
}

class _GestureActionPicker extends StatelessWidget {
  final GestureAction selected;

  const _GestureActionPicker({required this.selected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final byCategory = <GestureActionCategory, List<GestureAction>>{};
    for (final action in GestureAction.values) {
      byCategory.putIfAbsent(action.category, () => []).add(action);
    }

    // Cap the sheet height so the long action list scrolls inside a sheet that
    // never covers the whole screen.
    final maxHeight = MediaQuery.sizeOf(context).height * 0.8;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                'Choose action',
                style: theme.textTheme.titleLarge,
              ),
            ),
            Flexible(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  for (final category in GestureActionCategory.values)
                    if (byCategory[category] case final actions?
                        when actions.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 12, 24, 4),
                        child: Text(
                          category.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      for (final action in actions)
                        ListTile(
                          leading: Icon(action.icon),
                          title: Text(action.title),
                          subtitle: Text(action.description),
                          selected: action == selected,
                          trailing: action == selected
                              ? Icon(Icons.check, color: colorScheme.primary)
                              : null,
                          onTap: () => Navigator.of(context).pop(action),
                        ),
                    ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
