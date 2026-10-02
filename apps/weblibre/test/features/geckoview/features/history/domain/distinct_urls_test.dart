import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/history/domain/entities/history_entry.dart';

HistoryEntry _entry(
  String url,
  int time, {
  List<String> containers = const [],
}) {
  return HistoryEntry(
    visit: VisitInfo(
      url: url,
      title: url,
      visitTime: time,
      visitType: VisitType.link,
      isRemote: false,
    ),
    containerIds: containers,
  );
}

void main() {
  group('collapseToDistinctUrls', () {
    test('keeps the newest visit of each URL in timeline order', () {
      final entries = [
        _entry('https://a.example/', 50),
        _entry('https://b.example/', 40),
        _entry('https://a.example/', 30),
        _entry('https://c.example/', 20),
        _entry('https://a.example/', 10),
      ];

      final distinct = collapseToDistinctUrls(entries);

      expect(
        [for (final entry in distinct) (entry.url, entry.visitTime)],
        [
          ('https://a.example/', 50),
          ('https://b.example/', 40),
          ('https://c.example/', 20),
        ],
      );
    });

    test('carries the older visits, so deleting a row covers all of them', () {
      final distinct = collapseToDistinctUrls([
        _entry('https://a.example/', 50, containers: const ['work']),
        _entry('https://a.example/', 30),
        _entry('https://a.example/', 10),
      ]);

      final row = distinct.single;
      expect(row.containerIds, ['work']);
      expect([for (final visit in row.olderVisits) visit.visitTime], [30, 10]);
      expect(
        [for (final visit in row.allVisits) visit.visitTime],
        [50, 30, 10],
      );
    });

    test('leaves single visits untouched', () {
      final single = _entry('https://b.example/', 40);

      final distinct = collapseToDistinctUrls([single]);

      expect(identical(distinct.single, single), isTrue);
      expect(single.olderVisits, isEmpty);
      expect(single.allVisits, [single]);
    });

    test('a row matches filter text through the visits it stands for', () {
      HistoryEntry download(String path, int time) => HistoryEntry(
        visit: VisitInfo(
          url: 'https://a.example/file',
          title: path,
          visitTime: time,
          visitType: VisitType.download,
          isRemote: false,
        ),
        containerIds: const [],
      );

      final row = collapseToDistinctUrls([
        download('/downloads/report-v2.pdf', 20),
        download('/downloads/report-v1.pdf', 10),
      ]).single;

      expect(row.matchesText('v1'), isTrue);
      expect(row.matchesText('a.example'), isTrue);
      expect(row.matchesText('v3'), isFalse);
    });

    test('compares URLs exactly', () {
      final distinct = collapseToDistinctUrls([
        _entry('https://a.example/?utm_source=x', 20),
        _entry('https://a.example/', 10),
        _entry('https://www.a.example/', 5),
      ]);

      expect(distinct, hasLength(3));
    });
  });

  group('matchesText', () {
    HistoryEntry titled(String title, String url) => HistoryEntry(
      visit: VisitInfo(
        url: url,
        title: title,
        visitTime: 0,
        visitType: VisitType.link,
        isRemote: false,
      ),
      containerIds: const [],
    );

    test('matches the title or URL regardless of case', () {
      final entry = titled('Fox News', 'https://Example.org/Path');

      expect(entry.matchesText('fox n'), isTrue);
      expect(entry.matchesText('example.org/path'), isTrue);
      expect(entry.matchesText('wolf'), isFalse);
    });

    test('does not match across the end of one field into the next', () {
      final entry = titled('abc', 'https://def.example/');

      expect(entry.matchesText('chttps'), isFalse);
    });
  });
}
