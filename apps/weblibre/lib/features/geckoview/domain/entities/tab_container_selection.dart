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
