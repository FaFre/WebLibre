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

/// How a reorder/reparent operation should affect the moving tab's
/// `parent_id`. Distinguishes "leave parent_id alone" (the default for a
/// plain reorder) from "detach to root" and "attach to a specific tab".
///
/// Mirrors the shape of [TabContainerSelection].
sealed class TabParentChange {
  const TabParentChange();

  const factory TabParentChange.unchanged() = TabParentUnchanged;

  const factory TabParentChange.detach() = TabParentDetach;

  const factory TabParentChange.toParent(String parentTabId) =
      TabParentToSpecific;
}

final class TabParentUnchanged extends TabParentChange {
  const TabParentUnchanged();
}

final class TabParentDetach extends TabParentChange {
  const TabParentDetach();
}

final class TabParentToSpecific extends TabParentChange {
  final String parentTabId;

  const TabParentToSpecific(this.parentTabId);
}
