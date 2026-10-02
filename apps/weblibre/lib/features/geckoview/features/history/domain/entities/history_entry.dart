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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';

/// Maximum gap (epoch millis) between a WebLibre `visit_container` relation row
/// and a Mozilla Places `VisitInfo` for them to be considered the same visit.
/// The relation's `visit_time` is captured near — not exactly at — the Places
/// record time (the native delegate stamps `System.currentTimeMillis()`), so
/// tagging/filtering matches the closest relation within this tolerance.
const int historyVisitContainerMatchWindowMs = 5000;

/// A single history-screen row: a Mozilla Places visit (the source of truth for
/// url, title, visit type and time) annotated with the WebLibre container(s)
/// it belonged to.
///
/// [containerIds] is the visit's resolved container tag — at most one entry for
/// a normal visit (the nearest relation within
/// [historyVisitContainerMatchWindowMs]); empty when the visit was uncontained
/// or predates history-relation recording.
class HistoryEntry with FastEquatable {
  // Destructured into `hashParameters` field by field instead of listed here:
  // `VisitInfo` is a Pigeon class with identity equality, so listing it would
  // make every rebuilt entry compare unequal.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  /// The underlying Places visit; still used verbatim for opening the page and
  /// for the precise `(url, time)` Places delete.
  final VisitInfo visit;
  final List<String> containerIds;

  /// Primary key of the `visit_container` row that this visit paired with (the
  /// same one-to-one pairing that produced [containerIds]), or null when the
  /// visit is uncontained. Carried on the entry so a delete can drop exactly
  /// this visit's relation without re-deriving the nearest-time join — which
  /// could otherwise pick a sibling same-URL visit's relation and mislabel it.
  final int? containerRelationId;

  /// Older visits of the same URL that this row stands for when the timeline
  /// shows distinct URLs (see [collapseToDistinctUrls]). Empty otherwise.
  final List<HistoryEntry> olderVisits;

  HistoryEntry({
    required this.visit,
    required this.containerIds,
    this.containerRelationId,
    this.olderVisits = const [],
  });

  /// This visit followed by every older visit it stands for. Deleting a row
  /// deletes all of them, so a collapsed URL does not resurface with its next
  /// older visit.
  Iterable<HistoryEntry> get allVisits sync* {
    yield this;
    yield* olderVisits;
  }

  String get url => visit.url;
  String? get title => visit.title;
  int get visitTime => visit.visitTime;
  VisitType get visitType => visit.visitType;
  String? get previewImageUrl => visit.previewImageUrl;
  String? get contentId => visit.contentId;

  /// Whether [lowerCaseQuery] occurs in the title or URL of this visit or of
  /// any visit it stands for. A Distinct URLs row has to match through those
  /// too: downloads of one URL can have different file names (their titles).
  bool matchesText(String lowerCaseQuery) =>
      _searchText.contains(lowerCaseQuery);

  // Derived from fields that are compared already.
  // ignore: fast_equatable_lint/missing_field_in_equatable_props
  /// The titles and URLs [matchesText] looks in, lowercased once rather than
  /// for every entry on every keystroke of the history filter. Line breaks
  /// keep a query from matching across two of them.
  late final String _searchText = [
    for (final visit in allVisits) ...[?visit.title, visit.url],
  ].join('\n').toLowerCase();

  @override
  List<Object?> get hashParameters => [
    visit.url,
    visit.title,
    visit.visitTime,
    visit.visitType,
    visit.previewImageUrl,
    visit.contentId,
    containerIds,
    containerRelationId,
    olderVisits,
  ];
}

/// Collapse [entries] to one row per URL: the first entry seen for each URL
/// carries the later ones as [HistoryEntry.olderVisits].
///
/// [entries] must be sorted newest first, so each row is the newest visit and
/// keeps its place in the timeline. URLs are compared exactly: two addresses
/// that differ only in a tracking parameter or `www.` stay separate rows.
List<HistoryEntry> collapseToDistinctUrls(List<HistoryEntry> entries) {
  final olderByUrl = <String, List<HistoryEntry>>{};
  final newest = <HistoryEntry>[];
  for (final entry in entries) {
    final older = olderByUrl[entry.url];
    if (older == null) {
      olderByUrl[entry.url] = <HistoryEntry>[];
      newest.add(entry);
    } else {
      older.add(entry);
    }
  }

  return [
    for (final entry in newest)
      if (olderByUrl[entry.url]!.isEmpty)
        entry
      else
        HistoryEntry(
          visit: entry.visit,
          containerIds: entry.containerIds,
          containerRelationId: entry.containerRelationId,
          olderVisits: List.unmodifiable(olderByUrl[entry.url]!),
        ),
  ];
}

/// One-to-one nearest-time pairing between visits and `visit_container`
/// relations that share a canonical URL, given their epoch-millis timestamps.
///
/// Returns a map from visit index (into [visitTimes]) to the relation index
/// (into [relationTimes]) it pairs with. Pairs are assigned greedily from the
/// smallest in-window delta, consuming both sides, so a relation never tags two
/// visits and a visit never takes two relations. Shared by history annotation
/// and the per-container Places-delete mirror so they always agree on which
/// relation belongs to which visit.
Map<int, int> pairVisitsToRelationsByTime(
  List<int> visitTimes,
  List<int> relationTimes,
) {
  // All in-window (visit, relation) pairs, smallest delta first.
  final pairs = <({int visitIndex, int relationIndex, int delta})>[];
  for (var visitIndex = 0; visitIndex < visitTimes.length; visitIndex++) {
    for (
      var relationIndex = 0;
      relationIndex < relationTimes.length;
      relationIndex++
    ) {
      final delta = (relationTimes[relationIndex] - visitTimes[visitIndex])
          .abs();
      if (delta <= historyVisitContainerMatchWindowMs) {
        pairs.add((
          visitIndex: visitIndex,
          relationIndex: relationIndex,
          delta: delta,
        ));
      }
    }
  }
  pairs.sort((a, b) => a.delta.compareTo(b.delta));

  final relationByVisit = <int, int>{};
  final usedVisits = <int>{};
  final usedRelations = <int>{};
  for (final pair in pairs) {
    if (usedVisits.contains(pair.visitIndex) ||
        usedRelations.contains(pair.relationIndex)) {
      continue;
    }
    usedVisits.add(pair.visitIndex);
    usedRelations.add(pair.relationIndex);
    relationByVisit[pair.visitIndex] = pair.relationIndex;
  }
  return relationByVisit;
}

/// The visit times that must be loaded for [pairVisitsToRelationsByTime] to
/// pair the visits and relations between [rangeStart] and [rangeEnd] exactly
/// as it would over the complete history of one canonical URL, or null when
/// nothing in the range can take part in a pair (always the case for a URL
/// without relations).
///
/// Greedy pairing only links a visit and a relation within
/// [historyVisitContainerMatchWindowMs] of each other, and one pair's outcome
/// only depends on pairs sharing its visit or relation. Decisions therefore
/// propagate through components of the visit–relation graph (edges: within one
/// window), which can reach arbitrarily far through alternating visits and
/// relations, so no fixed margin around the range is enough. Visits never link
/// to each other: a run of untagged reloads needs nothing beyond the range.
///
/// Relations count as well as visits, from [relationMargin] before the range
/// to [relationMargin] after it: whether one pairs with nothing at all
/// (because its visit is one Places hides from the timeline) is only settled
/// once its whole component is loaded.
///
/// The result spans one window around every relation in a component that
/// contains such a visit or relation: a visit not yet loaded can only join
/// such a component through one of those relations. When [visitTimes] already
/// covers it, the pairing is final; if not, load the wider span and ask
/// again.
///
/// [relationTimes] must be all relations of the URL, not only a time slice.
({int start, int end})? pairingDependencyWindow({
  required List<int> visitTimes,
  required List<int> relationTimes,
  required int rangeStart,
  required int rangeEnd,
  int relationMargin = 0,
}) {
  if (relationTimes.isEmpty) return null;
  const window = historyVisitContainerMatchWindowMs;

  // Union-find over visits (0 until visitTimes.length) and relations (after).
  final parent = List<int>.generate(
    visitTimes.length + relationTimes.length,
    (index) => index,
  );
  int find(int node) {
    var root = node;
    while (parent[root] != root) {
      parent[root] = parent[parent[root]];
      root = parent[root];
    }
    return root;
  }

  final relationOrder = List<int>.generate(relationTimes.length, (i) => i)
    ..sort((a, b) => relationTimes[a].compareTo(relationTimes[b]));
  for (var visit = 0; visit < visitTimes.length; visit++) {
    final time = visitTimes[visit];
    // First relation at or after `time - window`, then every one within reach.
    var low = 0;
    var high = relationOrder.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (relationTimes[relationOrder[mid]] < time - window) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    for (var k = low; k < relationOrder.length; k++) {
      final relation = relationOrder[k];
      if (relationTimes[relation] > time + window) break;
      parent[find(visit)] = find(visitTimes.length + relation);
    }
  }

  bool inRange(int time) => time >= rangeStart && time <= rangeEnd;
  final anchoredRoots = {
    for (var visit = 0; visit < visitTimes.length; visit++)
      if (inRange(visitTimes[visit])) find(visit),
    for (var relation = 0; relation < relationTimes.length; relation++)
      if (relationTimes[relation] >= rangeStart - relationMargin &&
          relationTimes[relation] <= rangeEnd + relationMargin)
        find(visitTimes.length + relation),
  };

  int? start;
  int? end;
  for (var relation = 0; relation < relationTimes.length; relation++) {
    if (!anchoredRoots.contains(find(visitTimes.length + relation))) continue;
    final time = relationTimes[relation];
    if (start == null || time - window < start) start = time - window;
    if (end == null || time + window > end) end = time + window;
  }

  return start == null ? null : (start: start, end: end!);
}
