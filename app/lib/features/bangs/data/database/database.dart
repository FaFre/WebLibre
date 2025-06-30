import 'package:drift/drift.dart';
import 'package:weblibre/features/bangs/data/database/daos/bang.dart';
import 'package:weblibre/features/bangs/data/database/daos/sync.dart';
import 'package:weblibre/features/bangs/data/database/drift/converters/bang_format.dart';
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/search_history_entry.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';

part 'database.g.dart';

@DriftDatabase(include: {'database.drift'}, daos: [BangDao, SyncDao])
class BangDatabase extends _$BangDatabase with PrefixQueryBuilderMixin {
  @override
  final int schemaVersion = 1;

  @override
  final int ftsTokenLimit = 6;
  @override
  final int ftsMinTokenLength = 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  BangDatabase(super.e);
}
