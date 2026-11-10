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

import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';

sealed class TabContainerSelection {
  const TabContainerSelection();

  const factory TabContainerSelection.useSelected() =
      UseSelectedContainerTabSelection;

  const factory TabContainerSelection.unassigned() =
      UnassignedContainerTabSelection;

  const factory TabContainerSelection.specific(ContainerData container) =
      SpecificContainerTabSelection;

  /// [container] (null: unassigned) unless the URL's site is assigned to a
  /// container, which wins, exactly as it does over the selected container.
  /// For tabs opened from a page that is not necessarily the selected one (a
  /// split pane), so they land in that page's container.
  const factory TabContainerSelection.preferred(ContainerData? container) =
      PreferredContainerTabSelection;

  /// For a tab opened from [tabId]'s page: [tabId]'s container (none when it
  /// is in none), as [TabContainerSelection.preferred], so a site assigned
  /// elsewhere still wins. Never the selected container: that is the tab
  /// tray's choice and can differ from the page's, whose container the
  /// browser chrome shows. Resolved when the tab opens, from the container a
  /// copy of [tabId] would go into (`TabDataRepository.getContainerForCopy`):
  /// a tab's row is written after the tab opens, and an empty lookup taken at
  /// its word would send a link from a page in a container into none.
  const factory TabContainerSelection.openedFrom(String tabId) =
      OpenedFromTabContainerSelection;
}

final class UseSelectedContainerTabSelection extends TabContainerSelection {
  const UseSelectedContainerTabSelection();
}

final class UnassignedContainerTabSelection extends TabContainerSelection {
  const UnassignedContainerTabSelection();
}

final class SpecificContainerTabSelection extends TabContainerSelection {
  final ContainerData container;

  const SpecificContainerTabSelection(this.container);
}

final class PreferredContainerTabSelection extends TabContainerSelection {
  final ContainerData? container;

  const PreferredContainerTabSelection(this.container);
}

final class OpenedFromTabContainerSelection extends TabContainerSelection {
  final String tabId;

  const OpenedFromTabContainerSelection(this.tabId);
}
