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

import 'package:weblibre/features/geckoview/features/browser/features/contextual_toolbar/domain/entities/toolbar_button_id.dart';

class ToolbarButtonSpec {
  final ToolbarButtonId id;
  final bool defaultVisible;
  final ToolbarButtonId? defaultFallback;
  final bool canBeFallbackTarget;

  const ToolbarButtonSpec({
    required this.id,
    required this.defaultVisible,
    this.defaultFallback,
    this.canBeFallbackTarget = true,
  });
}

const backToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.back,
  defaultVisible: true,
  defaultFallback: ToolbarButtonId.bookmarks,
);

const forwardToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.forward,
  defaultVisible: true,
  defaultFallback: ToolbarButtonId.share,
);

const bookmarksToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.bookmarks,
  defaultVisible: false,
);

const shareToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.share,
  defaultVisible: false,
);

const addTabToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.addTab,
  defaultVisible: true,
);

const tabsCountToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.tabsCount,
  defaultVisible: true,
);

const navigationMenuToolbarButtonSpec = ToolbarButtonSpec(
  id: ToolbarButtonId.navigationMenu,
  defaultVisible: true,
);

const toolbarButtonSpecs = [
  backToolbarButtonSpec,
  forwardToolbarButtonSpec,
  bookmarksToolbarButtonSpec,
  shareToolbarButtonSpec,
  addTabToolbarButtonSpec,
  tabsCountToolbarButtonSpec,
  navigationMenuToolbarButtonSpec,
];

final Map<String, ToolbarButtonSpec> toolbarButtonSpecsById = {
  for (final spec in toolbarButtonSpecs) spec.id.name: spec,
};

final Set<String> knownToolbarButtonIds = toolbarButtonSpecsById.keys.toSet();
