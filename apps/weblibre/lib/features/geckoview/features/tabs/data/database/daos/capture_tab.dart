import 'package:drift/drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/capture_tab.drift.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/database.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart';

enum CaptureTabStatus { pending, ready, failed }

String _statusToDb(CaptureTabStatus status) => status.name;

CaptureTabStatus _statusFromDb(String raw) => CaptureTabStatus.values
    .firstWhere((s) => s.name == raw, orElse: () => CaptureTabStatus.pending);

@DriftAccessor()
class CaptureTabDao extends DatabaseAccessor<TabDatabase>
    with $CaptureTabDaoMixin {
  CaptureTabDao(super.db);

  Future<void> upsert({
    required String tabId,
    required String captureId,
    required String sourceUrl,
    required CaptureTabStatus status,
    DateTime? createdAt,
  }) {
    return into(db.captureTab).insert(
      CaptureTabCompanion.insert(
        tabId: tabId,
        captureId: captureId,
        sourceUrl: sourceUrl,
        status: Value(_statusToDb(status)),
        createdAt: createdAt ?? DateTime.now(),
      ),
      mode: InsertMode.insertOrReplace,
    );
  }

  Future<void> updateStatus(String tabId, CaptureTabStatus status) {
    return (update(db.captureTab)..where((t) => t.tabId.equals(tabId))).write(
      CaptureTabCompanion(status: Value(_statusToDb(status))),
    );
  }

  Future<void> updateCaptureId(String tabId, String captureId) {
    return (update(db.captureTab)..where((t) => t.tabId.equals(tabId))).write(
      CaptureTabCompanion(captureId: Value(captureId)),
    );
  }

  Future<int> deleteByTabId(String tabId) {
    return (delete(db.captureTab)..where((t) => t.tabId.equals(tabId))).go();
  }

  Future<CaptureTabData?> findByTabId(String tabId) {
    return (select(
      db.captureTab,
    )..where((t) => t.tabId.equals(tabId))).getSingleOrNull();
  }

  Future<List<CaptureTabData>> findAll() {
    return select(db.captureTab).get();
  }

  Stream<List<CaptureTabData>> watchAll() {
    return select(db.captureTab).watch();
  }

  CaptureTabStatus readStatus(CaptureTabData row) => _statusFromDb(row.status);
}
