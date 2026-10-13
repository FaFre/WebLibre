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
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// The local day a visit at [millisecondsSinceEpoch] falls on, as midnight.
///
/// History sections are calendar days, as in Fenix since 157: a relative
/// "2 days ago" put visits from either side of a midnight in one section.
DateTime historyDayOf(int millisecondsSinceEpoch) => DateUtils.dateOnly(
  DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch),
);

/// Heading of the history section for [day]: "Today", "Yesterday", then the
/// weekday and date, with the year only when it is not the current one.
String historyDayLabel(
  AppLocalizations l10n,
  DateTime day, {
  required DateTime now,
}) {
  final today = DateUtils.dateOnly(now);

  if (DateUtils.isSameDay(day, today)) {
    return l10n.history_dayToday;
  }
  if (DateUtils.isSameDay(
    day,
    DateTime(today.year, today.month, today.day - 1),
  )) {
    return l10n.history_dayYesterday;
  }

  return day.year == today.year
      ? DateFormat.MMMMEEEEd().format(day)
      : DateFormat.yMMMMEEEEd().format(day);
}
