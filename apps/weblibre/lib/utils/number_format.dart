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
import 'package:intl/intl.dart';

/// Formats integers in a compact, locale-aware form (e.g. 10.6M, 1.3K).
String formatCompactNumber(num value) {
  return NumberFormat.compact().format(value);
}

/// Formats a byte count as a short, human-readable string (B/KB/MB).
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
}

/// Parses an ISO-8601 timestamp and formats it as a short local date.
/// Returns the original string if parsing fails.
String formatIsoDate(String iso) {
  try {
    final dt = DateTime.parse(iso).toLocal();
    return DateFormat.yMMMd().format(dt);
  } catch (_) {
    return iso;
  }
}
