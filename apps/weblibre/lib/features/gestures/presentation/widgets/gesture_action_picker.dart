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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// Shows a modal bottom sheet listing every [BrowserAction] grouped by category,
/// each with its icon, title and description, and returns the chosen action (or
/// null if dismissed). Mirrors the icon + subtitle selection sheets used
/// elsewhere in the app (e.g. the contextual toolbar pickers).
Future<BrowserAction?> showGestureActionPicker(
  BuildContext context, {
  required BrowserAction selected,
}) async {
  final picked = await _showPicker(context, selected: selected);
  return picked?.action;
}

/// An entry listed above every action that stands for choosing none of them,
/// such as "keep the button's own behaviour".
typedef UnsetActionOption = ({String title, String description, IconData icon});

/// Like [showGestureActionPicker], but the list starts with [unsetOption] and
/// [selected] may be null to mark that entry as the current one.
///
/// Returns null if dismissed; otherwise a record whose `action` is null when
/// [unsetOption] was chosen.
Future<({BrowserAction? action})?> showOptionalBrowserActionPicker(
  BuildContext context, {
  required BrowserAction? selected,
  required UnsetActionOption unsetOption,
}) {
  return _showPicker(context, selected: selected, unsetOption: unsetOption);
}

Future<({BrowserAction? action})?> _showPicker(
  BuildContext context, {
  required BrowserAction? selected,
  UnsetActionOption? unsetOption,
}) {
  return showModalBottomSheet<({BrowserAction? action})>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) =>
        _GestureActionPicker(selected: selected, unsetOption: unsetOption),
  );
}

class _GestureActionPicker extends StatelessWidget {
  final BrowserAction? selected;
  final UnsetActionOption? unsetOption;

  const _GestureActionPicker({required this.selected, this.unsetOption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final byCategory = <BrowserActionCategory, List<BrowserAction>>{};
    for (final action in BrowserAction.values) {
      byCategory.putIfAbsent(action.category, () => []).add(action);
    }

    // A draggable sheet (matching the main browser menu) so the whole surface —
    // not just a small handle — can be swiped down to dismiss.
    return PointerScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle.
            const SheetDragHandle(),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Choose action', style: theme.textTheme.titleLarge),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  if (unsetOption case final unset?)
                    ListTile(
                      leading: Icon(unset.icon),
                      title: Text(unset.title),
                      subtitle: Text(unset.description),
                      selected: selected == null,
                      trailing: selected == null
                          ? Icon(Icons.check, color: colorScheme.primary)
                          : null,
                      onTap: () => Navigator.of(context).pop((action: null)),
                    ),
                  for (final category in BrowserActionCategory.values)
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
                          onTap: () =>
                              Navigator.of(context).pop((action: action)),
                        ),
                    ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
