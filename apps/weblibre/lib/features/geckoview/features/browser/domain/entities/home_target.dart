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

/// What the browser lands on when there is no tab to show.
enum HomeTarget {
  /// Show the home surface. The default, and what the browser has always done.
  home,

  /// Reopen the most recently used tab, scoped to the selected container.
  resumeLastTab,

  /// Open a configured address.
  customUrl;

  String get label => switch (this) {
    home => 'Home page',
    resumeLastTab => 'Last opened tab',
    customUrl => 'Custom address',
  };

  String get description => switch (this) {
    home => 'Show shortcuts and the sections you have chosen',
    resumeLastTab => 'Pick up where you left off',
    customUrl => 'Open a specific page',
  };
}
