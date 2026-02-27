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
import 'package:weblibre/core/uuid.dart';

const _isolatedPrefix = 'iso1_';

/// Generates a new unique isolation context ID in the format `iso1_<uuid-v4>`.
String newIsolatedContextId() {
  final id = uuid.v4();
  return '$_isolatedPrefix$id';
}

/// Returns `true` if the given context ID identifies an isolated tab context.
bool isIsolatedContextId(String? contextId) {
  if (contextId == null) return false;
  return contextId.startsWith(_isolatedPrefix);
}
