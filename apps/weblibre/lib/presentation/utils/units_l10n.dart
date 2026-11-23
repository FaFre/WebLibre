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
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// A byte count in the UI language, e.g. "1.50 MB" (B/KB/MB, binary steps).
///
/// The English-only `formatBytes` in `lib/utils/number_format.dart` is for
/// log and diagnostic text; anything shown to users goes through this.
String formatByteSize(AppLocalizations l10n, int bytes) {
  if (bytes < 1024) {
    return l10n.units_bytes(NumberFormat.decimalPattern().format(bytes));
  }
  if (bytes < 1024 * 1024) {
    return l10n.units_kilobytes(NumberFormat('0.0').format(bytes / 1024));
  }
  return formatMegabytes(l10n, bytes / (1024 * 1024));
}

/// A size already expressed in megabytes, with two decimals.
String formatMegabytes(AppLocalizations l10n, double megabytes) =>
    l10n.units_megabytes(NumberFormat('0.00').format(megabytes));

/// A duration in milliseconds, e.g. "300 ms".
String formatMilliseconds(AppLocalizations l10n, int milliseconds) =>
    l10n.units_milliseconds(NumberFormat.decimalPattern().format(milliseconds));

/// A length in logical pixels, rounded to whole ones, e.g. "64 px".
String formatPixels(AppLocalizations l10n, double pixels) =>
    l10n.units_pixels(NumberFormat.decimalPattern().format(pixels.round()));

/// A [fraction] as a percentage the way the UI language writes it, e.g.
/// "150%" or "150 %": from `Intl.defaultLocale`, which `resolveAppLocale`
/// sets to the UI language.
String formatPercent(double fraction) =>
    NumberFormat.percentPattern().format(fraction);

/// A duration given in [minutes], in whole hours when it is one, e.g.
/// "30 minutes" or "4 hours".
String formatMinutes(AppLocalizations l10n, int minutes) => minutes % 60 == 0
    ? l10n.units_hours(minutes ~/ 60)
    : l10n.units_minutes(minutes);
