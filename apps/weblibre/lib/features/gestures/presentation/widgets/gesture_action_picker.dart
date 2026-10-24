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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/features/browser_actions/data/models/browser_action.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/pointer_scrollable_sheet.dart';
import 'package:weblibre/presentation/widgets/sheet_drag_handle.dart';

/// Shows a modal bottom sheet listing every [BrowserAction] grouped by category,
/// each with its icon, title and description, and returns the chosen action (or
/// null if dismissed). A search field above the list narrows it down.
///
/// The one list for every trigger it is assigned from — drawn gestures, the
/// built-in swipes, a toolbar button's long press and its replacement — so an
/// action is found under the same name and in the same place each time.
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
/// [selected] may be null to mark that entry as the current one. [actions]
/// narrows the list to what the trigger can run, and [title] replaces the
/// "Choose action" heading.
///
/// Returns null if dismissed; otherwise a record whose `action` is null when
/// [unsetOption] was chosen.
Future<({BrowserAction? action})?> showOptionalBrowserActionPicker(
  BuildContext context, {
  required BrowserAction? selected,
  required UnsetActionOption unsetOption,
  List<BrowserAction> actions = BrowserAction.values,
  String? title,
}) {
  return _showPicker(
    context,
    selected: selected,
    unsetOption: unsetOption,
    actions: actions,
    title: title,
  );
}

Future<({BrowserAction? action})?> _showPicker(
  BuildContext context, {
  required BrowserAction? selected,
  UnsetActionOption? unsetOption,
  List<BrowserAction> actions = BrowserAction.values,
  String? title,
}) {
  return showModalBottomSheet<({BrowserAction? action})>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    isScrollControlled: true,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => _GestureActionPicker(
      selected: selected,
      unsetOption: unsetOption,
      actions: actions,
      title: title,
    ),
  );
}

const _maxChildSize = 0.95;

class _GestureActionPicker extends HookWidget {
  final BrowserAction? selected;
  final UnsetActionOption? unsetOption;
  final List<BrowserAction> actions;
  final String? title;

  const _GestureActionPicker({
    required this.selected,
    required this.actions,
    this.unsetOption,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final search = useSettingsSearch();
    final query = search.normalizedQuery;
    final sheetController = useDraggableScrollableController();
    final searchFocus = useFocusNode();

    // The keyboard takes much of the screen, so searching gets the sheet's
    // full height for its results.
    useEffect(() {
      void expandForKeyboard() {
        if (searchFocus.hasFocus && sheetController.isAttached) {
          sheetController.animateTo(
            _maxChildSize,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
          );
        }
      }

      searchFocus.addListener(expandForKeyboard);
      return () => searchFocus.removeListener(expandForKeyboard);
    }, [searchFocus, sheetController]);

    bool matches(List<String> values) =>
        query.isEmpty || matchesSettingsSearch(query, values);

    final byCategory = <BrowserActionCategory, List<BrowserAction>>{};
    for (final action in actions) {
      if (matches([
        action.label(context),
        action.description(context),
        action.category.label(context),
        ...action.keywords(context),
      ])) {
        byCategory.putIfAbsent(action.category, () => []).add(action);
      }
    }

    final unset = unsetOption;
    final showUnset =
        unset != null && matches([unset.title, unset.description]);

    // Keeps the bottom of the list above the keyboard; the sheet itself does
    // not move out of its way.
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      // A draggable sheet (matching the main browser menu) so the whole
      // surface — not just a small handle — can be swiped down to dismiss.
      child: PointerScrollableSheet(
        controller: sheetController,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: _maxChildSize,
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
                  child: Text(
                    title ?? l10n.gestures_chooseActionTitle,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SettingsSearchField(
                  controller: search.controller,
                  focusNode: searchFocus,
                  hintText: l10n.gestures_actionSearchHint,
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.only(bottom: 8),
                  children: [
                    if (showUnset)
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
                            category.label(context),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        for (final action in actions)
                          ListTile(
                            leading: Icon(action.icon),
                            title: Text(action.label(context)),
                            subtitle: Text(action.description(context)),
                            selected: action == selected,
                            trailing: action == selected
                                ? Icon(Icons.check, color: colorScheme.primary)
                                : null,
                            onTap: () =>
                                Navigator.of(context).pop((action: action)),
                          ),
                      ],
                    if (!showUnset && byCategory.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 32,
                        ),
                        child: Text(
                          l10n.gestures_noMatchingActions,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
