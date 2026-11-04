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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';

part 'setup_follow_ups.g.dart';

/// Goals whose setup opens once the browser is showing, after the commit.
///
/// In memory only: a sign-in or a lock set up from here is the user's
/// request in this session. If the process ends first, nothing is pending and
/// nothing was half-done, which is what cancelling has to leave behind
/// (acceptance scenario 28).
@Riverpod(keepAlive: true)
class PendingGoalSetups extends _$PendingGoalSetups {
  @override
  List<SetupGoal> build() => const [];

  void schedule(Iterable<SetupGoal> goals) {
    state = [
      for (final goal in goals)
        if (goal.opensAfterCommit) goal,
    ];
  }

  /// Returns what is pending and clears it, so each setup opens once.
  List<SetupGoal> take() {
    final goals = state;
    if (goals.isNotEmpty) state = const [];
    return goals;
  }
}
