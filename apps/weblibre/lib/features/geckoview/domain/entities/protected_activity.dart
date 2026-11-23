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

extension ProtectedActivityCutOff on ProtectedActivity {
  /// Activity a sleep or freeze only asks about before cutting it off (D13);
  /// everything else refuses.
  bool get asksBeforeCutOff =>
      this == ProtectedActivity.media ||
      this == ProtectedActivity.postResult ||
      this == ProtectedActivity.formData;
}

/// Whether a sleep or freeze that ended with [failure] was refused only for
/// [activities] the user may agree to cut off.
bool refusedOnlyToAsk(
  LifecycleFailure? failure,
  Iterable<ProtectedActivity> activities,
) =>
    failure == LifecycleFailure.protectedActivity &&
    activities.isNotEmpty &&
    activities.every((activity) => activity.asksBeforeCutOff);

/// How many tabs among [blockers] (each a tab and its activity) play media,
/// how many show a POST result, and how many hold form input.
({int mediaTabs, int postResultTabs, int formDataTabs}) countCutOffTabs(
  Iterable<(String?, ProtectedActivity)> blockers,
) {
  int tabsWith(ProtectedActivity activity) => {
    for (final (tabId, blocked) in blockers)
      if (blocked == activity) tabId,
  }.length;
  return (
    mediaTabs: tabsWith(ProtectedActivity.media),
    postResultTabs: tabsWith(ProtectedActivity.postResult),
    formDataTabs: tabsWith(ProtectedActivity.formData),
  );
}

/// What the user agreed to cut off during one sleep or freeze (D13): media and
/// POST results for the whole operation, form input per tab, since only the
/// tabs the question counted may lose theirs. A retry that meets activity
/// none of it covers asks again ([uncovered]).
class CutOffConsent {
  bool stopMedia = false;
  bool discardPostResult = false;
  final Set<String> formDataTabIds = {};

  /// Whether the user agreed to cut off [activity] in [tabId].
  bool covers(String? tabId, ProtectedActivity activity) => switch (activity) {
    ProtectedActivity.media => stopMedia,
    ProtectedActivity.postResult => discardPostResult,
    ProtectedActivity.formData => formDataTabIds.contains(tabId),
    _ => false,
  };

  /// The [blockers] (each a tab and its activity) not agreed to yet.
  List<(String?, ProtectedActivity)> uncovered(
    Iterable<(String?, ProtectedActivity)> blockers,
  ) => [
    for (final (tabId, activity) in blockers)
      if (!covers(tabId, activity)) (tabId, activity),
  ];

  /// Records the user's yes to [blockers].
  void agreeTo(Iterable<(String?, ProtectedActivity)> blockers) {
    for (final (tabId, activity) in blockers) {
      switch (activity) {
        case ProtectedActivity.media:
          stopMedia = true;
        case ProtectedActivity.postResult:
          discardPostResult = true;
        case ProtectedActivity.formData:
          if (tabId != null) formDataTabIds.add(tabId);
        default:
          break;
      }
    }
  }
}
