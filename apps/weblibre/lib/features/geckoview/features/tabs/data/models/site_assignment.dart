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

class SiteAssignment with FastEquatable {
  final String id;
  final String? contextualIdentity;
  final Uri assignedSite;

  SiteAssignment({
    required this.id,
    required this.contextualIdentity,
    //Drift type casting issue should be non null
    required String? assignedSite,
  }) : assignedSite = Uri.parse(assignedSite!);

  @override
  List<Object?> get hashParameters => [id, contextualIdentity, assignedSite];
}
