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

/// High-churn per-tab state, deliberately kept *out* of [TabState].
///
/// [TabState] is fanned out to the always-visible browser chrome — the quick
/// tab switcher chips, the grouped tab list, the contextual toolbar — through
/// providers that watch the whole `Map<String, TabState>`. Any field that ticks
/// during a page load or on a background timer therefore rebuilt every chip on
/// screen, even though no chip renders that field.
///
/// The fields here are each consumed by exactly one or two widgets, so they
/// live in their own keyed notifiers and are read through per-tab selectors.
/// A progress tick or a background tab's screenshot now invalidates only the
/// widget that actually shows it.
library;

import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/find_result.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/history.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/translation.dart';

part 'tab_detail_state.g.dart';

/// Load progress (0-100) per tab. Ticks continuously while a page loads.
@Riverpod(keepAlive: true)
class TabProgressStates extends _$TabProgressStates {
  @override
  Map<String, int> build() => const {};

  void update(String tabId, int progress) {
    if (state[tabId] == progress) {
      return;
    }

    state = {...state}..[tabId] = progress;
  }
}

@Riverpod()
int tabProgress(Ref ref, String? tabId) {
  if (tabId == null) {
    return 0;
  }

  return ref.watch(tabProgressStatesProvider.select((s) => s[tabId] ?? 0));
}

/// Page screenshots per tab. Refreshed on a 10s timer for the selected tab and
/// consumed only by the tab tray previews.
@Riverpod(keepAlive: true)
class TabThumbnails extends _$TabThumbnails {
  @override
  Map<String, EquatableImage> build() => const {};

  void update(String tabId, EquatableImage? thumbnail) {
    if (thumbnail == null) {
      if (!state.containsKey(tabId)) {
        return;
      }

      state = {...state}..remove(tabId);
      return;
    }

    if (state[tabId] == thumbnail) {
      return;
    }

    state = {...state}..[tabId] = thumbnail;
  }
}

@Riverpod()
EquatableImage? tabThumbnail(Ref ref, String? tabId) {
  if (tabId == null) {
    return null;
  }

  return ref.watch(tabThumbnailsProvider.select((s) => s[tabId]));
}

/// Session history (back/forward stack) per tab.
@Riverpod(keepAlive: true)
class TabHistoryStates extends _$TabHistoryStates {
  @override
  Map<String, HistoryState> build() => const {};

  void update(String tabId, HistoryState history) {
    if (state[tabId] == history) {
      return;
    }

    state = {...state}..[tabId] = history;
  }
}

@Riverpod()
HistoryState tabHistoryState(Ref ref, String? tabId) {
  if (tabId == null) {
    return HistoryState.$default();
  }

  return ref.watch(
    tabHistoryStatesProvider.select((s) => s[tabId] ?? HistoryState.$default()),
  );
}

/// Find-in-page match counters per tab. Emitted at a high rate by Gecko while
/// a search is running.
@Riverpod(keepAlive: true)
class TabFindResultStates extends _$TabFindResultStates {
  @override
  Map<String, FindResultState> build() => const {};

  void update(String tabId, FindResultState result) {
    if (state[tabId] == result) {
      return;
    }

    state = {...state}..[tabId] = result;
  }

  FindResultState resultFor(String tabId) =>
      state[tabId] ?? FindResultState.$default();
}

@Riverpod()
FindResultState tabFindResultState(Ref ref, String? tabId) {
  if (tabId == null) {
    return FindResultState.$default();
  }

  return ref.watch(
    tabFindResultStatesProvider.select(
      (s) => s[tabId] ?? FindResultState.$default(),
    ),
  );
}

/// Translation progress/result per tab.
@Riverpod(keepAlive: true)
class TabTranslationStates extends _$TabTranslationStates {
  @override
  Map<String, TranslationState> build() => const {};

  void update(String tabId, TranslationState translation) {
    if (state[tabId] == translation) {
      return;
    }

    state = {...state}..[tabId] = translation;
  }
}

@Riverpod()
TranslationState tabTranslationState(Ref ref, String? tabId) {
  if (tabId == null) {
    return TranslationState.$default();
  }

  return ref.watch(
    tabTranslationStatesProvider.select(
      (s) => s[tabId] ?? TranslationState.$default(),
    ),
  );
}
