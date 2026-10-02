/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_mozilla_components/src/extensions/latest_per_key_subject.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Event = ({String key, int value});

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LatestPerKeySubject', () {
    LatestPerKeySubject<String, _Event> subject() {
      final subject = LatestPerKeySubject<String, _Event>((event) => event.key);
      addTearDown(subject.close);
      return subject;
    }

    test("a late listener gets each key's latest event, newest last", () async {
      final events = subject()
        ..add((key: 'a', value: 1))
        ..add((key: 'b', value: 1))
        ..add((key: 'a', value: 2));

      await expectLater(
        events.stream,
        emitsInOrder([(key: 'b', value: 1), (key: 'a', value: 2)]),
      );
    });

    test('live events follow the replay', () async {
      final events = subject()..add((key: 'a', value: 1));

      final received = <_Event>[];
      final sub = events.stream.listen(received.add);
      addTearDown(sub.cancel);
      events.add((key: 'a', value: 2));
      await pumpEventQueue();

      expect(received, [(key: 'a', value: 1), (key: 'a', value: 2)]);
    });

    test('a key added since the last retain survives one retain', () {
      final events = subject()
        ..add((key: 'closed', value: 1))
        ..retainKeys({})
        ..add((key: 'new', value: 1));

      // `closed` was already held at the previous retain, `new` arrived since:
      // a tab's first events can precede the tab list that includes it.
      events.retainKeys({'open'});
      expect(events.values, [(key: 'new', value: 1)]);

      events.retainKeys({'open'});
      expect(events.values, isEmpty);
    });

    test('a listed key is dropped once a list omits it, however recent', () {
      final events = subject()
        ..retainKeys({'closing', 'open'})
        ..add((key: 'closing', value: 1));

      // Its last report came after the previous list, but that list had it:
      // it closed, and an unchanged list is never sent to drop it later.
      events.retainKeys({'open'});
      expect(events.values, isEmpty);

      // Undo brings the same key back ahead of the list that includes it.
      events
        ..add((key: 'closing', value: 2))
        ..retainKeys({'open'});
      expect(events.values, [(key: 'closing', value: 2)]);
    });

    test('a dropped key forgets its sequence numbers', () {
      final events = subject()
        ..addWhenMoreRecent(5, 'tab', (key: 'tab', value: 1))
        ..retainKeys({})
        ..retainKeys({});

      // A reused key starts over instead of comparing against what it had.
      expect(events.addWhenMoreRecent(1, 'tab', (key: 'tab', value: 2)), true);
    });
  });

  group('GeckoEventService', () {
    TabContentState content(String id, {String title = ''}) => TabContentState(
      id: id,
      url: 'https://$id.example/',
      title: title,
      progress: 100,
      isPrivate: false,
      isFullScreen: false,
      isLoading: false,
      showToolbarAsExpanded: false,
    );

    test('replays only the latest content state per tab', () async {
      final service = GeckoEventService.setUp();
      addTearDown(service.dispose);

      await service.onTabContentStateChange(1, content('a', title: 'One'));
      await service.onTabContentStateChange(2, content('b'));
      await service.onTabContentStateChange(3, content('a', title: 'Two'));

      await expectLater(
        service.tabContentEvents.map((state) => (state.id, state.title)),
        emitsInOrder([('b', ''), ('a', 'Two')]),
      );
    });

    test('stops replaying a tab once the tab list drops it', () async {
      final service = GeckoEventService.setUp();
      addTearDown(service.dispose);

      await service.onTabListChange(1, ['a', 'b']);
      await service.onTabContentStateChange(2, content('a'));
      await service.onTabContentStateChange(3, content('b'));
      // The only list that drops `a`: an unchanged list is not re-sent.
      await service.onTabListChange(4, ['b']);

      await expectLater(
        service.tabContentEvents.map((state) => state.id),
        emits('b'),
      );
    });

    test('a stale tab list does not prune', () async {
      final service = GeckoEventService.setUp();
      addTearDown(service.dispose);

      await service.onTabListChange(10, ['a']);
      await service.onTabContentStateChange(11, content('a'));
      await service.onTabListChange(12, ['a']);
      // Delivered late: describes the list before `a` was opened.
      await service.onTabListChange(9, []);

      await expectLater(
        service.tabContentEvents.map((state) => state.id),
        emits('a'),
      );
    });
  });
}
