// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart'
    as i1;
import 'dart:ui' as i2;
import 'package:weblibre/features/geckoview/features/tabs/data/database/definitions.drift.dart'
    as i3;
import 'package:weblibre/data/database/converters/color.dart' as i4;
import 'package:weblibre/features/geckoview/features/tabs/data/database/converters/container_metadata_converter.dart'
    as i5;
import 'package:weblibre/data/database/converters/uri.dart' as i6;
import 'package:drift/internal/modular.dart' as i7;
import 'package:weblibre/features/geckoview/features/tabs/data/models/tab_query_result.dart'
    as i8;
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart'
    as i9;

typedef $ContainerCreateCompanionBuilder =
    i3.ContainerCompanion Function({
      required String id,
      i0.Value<String?> name,
      required i2.Color color,
      i0.Value<i1.ContainerMetadata?> metadata,
      i0.Value<int> rowid,
    });
typedef $ContainerUpdateCompanionBuilder =
    i3.ContainerCompanion Function({
      i0.Value<String> id,
      i0.Value<String?> name,
      i0.Value<i2.Color> color,
      i0.Value<i1.ContainerMetadata?> metadata,
      i0.Value<int> rowid,
    });

final class $ContainerReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i3.Container,
          i1.ContainerData
        > {
  $ContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static i0.MultiTypedResultKey<i3.Tab, List<i3.TabData>> _tabRefsTable(
    i0.GeneratedDatabase db,
  ) => i0.MultiTypedResultKey.fromTable(
    i7.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab'),
    aliasName: i0.$_aliasNameGenerator(
      i7.ReadDatabaseContainer(db).resultSet<i3.Container>('container').id,
      i7.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab').containerId,
    ),
  );

  i3.$TabProcessedTableManager get tabRefs {
    final manager = i3
        .$TabTableManager(
          $_db,
          i7.ReadDatabaseContainer($_db).resultSet<i3.Tab>('tab'),
        )
        .filter((f) => f.containerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ContainerFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<i2.Color, i2.Color, int> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<
    i1.ContainerMetadata?,
    i1.ContainerMetadata,
    String
  >
  get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.Expression<bool> tabRefs(
    i0.Expression<bool> Function(i3.$TabFilterComposer f) f,
  ) {
    final i3.$TabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i7.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabFilterComposer(
            $db: $db,
            $table: i7.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContainerOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $ContainerAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.Container> {
  $ContainerAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i2.Color, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i1.ContainerMetadata?, String>
  get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  i0.Expression<T> tabRefs<T extends Object>(
    i0.Expression<T> Function(i3.$TabAnnotationComposer a) f,
  ) {
    final i3.$TabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i7.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$TabAnnotationComposer(
            $db: $db,
            $table: i7.ReadDatabaseContainer($db).resultSet<i3.Tab>('tab'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContainerTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.Container,
          i1.ContainerData,
          i3.$ContainerFilterComposer,
          i3.$ContainerOrderingComposer,
          i3.$ContainerAnnotationComposer,
          $ContainerCreateCompanionBuilder,
          $ContainerUpdateCompanionBuilder,
          (i1.ContainerData, i3.$ContainerReferences),
          i1.ContainerData,
          i0.PrefetchHooks Function({bool tabRefs})
        > {
  $ContainerTableManager(i0.GeneratedDatabase db, i3.Container table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$ContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$ContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$ContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String?> name = const i0.Value.absent(),
                i0.Value<i2.Color> color = const i0.Value.absent(),
                i0.Value<i1.ContainerMetadata?> metadata =
                    const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ContainerCompanion(
                id: id,
                name: name,
                color: color,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                i0.Value<String?> name = const i0.Value.absent(),
                required i2.Color color,
                i0.Value<i1.ContainerMetadata?> metadata =
                    const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.ContainerCompanion.insert(
                id: id,
                name: name,
                color: color,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), i3.$ContainerReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tabRefs = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (tabRefs)
                  i7.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab'),
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabRefs)
                    await i0.$_getPrefetchedData<
                      i1.ContainerData,
                      i3.Container,
                      i3.TabData
                    >(
                      currentTable: table,
                      referencedTable: i3.$ContainerReferences._tabRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          i3.$ContainerReferences(db, table, p0).tabRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.containerId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ContainerProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.Container,
      i1.ContainerData,
      i3.$ContainerFilterComposer,
      i3.$ContainerOrderingComposer,
      i3.$ContainerAnnotationComposer,
      $ContainerCreateCompanionBuilder,
      $ContainerUpdateCompanionBuilder,
      (i1.ContainerData, i3.$ContainerReferences),
      i1.ContainerData,
      i0.PrefetchHooks Function({bool tabRefs})
    >;
typedef $TabCreateCompanionBuilder =
    i3.TabCompanion Function({
      required String id,
      i0.Value<String?> parentId,
      i0.Value<String?> containerId,
      required String orderKey,
      i0.Value<Uri?> url,
      i0.Value<String?> title,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      required DateTime timestamp,
      i0.Value<int> rowid,
    });
typedef $TabUpdateCompanionBuilder =
    i3.TabCompanion Function({
      i0.Value<String> id,
      i0.Value<String?> parentId,
      i0.Value<String?> containerId,
      i0.Value<String> orderKey,
      i0.Value<Uri?> url,
      i0.Value<String?> title,
      i0.Value<bool?> isProbablyReaderable,
      i0.Value<String?> extractedContentMarkdown,
      i0.Value<String?> extractedContentPlain,
      i0.Value<String?> fullContentMarkdown,
      i0.Value<String?> fullContentPlain,
      i0.Value<DateTime> timestamp,
      i0.Value<int> rowid,
    });

final class $TabReferences
    extends i0.BaseReferences<i0.GeneratedDatabase, i3.Tab, i3.TabData> {
  $TabReferences(super.$_db, super.$_table, super.$_typedResult);

  static i3.Container _containerIdTable(i0.GeneratedDatabase db) =>
      i7.ReadDatabaseContainer(db)
          .resultSet<i3.Container>('container')
          .createAlias(
            i0.$_aliasNameGenerator(
              i7.ReadDatabaseContainer(db).resultSet<i3.Tab>('tab').containerId,
              i7.ReadDatabaseContainer(
                db,
              ).resultSet<i3.Container>('container').id,
            ),
          );

  i3.$ContainerProcessedTableManager? get containerId {
    final $_column = $_itemColumn<String>('container_id');
    if ($_column == null) return null;
    final manager = i3
        .$ContainerTableManager(
          $_db,
          i7.ReadDatabaseContainer($_db).resultSet<i3.Container>('container'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TabFilterComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => i0.ColumnFilters(column),
  );

  i3.$ContainerFilterComposer get containerId {
    final i3.$ContainerFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i7.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerFilterComposer(
            $db: $db,
            $table: i7.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabOrderingComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i3.$ContainerOrderingComposer get containerId {
    final i3.$ContainerOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i7.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerOrderingComposer(
            $db: $db,
            $table: i7.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabAnnotationComposer extends i0.Composer<i0.GeneratedDatabase, i3.Tab> {
  $TabAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  i0.GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  i3.$ContainerAnnotationComposer get containerId {
    final i3.$ContainerAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: i7.ReadDatabaseContainer(
        $db,
      ).resultSet<i3.Container>('container'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i3.$ContainerAnnotationComposer(
            $db: $db,
            $table: i7.ReadDatabaseContainer(
              $db,
            ).resultSet<i3.Container>('container'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.Tab,
          i3.TabData,
          i3.$TabFilterComposer,
          i3.$TabOrderingComposer,
          i3.$TabAnnotationComposer,
          $TabCreateCompanionBuilder,
          $TabUpdateCompanionBuilder,
          (i3.TabData, i3.$TabReferences),
          i3.TabData,
          i0.PrefetchHooks Function({bool containerId})
        > {
  $TabTableManager(i0.GeneratedDatabase db, i3.Tab table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$TabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$TabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$TabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String?> parentId = const i0.Value.absent(),
                i0.Value<String?> containerId = const i0.Value.absent(),
                i0.Value<String> orderKey = const i0.Value.absent(),
                i0.Value<Uri?> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                i0.Value<DateTime> timestamp = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabCompanion(
                id: id,
                parentId: parentId,
                containerId: containerId,
                orderKey: orderKey,
                url: url,
                title: title,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                timestamp: timestamp,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                i0.Value<String?> parentId = const i0.Value.absent(),
                i0.Value<String?> containerId = const i0.Value.absent(),
                required String orderKey,
                i0.Value<Uri?> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
                i0.Value<String?> extractedContentMarkdown =
                    const i0.Value.absent(),
                i0.Value<String?> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
                i0.Value<String?> fullContentPlain = const i0.Value.absent(),
                required DateTime timestamp,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabCompanion.insert(
                id: id,
                parentId: parentId,
                containerId: containerId,
                orderKey: orderKey,
                url: url,
                title: title,
                isProbablyReaderable: isProbablyReaderable,
                extractedContentMarkdown: extractedContentMarkdown,
                extractedContentPlain: extractedContentPlain,
                fullContentMarkdown: fullContentMarkdown,
                fullContentPlain: fullContentPlain,
                timestamp: timestamp,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i3.$TabReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({containerId = false}) {
            return i0.PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends i0.TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (containerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.containerId,
                                referencedTable: i3.$TabReferences
                                    ._containerIdTable(db),
                                referencedColumn: i3.$TabReferences
                                    ._containerIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $TabProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.Tab,
      i3.TabData,
      i3.$TabFilterComposer,
      i3.$TabOrderingComposer,
      i3.$TabAnnotationComposer,
      $TabCreateCompanionBuilder,
      $TabUpdateCompanionBuilder,
      (i3.TabData, i3.$TabReferences),
      i3.TabData,
      i0.PrefetchHooks Function({bool containerId})
    >;
typedef $TabFtsCreateCompanionBuilder =
    i3.TabFtsCompanion Function({
      required String title,
      required String url,
      required String extractedContentPlain,
      required String fullContentPlain,
      i0.Value<int> rowid,
    });
typedef $TabFtsUpdateCompanionBuilder =
    i3.TabFtsCompanion Function({
      i0.Value<String> title,
      i0.Value<String> url,
      i0.Value<String> extractedContentPlain,
      i0.Value<String> fullContentPlain,
      i0.Value<int> rowid,
    });

class $TabFtsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $TabFtsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $TabFtsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i3.TabFts> {
  $TabFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );
}

class $TabFtsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i3.TabFts,
          i3.TabFt,
          i3.$TabFtsFilterComposer,
          i3.$TabFtsOrderingComposer,
          i3.$TabFtsAnnotationComposer,
          $TabFtsCreateCompanionBuilder,
          $TabFtsUpdateCompanionBuilder,
          (
            i3.TabFt,
            i0.BaseReferences<i0.GeneratedDatabase, i3.TabFts, i3.TabFt>,
          ),
          i3.TabFt,
          i0.PrefetchHooks Function()
        > {
  $TabFtsTableManager(i0.GeneratedDatabase db, i3.TabFts table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i3.$TabFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i3.$TabFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i3.$TabFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> title = const i0.Value.absent(),
                i0.Value<String> url = const i0.Value.absent(),
                i0.Value<String> extractedContentPlain =
                    const i0.Value.absent(),
                i0.Value<String> fullContentPlain = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabFtsCompanion(
                title: title,
                url: url,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String url,
                required String extractedContentPlain,
                required String fullContentPlain,
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i3.TabFtsCompanion.insert(
                title: title,
                url: url,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TabFtsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i3.TabFts,
      i3.TabFt,
      i3.$TabFtsFilterComposer,
      i3.$TabFtsOrderingComposer,
      i3.$TabFtsAnnotationComposer,
      $TabFtsCreateCompanionBuilder,
      $TabFtsUpdateCompanionBuilder,
      (i3.TabFt, i0.BaseReferences<i0.GeneratedDatabase, i3.TabFts, i3.TabFt>),
      i3.TabFt,
      i0.PrefetchHooks Function()
    >;

class Container extends i0.Table
    with i0.TableInfo<Container, i1.ContainerData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Container(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> name = i0.GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<i2.Color, int> color =
      i0.GeneratedColumn<int>(
        'color',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i2.Color>(i3.Container.$convertercolor);
  late final i0.GeneratedColumnWithTypeConverter<i1.ContainerMetadata?, String>
  metadata = i0.GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<i1.ContainerMetadata?>(i3.Container.$convertermetadatan);
  @override
  List<i0.GeneratedColumn> get $columns => [id, name, color, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'container';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.ContainerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.ContainerData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      color: i3.Container.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}color'],
        )!,
      ),
      metadata: i3.Container.$convertermetadatan.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}metadata'],
        ),
      ),
    );
  }

  @override
  Container createAlias(String alias) {
    return Container(attachedDatabase, alias);
  }

  static i0.TypeConverter<i2.Color, int> $convertercolor =
      const i4.ColorConverter();
  static i0.TypeConverter<i1.ContainerMetadata, String> $convertermetadata =
      const i5.ContainerMetadataConverter();
  static i0.TypeConverter<i1.ContainerMetadata?, String?> $convertermetadatan =
      i0.NullAwareTypeConverter.wrap($convertermetadata);
  @override
  bool get dontWriteConstraints => true;
}

class ContainerCompanion extends i0.UpdateCompanion<i1.ContainerData> {
  final i0.Value<String> id;
  final i0.Value<String?> name;
  final i0.Value<i2.Color> color;
  final i0.Value<i1.ContainerMetadata?> metadata;
  final i0.Value<int> rowid;
  const ContainerCompanion({
    this.id = const i0.Value.absent(),
    this.name = const i0.Value.absent(),
    this.color = const i0.Value.absent(),
    this.metadata = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  ContainerCompanion.insert({
    required String id,
    this.name = const i0.Value.absent(),
    required i2.Color color,
    this.metadata = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       color = i0.Value(color);
  static i0.Insertable<i1.ContainerData> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? name,
    i0.Expression<int>? color,
    i0.Expression<String>? metadata,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.ContainerCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String?>? name,
    i0.Value<i2.Color>? color,
    i0.Value<i1.ContainerMetadata?>? metadata,
    i0.Value<int>? rowid,
  }) {
    return i3.ContainerCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = i0.Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = i0.Variable<int>(
        i3.Container.$convertercolor.toSql(color.value),
      );
    }
    if (metadata.present) {
      map['metadata'] = i0.Variable<String>(
        i3.Container.$convertermetadatan.toSql(metadata.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContainerCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Tab extends i0.Table with i0.TableInfo<Tab, i3.TabData> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tab(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final i0.GeneratedColumn<String> parentId = i0.GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES tab(id)ON DELETE SET NULL',
  );
  late final i0.GeneratedColumn<String> containerId =
      i0.GeneratedColumn<String>(
        'container_id',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: 'REFERENCES container(id)ON DELETE CASCADE',
      );
  late final i0.GeneratedColumn<String> orderKey = i0.GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i3.Tab.$converterurl);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<bool> isProbablyReaderable =
      i0.GeneratedColumn<bool>(
        'is_probably_readerable',
        aliasedName,
        true,
        type: i0.DriftSqlType.bool,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentMarkdown =
      i0.GeneratedColumn<String>(
        'extracted_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentMarkdown =
      i0.GeneratedColumn<String>(
        'full_content_markdown',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> timestamp =
      i0.GeneratedColumn<DateTime>(
        'timestamp',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    parentId,
    containerId,
    orderKey,
    url,
    title,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    timestamp,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i3.TabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.TabData(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      containerId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}container_id'],
      ),
      orderKey: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      url: i3.Tab.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      isProbablyReaderable: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}is_probably_readerable'],
      ),
      extractedContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_markdown'],
      ),
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      ),
      fullContentMarkdown: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_markdown'],
      ),
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri?, String?> $converterurl =
      const i6.UriConverterNullable();
  @override
  bool get dontWriteConstraints => true;
}

class TabData extends i0.DataClass implements i0.Insertable<i3.TabData> {
  final String id;
  final String? parentId;
  final String? containerId;
  final String orderKey;
  final Uri? url;
  final String? title;
  final bool? isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final DateTime timestamp;
  const TabData({
    required this.id,
    this.parentId,
    this.containerId,
    required this.orderKey,
    this.url,
    this.title,
    this.isProbablyReaderable,
    this.extractedContentMarkdown,
    this.extractedContentPlain,
    this.fullContentMarkdown,
    this.fullContentPlain,
    required this.timestamp,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = i0.Variable<String>(parentId);
    }
    if (!nullToAbsent || containerId != null) {
      map['container_id'] = i0.Variable<String>(containerId);
    }
    map['order_key'] = i0.Variable<String>(orderKey);
    if (!nullToAbsent || url != null) {
      map['url'] = i0.Variable<String>(i3.Tab.$converterurl.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    if (!nullToAbsent || isProbablyReaderable != null) {
      map['is_probably_readerable'] = i0.Variable<bool>(isProbablyReaderable);
    }
    if (!nullToAbsent || extractedContentMarkdown != null) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown,
      );
    }
    if (!nullToAbsent || extractedContentPlain != null) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain,
      );
    }
    if (!nullToAbsent || fullContentMarkdown != null) {
      map['full_content_markdown'] = i0.Variable<String>(fullContentMarkdown);
    }
    if (!nullToAbsent || fullContentPlain != null) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    }
    map['timestamp'] = i0.Variable<DateTime>(timestamp);
    return map;
  }

  factory TabData.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parent_id']),
      containerId: serializer.fromJson<String?>(json['container_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      url: serializer.fromJson<Uri?>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      isProbablyReaderable: serializer.fromJson<bool?>(
        json['is_probably_readerable'],
      ),
      extractedContentMarkdown: serializer.fromJson<String?>(
        json['extracted_content_markdown'],
      ),
      extractedContentPlain: serializer.fromJson<String?>(
        json['extracted_content_plain'],
      ),
      fullContentMarkdown: serializer.fromJson<String?>(
        json['full_content_markdown'],
      ),
      fullContentPlain: serializer.fromJson<String?>(
        json['full_content_plain'],
      ),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parent_id': serializer.toJson<String?>(parentId),
      'container_id': serializer.toJson<String?>(containerId),
      'order_key': serializer.toJson<String>(orderKey),
      'url': serializer.toJson<Uri?>(url),
      'title': serializer.toJson<String?>(title),
      'is_probably_readerable': serializer.toJson<bool?>(isProbablyReaderable),
      'extracted_content_markdown': serializer.toJson<String?>(
        extractedContentMarkdown,
      ),
      'extracted_content_plain': serializer.toJson<String?>(
        extractedContentPlain,
      ),
      'full_content_markdown': serializer.toJson<String?>(fullContentMarkdown),
      'full_content_plain': serializer.toJson<String?>(fullContentPlain),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  i3.TabData copyWith({
    String? id,
    i0.Value<String?> parentId = const i0.Value.absent(),
    i0.Value<String?> containerId = const i0.Value.absent(),
    String? orderKey,
    i0.Value<Uri?> url = const i0.Value.absent(),
    i0.Value<String?> title = const i0.Value.absent(),
    i0.Value<bool?> isProbablyReaderable = const i0.Value.absent(),
    i0.Value<String?> extractedContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> extractedContentPlain = const i0.Value.absent(),
    i0.Value<String?> fullContentMarkdown = const i0.Value.absent(),
    i0.Value<String?> fullContentPlain = const i0.Value.absent(),
    DateTime? timestamp,
  }) => i3.TabData(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    containerId: containerId.present ? containerId.value : this.containerId,
    orderKey: orderKey ?? this.orderKey,
    url: url.present ? url.value : this.url,
    title: title.present ? title.value : this.title,
    isProbablyReaderable: isProbablyReaderable.present
        ? isProbablyReaderable.value
        : this.isProbablyReaderable,
    extractedContentMarkdown: extractedContentMarkdown.present
        ? extractedContentMarkdown.value
        : this.extractedContentMarkdown,
    extractedContentPlain: extractedContentPlain.present
        ? extractedContentPlain.value
        : this.extractedContentPlain,
    fullContentMarkdown: fullContentMarkdown.present
        ? fullContentMarkdown.value
        : this.fullContentMarkdown,
    fullContentPlain: fullContentPlain.present
        ? fullContentPlain.value
        : this.fullContentPlain,
    timestamp: timestamp ?? this.timestamp,
  );
  TabData copyWithCompanion(i3.TabCompanion data) {
    return TabData(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      containerId: data.containerId.present
          ? data.containerId.value
          : this.containerId,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      isProbablyReaderable: data.isProbablyReaderable.present
          ? data.isProbablyReaderable.value
          : this.isProbablyReaderable,
      extractedContentMarkdown: data.extractedContentMarkdown.present
          ? data.extractedContentMarkdown.value
          : this.extractedContentMarkdown,
      extractedContentPlain: data.extractedContentPlain.present
          ? data.extractedContentPlain.value
          : this.extractedContentPlain,
      fullContentMarkdown: data.fullContentMarkdown.present
          ? data.fullContentMarkdown.value
          : this.fullContentMarkdown,
      fullContentPlain: data.fullContentPlain.present
          ? data.fullContentPlain.value
          : this.fullContentPlain,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    containerId,
    orderKey,
    url,
    title,
    isProbablyReaderable,
    extractedContentMarkdown,
    extractedContentPlain,
    fullContentMarkdown,
    fullContentPlain,
    timestamp,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.TabData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.containerId == this.containerId &&
          other.orderKey == this.orderKey &&
          other.url == this.url &&
          other.title == this.title &&
          other.isProbablyReaderable == this.isProbablyReaderable &&
          other.extractedContentMarkdown == this.extractedContentMarkdown &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentMarkdown == this.fullContentMarkdown &&
          other.fullContentPlain == this.fullContentPlain &&
          other.timestamp == this.timestamp);
}

class TabCompanion extends i0.UpdateCompanion<i3.TabData> {
  final i0.Value<String> id;
  final i0.Value<String?> parentId;
  final i0.Value<String?> containerId;
  final i0.Value<String> orderKey;
  final i0.Value<Uri?> url;
  final i0.Value<String?> title;
  final i0.Value<bool?> isProbablyReaderable;
  final i0.Value<String?> extractedContentMarkdown;
  final i0.Value<String?> extractedContentPlain;
  final i0.Value<String?> fullContentMarkdown;
  final i0.Value<String?> fullContentPlain;
  final i0.Value<DateTime> timestamp;
  final i0.Value<int> rowid;
  const TabCompanion({
    this.id = const i0.Value.absent(),
    this.parentId = const i0.Value.absent(),
    this.containerId = const i0.Value.absent(),
    this.orderKey = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.timestamp = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TabCompanion.insert({
    required String id,
    this.parentId = const i0.Value.absent(),
    this.containerId = const i0.Value.absent(),
    required String orderKey,
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.isProbablyReaderable = const i0.Value.absent(),
    this.extractedContentMarkdown = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentMarkdown = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    required DateTime timestamp,
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       orderKey = i0.Value(orderKey),
       timestamp = i0.Value(timestamp);
  static i0.Insertable<i3.TabData> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? parentId,
    i0.Expression<String>? containerId,
    i0.Expression<String>? orderKey,
    i0.Expression<String>? url,
    i0.Expression<String>? title,
    i0.Expression<bool>? isProbablyReaderable,
    i0.Expression<String>? extractedContentMarkdown,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentMarkdown,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<DateTime>? timestamp,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (containerId != null) 'container_id': containerId,
      if (orderKey != null) 'order_key': orderKey,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (isProbablyReaderable != null)
        'is_probably_readerable': isProbablyReaderable,
      if (extractedContentMarkdown != null)
        'extracted_content_markdown': extractedContentMarkdown,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentMarkdown != null)
        'full_content_markdown': fullContentMarkdown,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.TabCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String?>? parentId,
    i0.Value<String?>? containerId,
    i0.Value<String>? orderKey,
    i0.Value<Uri?>? url,
    i0.Value<String?>? title,
    i0.Value<bool?>? isProbablyReaderable,
    i0.Value<String?>? extractedContentMarkdown,
    i0.Value<String?>? extractedContentPlain,
    i0.Value<String?>? fullContentMarkdown,
    i0.Value<String?>? fullContentPlain,
    i0.Value<DateTime>? timestamp,
    i0.Value<int>? rowid,
  }) {
    return i3.TabCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      containerId: containerId ?? this.containerId,
      orderKey: orderKey ?? this.orderKey,
      url: url ?? this.url,
      title: title ?? this.title,
      isProbablyReaderable: isProbablyReaderable ?? this.isProbablyReaderable,
      extractedContentMarkdown:
          extractedContentMarkdown ?? this.extractedContentMarkdown,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentMarkdown: fullContentMarkdown ?? this.fullContentMarkdown,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = i0.Variable<String>(parentId.value);
    }
    if (containerId.present) {
      map['container_id'] = i0.Variable<String>(containerId.value);
    }
    if (orderKey.present) {
      map['order_key'] = i0.Variable<String>(orderKey.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(i3.Tab.$converterurl.toSql(url.value));
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (isProbablyReaderable.present) {
      map['is_probably_readerable'] = i0.Variable<bool>(
        isProbablyReaderable.value,
      );
    }
    if (extractedContentMarkdown.present) {
      map['extracted_content_markdown'] = i0.Variable<String>(
        extractedContentMarkdown.value,
      );
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentMarkdown.present) {
      map['full_content_markdown'] = i0.Variable<String>(
        fullContentMarkdown.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (timestamp.present) {
      map['timestamp'] = i0.Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('containerId: $containerId, ')
          ..write('orderKey: $orderKey, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('isProbablyReaderable: $isProbablyReaderable, ')
          ..write('extractedContentMarkdown: $extractedContentMarkdown, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentMarkdown: $fullContentMarkdown, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('timestamp: $timestamp, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class TabFts extends i0.Table
    with i0.TableInfo<TabFts, i3.TabFt>, i0.VirtualTableInfo<TabFts, i3.TabFt> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  TabFts(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> url = i0.GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> extractedContentPlain =
      i0.GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<String> fullContentPlain =
      i0.GeneratedColumn<String>(
        'full_content_plain',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    title,
    url,
    extractedContentPlain,
    fullContentPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tab_fts';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i3.TabFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i3.TabFt(
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      extractedContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      )!,
      fullContentPlain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      )!,
    );
  }

  @override
  TabFts createAlias(String alias) {
    return TabFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, url, extracted_content_plain, full_content_plain, content=tab, tokenize="trigram")';
}

class TabFt extends i0.DataClass implements i0.Insertable<i3.TabFt> {
  final String title;
  final String url;
  final String extractedContentPlain;
  final String fullContentPlain;
  const TabFt({
    required this.title,
    required this.url,
    required this.extractedContentPlain,
    required this.fullContentPlain,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['title'] = i0.Variable<String>(title);
    map['url'] = i0.Variable<String>(url);
    map['extracted_content_plain'] = i0.Variable<String>(extractedContentPlain);
    map['full_content_plain'] = i0.Variable<String>(fullContentPlain);
    return map;
  }

  factory TabFt.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return TabFt(
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      extractedContentPlain: serializer.fromJson<String>(
        json['extracted_content_plain'],
      ),
      fullContentPlain: serializer.fromJson<String>(json['full_content_plain']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'extracted_content_plain': serializer.toJson<String>(
        extractedContentPlain,
      ),
      'full_content_plain': serializer.toJson<String>(fullContentPlain),
    };
  }

  i3.TabFt copyWith({
    String? title,
    String? url,
    String? extractedContentPlain,
    String? fullContentPlain,
  }) => i3.TabFt(
    title: title ?? this.title,
    url: url ?? this.url,
    extractedContentPlain: extractedContentPlain ?? this.extractedContentPlain,
    fullContentPlain: fullContentPlain ?? this.fullContentPlain,
  );
  TabFt copyWithCompanion(i3.TabFtsCompanion data) {
    return TabFt(
      title: data.title.present ? data.title.value : this.title,
      url: data.url.present ? data.url.value : this.url,
      extractedContentPlain: data.extractedContentPlain.present
          ? data.extractedContentPlain.value
          : this.extractedContentPlain,
      fullContentPlain: data.fullContentPlain.present
          ? data.fullContentPlain.value
          : this.fullContentPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TabFt(')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(title, url, extractedContentPlain, fullContentPlain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i3.TabFt &&
          other.title == this.title &&
          other.url == this.url &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentPlain == this.fullContentPlain);
}

class TabFtsCompanion extends i0.UpdateCompanion<i3.TabFt> {
  final i0.Value<String> title;
  final i0.Value<String> url;
  final i0.Value<String> extractedContentPlain;
  final i0.Value<String> fullContentPlain;
  final i0.Value<int> rowid;
  const TabFtsCompanion({
    this.title = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.extractedContentPlain = const i0.Value.absent(),
    this.fullContentPlain = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  TabFtsCompanion.insert({
    required String title,
    required String url,
    required String extractedContentPlain,
    required String fullContentPlain,
    this.rowid = const i0.Value.absent(),
  }) : title = i0.Value(title),
       url = i0.Value(url),
       extractedContentPlain = i0.Value(extractedContentPlain),
       fullContentPlain = i0.Value(fullContentPlain);
  static i0.Insertable<i3.TabFt> custom({
    i0.Expression<String>? title,
    i0.Expression<String>? url,
    i0.Expression<String>? extractedContentPlain,
    i0.Expression<String>? fullContentPlain,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i3.TabFtsCompanion copyWith({
    i0.Value<String>? title,
    i0.Value<String>? url,
    i0.Value<String>? extractedContentPlain,
    i0.Value<String>? fullContentPlain,
    i0.Value<int>? rowid,
  }) {
    return i3.TabFtsCompanion(
      title: title ?? this.title,
      url: url ?? this.url,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(url.value);
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = i0.Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = i0.Variable<String>(fullContentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabFtsCompanion(')
          ..write('title: $title, ')
          ..write('url: $url, ')
          ..write('extractedContentPlain: $extractedContentPlain, ')
          ..write('fullContentPlain: $fullContentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Trigger get tabMaintainParentChainOnDelete => i0.Trigger(
  'CREATE TRIGGER tab_maintain_parent_chain_on_delete BEFORE DELETE ON tab BEGIN UPDATE tab SET parent_id = OLD.parent_id WHERE parent_id = OLD.id;END',
  'tab_maintain_parent_chain_on_delete',
);
i0.Trigger get tabAfterInsert => i0.Trigger(
  'CREATE TRIGGER tab_after_insert AFTER INSERT ON tab BEGIN INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
  'tab_after_insert',
);
i0.Trigger get tabAfterDelete => i0.Trigger(
  'CREATE TRIGGER tab_after_delete AFTER DELETE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);END',
  'tab_after_delete',
);
i0.Trigger get tabAfterUpdate => i0.Trigger(
  'CREATE TRIGGER tab_after_update AFTER UPDATE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
  'tab_after_update',
);

class DefinitionsDrift extends i7.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO tab_fts (tab_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {tabFts},
    );
  }

  i0.Selectable<i1.ContainerDataWithCount> containersWithCount() {
    return customSelect(
      'SELECT container.*, tab_agg.tab_count FROM container LEFT JOIN (SELECT container_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY tab_agg.last_updated DESC NULLS LAST',
      variables: [],
      readsFrom: {container, tab},
    ).map(
      (i0.QueryRow row) => i1.ContainerDataWithCount(
        id: row.read<String>('id'),
        name: row.readNullable<String>('name'),
        color: i3.Container.$convertercolor.fromSql(row.read<int>('color')),
        metadata: i0.NullAwareTypeConverter.wrapFromSql(
          i3.Container.$convertermetadata,
          row.readNullable<String>('metadata'),
        ),
        tabCount: row.readNullable<int>('tab_count'),
      ),
    );
  }

  i0.Selectable<String> leadingOrderKey({
    required int bucket,
    required String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> trailingOrderKey({
    required int bucket,
    required String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [i0.Variable<int>(bucket), i0.Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> orderKeyAfterTab({
    required String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [i0.Variable<String>(containerId), i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<String> orderKeyBeforeTab({
    required String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LAG(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_before(order_key, prev_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [i0.Variable<String>(containerId), i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.read<String>('_c0'));
  }

  i0.Selectable<i8.TabQueryResult> queryTabsBasic({required String query}) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight) SELECT t.id, t.title, CAST(t.url AS TEXT) AS url, t.url AS clean_url, bm25(tab_fts, weights.title_weight, weights.url_weight) AS weighted_rank FROM tab_fts AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights WHERE fts.title LIKE ?1 OR fts.url LIKE ?1 ORDER BY weighted_rank ASC, t.timestamp DESC',
      variables: [i0.Variable<String>(query)],
      readsFrom: {tab, tabFts},
    ).map(
      (i0.QueryRow row) => i8.TabQueryResult(
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: i3.Tab.$converterurl.fromSql(
          row.readNullable<String>('clean_url'),
        ),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  i0.Selectable<i8.TabQueryResult> queryTabsFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight, 3.0 AS extracted_weight, 1.0 AS full_weight) SELECT t.id, highlight(tab_fts, 0, ?1, ?2) AS title, highlight(tab_fts, 1, ?1, ?2) AS url, snippet(tab_fts, 2, ?1, ?2, ?3, ?4) AS extracted_content, snippet(tab_fts, 3, ?1, ?2, ?3, ?4) AS full_content, t.url AS clean_url,(bm25(tab_fts, weights.title_weight, weights.url_weight, weights.extracted_weight, weights.full_weight))AS weighted_rank FROM tab_fts(?5)AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights ORDER BY weighted_rank ASC, t.timestamp DESC',
      variables: [
        i0.Variable<String>(beforeMatch),
        i0.Variable<String>(afterMatch),
        i0.Variable<String>(ellipsis),
        i0.Variable<int>(snippetLength),
        i0.Variable<String>(query),
      ],
      readsFrom: {tab, tabFts},
    ).map(
      (i0.QueryRow row) => i8.TabQueryResult(
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: i3.Tab.$converterurl.fromSql(
          row.readNullable<String>('clean_url'),
        ),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  i0.Selectable<TabTreesResult> tabTrees() {
    return customSelect(
      'WITH RECURSIVE descendants AS (SELECT id, parent_id, timestamp, id AS root_id FROM tab WHERE parent_id IS NULL UNION ALL SELECT t.id, t.parent_id, t.timestamp, d.root_id FROM tab AS t JOIN descendants AS d ON t.parent_id = d.id), root_stats AS (SELECT root_id, MAX(timestamp) AS max_timestamp, COUNT(*) AS total_children FROM descendants GROUP BY root_id) SELECT d.root_id AS root_tab_id, d.id AS latest_tab_id, d.timestamp AS latest_timestamp, rs.total_children AS total_tabs FROM descendants AS d JOIN root_stats AS rs ON d.root_id = rs.root_id AND d.timestamp = rs.max_timestamp ORDER BY d.timestamp DESC',
      variables: [],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => TabTreesResult(
        rootTabId: row.read<String>('root_tab_id'),
        latestTabId: row.read<String>('latest_tab_id'),
        latestTimestamp: row.read<DateTime>('latest_timestamp'),
        totalTabs: row.read<int>('total_tabs'),
      ),
    );
  }

  i0.Selectable<UnorderedTabDescendantsResult> unorderedTabDescendants({
    required String tabId,
  }) {
    return customSelect(
      'WITH RECURSIVE descendants AS (SELECT id, parent_id FROM tab WHERE id = ?1 UNION ALL SELECT t.id, t.parent_id FROM tab AS t JOIN descendants AS d ON t.parent_id = d.id) SELECT id, parent_id FROM descendants',
      variables: [i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map(
      (i0.QueryRow row) => UnorderedTabDescendantsResult(
        id: row.read<String>('id'),
        parentId: row.readNullable<String>('parent_id'),
      ),
    );
  }

  i0.Selectable<String?> previousTabByTimestamp({required String tabId}) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, timestamp, LAG(id)OVER (ORDER BY timestamp RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_tab_id FROM tab) SELECT prev_tab_id FROM ranked_tabs WHERE id = ?1',
      variables: [i0.Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('prev_tab_id'));
  }

  i0.Selectable<String?> previousTabByOrderKey({
    required bool skipContainerCheck,
    String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, order_key, LAG(id)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS prev_tab_id FROM tab WHERE ?1 OR container_id IS ?2) SELECT prev_tab_id FROM ranked_tabs WHERE id = ?3',
      variables: [
        i0.Variable<bool>(skipContainerCheck),
        i0.Variable<String>(containerId),
        i0.Variable<String>(tabId),
      ],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('prev_tab_id'));
  }

  i0.Selectable<String?> nextTabByOrderKey({
    required bool skipContainerCheck,
    String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ranked_tabs AS (SELECT id, order_key, LEAD(id)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_tab_id FROM tab WHERE ?1 OR container_id IS ?2) SELECT next_tab_id FROM ranked_tabs WHERE id = ?3',
      variables: [
        i0.Variable<bool>(skipContainerCheck),
        i0.Variable<String>(containerId),
        i0.Variable<String>(tabId),
      ],
      readsFrom: {tab},
    ).map((i0.QueryRow row) => row.readNullable<String>('next_tab_id'));
  }

  i0.Selectable<bool> isSiteAssignedToContainer({String? uri}) {
    return customSelect(
      'SELECT EXISTS (SELECT 1 AS _c0 FROM container CROSS JOIN json_each(container.metadata, \'\$.assignedSites\')WHERE json_each.value = ?1) AS existing',
      variables: [i0.Variable<String>(uri)],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<bool>('existing'));
  }

  i0.Selectable<bool> areSitesAvailable({
    required String uriList,
    required String ignoreContainerId,
  }) {
    return customSelect(
      'SELECT NOT EXISTS (SELECT 1 AS _c0 FROM container CROSS JOIN json_each(container.metadata, \'\$.assignedSites\')WHERE json_each.value IN (SELECT value FROM json_each(?1)) AND container.id IS NOT ?2) AS existing',
      variables: [
        i0.Variable<String>(uriList),
        i0.Variable<String>(ignoreContainerId),
      ],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<bool>('existing'));
  }

  i0.Selectable<String> siteAssignedContainerId({String? uri}) {
    return customSelect(
      'SELECT id FROM container WHERE EXISTS (SELECT 1 AS _c0 FROM json_each(container.metadata, \'\$.assignedSites\')WHERE value = ?1)',
      variables: [i0.Variable<String>(uri)],
      readsFrom: {container},
    ).map((i0.QueryRow row) => row.read<String>('id'));
  }

  i0.Selectable<i9.SiteAssignment> allAssignedSites() {
    return customSelect(
      'SELECT container.id, COALESCE(container.metadata ->> \'\$.contextualIdentity\', \'general\') AS contextualIdentity, value AS assigned_site FROM container CROSS JOIN json_each(container.metadata, \'\$.assignedSites\')WHERE value IS NOT NULL',
      variables: [],
      readsFrom: {container},
    ).map(
      (i0.QueryRow row) => i9.SiteAssignment(
        id: row.read<String>('id'),
        contextualIdentity: row.read<String>('contextualIdentity'),
        assignedSite: row.readNullable<String>('assigned_site'),
      ),
    );
  }

  i3.TabFts get tabFts => i7.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.TabFts>('tab_fts');
  i3.Container get container => i7.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i3.Container>('container');
  i3.Tab get tab =>
      i7.ReadDatabaseContainer(attachedDatabase).resultSet<i3.Tab>('tab');
}

class TabTreesResult {
  final String rootTabId;
  final String latestTabId;
  final DateTime latestTimestamp;
  final int totalTabs;
  TabTreesResult({
    required this.rootTabId,
    required this.latestTabId,
    required this.latestTimestamp,
    required this.totalTabs,
  });
}

class UnorderedTabDescendantsResult {
  final String id;
  final String? parentId;
  UnorderedTabDescendantsResult({required this.id, this.parentId});
}
