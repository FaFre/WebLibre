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
import 'package:weblibre/features/gestures/data/models/built_in_gesture.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_behavior_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_bindings_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_excluded_sites_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_feedback_screen.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/features/settings/presentation/controllers/save_settings.dart';
import 'package:weblibre/features/settings/presentation/widgets/setting_value_tile.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

/// Every gesture WebLibre knows, grouped by where it is made (issue #626):
/// the swipes on the tab bar and on tabs, each rebindable, the fixed ones
/// listed so none is undeclared, and the drawn stroke gestures on web pages
/// with their own subpages.
class GestureSettingsScreen extends HookConsumerWidget {
  const GestureSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: gesture.title,
            subtitle: gesture.description,
            keywords: const ['swipe'],
            child: _BuiltInGestureTile(gesture: gesture),
          ),
    ];

    return SettingsCustomScrollScaffold(
      title: 'Gestures',
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
              child: const Text('Reset Swipes to Defaults'),
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
                  title: BuiltInGestureSurface.tabBar.title,
                  entries: builtInEntries(BuiltInGestureSurface.tabBar),
                ),
                SettingsSectionDefinition(
                  title: BuiltInGestureSurface.tabView.title,
                  entries: [
                    ...builtInEntries(BuiltInGestureSurface.tabView),
                    const SettingsEntryDefinition(
                      title: 'Two-finger swipe',
                      keywords: ['container'],
                      child: _FixedGestureTile(
                        icon: MdiIcons.gestureSwipeHorizontal,
                        title: 'Two-finger swipe',
                        action: 'Next or previous container',
                        actionIcon: MdiIcons.folderMultipleOutline,
                      ),
                    ),
                    const SettingsEntryDefinition(
                      title: 'Pinch',
                      keywords: ['grid', 'list', 'tree', 'layout'],
                      child: _FixedGestureTile(
                        icon: MdiIcons.gesturePinch,
                        title: 'Pinch',
                        action: 'Grid, list or tree layout',
                        actionIcon: MdiIcons.viewGridOutline,
                      ),
                    ),
                  ],
                ),
                SettingsSectionDefinition(
                  title: 'Web Pages',
                  entries: [
                    SettingsEntryDefinition(
                      title: 'Drawn gestures',
                      keywords: const ['stroke'],
                      child: SwitchListTile.adaptive(
                        secondary: const Icon(MdiIcons.gestureSwipe),
                        title: const Text('Drawn gestures'),
                        subtitle: const Text(
                          'Draw strokes on a page to run actions',
                        ),
                        value: settings.enabled,
                        onChanged: (value) => repository.updateSettings(
                          (current) => current.copyWith.enabled(value),
                        ),
                      ),
                    ),
                    if (settings.enabled) ...[
                      SettingsEntryDefinition(
                        title: 'Gesture bindings',
                        child: ListTile(
                          leading: const Icon(MdiIcons.gestureDoubleTap),
                          title: const Text('Gesture bindings'),
                          subtitle: const Text('Strokes mapped to actions'),
                          trailing: _CountChevron(
                            count: settings.bindings.length,
                          ),
                          onTap: () => open(const GestureBindingsScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: 'Behavior & timing',
                        child: ListTile(
                          leading: const Icon(Icons.tune),
                          title: const Text('Behavior & timing'),
                          subtitle: const Text(
                            'Stroke length, timeout, cooldown',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => open(const GestureBehaviorScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: 'Excluded sites',
                        child: ListTile(
                          leading: const Icon(Icons.public_off),
                          title: const Text('Excluded sites'),
                          subtitle: const Text('Disable gestures per site'),
                          trailing: _CountChevron(
                            count: settings.excludedSites.length,
                          ),
                          onTap: () => open(const GestureExcludedSitesScreen()),
                        ),
                      ),
                      SettingsEntryDefinition(
                        title: 'Feedback',
                        child: ListTile(
                          leading: const Icon(Icons.bolt_outlined),
                          title: const Text('Feedback'),
                          subtitle: const Text('Live overlay and suggestions'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => open(const GestureFeedbackScreen()),
                        ),
                      ),
                    ],
                    const SettingsEntryDefinition(
                      title: 'Pull to refresh',
                      keywords: ['reload'],
                      child: _PullToRefreshTile(),
                    ),
                  ],
                ),
                SettingsSectionDefinition(
                  title: 'Toolbar',
                  entries: [
                    SettingsEntryDefinition(
                      title: 'Long press on buttons',
                      child: ListTile(
                        leading: const Icon(Icons.touch_app_outlined),
                        title: const Text('Long press on buttons'),
                        subtitle: const Text(
                          'Chosen per button when customizing the toolbar',
                        ),
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

  static const UnsetActionOption _doNothing = (
    title: 'Do nothing',
    description: 'The swipe is ignored',
    icon: Icons.block,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(builtInGestureBindingProvider(gesture));
    final legacyTabBarSwipe = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.tabBarSwipeAction),
    );

    return SettingValueTile(
      icon: gesture.icon,
      title: gesture.title,
      description: gesture.description,
      value: action?.title ?? _doNothing.title,
      valueIcon: action?.icon ?? _doNothing.icon,
      onTap: () async {
        final picked = await showOptionalBrowserActionPicker(
          context,
          selected: action,
          unsetOption: _doNothing,
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
    return SettingValueTile(
      icon: icon,
      title: title,
      description: 'Built in, cannot be changed',
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
    final enabled = ref.watch(
      generalSettingsWithDefaultsProvider.select((s) => s.pullToRefreshEnabled),
    );

    return SwitchListTile.adaptive(
      secondary: const Icon(MdiIcons.gestureSwipeDown),
      title: const Text('Pull to refresh'),
      subtitle: const Text('Swipe down at the top of a page to reload it'),
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
