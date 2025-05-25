import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show Color;
import 'package:weblibre/data/database/converters/color.dart';
import 'package:weblibre/data/database/converters/uri.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/converters/container_metadata_converter.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:weblibre/features/search/domain/fts_tokenizer.dart';

part 'database.g.dart';

@DriftDatabase(include: {'database.drift'}, daos: [ContainerDao, TabDao])
class TabDatabase extends _$TabDatabase with TrigramQueryBuilderMixin {
  @override
  final int schemaVersion = 2;

  @override
  final int ftsTokenLimit = 10;
  @override
  final int ftsMinTokenLength = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
      await optimizeFtsIndex();
    },
  );

  TabDatabase(super.e);
}
