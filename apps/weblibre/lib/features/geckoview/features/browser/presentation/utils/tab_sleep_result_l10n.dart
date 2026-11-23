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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:weblibre/features/geckoview/domain/entities/protected_activity.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/protected_activity_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension TabSleepResultsL10n on List<TabSleepResult> {
  /// What to tell the user after a sleep of these tabs, and whether the sleep
  /// itself failed rather than a tab's activity keeping it awake. Null when
  /// every tab went to sleep.
  ({String text, bool failed})? describe(AppLocalizations l10n) {
    final kept = where((result) => !result.asleep).toList();
    if (kept.isEmpty) return null;

    if (length > 1) {
      return (
        text: l10n.browser_sleepTabsPartial(length - kept.length, kept.length),
        failed: false,
      );
    }

    final result = kept.single;
    if (result.failure != LifecycleFailure.protectedActivity) {
      return (text: l10n.browser_sleepTabFailed, failed: true);
    }
    final reason = result.blockers.firstWhere(
      (activity) => !activity.asksBeforeCutOff,
      orElse: () => result.blockers.first,
    );
    return (text: reason.describeSleepRefusal(l10n), failed: false);
  }
}
