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

/// What a Wake the user asked for did (5.2.1, D34 of
/// `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
enum TabWakeOutcome {
  /// Its hold is gone, and its page loads when it is shown.
  woken,

  /// It stays asleep: its proxy routing is not installed, or has no route
  /// out for its storage, and it must not load another way.
  routingNotReady,

  /// It stays asleep with its hold: its container is frozen, so it could not
  /// load, and woken it would load after a Resume, which keeps sleeping tabs
  /// asleep (D26).
  containerFrozen,
}
