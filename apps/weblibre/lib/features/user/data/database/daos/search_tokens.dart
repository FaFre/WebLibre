import 'package:drift/drift.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart';

class ReservedToken {
  final int id;
  final Uint8List token;
  const ReservedToken({required this.id, required this.token});
}

@DriftAccessor()
class SearchTokensDao extends DatabaseAccessor<UserDatabase> {
  SearchTokensDao(super.attachedDatabase);

  Future<void> addTokens(
    List<Uint8List> tokens, {
    required String issuerKeyVersion,
  }) {
    return batch((b) {
      b.insertAll(
        db.searchTokens,
        tokens
            .map(
              (t) => SearchTokensCompanion.insert(
                token: t,
                issuerKeyVersion: issuerKeyVersion,
                insertedAt: DateTime.now(),
              ),
            )
            .toList(),
      );
    });
  }

  /// Reserve the oldest unreserved token. Stamps `reserved_at` so the same
  /// row won't be handed out twice. Caller MUST follow with either
  /// [commitReserved] (server consumed it) or [releaseReserved] (we know the
  /// server didn't see it).
  Future<ReservedToken?> reserveOne() {
    return transaction(() async {
      final row =
          await (select(db.searchTokens)
                ..where((t) => t.reservedAt.isNull())
                ..orderBy([(t) => OrderingTerm.asc(t.id)])
                ..limit(1))
              .getSingleOrNull();
      if (row == null) return null;
      await (update(db.searchTokens)..where((t) => t.id.equals(row.id))).write(
        SearchTokensCompanion(reservedAt: Value(DateTime.now())),
      );
      return ReservedToken(id: row.id, token: row.token);
    });
  }

  /// Permanently delete a reserved token after a successful redemption.
  Future<void> commitReserved(int id) async {
    await (delete(db.searchTokens)..where((t) => t.id.equals(id))).go();
  }

  /// Clear the reservation so the token is handed out again. Use only when
  /// the server is known not to have consumed it.
  Future<void> releaseReserved(int id) async {
    await (update(db.searchTokens)..where((t) => t.id.equals(id))).write(
      const SearchTokensCompanion(reservedAt: Value(null)),
    );
  }

  /// Release any reservation older than [maxAge] — covers crashes mid-flight.
  /// Returns the number of rows released.
  Future<int> releaseStaleReservations(Duration maxAge) async {
    final cutoff = DateTime.now().subtract(maxAge);
    return (update(db.searchTokens)..where(
          (t) =>
              t.reservedAt.isNotNull() &
              t.reservedAt.isSmallerThanValue(cutoff),
        ))
        .write(const SearchTokensCompanion(reservedAt: Value(null)));
  }

  Future<int> count() async {
    final c = db.searchTokens.id.count();
    final query = selectOnly(db.searchTokens)
      ..addColumns([c])
      ..where(db.searchTokens.reservedAt.isNull());
    final row = await query.getSingle();
    return row.read(c) ?? 0;
  }

  Stream<int> watchCount() {
    final c = db.searchTokens.id.count();
    final query = selectOnly(db.searchTokens)
      ..addColumns([c])
      ..where(db.searchTokens.reservedAt.isNull());
    return query.map((row) => row.read(c) ?? 0).watchSingle();
  }

  Future<int> clear() {
    return delete(db.searchTokens).go();
  }
}
