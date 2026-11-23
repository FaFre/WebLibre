import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab/background_stand_ins.dart';

/// A background tab whose navigation the container extension cancels gets one
/// stand-in tab per page in the assigned container, which always ends up on
/// the page's latest URL: no tab per attempt, and no navigation dropped.
void main() {
  const open = ['bg', 'other', 'standIn', 'standIn2', 'onScreen'];
  late BackgroundStandIns standIns;

  /// By source tab: its latest report, which alone is current, as the tab
  /// repository's latest request per tab.
  late Map<String, Object> latestReport;

  setUp(() {
    standIns = BackgroundStandIns();
    latestReport = {};
  });

  /// A navigation of [source] to [url] reported now, with [selected] the
  /// native selection then; it waits for its turn ([run]).
  StandInReport report(
    String url, {
    String source = 'bg',
    String? selected = 'onScreen',
  }) {
    final token = Object();
    latestReport[source] = token;
    final report = StandInReport(
      sourceTabId: source,
      uri: Uri.parse(url),
      selectedTabId: selected,
      isCurrent: () => identical(latestReport[source], token),
    );
    standIns.arrived(report);
    return report;
  }

  /// [report]'s turn, with [tabs] open and [selected] selected natively:
  /// whether it has anything left to do.
  bool run(
    StandInReport report, {
    Iterable<String> tabs = open,
    String? selected = 'onScreen',
  }) {
    standIns.sync(openTabIds: tabs, selectedTabId: selected);
    return standIns.take(report);
  }

  /// A navigation reported and run at once: what it calls for.
  BackgroundReopen request(
    String url, {
    String source = 'bg',
    Iterable<String> tabs = open,
    String? selected = 'onScreen',
  }) {
    final reported = report(url, source: source, selected: selected);
    expect(run(reported, tabs: tabs, selected: selected), isTrue);
    return standIns.request(source, reported.uri);
  }

  /// [standIn] opened on [url], with [tabs] open by then: the URL to load in
  /// it right away.
  Uri? opened(
    String url,
    String standIn, {
    String source = 'bg',
    Iterable<String> tabs = open,
  }) => standIns.opened(source, Uri.parse(url), standIn, openTabIds: tabs);

  /// Requests [url] and records [standIn] as opened for it.
  void openFor(String url, String standIn, {String source = 'bg'}) {
    expect(request(url, source: source), isA<OpenStandIn>());
    expect(opened(url, standIn, source: source), isNull);
  }

  Matcher loadsIn(String tabId) =>
      isA<LoadInStandIn>().having((r) => r.tabId, 'tabId', tabId);

  test('the first navigation to a page opens a stand-in', () {
    expect(request('https://work.example/view?id=1'), isA<OpenStandIn>());
  });

  test('the same URL again leaves the stand-in as it is', () {
    openFor('https://login.example/authorize?state=1', 'standIn');

    expect(
      request('https://login.example/authorize?state=1'),
      isA<StandInCurrent>(),
    );
  });

  test('another URL of the page loads in the stand-in, never dropped', () {
    openFor('https://work.example/view?id=1', 'standIn');

    expect(request('https://work.example/view?id=2'), loadsIn('standIn'));
    // A retry with a fresh state, or a callback with a fresh code, alike.
    expect(request('https://work.example/view?id=2#top'), loadsIn('standIn'));
    expect(
      request('https://work.example/view?id=2#top'),
      isA<StandInCurrent>(),
    );
  });

  test('another path of the site gets a stand-in of its own', () {
    openFor('https://work.example/inbox', 'standIn');

    expect(request('https://work.example/callback?code=x'), isA<OpenStandIn>());
  });

  test('an origin without a path is its root page', () {
    openFor('https://work.example', 'standIn');

    expect(request('https://work.example/?a=1'), loadsIn('standIn'));
  });

  test('stand-ins belong to their source tab', () {
    openFor('https://work.example/', 'standIn');

    expect(
      request('https://work.example/', source: 'other'),
      isA<OpenStandIn>(),
    );
  });

  group('a report while the stand-in opens', () {
    const first = 'https://work.example/view?id=1';

    test('is loaded there once it has, not given a second tab', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');

      expect(opened(first, 'standIn'), second.uri);
      expect(run(second), isFalse);
      expect(request('https://work.example/view?id=3'), loadsIn('standIn'));
    });

    test('stays in the stand-in when it was selected after the report', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');
      // Selected natively after the report came in, before the open
      // returned: the navigation still belongs to it.

      expect(opened(first, 'standIn'), second.uri);
      expect(run(second, selected: 'standIn'), isFalse);
    });

    test('made after the stand-in was selected opens another', () {
      expect(request(first), isA<OpenStandIn>());
      // Selected natively before the open returned, and before the report.
      final second = report(
        'https://work.example/view?id=2',
        selected: 'standIn',
      );

      expect(opened(first, 'standIn'), isNull);
      expect(run(second, selected: 'standIn'), isTrue);
      expect(standIns.request('bg', second.uri), isA<OpenStandIn>());
    });

    test('superseded by a newer report of another page is not loaded', () {
      expect(request('https://work.example/inbox'), isA<OpenStandIn>());
      final retry = report('https://work.example/inbox?retry=1');
      final feed = report('https://work.example/feed');

      expect(opened('https://work.example/inbox', 'standIn'), isNull);
      expect(run(retry), isFalse);
      expect(run(feed), isTrue);
    });

    test('superseded elsewhere meanwhile is not loaded', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');
      // A newer report for the tab that never became a stand-in report.
      latestReport['bg'] = Object();

      expect(opened(first, 'standIn'), isNull);
      expect(run(second), isFalse);
    });

    test('of a source closed meanwhile is not loaded', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');

      expect(
        opened(first, 'standIn', tabs: ['other', 'standIn', 'onScreen']),
        isNull,
      );
      expect(run(second, tabs: ['other', 'standIn', 'onScreen']), isFalse);
      // Undo brings "bg" back under the same id: the stand-in is not its.
      expect(request('https://work.example/view?id=3'), isA<OpenStandIn>());
    });

    test('stays queued when the new stand-in closed meanwhile', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');

      // "standIn" closed before the open was recorded.
      expect(opened(first, 'standIn', tabs: ['bg', 'onScreen']), isNull);
      expect(run(second, tabs: ['bg', 'onScreen']), isTrue);
      expect(standIns.request('bg', second.uri), isA<OpenStandIn>());
    });

    test('made after the stand-in was seen and left is not loaded', () {
      expect(request(first), isA<OpenStandIn>());
      // Selected, then left, before the open returned.
      standIns.forget('standIn');
      final second = report('https://work.example/view?id=2');

      expect(opened(first, 'standIn'), isNull);
      // Its turn opens a new stand-in: the seen one is never reused.
      expect(run(second), isTrue);
      expect(standIns.request('bg', second.uri), isA<OpenStandIn>());
    });

    test('made before the stand-in was seen and left is still loaded', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');
      standIns.forget('standIn');

      expect(opened(first, 'standIn'), second.uri);
      expect(run(second), isFalse);
      // Seen while it opened: not reused for what comes next.
      expect(request('https://work.example/view?id=3'), isA<OpenStandIn>());
    });

    test('a selection a superseded report saw keeps the stand-in unused', () {
      expect(request(first), isA<OpenStandIn>());
      // Natively selected when this came in, and left before the debounced
      // selection event fired.
      final second = report(
        'https://work.example/view?id=2',
        selected: 'standIn',
      );
      final third = report('https://work.example/view?id=3');

      expect(opened(first, 'standIn'), isNull);
      expect(run(second), isFalse);
      expect(run(third), isTrue);
      expect(standIns.request('bg', third.uri), isA<OpenStandIn>());
    });

    test('waits its turn when the open tabs could not be listed', () {
      expect(request(first), isA<OpenStandIn>());
      final second = report('https://work.example/view?id=2');

      // The listing after the open failed: recorded unchecked, no catch-up.
      expect(
        standIns.opened('bg', Uri.parse(first), 'standIn', openTabIds: null),
        isNull,
      );
      // Its turn loads it in the stand-in, not in a second tab.
      expect(run(second), isTrue);
      expect(standIns.request('bg', second.uri), loadsIn('standIn'));
    });

    test('an unchecked stand-in is dropped once it is listed closed', () {
      expect(request(first), isA<OpenStandIn>());
      expect(
        standIns.opened('bg', Uri.parse(first), 'standIn', openTabIds: null),
        isNull,
      );

      expect(
        request('https://work.example/view?id=2', tabs: ['bg', 'onScreen']),
        isA<OpenStandIn>(),
      );
    });

    test('a failed open leaves nothing in flight', () {
      expect(request(first), isA<OpenStandIn>());
      standIns.openFailed();

      // No open to record a tab for any more.
      expect(opened(first, 'standIn'), isNull);
      expect(request('https://work.example/view?id=2'), isA<OpenStandIn>());
    });

    test('of another page waits its turn', () {
      expect(request('https://work.example/inbox'), isA<OpenStandIn>());
      final feed = report('https://work.example/feed');

      expect(opened('https://work.example/inbox', 'standIn'), isNull);
      expect(run(feed), isTrue);
      expect(standIns.request('bg', feed.uri), isA<OpenStandIn>());
    });

    test('of a source seen meanwhile waits its turn', () {
      expect(request('https://work.example/'), isA<OpenStandIn>());
      final second = report('https://work.example/?a=1');
      standIns.forget('bg');

      // Nothing stands in for it any more: not recorded, and the report is
      // left to its own turn, never dropped.
      expect(opened('https://work.example/', 'standIn'), isNull);
      expect(run(second), isTrue);
      expect(standIns.request('bg', second.uri), isA<OpenStandIn>());
    });
  });

  test('a superseded report has nothing left to do', () {
    final first = report('https://work.example/view?id=1');
    final second = report('https://work.example/view?id=2');

    // Known before its turn asks native anything; checking takes nothing.
    expect(standIns.isWaiting(first), isFalse);
    expect(standIns.isWaiting(second), isTrue);
    expect(standIns.isWaiting(second), isTrue);
    expect(run(first), isFalse);
    expect(run(second), isTrue);
  });

  test('a turn that ends without taking its report clears it', () {
    var current = true;
    final queued = StandInReport(
      sourceTabId: 'bg',
      uri: Uri.parse('https://work.example/view?id=1'),
      selectedTabId: 'onScreen',
      isCurrent: () => current,
    );
    standIns.arrived(queued);
    // Superseded by a report that never became a stand-in report.
    current = false;
    expect(standIns.isWaiting(queued), isFalse);
    standIns.done(queued);

    // The entry is gone, not merely skipped while superseded.
    current = true;
    expect(standIns.isWaiting(queued), isFalse);
  });

  test('a turn that ends keeps a newer report waiting', () {
    final first = report('https://work.example/view?id=1');
    final second = report('https://work.example/view?id=2');
    standIns.done(first);

    expect(run(second), isTrue);
  });

  test('a report superseded elsewhere has nothing left to do', () {
    final queued = report('https://work.example/');
    // A newer report for the tab that never became a stand-in report.
    latestReport['bg'] = Object();

    expect(run(queued), isFalse);
  });

  test('a queued report of a closed source has nothing left to do', () {
    final queued = report('https://work.example/');

    // "bg" closed while its report waited.
    expect(run(queued, tabs: ['other', 'onScreen']), isFalse);
  });

  test('a selection a queued report saw is never taken over', () {
    openFor('https://work.example/view?id=1', 'standIn');
    // Natively selected when this came in, left again before its turn and
    // before the debounced selection event.
    final queued = report(
      'https://work.example/view?id=2',
      selected: 'standIn',
    );

    expect(run(queued), isTrue);
    expect(standIns.request('bg', queued.uri), isA<OpenStandIn>());
  });

  test('a queued report checks the selection at its turn', () {
    openFor('https://work.example/view?id=1', 'standIn');
    // Reported while another open ran; the stand-in was selected natively
    // before its turn, and the debounced selection event has not come yet.
    final queued = report('https://work.example/view?id=2');

    expect(run(queued, selected: 'standIn'), isTrue);
    expect(standIns.request('bg', queued.uri), isA<OpenStandIn>());
  });

  test('a stand-in that failed to open is tried again', () {
    expect(request('https://work.example/'), isA<OpenStandIn>());
    // Never reported as opened.

    expect(request('https://work.example/'), isA<OpenStandIn>());
  });

  test('a seen source tab starts over', () {
    openFor('https://work.example/', 'standIn');
    standIns.forget('bg');

    expect(request('https://work.example/?a=1'), isA<OpenStandIn>());
  });

  test('a seen stand-in is never taken over', () {
    openFor('https://work.example/', 'standIn');
    standIns.forget('standIn');

    expect(request('https://work.example/?a=1'), isA<OpenStandIn>());
  });

  test('another tab seen while a stand-in opened leaves it recorded', () {
    expect(request('https://work.example/'), isA<OpenStandIn>());
    standIns.forget('other');
    expect(opened('https://work.example/', 'standIn'), isNull);

    expect(request('https://work.example/?a=1'), loadsIn('standIn'));
  });

  test('a closed stand-in is replaced by a new one', () {
    openFor('https://work.example/', 'standIn');

    expect(
      request('https://work.example/?a=1', tabs: ['bg', 'other', 'onScreen']),
      isA<OpenStandIn>(),
    );
  });

  test('stand-ins of a closed source tab are dropped', () {
    openFor('https://work.example/', 'standIn');
    // "bg" closed; its id is reported again (reused) later.
    expect(
      request(
        'https://work.example/',
        source: 'other',
        tabs: ['other', 'onScreen'],
      ),
      isA<OpenStandIn>(),
    );

    expect(request('https://work.example/?a=1'), isA<OpenStandIn>());
  });

  test('a stand-in closed a moment ago is replaced, not reused', () {
    openFor('https://work.example/', 'standIn');

    // Closed natively; the Dart tab states would still list it for a while.
    expect(
      request('https://work.example/?a=1', tabs: ['bg', 'onScreen']),
      isA<OpenStandIn>(),
    );
  });

  test('a stand-in selected a moment ago is never taken over', () {
    openFor('https://work.example/', 'standIn');

    // Selected natively, before the debounced selection event arrived.
    expect(
      request('https://work.example/?a=1', selected: 'standIn'),
      isA<OpenStandIn>(),
    );
  });

  test('a stand-in shown beside the selected tab is never taken over', () {
    openFor('https://work.example/view?id=1', 'standIn');

    // A split pair shows it as the unfocused page, never selected.
    standIns.sync(
      openTabIds: open,
      selectedTabId: 'onScreen',
      visibleTabIds: ['standIn'],
    );

    expect(request('https://work.example/view?id=2'), isA<OpenStandIn>());
  });

  test(
    'a source shown beside the selected tab keeps reusing its stand-ins',
    () {
      openFor('https://work.example/view?id=1', 'standIn');

      // The unfocused page of a split pair retrying in place: one tab, not one
      // per attempt.
      standIns.sync(
        openTabIds: open,
        selectedTabId: 'onScreen',
        visibleTabIds: ['bg'],
      );

      expect(request('https://work.example/view?id=2'), loadsIn('standIn'));
    },
  );

  test('retiring a stand-in keeps the rest of its source', () {
    openFor('https://work.example/inbox', 'standIn');
    openFor('https://work.example/feed', 'standIn2');
    standIns.retire('standIn');

    expect(request('https://work.example/inbox?a=1'), isA<OpenStandIn>());
    expect(request('https://work.example/feed?a=1'), loadsIn('standIn2'));
  });
}
