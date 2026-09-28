import 'package:drift/native.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/data/database/functions/url_functions.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_filter_options.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/container_history.dart';
import 'package:weblibre/features/geckoview/features/history/domain/repositories/history.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/providers.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/local_index_pruner.dart';
import 'package:weblibre/utils/url_canonical.dart';

VisitInfo _visit(String url, int time) {
  return VisitInfo(
    url: url,
    title: url,
    visitTime: time,
    visitType: VisitType.link,
    isRemote: false,
  );
}

/// Places, filtered by time and type like the native side.
class _FakeHistoryRepository extends HistoryRepository {
  _FakeHistoryRepository(this.visits);

  final List<VisitInfo> visits;
  int queries = 0;
  final deletedRanges = <(DateTime, DateTime)>[];
  final deletedDownloadRanges = <(DateTime, DateTime)>[];

  @override
  Future<List<VisitInfo>> getDetailedVisits(HistoryFilterOptions options) {
    queries++;
    final start = options.dateRange!.start.millisecondsSinceEpoch;
    final end = options.dateRange!.end.millisecondsSinceEpoch;
    return Future.value([
      for (final visit in visits)
        if (visit.visitTime >= start &&
            visit.visitTime <= end &&
            options.visitTypes.contains(visit.visitType))
          visit,
    ]);
  }

  @override
  Future<void> deleteVisitsBetween(DateTime start, DateTime end) async {
    deletedRanges.add((start, end));
  }

  @override
  Future<void> deleteDownloadsBetween(DateTime start, DateTime end) async {
    deletedDownloadRanges.add((start, end));
  }
}

class _FakeLocalIndexPruner extends LocalIndexPruner {
  int pruned = 0;

  @override
  Future<int> prune({int batchSize = 200}) async {
    pruned++;
    return 0;
  }
}

void main() {
  group('pairingDependencyWindow', () {
    const window = historyVisitContainerMatchWindowMs;

    test('is null without a visit in the range', () {
      expect(
        pairingDependencyWindow(
          visitTimes: const [50],
          relationTimes: const [60],
          rangeStart: 100,
          rangeEnd: 200,
        ),
        isNull,
      );
    });

    test('spans the relations of the chain reaching the range', () {
      expect(
        pairingDependencyWindow(
          // 100000 in range, linked through the relation at 95000 to 91000,
          // and through it to the relation at 89990; 70000 is out of reach.
          visitTimes: const [100000, 91000, 70000],
          relationTimes: const [95000, 89990],
          rangeStart: 100000,
          rangeEnd: 110000,
        ),
        (start: 89990 - window, end: 95000 + window),
      );
    });

    test('is null for a URL without relations', () {
      expect(
        pairingDependencyWindow(
          visitTimes: const [100000, 97000, 94000],
          relationTimes: const [],
          rangeStart: 100000,
          rangeEnd: 110000,
        ),
        isNull,
      );
    });

    test('covers relations within the margin around the range', () {
      expect(
        pairingDependencyWindow(
          visitTimes: const [],
          relationTimes: const [202000],
          rangeStart: 100000,
          rangeEnd: 200000,
          relationMargin: window,
        ),
        (start: 202000 - window, end: 202000 + window),
      );
    });

    test('covers a relation in the range that no visit reaches', () {
      expect(
        pairingDependencyWindow(
          visitTimes: const [],
          relationTimes: const [150000],
          rangeStart: 100000,
          rangeEnd: 200000,
        ),
        (start: 150000 - window, end: 150000 + window),
      );
    });

    test('never links visits to each other', () {
      // A run of reloads three seconds apart leads from the range to the
      // relation at 80000, but only through visits: nothing in the range can
      // take it.
      expect(
        pairingDependencyWindow(
          visitTimes: [
            for (var time = 100000; time > 80000; time -= 3000) time,
          ],
          relationTimes: const [80000],
          rangeStart: 100000,
          rangeEnd: 110000,
        ),
        isNull,
      );
    });
  });

  group('deleteVisitsBetween', () {
    late TabDatabase db;
    late ProviderContainer container;
    late _FakeHistoryRepository history;
    late _FakeLocalIndexPruner pruner;

    setUp(() async {
      db = TabDatabase(
        NativeDatabase.memory(
          setup: (database) {
            registerLexorankFunctions(database);
            registerUrlFunctions(database);
          },
        ),
      );
      await db.customStatement(
        'INSERT INTO container (id, color, order_key, is_pinned, metadata) '
        "VALUES ('work', 0, 'work', 0, '{}')",
      );
      pruner = _FakeLocalIndexPruner();
    });

    tearDown(() async {
      container.dispose();
      await db.close();
    });

    Future<void> seed(
      List<VisitInfo> visits,
      List<({String url, int time})> tags,
    ) async {
      for (final tag in tags) {
        await db.visitContainerDao.insertRelation(
          rawUrl: '${tag.url}#${tag.time}',
          urlCanonical: canonicalizeUrl(tag.url)!.canonical,
          visitTime: tag.time,
          containerId: 'work',
        );
      }
      history = _FakeHistoryRepository(visits);
      container = ProviderContainer(
        overrides: [
          tabDatabaseProvider.overrideWith((ref) => db),
          historyRepositoryProvider.overrideWith(() => history),
          localIndexPrunerProvider.overrideWith(() => pruner),
        ],
      );
    }

    Future<void> deleteRange(int start, int end) {
      return container
          .read(containerHistoryRepositoryProvider.notifier)
          .deleteVisitsBetween(
            DateTime.fromMillisecondsSinceEpoch(start),
            DateTime.fromMillisecondsSinceEpoch(end),
          );
    }

    Future<List<int>> remainingTagTimes() async => [
      for (final row in await db.visitContainerDao.relationsForContainer(
        'work',
      ))
        row.visitTime,
    ];

    test('deletes the Places range and the download list entries in it, then '
        'prunes the local index', () async {
      await seed(const [], const []);

      await deleteRange(100000, 200000);

      final range = (
        DateTime.fromMillisecondsSinceEpoch(100000),
        DateTime.fromMillisecondsSinceEpoch(200000),
      );
      expect(history.deletedRanges, [range]);
      expect(history.deletedDownloadRanges, [range]);
      await pumpEventQueue();
      expect(pruner.pruned, 1);
    });

    test('drops the tags of the deleted visits, not the tags stamped in the '
        'range', () async {
      await seed(
        [
          _visit('https://a.example/', 199000),
          _visit('https://b.example/', 98000),
        ],
        const [
          // Stamped after the range end, for the visit inside it.
          (url: 'https://a.example/', time: 202000),
          // Stamped inside the range, for the visit before it.
          (url: 'https://b.example/', time: 101000),
        ],
      );

      await deleteRange(100000, 200000);

      expect(await remainingTagTimes(), [101000]);
    });

    test(
      'queries once for a URL reloaded every few seconds without tags',
      () async {
        const url = 'https://a.example/';
        await seed([
          for (var time = 200000; time > 0; time -= 3000) _visit(url, time),
        ], const []);

        await deleteRange(100000, 200000);

        expect(history.queries, 1);
      },
    );

    test('drops the tags of visits Places hides from the timeline', () async {
      // A redirect hop: tagged like any visit, but its URL is hidden, so the
      // visit query never returns it while the range delete removes it.
      await seed(
        [_visit('https://b.example/', 30000)],
        const [
          (url: 'https://a.example/redirect', time: 150000),
          // Same URL as a visible visit, but far from it: no visit takes it.
          (url: 'https://b.example/', time: 160000),
          // Its own visible visit, outside the range.
          (url: 'https://b.example/', time: 30500),
          // More than a window past the range: its visit can't be in it.
          (url: 'https://a.example/redirect', time: 206000),
        ],
      );

      await deleteRange(100000, 200000);

      expect(await remainingTagTimes(), [206000, 30500]);
    });

    test("drops a hidden visit's tag stamped just past the range", () async {
      // A redirect hop at 199000, inside the range, whose tag was stamped at
      // 202000. Neither the visit query nor the tags stamped in the range show
      // it, but a tag no visible visit takes within a window of the range goes.
      await seed(
        [
          // A visible visit just past the range keeps its own tag.
          _visit('https://c.example/', 203000),
        ],
        const [
          (url: 'https://a.example/redirect', time: 202000),
          (url: 'https://c.example/', time: 203500),
        ],
      );

      await deleteRange(100000, 200000);

      expect(await remainingTagTimes(), [203500]);
    });

    test('pairs over the whole chain, however far it reaches', () async {
      // The in-range visit at 100000 and the surviving one at 91000 both lie
      // within a window of the tag at 95000, which belongs to 91000: the tag
      // at 89990 is taken by the exact-time visit at 89990. That visit is
      // more than two windows before the range, so a fixed margin would
      // miss it and give 91000 the tag at 89990 instead, deleting the tag at
      // 95000 with 100000.
      const url = 'https://a.example/';
      await seed(
        [_visit(url, 100000), _visit(url, 91000), _visit(url, 89990)],
        const [(url: url, time: 95000), (url: url, time: 89990)],
      );

      await deleteRange(100000, 200000);

      expect(await remainingTagTimes(), [95000, 89990]);
    });
  });
}
