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
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_behavior_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_bindings_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_excluded_sites_screen.dart';
import 'package:weblibre/features/gestures/presentation/screens/gesture_feedback_screen.dart';
import 'package:weblibre/features/settings/presentation/widgets/settings_detail.dart';

/// Overview screen for gesture configuration: a master switch plus entries that
/// open the dedicated bindings / behavior / excluded-sites / feedback subpages.
class GestureSettingsScreen extends HookConsumerWidget {
  const GestureSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);
    final repository = ref.read(gestureSettingsRepositoryProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    void open(Widget screen) {
      unawaited(
        Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => screen)),
      );
    }

    return SettingsCustomScrollScaffold(
      title: 'Gestures',
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Card.filled(
              margin: EdgeInsets.zero,
              color: colorScheme.primaryContainer,
              clipBehavior: Clip.antiAlias,
              child: SwitchListTile.adaptive(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                secondary: Icon(
                  MdiIcons.gestureSwipe,
                  color: colorScheme.onPrimaryContainer,
                ),
                title: Text(
                  'Enable Gestures',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Draw stroke gestures on web pages to trigger actions',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                value: settings.enabled,
                onChanged: (value) async {
                  await repository.updateSettings(
                    (current) => current.copyWith.enabled(value),
                  );
                },
              ),
            ),
          ),
        ),
        if (settings.enabled)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: buildSettingsSectionWidgets(context, [
                  SettingsSectionDefinition(
                    title: 'Configuration',
                    entries: [
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
                            'Sensitivity, timeout, cooldown',
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
                  ),
                ]),
              ),
            ),
          ),
      ],
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
