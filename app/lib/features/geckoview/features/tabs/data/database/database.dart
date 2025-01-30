import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show Color, IconData;
import 'package:lensai/data/database/converters/color.dart';
import 'package:lensai/data/database/converters/icon_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/daos/container.dart';
import 'package:lensai/features/geckoview/features/tabs/data/database/daos/tab.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:lensai/features/geckoview/features/tabs/data/models/tab_query_result.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/database/daos/vector.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/database/database.dart';
import 'package:lensai/features/geckoview/features/tabs/features/vector_store/data/models/vector_result.dart';
import 'package:lensai/features/search/domain/fts_tokenizer.dart';

part 'database.g.dart';

@DriftDatabase(
  include: {'database.drift'},
  daos: [ContainerDao, TabDao, VectorDao],
)
class TabDatabase extends _$TabDatabase with TrigramQueryBuilderMixin {
  final int embeddingDimensions;

  @override
  final int schemaVersion = 2;

  @override
  final int ftsTokenLimit = 10;
  @override
  final int ftsMinTokenLength = 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          final migrator =
              VectorDatabaseMigrator(dimensions: embeddingDimensions);

          await m.database.customStatement(migrator.vectorTableDefinition);

          //instead of m.createAll(); we igoner vec0 table
          for (final entity
              in allSchemaEntities.where((entity) => entity is! DocumentVec)) {
            await m.create(entity);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
          await optimizeFtsIndex();
        },
      );

  TabDatabase(super.e, {required this.embeddingDimensions});
}
