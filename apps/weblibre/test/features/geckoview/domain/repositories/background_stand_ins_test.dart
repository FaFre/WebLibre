import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';

/// A background tab whose navigation the container extension cancels gets one
/// stand-in tab per page in the assigned container, which always ends up on
/// the page's latest URL: no tab per attempt, and no navigation dropped.
void main() {
  const open = ['bg', 'other', 'standIn', 'standIn2', 'onScreen'];
  late BackgroundStandIns standIns;

  setUp(() => standIns = BackgroundStandIns());

  /// Syncs with the native store ([tabs] open, [selected] selected), then
  /// asks what a background navigation of [source] to [url] calls for.
  BackgroundReopen request(
    String url, {
    String source = 'bg',
    Iterable<String> tabs = open,
    String? selected = 'onScreen',
  }) {
    standIns.sync(openTabIds: tabs, selectedTabId: selected);
    return standIns.request(source, Uri.parse(url));
  }

  /// Requests [url] and records [standIn] as opened for it.
  void openFor(String url, String standIn, {String source = 'bg'}) {
    expect(request(url, source: source), isA<OpenStandIn>());
    expect(standIns.opened(source, Uri.parse(url), standIn), isNull);
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

  test('a navigation while the stand-in opens is loaded once it has', () {
    expect(request('https://work.example/view?id=1'), isA<OpenStandIn>());
    // Not a second tab: the one being opened picks it up.
    expect(request('https://work.example/view?id=2'), isA<StandInCurrent>());

    expect(
      standIns.opened(
        'bg',
        Uri.parse('https://work.example/view?id=1'),
        'standIn',
      ),
      Uri.parse('https://work.example/view?id=2'),
    );
    expect(request('https://work.example/view?id=3'), loadsIn('standIn'));
  });

  test('a stand-in that failed to open is given back', () {
    expect(request('https://work.example/'), isA<OpenStandIn>());
    standIns.release('bg', Uri.parse('https://work.example/?retry=1'));

    expect(request('https://work.example/'), isA<OpenStandIn>());
  });

  test('releasing never drops a stand-in that opened', () {
    openFor('https://work.example/', 'standIn');
    standIns.release('bg', Uri.parse('https://work.example/'));

    expect(request('https://work.example/?a=1'), loadsIn('standIn'));
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

  test('a stand-in seen while it opened is not recorded', () {
    expect(request('https://work.example/'), isA<OpenStandIn>());
    standIns.forget('bg');

    expect(
      standIns.opened('bg', Uri.parse('https://work.example/'), 'standIn'),
      isNull,
    );
    expect(request('https://work.example/?a=1'), isA<OpenStandIn>());
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

  test('the catch-up load stays in the stand-in once it was selected', () {
    expect(request('https://work.example/view?id=1'), isA<OpenStandIn>());
    expect(request('https://work.example/view?id=2'), isA<StandInCurrent>());
    // Selected while it opened: the navigation that came in before still
    // belongs to it, so it is handed back for loading there, not dropped and
    // not given a hidden tab of its own.
    standIns.sync(openTabIds: open, selectedTabId: 'standIn');

    expect(
      standIns.opened(
        'bg',
        Uri.parse('https://work.example/view?id=1'),
        'standIn',
      ),
      Uri.parse('https://work.example/view?id=2'),
    );
  });

  test('the catch-up load is the latest URL the page wanted', () {
    expect(request('https://work.example/view?id=1'), isA<OpenStandIn>());
    expect(request('https://work.example/view?id=2'), isA<StandInCurrent>());
    expect(request('https://work.example/view?id=3'), isA<StandInCurrent>());

    expect(
      standIns.opened(
        'bg',
        Uri.parse('https://work.example/view?id=1'),
        'standIn',
      ),
      Uri.parse('https://work.example/view?id=3'),
    );
    // One after the open loads in the stand-in by itself.
    expect(request('https://work.example/view?id=4'), loadsIn('standIn'));
  });

  test('a state asked for before a stand-in opened keeps it', () {
    expect(request('https://work.example/'), isA<OpenStandIn>());
    // Another report asks the native store now; its answer arrives after the
    // stand-in opened, and lists no such tab yet.
    final takenAt = standIns.stamp;
    expect(
      standIns.opened('bg', Uri.parse('https://work.example/'), 'new'),
      isNull,
    );
    standIns.sync(
      openTabIds: open,
      selectedTabId: 'onScreen',
      takenAt: takenAt,
    );

    // By the next report, the native store lists it.
    expect(
      request('https://work.example/?a=1', tabs: [...open, 'new']),
      loadsIn('new'),
    );
  });

  test(
    'a state asked for after a stand-in opened still drops it if closed',
    () {
      openFor('https://work.example/', 'standIn');
      final takenAt = standIns.stamp;
      standIns.sync(
        openTabIds: ['bg', 'onScreen'],
        selectedTabId: 'onScreen',
        takenAt: takenAt,
      );

      expect(request('https://work.example/?a=1'), isA<OpenStandIn>());
    },
  );

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
