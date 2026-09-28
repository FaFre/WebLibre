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
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/browser_actions/presentation/utils/browser_action_l10n.dart';
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_behavior_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_bindings_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_excluded_sites_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_feedback_screen.dart';
import 'package:weblibre/features/gestures/presentation/utils/built_in_gesture_l10n.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/setting_value_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Every gesture WebLibre knows, grouped by where it is made (issue #626):
/// the swipes on the tab bar and on tabs, each rebindable, the fixed ones
/// listed so none is undeclared, and the drawn stroke gestures on web pages
/// with their own subpages.
class GestureSettingsScreen extends HookConsumerWidget {
  const GestureSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);
    final repository = ref.read(gestureSettingsRepositoryProvider.notifier);

    void open(Widget screen) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => screen));
    }

    List<SettingsEntryDefinition> builtInEntries(
      BuiltInGestureSurface surface,
    ) => [
      for (final gesture in BuiltInGesture.values)
        if (gesture.surface == surface)
          SettingsEntryDefinition(
            title: gesture.label(context),
            subtitle: gesture.description(context),
            keywords: settingsKeywords(l10n.gestures_builtInGestureKeywords),
            child: _BuiltInGestureTile(gesture: gesture),
          ),
    ];

    return SettingsCustomScrollScaffold(
      title: l10n.gestures_screenTitle,
      actions: [
        MenuAnchor(
          builder: (context, controller, child) => IconButton(
            onPressed: () =>
                controller.isOpen ? controller.close() : controller.open(),
            icon: const Icon(Icons.more_vert),
          ),
          menuChildren: [
            MenuItemButton(
              leadingIcon: const Icon(Icons.restore),
              onPressed: settings.builtInOverrides.isEmpty
                  ? null
                  : () => repository.updateSettings(
                      (current) => current.copyWith.builtInOverrides(const {}),
                    ),
              child: Text(l10n.gestures_resetSwipesToDefaultsAction),
            ),
          ],
        ),
      ],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildSettingsSectionWidgets(context, [
                SettingsSectionDefinition(
                  title: BuiltInGestureSurface.tabBar.label(context),
                  entries: builtInEntries(BuiltInGestureSurface.tabBar),
                ),
                SettingsSectionDefinition(
                  title: BuiltInGestureSurface.tabView.label(context),
                  entries: [
                    ...builtInEntries(BuiltInGestureSurface.tabView),
                    SettingsEntryDefinition(
                      title: l10n.gestures_twoFingerSwipeTitle,
                      keywords: settingsKeywords(
                        l10n.gestures_twoFingerSwipeKeywords,
                      ),
                      child: _FixedGestureTile(
                        icon: MdiIcons.gestureSwipeHorizontal,
                        title: l10n.gestures_twoFingerSwipeTitle,
                        action: l10n.gestures_twoFingerSwipeAction,
                        actionIcon: MdiIcons.folderMultipleOutline,
                      ),
                    ),
                    SettingsEntryDefinition(
                      title: l10n.gestures_pinchTitle,
                      keywords: settingsKeywords(l10n.gestures_pinchKeywords),
                      child: _FixedGestureTile(
                        icon: MdiIcons.gesturePinch,
                        title: l10n.gestures_pinchTitle,
                        action: l10n.gestures_pinchAction,
                        actionIcon: MdiIcons.viewGridOutline,
                      ),
                    ),
                  ],
                ),
                SettingsSectionDefinition(
                  title: l10n.gestures_webPagesSectionTitle,
                  entries: [
                    SettingsEntryDefinition(
                      title: l10n.gestures_drawnGesturesTitle,
                      keywords: settingsKeywords(
                        l10n.gestures_drawnGesturesKeywords,
                      ),
                      child: SwitchListTile.adaptive(
                        secondary: const Icon(MdiIcons.gestureSwipe),
                        title: Text(l10n.gestures_drawnGesturesTitle),
                        subtitle: Text(l10n.gestures_drawnGesturesSubtitle),
                        value: settings.enabled,
                        onChanged: (value) => repository.updateSettings(
                          (current) => current.copyWith.enabled(value),
                        ),
                      ),
                    ),
                    if (settings.enabled) ...[
                      SettingsEntryDefinition(
                        title: l10n.gestures_gestureBindingsTitle,
                        child: ListTile(
                          leading: const Icon(MdiIcons.gestureDoubleTap),
                          title: Text(l10n.gestures_gestureBindingsTitle),
                          subtitle: Text(l10n.gestures_gestureBindingsSubtitle),
                          trailing: _CountChevron(
                            count: settings.bindings.length,
                          ),
                          onTap: () => open(const GestureBindingsScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: l10n.gestures_behaviorTimingTitle,
                        child: ListTile(
                          leading: const Icon(Icons.tune),
                          title: Text(l10n.gestures_behaviorTimingTitle),
                          subtitle: Text(
                            l10n.gestures_behaviorTimingSubtitleShort,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => open(const GestureBehaviorScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: l10n.gestures_excludedSitesTitle,
                        child: ListTile(
                          leading: const Icon(Icons.public_off),
                          title: Text(l10n.gestures_excludedSitesTitle),
                          subtitle: Text(l10n.gestures_excludedSitesSubtitle),
                          trailing: _CountChevron(
                            count: settings.excludedSites.length,
                          ),
                          onTap: () => open(const GestureExcludedSitesScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: l10n.gestures_feedbackTitle,
                        child: ListTile(
                          leading: const Icon(Icons.bolt_outlined),
                          title: Text(l10n.gestures_feedbackTitle),
                          subtitle: Text(l10n.gestures_feedbackSubtitleShort),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => open(const GestureFeedbackScreen()),
                        ),
                      ),
                    ],
                    SettingsEntryDefinition(
                      title: l10n.gestures_pullToRefreshTitle,
                      keywords: settingsKeywords(
                        l10n.gestures_pullToRefreshKeywords,
                      ),
                      child: const _PullToRefreshTile(),
                    ),
                  ],
                ),
                SettingsSectionDefinition(
                  title: l10n.gestures_toolbarSectionTitle,
                  entries: [
                    SettingsEntryDefinition(
                      title: l10n.gestures_longPressButtonsTitle,
                      child: ListTile(
                        leading: const Icon(Icons.touch_app_outlined),
                        title: Text(l10n.gestures_longPressButtonsTitle),
                        subtitle: Text(l10n.gestures_longPressButtonsSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => const ContextualToolbarSettingsRoute()
                            .push(context),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

/// One rebindable [BuiltInGesture]: what it does now, and a tap to change it.
class _BuiltInGestureTile extends HookConsumerWidget {
  const _BuiltInGestureTile({required this.gesture});

  final BuiltInGesture gesture;

  static UnsetActionOption _doNothing(AppLocalizations l10n) => (
    title: l10n.gestures_doNothingTitle,
    description: l10n.gestures_doNothingSubtitle,
    icon: Icons.block,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final doNothing = _doNothing(l10n);
    final action = ref.watch(builtInGestureBindingProvider(gesture));
    final legacyTabBarSwipe = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarSwipeAction),
    );

    return SettingValueTile(
      icon: gesture.icon,
      title: gesture.label(context),
      description: gesture.description(context),
      value: action?.label(context) ?? doNothing.title,
      valueIcon: action?.icon ?? doNothing.icon,
      onTap: () async {
        final picked = await showOptionalBrowserActionPicker(
          context,
          selected: action,
          unsetOption: doNothing,
          actions: gesture.allowedActions,
        );
        if (picked == null || picked.action == action) return;

        await ref
            .read(gestureSettingsRepositoryProvider.notifier)
            .updateSettings(
              (current) => current.withBuiltInBinding(
                gesture,
                picked.action,
                legacyTabBarSwipe: legacyTabBarSwipe,
              ),
            );
      },
    );
  }
}

/// A gesture that always does the same thing, listed so the user knows it
/// exists.
class _FixedGestureTile extends StatelessWidget {
  const _FixedGestureTile({
    required this.icon,
    required this.title,
    required this.action,
    required this.actionIcon,
  });

  final IconData icon;
  final String title;

  /// What the gesture always does.
  final String action;
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SettingValueTile(
      icon: icon,
      title: title,
      description: l10n.gestures_builtInCannotBeChangedDescription,
      value: action,
      valueIcon: actionIcon,
    );
  }
}

/// The same switch as in the browsing settings: pulling a page down is a
/// gesture too, so it is listed here with the others.
class _PullToRefreshTile extends HookConsumerWidget {
  const _PullToRefreshTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pullToRefreshEnabled),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.gestureSwipeDown),
      title: Text(l10n.gestures_pullToRefreshTitle),
      subtitle: Text(l10n.gestures_pullToRefreshSubtitle),
      value: enabled,
      onChanged: (value) => ref
          .read(saveGeneralSettingsControllerProvider.notifier)
          .save((current) => current.copyWith.pullToRefreshEnabled(value)),
    );
  }
}

class _CountChevron extends StatelessWidget {
  final int count;

  const _CountChevron({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (count > 0)
          Text('$count', style: Theme.of(context).textTheme.labelLarge),
        const Icon(Icons.chevron_right),
      ],
    );
  }
}
