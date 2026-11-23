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

/// What a background tab's cancelled navigation calls for; see
/// [BackgroundStandIns.request].
sealed class BackgroundReopen {
  const BackgroundReopen();
}

/// No tab stands in for this page yet: open one, then report it with
/// [BackgroundStandIns.opened].
final class OpenStandIn extends BackgroundReopen {
  const OpenStandIn();
}

/// [tabId] stands in for this page: load the new URL in it.
final class LoadInStandIn extends BackgroundReopen {
  final String tabId;

  const LoadInStandIn(this.tabId);
}

/// The stand-in already shows this URL.
final class StandInCurrent extends BackgroundReopen {
  const StandInCurrent();
}

/// A background tab's cancelled navigation, as reported.
class StandInReport {
  final String sourceTabId;
  final Uri uri;

  /// The native store's selection when it was reported.
  final String? selectedTabId;

  /// Whether no newer report for [sourceTabId] has come in since; a newer one
  /// supersedes it, whatever its page.
  final bool Function() isCurrent;

  StandInReport({
    required this.sourceTabId,
    required this.uri,
    required this.selectedTabId,
    required this.isCurrent,
  });
}

/// A page's stand-in: the tab and the URL it shows.
class _StandIn {
  final String tabId;
  Uri url;

  _StandIn(this.tabId, this.url);
}

/// The tabs that stand in for background tabs' cancelled navigations, so a
/// page that keeps trying reuses one tab instead of opening one per attempt.
///
/// A background page that keeps navigating to a site assigned elsewhere (an
/// auto-refresh, a login redirect on every attempt) would otherwise open a new
/// hidden tab each time. Dropping the repeats instead would lose navigations
/// that only look like them: `/view?id=1` then `/view?id=2`, or a callback
/// with a fresh code. So each page (origin and path) of a background tab gets
/// one stand-in tab, and a later navigation to that page loads its URL there:
/// the latest one wins, as it would have in the tab itself. Another path of
/// the site is another page with its own stand-in.
///
/// Nobody has seen a stand-in: once either tab is selected or closed, the next
/// navigation opens a new one rather than taking over a page the user may be
/// on. [sync] applies both from the native store right before each decision:
/// the Dart tab states keep closed tabs for a while, and the selection events
/// are debounced, so a stand-in closed or picked a moment ago still looks
/// open and unseen there. [forget] covers a tab seen and left again.
///
/// The caller runs one report at a time, from [take] to [opened] or the load,
/// so no state changes under a decision but [arrived], [forget] and [retire].
///
/// The one exception to deciding by the state at a report's turn: a report
/// that came in while its page's stand-in was opening, before anyone saw that
/// tab, belongs to the stand-in. The open loads it there ([opened]), and the
/// report has nothing left to do.
///
/// A tab seen while it was being opened is never a stand-in: the user may be
/// back on it, and the native selection no longer says so once they left.
class BackgroundStandIns {
  /// By source tab, then page: its stand-in.
  final _standIns = <String, Map<String, _StandIn>>{};

  /// By source tab: its latest report whose turn has not come yet, with the
  /// tabs seen during the open in progress before it came in. Only the latest
  /// can be current ([StandInReport.isCurrent]).
  final _waiting = <String, ({StandInReport report, Set<String> seenBefore})>{};

  /// The page an [OpenStandIn] was handed out for, until [opened]; cleared by
  /// [forget]ting its source meanwhile.
  ({String sourceTabId, String page})? _opening;

  /// The tabs seen ([retire]) since the [OpenStandIn] in progress was handed
  /// out: the stand-in may be among them before its id is known.
  final _seenWhileOpening = <String>{};

  static String _pageOf(Uri uri) =>
      '${uri.origin}${uri.path.isEmpty ? '/' : uri.path}';

  /// Records [report] the moment it comes in, before it waits for its turn.
  ///
  /// The tab selected natively then ([StandInReport.selectedTabId]) was seen
  /// ([forget]), even if the report is superseded later: the debounced
  /// selection event may never come, once the user has left it again.
  void arrived(StandInReport report) {
    if (report.selectedTabId case final selected?) forget(selected);
    _waiting[report.sourceTabId] = (
      report: report,
      seenBefore: {..._seenWhileOpening},
    );
  }

  /// Whether [report] may still have something to do, without taking it: a
  /// cheap check before its turn asks the native store anything. Not when a
  /// stand-in's open loaded it ([opened]), a newer report superseded it, or
  /// its source closed.
  bool isWaiting(StandInReport report) =>
      identical(_waiting[report.sourceTabId]?.report, report) &&
      report.isCurrent();

  /// [report]'s turn is over, however it ended: its entry goes, unless a newer
  /// report has taken its place.
  void done(StandInReport report) {
    if (identical(_waiting[report.sourceTabId]?.report, report)) {
      _waiting.remove(report.sourceTabId);
    }
  }

  /// Whether [report], whose turn it is, still has something to do, right
  /// after a [sync]; see [isWaiting].
  bool take(StandInReport report) {
    if (!isWaiting(report)) return false;
    _waiting.remove(report.sourceTabId);
    return true;
  }

  /// Applies the native store's state: drops what involves a closed tab (not
  /// among [openTabIds]) and the selected tab ([selectedTabId]), and
  /// [retire]s the tabs on screen beside it ([visibleTabIds], the other page
  /// of a split pair).
  void sync({
    required Iterable<String> openTabIds,
    String? selectedTabId,
    Iterable<String> visibleTabIds = const [],
  }) {
    final open = openTabIds.toSet();
    _waiting.removeWhere((source, _) => !open.contains(source));
    _standIns.removeWhere((source, _) => !open.contains(source));
    for (final pages in _standIns.values) {
      pages.removeWhere((_, standIn) => !open.contains(standIn.tabId));
    }
    _standIns.removeWhere((_, pages) => pages.isEmpty);
    if (selectedTabId != null) forget(selectedTabId);
    visibleTabIds.forEach(retire);
  }

  /// What background tab [sourceTabId]'s cancelled navigation to [uri] calls
  /// for, right after [take]. A [LoadInStandIn] records [uri] as the URL the
  /// stand-in shows.
  BackgroundReopen request(String sourceTabId, Uri uri) {
    final page = _pageOf(uri);
    final standIn = _standIns[sourceTabId]?[page];
    if (standIn == null) {
      _opening = (sourceTabId: sourceTabId, page: page);
      _seenWhileOpening.clear();
      return const OpenStandIn();
    }
    if (standIn.url == uri) return const StandInCurrent();

    standIn.url = uri;
    return LoadInStandIn(standIn.tabId);
  }

  /// Records [standInTabId], opened on [uri] after an [OpenStandIn], as the
  /// stand-in, with [openTabIds] the tabs open now ([sync]). Returns the URL
  /// of a report that came in while it opened, for the caller to load in the
  /// stand-in right away: one for the same page, still current, and made
  /// before anyone saw the stand-in. That navigation belongs to the stand-in
  /// even if the user has picked it since; it would have loaded there had the
  /// tab been open. Any other report is left to its turn.
  ///
  /// Nothing is recorded and no report taken when the stand-in or
  /// [sourceTabId] is closed already, or when [sourceTabId] was seen while it
  /// opened: nothing stands in for it any more. A stand-in seen while it
  /// opened takes its report but is not recorded.
  ///
  /// [openTabIds] is null when the open tabs could not be listed. The
  /// stand-in is recorded all the same, or the next report would open a
  /// second one beside it, and the next [sync] drops it if it is gone; a
  /// report that came in meanwhile is left to its turn, which loads it there.
  Uri? opened(
    String sourceTabId,
    Uri uri,
    String standInTabId, {
    required Iterable<String>? openTabIds,
  }) {
    if (openTabIds != null) sync(openTabIds: openTabIds);
    final page = _pageOf(uri);
    final opening = _opening;
    final seen = {..._seenWhileOpening};
    _opening = null;
    _seenWhileOpening.clear();
    if (opening != (sourceTabId: sourceTabId, page: page) ||
        (openTabIds != null &&
            (!openTabIds.contains(sourceTabId) ||
                !openTabIds.contains(standInTabId)))) {
      return null;
    }

    final standIn = _StandIn(standInTabId, uri);
    if (!seen.contains(standInTabId)) {
      _standIns.putIfAbsent(sourceTabId, () => {})[page] = standIn;
    }
    if (openTabIds == null) return null;

    final waiting = _waiting[sourceTabId];
    if (waiting == null ||
        _pageOf(waiting.report.uri) != page ||
        waiting.seenBefore.contains(standInTabId) ||
        !waiting.report.isCurrent()) {
      return null;
    }
    _waiting.remove(sourceTabId);
    if (waiting.report.uri == uri) return null;
    standIn.url = waiting.report.uri;
    return waiting.report.uri;
  }

  /// Ends the open an [OpenStandIn] was handed out for without a tab: nothing
  /// is being opened any more.
  void openFailed() {
    _opening = null;
    _seenWhileOpening.clear();
  }

  /// [tabId] was seen: it neither has stand-ins nor stands in any more.
  void forget(String tabId) {
    _standIns.remove(tabId);
    if (_opening?.sourceTabId == tabId) _opening = null;
    retire(tabId);
  }

  /// [tabId] is on screen: it no longer stands in for anything, so the next
  /// navigation of its page opens a new stand-in rather than replace a page
  /// the user may be reading. Its own stand-ins stay: a split pair's
  /// unfocused page keeps reusing them while it stays on screen, as a page
  /// retrying there would otherwise open a tab per attempt.
  void retire(String tabId) {
    if (_opening != null) _seenWhileOpening.add(tabId);
    for (final pages in _standIns.values) {
      pages.removeWhere((_, standIn) => standIn.tabId == tabId);
    }
    _standIns.removeWhere((_, pages) => pages.isEmpty);
  }
}
