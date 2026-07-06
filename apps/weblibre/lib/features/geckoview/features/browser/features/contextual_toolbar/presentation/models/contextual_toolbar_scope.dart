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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/entities/sheet.dart';
import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_config_location.dart';

class ContextualToolbarScope with FastEquatable {
  final String? selectedTabId;
  final Sheet? displayedSheet;
  final TabState? tabState;
  final bool isPreview;

  /// Which configuration set this scope renders for, so shared registry
  /// builders that read sibling button config (e.g. the back button's
  /// stop-loading fallback) consult the correct location.
  final ToolbarConfigLocation location;

  ContextualToolbarScope({
    required this.selectedTabId,
    required this.displayedSheet,
    required this.tabState,
    required this.isPreview,
    this.location = ToolbarConfigLocation.contextual,
  });

  @override
  List<Object?> get hashParameters => [
    selectedTabId,
    displayedSheet,
    tabState,
    isPreview,
    location,
  ];
}
