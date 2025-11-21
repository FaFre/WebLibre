/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
enum BangGroup {
  general(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/bangs.json',
    bundled: 'assets/bangs/bangs.json',
  ),
  assistant(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/assistant_bangs.json',
    bundled: 'assets/bangs/assistant_bangs.json',
  ),
  kagi(
    remote:
        'https://raw.githubusercontent.com/FaFre/bangs/main/data/kagi_bangs.json',
    bundled: 'assets/bangs/kagi_bangs.json',
  ),
  user(remote: null, bundled: null);

  final String? bundled;
  final String? remote;

  const BangGroup({required this.bundled, required this.remote});
}
