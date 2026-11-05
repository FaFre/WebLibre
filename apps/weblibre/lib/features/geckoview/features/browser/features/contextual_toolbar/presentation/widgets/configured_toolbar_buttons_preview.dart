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
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/models/contextual_toolbar_scope.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/toolbar_button_registry.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/presentation/widgets/contextual_toolbar.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

/// The buttons [configs] put on a toolbar, drawn as preview buttons that act
/// on nothing.
///
/// Built through the same registry as the real toolbar, with the scope marked
/// as a preview, so a button looks exactly as it will in the browser.
class ConfiguredToolbarButtonsPreview extends ConsumerWidget {
  const ConfiguredToolbarButtonsPreview({
    super.key,
    required this.configs,
    required this.location,
    this.axis = Axis.horizontal,
    this.wrap = false,
    this.trailing = const [],
  });

  final List<ToolbarButtonConfig> configs;
  final ToolbarConfigLocation location;

  /// See [ContextualToolbarView.axis].
  final Axis axis;

  /// See [ContextualToolbarView.wrap].
  final bool wrap;

  /// See [ContextualToolbarView.trailing].
  final List<Widget> trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scope = ContextualToolbarScope(
      selectedTabId: null,
      displayedSheet: null,
      tabState: null,
      isPreview: true,
      location: location,
    );

    final buttons = [
      for (final config in configs)
        if (config.isVisible)
          if (toolbarButtonRegistryById[config.buttonId] case final def?)
            def.builder(scope, context, ref),
    ];

    return ContextualToolbarView(
      buttons: buttons,
      axis: axis,
      wrap: wrap,
      trailing: trailing,
    );
  }
}
