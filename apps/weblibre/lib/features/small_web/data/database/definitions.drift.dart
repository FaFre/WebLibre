// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/small_web/data/database/definitions.drift.dart'
    as i1;
import 'package:weblibre/data/database/converters/uri.dart' as i2;
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart'
    as i3;
import 'package:weblibre/data/database/converters/string_list.dart' as i4;
import 'package:weblibre/features/small_web/data/models/wander_console_source.dart'
    as i5;
import 'package:drift/internal/modular.dart' as i6;

typedef $SmallWebItemsCreateCompanionBuilder =
    i1.SmallWebItemsCompanion Function({
      required String id,
      required Uri url,
      i0.Value<String?> title,
      required String domain,
      i0.Value<String?> author,
      i0.Value<String?> summary,
      i0.Value<DateTime?> publishedAt,
      i0.Value<DateTime> createdAt,
      i0.Value<DateTime> updatedAt,
      i0.Value<int> rowid,
    });
typedef $SmallWebItemsUpdateCompanionBuilder =
    i1.SmallWebItemsCompanion Function({
      i0.Value<String> id,
      i0.Value<Uri> url,
      i0.Value<String?> title,
      i0.Value<String> domain,
      i0.Value<String?> author,
      i0.Value<String?> summary,
      i0.Value<DateTime?> publishedAt,
      i0.Value<DateTime> createdAt,
      i0.Value<DateTime> updatedAt,
      i0.Value<int> rowid,
    });

final class $SmallWebItemsReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.SmallWebItems,
          i1.SmallWebItem
        > {
  $SmallWebItemsReferences(super.$_db, super.$_table, super.$_typedResult);

  static i0.MultiTypedResultKey<
    i1.SmallWebMemberships,
    List<i1.SmallWebMembership>
  >
  _smallWebMembershipsRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i6.ReadDatabaseContainer(
          db,
        ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
        aliasName: i0.$_aliasNameGenerator(
          i6.ReadDatabaseContainer(
            db,
          ).resultSet<i1.SmallWebItems>('small_web_items').id,
          i6.ReadDatabaseContainer(
            db,
          ).resultSet<i1.SmallWebMemberships>('small_web_memberships').itemId,
        ),
      );

  i1.$SmallWebMembershipsProcessedTableManager get smallWebMembershipsRefs {
    final manager = i1
        .$SmallWebMembershipsTableManager(
          $_db,
          i6.ReadDatabaseContainer(
            $_db,
          ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
        )
        .filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _smallWebMembershipsRefsTable($_db),
    );
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static i0.MultiTypedResultKey<i1.SmallWebVisits, List<i1.SmallWebVisit>>
  _smallWebVisitsRefsTable(i0.GeneratedDatabase db) =>
      i0.MultiTypedResultKey.fromTable(
        i6.ReadDatabaseContainer(
          db,
        ).resultSet<i1.SmallWebVisits>('small_web_visits'),
        aliasName: i0.$_aliasNameGenerator(
          i6.ReadDatabaseContainer(
            db,
          ).resultSet<i1.SmallWebItems>('small_web_items').id,
          i6.ReadDatabaseContainer(
            db,
          ).resultSet<i1.SmallWebVisits>('small_web_visits').itemId,
        ),
      );

  i1.$SmallWebVisitsProcessedTableManager get smallWebVisitsRefs {
    final manager = i1
        .$SmallWebVisitsTableManager(
          $_db,
          i6.ReadDatabaseContainer(
            $_db,
          ).resultSet<i1.SmallWebVisits>('small_web_visits'),
        )
        .filter((f) => f.itemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_smallWebVisitsRefsTable($_db));
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $SmallWebItemsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebItems> {
  $SmallWebItemsFilterComposer({
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

  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.Expression<bool> smallWebMembershipsRefs(
    i0.Expression<bool> Function(i1.$SmallWebMembershipsFilterComposer f) f,
  ) {
    final i1.$SmallWebMembershipsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebMembershipsFilterComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  i0.Expression<bool> smallWebVisitsRefs(
    i0.Expression<bool> Function(i1.$SmallWebVisitsFilterComposer f) f,
  ) {
    final i1.$SmallWebVisitsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebVisits>('small_web_visits'),
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebVisitsFilterComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebVisits>('small_web_visits'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SmallWebItemsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebItems> {
  $SmallWebItemsOrderingComposer({
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

  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $SmallWebItemsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebItems> {
  $SmallWebItemsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  i0.GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  i0.GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  i0.GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  i0.Expression<T> smallWebMembershipsRefs<T extends Object>(
    i0.Expression<T> Function(i1.$SmallWebMembershipsAnnotationComposer a) f,
  ) {
    final i1.$SmallWebMembershipsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebMembershipsAnnotationComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebMemberships>('small_web_memberships'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  i0.Expression<T> smallWebVisitsRefs<T extends Object>(
    i0.Expression<T> Function(i1.$SmallWebVisitsAnnotationComposer a) f,
  ) {
    final i1.$SmallWebVisitsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebVisits>('small_web_visits'),
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebVisitsAnnotationComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebVisits>('small_web_visits'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $SmallWebItemsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.SmallWebItems,
          i1.SmallWebItem,
          i1.$SmallWebItemsFilterComposer,
          i1.$SmallWebItemsOrderingComposer,
          i1.$SmallWebItemsAnnotationComposer,
          $SmallWebItemsCreateCompanionBuilder,
          $SmallWebItemsUpdateCompanionBuilder,
          (i1.SmallWebItem, i1.$SmallWebItemsReferences),
          i1.SmallWebItem,
          i0.PrefetchHooks Function({
            bool smallWebMembershipsRefs,
            bool smallWebVisitsRefs,
          })
        > {
  $SmallWebItemsTableManager(i0.GeneratedDatabase db, i1.SmallWebItems table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SmallWebItemsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SmallWebItemsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SmallWebItemsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<Uri> url = const i0.Value.absent(),
                i0.Value<String?> title = const i0.Value.absent(),
                i0.Value<String> domain = const i0.Value.absent(),
                i0.Value<String?> author = const i0.Value.absent(),
                i0.Value<String?> summary = const i0.Value.absent(),
                i0.Value<DateTime?> publishedAt = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<DateTime> updatedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebItemsCompanion(
                id: id,
                url: url,
                title: title,
                domain: domain,
                author: author,
                summary: summary,
                publishedAt: publishedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uri url,
                i0.Value<String?> title = const i0.Value.absent(),
                required String domain,
                i0.Value<String?> author = const i0.Value.absent(),
                i0.Value<String?> summary = const i0.Value.absent(),
                i0.Value<DateTime?> publishedAt = const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<DateTime> updatedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebItemsCompanion.insert(
                id: id,
                url: url,
                title: title,
                domain: domain,
                author: author,
                summary: summary,
                publishedAt: publishedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i1.$SmallWebItemsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({smallWebMembershipsRefs = false, smallWebVisitsRefs = false}) {
                return i0.PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (smallWebMembershipsRefs)
                      i6.ReadDatabaseContainer(
                        db,
                      ).resultSet<i1.SmallWebMemberships>(
                        'small_web_memberships',
                      ),
                    if (smallWebVisitsRefs)
                      i6.ReadDatabaseContainer(
                        db,
                      ).resultSet<i1.SmallWebVisits>('small_web_visits'),
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (smallWebMembershipsRefs)
                        await i0.$_getPrefetchedData<
                          i1.SmallWebItem,
                          i1.SmallWebItems,
                          i1.SmallWebMembership
                        >(
                          currentTable: table,
                          referencedTable: i1.$SmallWebItemsReferences
                              ._smallWebMembershipsRefsTable(db),
                          managerFromTypedResult: (p0) => i1
                              .$SmallWebItemsReferences(db, table, p0)
                              .smallWebMembershipsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (smallWebVisitsRefs)
                        await i0.$_getPrefetchedData<
                          i1.SmallWebItem,
                          i1.SmallWebItems,
                          i1.SmallWebVisit
                        >(
                          currentTable: table,
                          referencedTable: i1.$SmallWebItemsReferences
                              ._smallWebVisitsRefsTable(db),
                          managerFromTypedResult: (p0) => i1
                              .$SmallWebItemsReferences(db, table, p0)
                              .smallWebVisitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
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

typedef $SmallWebItemsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.SmallWebItems,
      i1.SmallWebItem,
      i1.$SmallWebItemsFilterComposer,
      i1.$SmallWebItemsOrderingComposer,
      i1.$SmallWebItemsAnnotationComposer,
      $SmallWebItemsCreateCompanionBuilder,
      $SmallWebItemsUpdateCompanionBuilder,
      (i1.SmallWebItem, i1.$SmallWebItemsReferences),
      i1.SmallWebItem,
      i0.PrefetchHooks Function({
        bool smallWebMembershipsRefs,
        bool smallWebVisitsRefs,
      })
    >;
typedef $SmallWebMembershipsCreateCompanionBuilder =
    i1.SmallWebMembershipsCompanion Function({
      required String id,
      required String itemId,
      required i3.SmallWebSourceKind sourceKind,
      i0.Value<String?> mode,
      i0.Value<Uri?> consoleUrl,
      i0.Value<List<String>> categories,
      i0.Value<DateTime> fetchedAt,
      i0.Value<int> rowid,
    });
typedef $SmallWebMembershipsUpdateCompanionBuilder =
    i1.SmallWebMembershipsCompanion Function({
      i0.Value<String> id,
      i0.Value<String> itemId,
      i0.Value<i3.SmallWebSourceKind> sourceKind,
      i0.Value<String?> mode,
      i0.Value<Uri?> consoleUrl,
      i0.Value<List<String>> categories,
      i0.Value<DateTime> fetchedAt,
      i0.Value<int> rowid,
    });

final class $SmallWebMembershipsReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.SmallWebMemberships,
          i1.SmallWebMembership
        > {
  $SmallWebMembershipsReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static i1.SmallWebItems _itemIdTable(i0.GeneratedDatabase db) =>
      i6.ReadDatabaseContainer(db)
          .resultSet<i1.SmallWebItems>('small_web_items')
          .createAlias(
            i0.$_aliasNameGenerator(
              i6.ReadDatabaseContainer(db)
                  .resultSet<i1.SmallWebMemberships>('small_web_memberships')
                  .itemId,
              i6.ReadDatabaseContainer(
                db,
              ).resultSet<i1.SmallWebItems>('small_web_items').id,
            ),
          );

  i1.$SmallWebItemsProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = i1
        .$SmallWebItemsTableManager(
          $_db,
          i6.ReadDatabaseContainer(
            $_db,
          ).resultSet<i1.SmallWebItems>('small_web_items'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SmallWebMembershipsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebMemberships> {
  $SmallWebMembershipsFilterComposer({
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

  i0.ColumnWithTypeConverterFilters<
    i3.SmallWebSourceKind,
    i3.SmallWebSourceKind,
    int
  >
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get consoleUrl =>
      $composableBuilder(
        column: $table.consoleUrl,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i1.$SmallWebItemsFilterComposer get itemId {
    final i1.$SmallWebItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsFilterComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebMembershipsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebMemberships> {
  $SmallWebMembershipsOrderingComposer({
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

  i0.ColumnOrderings<int> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get consoleUrl => $composableBuilder(
    column: $table.consoleUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get categories => $composableBuilder(
    column: $table.categories,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i1.$SmallWebItemsOrderingComposer get itemId {
    final i1.$SmallWebItemsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsOrderingComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebMembershipsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebMemberships> {
  $SmallWebMembershipsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i3.SmallWebSourceKind, int>
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get consoleUrl =>
      $composableBuilder(
        column: $table.consoleUrl,
        builder: (column) => column,
      );

  i0.GeneratedColumnWithTypeConverter<List<String>, String> get categories =>
      $composableBuilder(
        column: $table.categories,
        builder: (column) => column,
      );

  i0.GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  i1.$SmallWebItemsAnnotationComposer get itemId {
    final i1.$SmallWebItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsAnnotationComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebMembershipsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.SmallWebMemberships,
          i1.SmallWebMembership,
          i1.$SmallWebMembershipsFilterComposer,
          i1.$SmallWebMembershipsOrderingComposer,
          i1.$SmallWebMembershipsAnnotationComposer,
          $SmallWebMembershipsCreateCompanionBuilder,
          $SmallWebMembershipsUpdateCompanionBuilder,
          (i1.SmallWebMembership, i1.$SmallWebMembershipsReferences),
          i1.SmallWebMembership,
          i0.PrefetchHooks Function({bool itemId})
        > {
  $SmallWebMembershipsTableManager(
    i0.GeneratedDatabase db,
    i1.SmallWebMemberships table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SmallWebMembershipsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SmallWebMembershipsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SmallWebMembershipsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String> itemId = const i0.Value.absent(),
                i0.Value<i3.SmallWebSourceKind> sourceKind =
                    const i0.Value.absent(),
                i0.Value<String?> mode = const i0.Value.absent(),
                i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
                i0.Value<List<String>> categories = const i0.Value.absent(),
                i0.Value<DateTime> fetchedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebMembershipsCompanion(
                id: id,
                itemId: itemId,
                sourceKind: sourceKind,
                mode: mode,
                consoleUrl: consoleUrl,
                categories: categories,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required i3.SmallWebSourceKind sourceKind,
                i0.Value<String?> mode = const i0.Value.absent(),
                i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
                i0.Value<List<String>> categories = const i0.Value.absent(),
                i0.Value<DateTime> fetchedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebMembershipsCompanion.insert(
                id: id,
                itemId: itemId,
                sourceKind: sourceKind,
                mode: mode,
                consoleUrl: consoleUrl,
                categories: categories,
                fetchedAt: fetchedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i1.$SmallWebMembershipsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: i1
                                    .$SmallWebMembershipsReferences
                                    ._itemIdTable(db),
                                referencedColumn: i1
                                    .$SmallWebMembershipsReferences
                                    ._itemIdTable(db)
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

typedef $SmallWebMembershipsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.SmallWebMemberships,
      i1.SmallWebMembership,
      i1.$SmallWebMembershipsFilterComposer,
      i1.$SmallWebMembershipsOrderingComposer,
      i1.$SmallWebMembershipsAnnotationComposer,
      $SmallWebMembershipsCreateCompanionBuilder,
      $SmallWebMembershipsUpdateCompanionBuilder,
      (i1.SmallWebMembership, i1.$SmallWebMembershipsReferences),
      i1.SmallWebMembership,
      i0.PrefetchHooks Function({bool itemId})
    >;
typedef $WanderConsolesCreateCompanionBuilder =
    i1.WanderConsolesCompanion Function({
      required Uri url,
      required Uri wanderJsUrl,
      i0.Value<DateTime?> lastFetchedAt,
      i0.Value<bool?> lastFetchFailed,
      i0.Value<Uri?> discoveredFromUrl,
      required i5.WanderConsoleSource source,
      i0.Value<DateTime> createdAt,
      i0.Value<int> rowid,
    });
typedef $WanderConsolesUpdateCompanionBuilder =
    i1.WanderConsolesCompanion Function({
      i0.Value<Uri> url,
      i0.Value<Uri> wanderJsUrl,
      i0.Value<DateTime?> lastFetchedAt,
      i0.Value<bool?> lastFetchFailed,
      i0.Value<Uri?> discoveredFromUrl,
      i0.Value<i5.WanderConsoleSource> source,
      i0.Value<DateTime> createdAt,
      i0.Value<int> rowid,
    });

class $WanderConsolesFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoles> {
  $WanderConsolesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<Uri, Uri, String> get wanderJsUrl =>
      $composableBuilder(
        column: $table.wanderJsUrl,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<bool> get lastFetchFailed => $composableBuilder(
    column: $table.lastFetchFailed,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get discoveredFromUrl =>
      $composableBuilder(
        column: $table.discoveredFromUrl,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnWithTypeConverterFilters<
    i5.WanderConsoleSource,
    i5.WanderConsoleSource,
    int
  >
  get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $WanderConsolesOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoles> {
  $WanderConsolesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get wanderJsUrl => $composableBuilder(
    column: $table.wanderJsUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<bool> get lastFetchFailed => $composableBuilder(
    column: $table.lastFetchFailed,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get discoveredFromUrl => $composableBuilder(
    column: $table.discoveredFromUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<int> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $WanderConsolesAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoles> {
  $WanderConsolesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri, String> get wanderJsUrl =>
      $composableBuilder(
        column: $table.wanderJsUrl,
        builder: (column) => column,
      );

  i0.GeneratedColumn<DateTime> get lastFetchedAt => $composableBuilder(
    column: $table.lastFetchedAt,
    builder: (column) => column,
  );

  i0.GeneratedColumn<bool> get lastFetchFailed => $composableBuilder(
    column: $table.lastFetchFailed,
    builder: (column) => column,
  );

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get discoveredFromUrl =>
      $composableBuilder(
        column: $table.discoveredFromUrl,
        builder: (column) => column,
      );

  i0.GeneratedColumnWithTypeConverter<i5.WanderConsoleSource, int> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  i0.GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $WanderConsolesTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.WanderConsoles,
          i1.WanderConsole,
          i1.$WanderConsolesFilterComposer,
          i1.$WanderConsolesOrderingComposer,
          i1.$WanderConsolesAnnotationComposer,
          $WanderConsolesCreateCompanionBuilder,
          $WanderConsolesUpdateCompanionBuilder,
          (
            i1.WanderConsole,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.WanderConsoles,
              i1.WanderConsole
            >,
          ),
          i1.WanderConsole,
          i0.PrefetchHooks Function()
        > {
  $WanderConsolesTableManager(i0.GeneratedDatabase db, i1.WanderConsoles table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$WanderConsolesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$WanderConsolesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$WanderConsolesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<Uri> url = const i0.Value.absent(),
                i0.Value<Uri> wanderJsUrl = const i0.Value.absent(),
                i0.Value<DateTime?> lastFetchedAt = const i0.Value.absent(),
                i0.Value<bool?> lastFetchFailed = const i0.Value.absent(),
                i0.Value<Uri?> discoveredFromUrl = const i0.Value.absent(),
                i0.Value<i5.WanderConsoleSource> source =
                    const i0.Value.absent(),
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.WanderConsolesCompanion(
                url: url,
                wanderJsUrl: wanderJsUrl,
                lastFetchedAt: lastFetchedAt,
                lastFetchFailed: lastFetchFailed,
                discoveredFromUrl: discoveredFromUrl,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uri url,
                required Uri wanderJsUrl,
                i0.Value<DateTime?> lastFetchedAt = const i0.Value.absent(),
                i0.Value<bool?> lastFetchFailed = const i0.Value.absent(),
                i0.Value<Uri?> discoveredFromUrl = const i0.Value.absent(),
                required i5.WanderConsoleSource source,
                i0.Value<DateTime> createdAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.WanderConsolesCompanion.insert(
                url: url,
                wanderJsUrl: wanderJsUrl,
                lastFetchedAt: lastFetchedAt,
                lastFetchFailed: lastFetchFailed,
                discoveredFromUrl: discoveredFromUrl,
                source: source,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $WanderConsolesProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.WanderConsoles,
      i1.WanderConsole,
      i1.$WanderConsolesFilterComposer,
      i1.$WanderConsolesOrderingComposer,
      i1.$WanderConsolesAnnotationComposer,
      $WanderConsolesCreateCompanionBuilder,
      $WanderConsolesUpdateCompanionBuilder,
      (
        i1.WanderConsole,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.WanderConsoles,
          i1.WanderConsole
        >,
      ),
      i1.WanderConsole,
      i0.PrefetchHooks Function()
    >;
typedef $WanderConsoleNeighborsCreateCompanionBuilder =
    i1.WanderConsoleNeighborsCompanion Function({
      required String sourceConsoleUrl,
      required String targetConsoleUrl,
      i0.Value<DateTime> discoveredAt,
      i0.Value<int> rowid,
    });
typedef $WanderConsoleNeighborsUpdateCompanionBuilder =
    i1.WanderConsoleNeighborsCompanion Function({
      i0.Value<String> sourceConsoleUrl,
      i0.Value<String> targetConsoleUrl,
      i0.Value<DateTime> discoveredAt,
      i0.Value<int> rowid,
    });

class $WanderConsoleNeighborsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoleNeighbors> {
  $WanderConsoleNeighborsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get targetConsoleUrl => $composableBuilder(
    column: $table.targetConsoleUrl,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $WanderConsoleNeighborsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoleNeighbors> {
  $WanderConsoleNeighborsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get targetConsoleUrl => $composableBuilder(
    column: $table.targetConsoleUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $WanderConsoleNeighborsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.WanderConsoleNeighbors> {
  $WanderConsoleNeighborsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get targetConsoleUrl => $composableBuilder(
    column: $table.targetConsoleUrl,
    builder: (column) => column,
  );

  i0.GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );
}

class $WanderConsoleNeighborsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.WanderConsoleNeighbors,
          i1.WanderConsoleNeighbor,
          i1.$WanderConsoleNeighborsFilterComposer,
          i1.$WanderConsoleNeighborsOrderingComposer,
          i1.$WanderConsoleNeighborsAnnotationComposer,
          $WanderConsoleNeighborsCreateCompanionBuilder,
          $WanderConsoleNeighborsUpdateCompanionBuilder,
          (
            i1.WanderConsoleNeighbor,
            i0.BaseReferences<
              i0.GeneratedDatabase,
              i1.WanderConsoleNeighbors,
              i1.WanderConsoleNeighbor
            >,
          ),
          i1.WanderConsoleNeighbor,
          i0.PrefetchHooks Function()
        > {
  $WanderConsoleNeighborsTableManager(
    i0.GeneratedDatabase db,
    i1.WanderConsoleNeighbors table,
  ) : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$WanderConsoleNeighborsFilterComposer($db: db, $table: table),
          createOrderingComposer: () => i1
              .$WanderConsoleNeighborsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$WanderConsoleNeighborsAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                i0.Value<String> sourceConsoleUrl = const i0.Value.absent(),
                i0.Value<String> targetConsoleUrl = const i0.Value.absent(),
                i0.Value<DateTime> discoveredAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.WanderConsoleNeighborsCompanion(
                sourceConsoleUrl: sourceConsoleUrl,
                targetConsoleUrl: targetConsoleUrl,
                discoveredAt: discoveredAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String sourceConsoleUrl,
                required String targetConsoleUrl,
                i0.Value<DateTime> discoveredAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.WanderConsoleNeighborsCompanion.insert(
                sourceConsoleUrl: sourceConsoleUrl,
                targetConsoleUrl: targetConsoleUrl,
                discoveredAt: discoveredAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $WanderConsoleNeighborsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.WanderConsoleNeighbors,
      i1.WanderConsoleNeighbor,
      i1.$WanderConsoleNeighborsFilterComposer,
      i1.$WanderConsoleNeighborsOrderingComposer,
      i1.$WanderConsoleNeighborsAnnotationComposer,
      $WanderConsoleNeighborsCreateCompanionBuilder,
      $WanderConsoleNeighborsUpdateCompanionBuilder,
      (
        i1.WanderConsoleNeighbor,
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.WanderConsoleNeighbors,
          i1.WanderConsoleNeighbor
        >,
      ),
      i1.WanderConsoleNeighbor,
      i0.PrefetchHooks Function()
    >;
typedef $SmallWebVisitsCreateCompanionBuilder =
    i1.SmallWebVisitsCompanion Function({
      required String id,
      required String itemId,
      required i3.SmallWebSourceKind sourceKind,
      i0.Value<String?> mode,
      i0.Value<Uri?> consoleUrl,
      i0.Value<DateTime> visitedAt,
      i0.Value<int> rowid,
    });
typedef $SmallWebVisitsUpdateCompanionBuilder =
    i1.SmallWebVisitsCompanion Function({
      i0.Value<String> id,
      i0.Value<String> itemId,
      i0.Value<i3.SmallWebSourceKind> sourceKind,
      i0.Value<String?> mode,
      i0.Value<Uri?> consoleUrl,
      i0.Value<DateTime> visitedAt,
      i0.Value<int> rowid,
    });

final class $SmallWebVisitsReferences
    extends
        i0.BaseReferences<
          i0.GeneratedDatabase,
          i1.SmallWebVisits,
          i1.SmallWebVisit
        > {
  $SmallWebVisitsReferences(super.$_db, super.$_table, super.$_typedResult);

  static i1.SmallWebItems _itemIdTable(i0.GeneratedDatabase db) =>
      i6.ReadDatabaseContainer(db)
          .resultSet<i1.SmallWebItems>('small_web_items')
          .createAlias(
            i0.$_aliasNameGenerator(
              i6.ReadDatabaseContainer(
                db,
              ).resultSet<i1.SmallWebVisits>('small_web_visits').itemId,
              i6.ReadDatabaseContainer(
                db,
              ).resultSet<i1.SmallWebItems>('small_web_items').id,
            ),
          );

  i1.$SmallWebItemsProcessedTableManager get itemId {
    final $_column = $_itemColumn<String>('item_id')!;

    final manager = i1
        .$SmallWebItemsTableManager(
          $_db,
          i6.ReadDatabaseContainer(
            $_db,
          ).resultSet<i1.SmallWebItems>('small_web_items'),
        )
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return i0.ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $SmallWebVisitsFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebVisits> {
  $SmallWebVisitsFilterComposer({
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

  i0.ColumnWithTypeConverterFilters<
    i3.SmallWebSourceKind,
    i3.SmallWebSourceKind,
    int
  >
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => i0.ColumnWithTypeConverterFilters(column),
  );

  i0.ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnWithTypeConverterFilters<Uri?, Uri, String> get consoleUrl =>
      $composableBuilder(
        column: $table.consoleUrl,
        builder: (column) => i0.ColumnWithTypeConverterFilters(column),
      );

  i0.ColumnFilters<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => i0.ColumnFilters(column),
  );

  i1.$SmallWebItemsFilterComposer get itemId {
    final i1.$SmallWebItemsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsFilterComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebVisitsOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebVisits> {
  $SmallWebVisitsOrderingComposer({
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

  i0.ColumnOrderings<int> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get consoleUrl => $composableBuilder(
    column: $table.consoleUrl,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<DateTime> get visitedAt => $composableBuilder(
    column: $table.visitedAt,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i1.$SmallWebItemsOrderingComposer get itemId {
    final i1.$SmallWebItemsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsOrderingComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebVisitsAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.SmallWebVisits> {
  $SmallWebVisitsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<i3.SmallWebSourceKind, int>
  get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  i0.GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  i0.GeneratedColumnWithTypeConverter<Uri?, String> get consoleUrl =>
      $composableBuilder(
        column: $table.consoleUrl,
        builder: (column) => column,
      );

  i0.GeneratedColumn<DateTime> get visitedAt =>
      $composableBuilder(column: $table.visitedAt, builder: (column) => column);

  i1.$SmallWebItemsAnnotationComposer get itemId {
    final i1.$SmallWebItemsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: i6.ReadDatabaseContainer(
        $db,
      ).resultSet<i1.SmallWebItems>('small_web_items'),
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => i1.$SmallWebItemsAnnotationComposer(
            $db: $db,
            $table: i6.ReadDatabaseContainer(
              $db,
            ).resultSet<i1.SmallWebItems>('small_web_items'),
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $SmallWebVisitsTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.SmallWebVisits,
          i1.SmallWebVisit,
          i1.$SmallWebVisitsFilterComposer,
          i1.$SmallWebVisitsOrderingComposer,
          i1.$SmallWebVisitsAnnotationComposer,
          $SmallWebVisitsCreateCompanionBuilder,
          $SmallWebVisitsUpdateCompanionBuilder,
          (i1.SmallWebVisit, i1.$SmallWebVisitsReferences),
          i1.SmallWebVisit,
          i0.PrefetchHooks Function({bool itemId})
        > {
  $SmallWebVisitsTableManager(i0.GeneratedDatabase db, i1.SmallWebVisits table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$SmallWebVisitsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$SmallWebVisitsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$SmallWebVisitsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> id = const i0.Value.absent(),
                i0.Value<String> itemId = const i0.Value.absent(),
                i0.Value<i3.SmallWebSourceKind> sourceKind =
                    const i0.Value.absent(),
                i0.Value<String?> mode = const i0.Value.absent(),
                i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
                i0.Value<DateTime> visitedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebVisitsCompanion(
                id: id,
                itemId: itemId,
                sourceKind: sourceKind,
                mode: mode,
                consoleUrl: consoleUrl,
                visitedAt: visitedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String itemId,
                required i3.SmallWebSourceKind sourceKind,
                i0.Value<String?> mode = const i0.Value.absent(),
                i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
                i0.Value<DateTime> visitedAt = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.SmallWebVisitsCompanion.insert(
                id: id,
                itemId: itemId,
                sourceKind: sourceKind,
                mode: mode,
                consoleUrl: consoleUrl,
                visitedAt: visitedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  i1.$SmallWebVisitsReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({itemId = false}) {
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
                    if (itemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.itemId,
                                referencedTable: i1.$SmallWebVisitsReferences
                                    ._itemIdTable(db),
                                referencedColumn: i1.$SmallWebVisitsReferences
                                    ._itemIdTable(db)
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

typedef $SmallWebVisitsProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.SmallWebVisits,
      i1.SmallWebVisit,
      i1.$SmallWebVisitsFilterComposer,
      i1.$SmallWebVisitsOrderingComposer,
      i1.$SmallWebVisitsAnnotationComposer,
      $SmallWebVisitsCreateCompanionBuilder,
      $SmallWebVisitsUpdateCompanionBuilder,
      (i1.SmallWebVisit, i1.$SmallWebVisitsReferences),
      i1.SmallWebVisit,
      i0.PrefetchHooks Function({bool itemId})
    >;

class SmallWebItems extends i0.Table
    with i0.TableInfo<SmallWebItems, i1.SmallWebItem> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  SmallWebItems(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL UNIQUE',
      ).withConverter<Uri>(i1.SmallWebItems.$converterurl);
  late final i0.GeneratedColumn<String> title = i0.GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> domain = i0.GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> author = i0.GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> summary = i0.GeneratedColumn<String>(
    'summary',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<DateTime> publishedAt =
      i0.GeneratedColumn<DateTime>(
        'published_at',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<DateTime> createdAt =
      i0.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  late final i0.GeneratedColumn<DateTime> updatedAt =
      i0.GeneratedColumn<DateTime>(
        'updated_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    url,
    title,
    domain,
    author,
    summary,
    publishedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'small_web_items';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.SmallWebItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.SmallWebItem(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      url: i1.SmallWebItems.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      domain: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      author: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      summary: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}summary'],
      ),
      publishedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  SmallWebItems createAlias(String alias) {
    return SmallWebItems(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterurl = const i2.UriConverter();
  @override
  bool get dontWriteConstraints => true;
}

class SmallWebItem extends i0.DataClass
    implements i0.Insertable<i1.SmallWebItem> {
  final String id;
  final Uri url;
  final String? title;
  final String domain;
  final String? author;
  final String? summary;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SmallWebItem({
    required this.id,
    required this.url,
    this.title,
    required this.domain,
    this.author,
    this.summary,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    {
      map['url'] = i0.Variable<String>(
        i1.SmallWebItems.$converterurl.toSql(url),
      );
    }
    if (!nullToAbsent || title != null) {
      map['title'] = i0.Variable<String>(title);
    }
    map['domain'] = i0.Variable<String>(domain);
    if (!nullToAbsent || author != null) {
      map['author'] = i0.Variable<String>(author);
    }
    if (!nullToAbsent || summary != null) {
      map['summary'] = i0.Variable<String>(summary);
    }
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = i0.Variable<DateTime>(publishedAt);
    }
    map['created_at'] = i0.Variable<DateTime>(createdAt);
    map['updated_at'] = i0.Variable<DateTime>(updatedAt);
    return map;
  }

  factory SmallWebItem.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return SmallWebItem(
      id: serializer.fromJson<String>(json['id']),
      url: serializer.fromJson<Uri>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      domain: serializer.fromJson<String>(json['domain']),
      author: serializer.fromJson<String?>(json['author']),
      summary: serializer.fromJson<String?>(json['summary']),
      publishedAt: serializer.fromJson<DateTime?>(json['published_at']),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
      updatedAt: serializer.fromJson<DateTime>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'url': serializer.toJson<Uri>(url),
      'title': serializer.toJson<String?>(title),
      'domain': serializer.toJson<String>(domain),
      'author': serializer.toJson<String?>(author),
      'summary': serializer.toJson<String?>(summary),
      'published_at': serializer.toJson<DateTime?>(publishedAt),
      'created_at': serializer.toJson<DateTime>(createdAt),
      'updated_at': serializer.toJson<DateTime>(updatedAt),
    };
  }

  i1.SmallWebItem copyWith({
    String? id,
    Uri? url,
    i0.Value<String?> title = const i0.Value.absent(),
    String? domain,
    i0.Value<String?> author = const i0.Value.absent(),
    i0.Value<String?> summary = const i0.Value.absent(),
    i0.Value<DateTime?> publishedAt = const i0.Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => i1.SmallWebItem(
    id: id ?? this.id,
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    domain: domain ?? this.domain,
    author: author.present ? author.value : this.author,
    summary: summary.present ? summary.value : this.summary,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  SmallWebItem copyWithCompanion(i1.SmallWebItemsCompanion data) {
    return SmallWebItem(
      id: data.id.present ? data.id.value : this.id,
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      domain: data.domain.present ? data.domain.value : this.domain,
      author: data.author.present ? data.author.value : this.author,
      summary: data.summary.present ? data.summary.value : this.summary,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebItem(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    url,
    title,
    domain,
    author,
    summary,
    publishedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.SmallWebItem &&
          other.id == this.id &&
          other.url == this.url &&
          other.title == this.title &&
          other.domain == this.domain &&
          other.author == this.author &&
          other.summary == this.summary &&
          other.publishedAt == this.publishedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SmallWebItemsCompanion extends i0.UpdateCompanion<i1.SmallWebItem> {
  final i0.Value<String> id;
  final i0.Value<Uri> url;
  final i0.Value<String?> title;
  final i0.Value<String> domain;
  final i0.Value<String?> author;
  final i0.Value<String?> summary;
  final i0.Value<DateTime?> publishedAt;
  final i0.Value<DateTime> createdAt;
  final i0.Value<DateTime> updatedAt;
  final i0.Value<int> rowid;
  const SmallWebItemsCompanion({
    this.id = const i0.Value.absent(),
    this.url = const i0.Value.absent(),
    this.title = const i0.Value.absent(),
    this.domain = const i0.Value.absent(),
    this.author = const i0.Value.absent(),
    this.summary = const i0.Value.absent(),
    this.publishedAt = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.updatedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  SmallWebItemsCompanion.insert({
    required String id,
    required Uri url,
    this.title = const i0.Value.absent(),
    required String domain,
    this.author = const i0.Value.absent(),
    this.summary = const i0.Value.absent(),
    this.publishedAt = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.updatedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       url = i0.Value(url),
       domain = i0.Value(domain);
  static i0.Insertable<i1.SmallWebItem> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? url,
    i0.Expression<String>? title,
    i0.Expression<String>? domain,
    i0.Expression<String>? author,
    i0.Expression<String>? summary,
    i0.Expression<DateTime>? publishedAt,
    i0.Expression<DateTime>? createdAt,
    i0.Expression<DateTime>? updatedAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (domain != null) 'domain': domain,
      if (author != null) 'author': author,
      if (summary != null) 'summary': summary,
      if (publishedAt != null) 'published_at': publishedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.SmallWebItemsCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<Uri>? url,
    i0.Value<String?>? title,
    i0.Value<String>? domain,
    i0.Value<String?>? author,
    i0.Value<String?>? summary,
    i0.Value<DateTime?>? publishedAt,
    i0.Value<DateTime>? createdAt,
    i0.Value<DateTime>? updatedAt,
    i0.Value<int>? rowid,
  }) {
    return i1.SmallWebItemsCompanion(
      id: id ?? this.id,
      url: url ?? this.url,
      title: title ?? this.title,
      domain: domain ?? this.domain,
      author: author ?? this.author,
      summary: summary ?? this.summary,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (url.present) {
      map['url'] = i0.Variable<String>(
        i1.SmallWebItems.$converterurl.toSql(url.value),
      );
    }
    if (title.present) {
      map['title'] = i0.Variable<String>(title.value);
    }
    if (domain.present) {
      map['domain'] = i0.Variable<String>(domain.value);
    }
    if (author.present) {
      map['author'] = i0.Variable<String>(author.value);
    }
    if (summary.present) {
      map['summary'] = i0.Variable<String>(summary.value);
    }
    if (publishedAt.present) {
      map['published_at'] = i0.Variable<DateTime>(publishedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = i0.Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = i0.Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebItemsCompanion(')
          ..write('id: $id, ')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('domain: $domain, ')
          ..write('author: $author, ')
          ..write('summary: $summary, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SmallWebMemberships extends i0.Table
    with i0.TableInfo<SmallWebMemberships, i1.SmallWebMembership> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  SmallWebMemberships(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<String> itemId = i0.GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES small_web_items(id)ON DELETE CASCADE',
  );
  late final i0.GeneratedColumnWithTypeConverter<i3.SmallWebSourceKind, int>
  sourceKind =
      i0.GeneratedColumn<int>(
        'source_kind',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i3.SmallWebSourceKind>(
        i1.SmallWebMemberships.$convertersourceKind,
      );
  late final i0.GeneratedColumn<String> mode = i0.GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> consoleUrl =
      i0.GeneratedColumn<String>(
        'console_url',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i1.SmallWebMemberships.$converterconsoleUrl);
  late final i0.GeneratedColumnWithTypeConverter<List<String>, String>
  categories = i0.GeneratedColumn<String>(
    'categories',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'[]\'',
    defaultValue: const i0.CustomExpression('\'[]\''),
  ).withConverter<List<String>>(i1.SmallWebMemberships.$convertercategories);
  late final i0.GeneratedColumn<DateTime> fetchedAt =
      i0.GeneratedColumn<DateTime>(
        'fetched_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    itemId,
    sourceKind,
    mode,
    consoleUrl,
    categories,
    fetchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'small_web_memberships';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<i0.GeneratedColumn>> get uniqueKeys => [
    {itemId, sourceKind, mode, consoleUrl},
  ];
  @override
  i1.SmallWebMembership map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.SmallWebMembership(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      sourceKind: i1.SmallWebMemberships.$convertersourceKind.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}source_kind'],
        )!,
      ),
      mode: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
      consoleUrl: i1.SmallWebMemberships.$converterconsoleUrl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}console_url'],
        ),
      ),
      categories: i1.SmallWebMemberships.$convertercategories.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}categories'],
        )!,
      ),
      fetchedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
    );
  }

  @override
  SmallWebMemberships createAlias(String alias) {
    return SmallWebMemberships(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i3.SmallWebSourceKind, int, int>
  $convertersourceKind = const i0.EnumIndexConverter<i3.SmallWebSourceKind>(
    i3.SmallWebSourceKind.values,
  );
  static i0.TypeConverter<Uri?, String?> $converterconsoleUrl =
      const i2.UriConverterNullable();
  static i0.TypeConverter<List<String>, String> $convertercategories =
      const i4.StringListConverter();
  @override
  List<String> get customConstraints => const [
    'UNIQUE(item_id, source_kind, mode, console_url)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class SmallWebMembership extends i0.DataClass
    implements i0.Insertable<i1.SmallWebMembership> {
  final String id;
  final String itemId;
  final i3.SmallWebSourceKind sourceKind;
  final String? mode;
  final Uri? consoleUrl;
  final List<String> categories;
  final DateTime fetchedAt;
  const SmallWebMembership({
    required this.id,
    required this.itemId,
    required this.sourceKind,
    this.mode,
    this.consoleUrl,
    required this.categories,
    required this.fetchedAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    map['item_id'] = i0.Variable<String>(itemId);
    {
      map['source_kind'] = i0.Variable<int>(
        i1.SmallWebMemberships.$convertersourceKind.toSql(sourceKind),
      );
    }
    if (!nullToAbsent || mode != null) {
      map['mode'] = i0.Variable<String>(mode);
    }
    if (!nullToAbsent || consoleUrl != null) {
      map['console_url'] = i0.Variable<String>(
        i1.SmallWebMemberships.$converterconsoleUrl.toSql(consoleUrl),
      );
    }
    {
      map['categories'] = i0.Variable<String>(
        i1.SmallWebMemberships.$convertercategories.toSql(categories),
      );
    }
    map['fetched_at'] = i0.Variable<DateTime>(fetchedAt);
    return map;
  }

  factory SmallWebMembership.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return SmallWebMembership(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['item_id']),
      sourceKind: i1.SmallWebMemberships.$convertersourceKind.fromJson(
        serializer.fromJson<int>(json['source_kind']),
      ),
      mode: serializer.fromJson<String?>(json['mode']),
      consoleUrl: serializer.fromJson<Uri?>(json['console_url']),
      categories: serializer.fromJson<List<String>>(json['categories']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetched_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'item_id': serializer.toJson<String>(itemId),
      'source_kind': serializer.toJson<int>(
        i1.SmallWebMemberships.$convertersourceKind.toJson(sourceKind),
      ),
      'mode': serializer.toJson<String?>(mode),
      'console_url': serializer.toJson<Uri?>(consoleUrl),
      'categories': serializer.toJson<List<String>>(categories),
      'fetched_at': serializer.toJson<DateTime>(fetchedAt),
    };
  }

  i1.SmallWebMembership copyWith({
    String? id,
    String? itemId,
    i3.SmallWebSourceKind? sourceKind,
    i0.Value<String?> mode = const i0.Value.absent(),
    i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
    List<String>? categories,
    DateTime? fetchedAt,
  }) => i1.SmallWebMembership(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    sourceKind: sourceKind ?? this.sourceKind,
    mode: mode.present ? mode.value : this.mode,
    consoleUrl: consoleUrl.present ? consoleUrl.value : this.consoleUrl,
    categories: categories ?? this.categories,
    fetchedAt: fetchedAt ?? this.fetchedAt,
  );
  SmallWebMembership copyWithCompanion(i1.SmallWebMembershipsCompanion data) {
    return SmallWebMembership(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      mode: data.mode.present ? data.mode.value : this.mode,
      consoleUrl: data.consoleUrl.present
          ? data.consoleUrl.value
          : this.consoleUrl,
      categories: data.categories.present
          ? data.categories.value
          : this.categories,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebMembership(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('mode: $mode, ')
          ..write('consoleUrl: $consoleUrl, ')
          ..write('categories: $categories, ')
          ..write('fetchedAt: $fetchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    itemId,
    sourceKind,
    mode,
    consoleUrl,
    categories,
    fetchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.SmallWebMembership &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.sourceKind == this.sourceKind &&
          other.mode == this.mode &&
          other.consoleUrl == this.consoleUrl &&
          other.categories == this.categories &&
          other.fetchedAt == this.fetchedAt);
}

class SmallWebMembershipsCompanion
    extends i0.UpdateCompanion<i1.SmallWebMembership> {
  final i0.Value<String> id;
  final i0.Value<String> itemId;
  final i0.Value<i3.SmallWebSourceKind> sourceKind;
  final i0.Value<String?> mode;
  final i0.Value<Uri?> consoleUrl;
  final i0.Value<List<String>> categories;
  final i0.Value<DateTime> fetchedAt;
  final i0.Value<int> rowid;
  const SmallWebMembershipsCompanion({
    this.id = const i0.Value.absent(),
    this.itemId = const i0.Value.absent(),
    this.sourceKind = const i0.Value.absent(),
    this.mode = const i0.Value.absent(),
    this.consoleUrl = const i0.Value.absent(),
    this.categories = const i0.Value.absent(),
    this.fetchedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  SmallWebMembershipsCompanion.insert({
    required String id,
    required String itemId,
    required i3.SmallWebSourceKind sourceKind,
    this.mode = const i0.Value.absent(),
    this.consoleUrl = const i0.Value.absent(),
    this.categories = const i0.Value.absent(),
    this.fetchedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       itemId = i0.Value(itemId),
       sourceKind = i0.Value(sourceKind);
  static i0.Insertable<i1.SmallWebMembership> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? itemId,
    i0.Expression<int>? sourceKind,
    i0.Expression<String>? mode,
    i0.Expression<String>? consoleUrl,
    i0.Expression<String>? categories,
    i0.Expression<DateTime>? fetchedAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (mode != null) 'mode': mode,
      if (consoleUrl != null) 'console_url': consoleUrl,
      if (categories != null) 'categories': categories,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.SmallWebMembershipsCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String>? itemId,
    i0.Value<i3.SmallWebSourceKind>? sourceKind,
    i0.Value<String?>? mode,
    i0.Value<Uri?>? consoleUrl,
    i0.Value<List<String>>? categories,
    i0.Value<DateTime>? fetchedAt,
    i0.Value<int>? rowid,
  }) {
    return i1.SmallWebMembershipsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      sourceKind: sourceKind ?? this.sourceKind,
      mode: mode ?? this.mode,
      consoleUrl: consoleUrl ?? this.consoleUrl,
      categories: categories ?? this.categories,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = i0.Variable<String>(itemId.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = i0.Variable<int>(
        i1.SmallWebMemberships.$convertersourceKind.toSql(sourceKind.value),
      );
    }
    if (mode.present) {
      map['mode'] = i0.Variable<String>(mode.value);
    }
    if (consoleUrl.present) {
      map['console_url'] = i0.Variable<String>(
        i1.SmallWebMemberships.$converterconsoleUrl.toSql(consoleUrl.value),
      );
    }
    if (categories.present) {
      map['categories'] = i0.Variable<String>(
        i1.SmallWebMemberships.$convertercategories.toSql(categories.value),
      );
    }
    if (fetchedAt.present) {
      map['fetched_at'] = i0.Variable<DateTime>(fetchedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebMembershipsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('mode: $mode, ')
          ..write('consoleUrl: $consoleUrl, ')
          ..write('categories: $categories, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxMembershipSourceMode => i0.Index(
  'idx_membership_source_mode',
  'CREATE INDEX idx_membership_source_mode ON small_web_memberships (source_kind, mode)',
);
i0.Index get idxMembershipItem => i0.Index(
  'idx_membership_item',
  'CREATE INDEX idx_membership_item ON small_web_memberships (item_id)',
);

class WanderConsoles extends i0.Table
    with i0.TableInfo<WanderConsoles, i1.WanderConsole> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  WanderConsoles(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> url =
      i0.GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL PRIMARY KEY',
      ).withConverter<Uri>(i1.WanderConsoles.$converterurl);
  late final i0.GeneratedColumnWithTypeConverter<Uri, String> wanderJsUrl =
      i0.GeneratedColumn<String>(
        'wander_js_url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Uri>(i1.WanderConsoles.$converterwanderJsUrl);
  late final i0.GeneratedColumn<DateTime> lastFetchedAt =
      i0.GeneratedColumn<DateTime>(
        'last_fetched_at',
        aliasedName,
        true,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumn<bool> lastFetchFailed =
      i0.GeneratedColumn<bool>(
        'last_fetch_failed',
        aliasedName,
        true,
        type: i0.DriftSqlType.bool,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String>
  discoveredFromUrl = i0.GeneratedColumn<String>(
    'discovered_from_url',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<Uri?>(i1.WanderConsoles.$converterdiscoveredFromUrl);
  late final i0.GeneratedColumnWithTypeConverter<i5.WanderConsoleSource, int>
  source = i0.GeneratedColumn<int>(
    'source',
    aliasedName,
    false,
    type: i0.DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  ).withConverter<i5.WanderConsoleSource>(i1.WanderConsoles.$convertersource);
  late final i0.GeneratedColumn<DateTime> createdAt =
      i0.GeneratedColumn<DateTime>(
        'created_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    url,
    wanderJsUrl,
    lastFetchedAt,
    lastFetchFailed,
    discoveredFromUrl,
    source,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wander_consoles';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {url};
  @override
  i1.WanderConsole map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.WanderConsole(
      url: i1.WanderConsoles.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
      wanderJsUrl: i1.WanderConsoles.$converterwanderJsUrl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}wander_js_url'],
        )!,
      ),
      lastFetchedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched_at'],
      ),
      lastFetchFailed: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.bool,
        data['${effectivePrefix}last_fetch_failed'],
      ),
      discoveredFromUrl: i1.WanderConsoles.$converterdiscoveredFromUrl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}discovered_from_url'],
        ),
      ),
      source: i1.WanderConsoles.$convertersource.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}source'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  WanderConsoles createAlias(String alias) {
    return WanderConsoles(attachedDatabase, alias);
  }

  static i0.TypeConverter<Uri, String> $converterurl = const i2.UriConverter();
  static i0.TypeConverter<Uri, String> $converterwanderJsUrl =
      const i2.UriConverter();
  static i0.TypeConverter<Uri?, String?> $converterdiscoveredFromUrl =
      const i2.UriConverterNullable();
  static i0.JsonTypeConverter2<i5.WanderConsoleSource, int, int>
  $convertersource = const i0.EnumIndexConverter<i5.WanderConsoleSource>(
    i5.WanderConsoleSource.values,
  );
  @override
  bool get dontWriteConstraints => true;
}

class WanderConsole extends i0.DataClass
    implements i0.Insertable<i1.WanderConsole> {
  final Uri url;
  final Uri wanderJsUrl;
  final DateTime? lastFetchedAt;
  final bool? lastFetchFailed;
  final Uri? discoveredFromUrl;
  final i5.WanderConsoleSource source;
  final DateTime createdAt;
  const WanderConsole({
    required this.url,
    required this.wanderJsUrl,
    this.lastFetchedAt,
    this.lastFetchFailed,
    this.discoveredFromUrl,
    required this.source,
    required this.createdAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    {
      map['url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterurl.toSql(url),
      );
    }
    {
      map['wander_js_url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterwanderJsUrl.toSql(wanderJsUrl),
      );
    }
    if (!nullToAbsent || lastFetchedAt != null) {
      map['last_fetched_at'] = i0.Variable<DateTime>(lastFetchedAt);
    }
    if (!nullToAbsent || lastFetchFailed != null) {
      map['last_fetch_failed'] = i0.Variable<bool>(lastFetchFailed);
    }
    if (!nullToAbsent || discoveredFromUrl != null) {
      map['discovered_from_url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterdiscoveredFromUrl.toSql(discoveredFromUrl),
      );
    }
    {
      map['source'] = i0.Variable<int>(
        i1.WanderConsoles.$convertersource.toSql(source),
      );
    }
    map['created_at'] = i0.Variable<DateTime>(createdAt);
    return map;
  }

  factory WanderConsole.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return WanderConsole(
      url: serializer.fromJson<Uri>(json['url']),
      wanderJsUrl: serializer.fromJson<Uri>(json['wander_js_url']),
      lastFetchedAt: serializer.fromJson<DateTime?>(json['last_fetched_at']),
      lastFetchFailed: serializer.fromJson<bool?>(json['last_fetch_failed']),
      discoveredFromUrl: serializer.fromJson<Uri?>(json['discovered_from_url']),
      source: i1.WanderConsoles.$convertersource.fromJson(
        serializer.fromJson<int>(json['source']),
      ),
      createdAt: serializer.fromJson<DateTime>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<Uri>(url),
      'wander_js_url': serializer.toJson<Uri>(wanderJsUrl),
      'last_fetched_at': serializer.toJson<DateTime?>(lastFetchedAt),
      'last_fetch_failed': serializer.toJson<bool?>(lastFetchFailed),
      'discovered_from_url': serializer.toJson<Uri?>(discoveredFromUrl),
      'source': serializer.toJson<int>(
        i1.WanderConsoles.$convertersource.toJson(source),
      ),
      'created_at': serializer.toJson<DateTime>(createdAt),
    };
  }

  i1.WanderConsole copyWith({
    Uri? url,
    Uri? wanderJsUrl,
    i0.Value<DateTime?> lastFetchedAt = const i0.Value.absent(),
    i0.Value<bool?> lastFetchFailed = const i0.Value.absent(),
    i0.Value<Uri?> discoveredFromUrl = const i0.Value.absent(),
    i5.WanderConsoleSource? source,
    DateTime? createdAt,
  }) => i1.WanderConsole(
    url: url ?? this.url,
    wanderJsUrl: wanderJsUrl ?? this.wanderJsUrl,
    lastFetchedAt: lastFetchedAt.present
        ? lastFetchedAt.value
        : this.lastFetchedAt,
    lastFetchFailed: lastFetchFailed.present
        ? lastFetchFailed.value
        : this.lastFetchFailed,
    discoveredFromUrl: discoveredFromUrl.present
        ? discoveredFromUrl.value
        : this.discoveredFromUrl,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
  );
  WanderConsole copyWithCompanion(i1.WanderConsolesCompanion data) {
    return WanderConsole(
      url: data.url.present ? data.url.value : this.url,
      wanderJsUrl: data.wanderJsUrl.present
          ? data.wanderJsUrl.value
          : this.wanderJsUrl,
      lastFetchedAt: data.lastFetchedAt.present
          ? data.lastFetchedAt.value
          : this.lastFetchedAt,
      lastFetchFailed: data.lastFetchFailed.present
          ? data.lastFetchFailed.value
          : this.lastFetchFailed,
      discoveredFromUrl: data.discoveredFromUrl.present
          ? data.discoveredFromUrl.value
          : this.discoveredFromUrl,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WanderConsole(')
          ..write('url: $url, ')
          ..write('wanderJsUrl: $wanderJsUrl, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastFetchFailed: $lastFetchFailed, ')
          ..write('discoveredFromUrl: $discoveredFromUrl, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    wanderJsUrl,
    lastFetchedAt,
    lastFetchFailed,
    discoveredFromUrl,
    source,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.WanderConsole &&
          other.url == this.url &&
          other.wanderJsUrl == this.wanderJsUrl &&
          other.lastFetchedAt == this.lastFetchedAt &&
          other.lastFetchFailed == this.lastFetchFailed &&
          other.discoveredFromUrl == this.discoveredFromUrl &&
          other.source == this.source &&
          other.createdAt == this.createdAt);
}

class WanderConsolesCompanion extends i0.UpdateCompanion<i1.WanderConsole> {
  final i0.Value<Uri> url;
  final i0.Value<Uri> wanderJsUrl;
  final i0.Value<DateTime?> lastFetchedAt;
  final i0.Value<bool?> lastFetchFailed;
  final i0.Value<Uri?> discoveredFromUrl;
  final i0.Value<i5.WanderConsoleSource> source;
  final i0.Value<DateTime> createdAt;
  final i0.Value<int> rowid;
  const WanderConsolesCompanion({
    this.url = const i0.Value.absent(),
    this.wanderJsUrl = const i0.Value.absent(),
    this.lastFetchedAt = const i0.Value.absent(),
    this.lastFetchFailed = const i0.Value.absent(),
    this.discoveredFromUrl = const i0.Value.absent(),
    this.source = const i0.Value.absent(),
    this.createdAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  WanderConsolesCompanion.insert({
    required Uri url,
    required Uri wanderJsUrl,
    this.lastFetchedAt = const i0.Value.absent(),
    this.lastFetchFailed = const i0.Value.absent(),
    this.discoveredFromUrl = const i0.Value.absent(),
    required i5.WanderConsoleSource source,
    this.createdAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : url = i0.Value(url),
       wanderJsUrl = i0.Value(wanderJsUrl),
       source = i0.Value(source);
  static i0.Insertable<i1.WanderConsole> custom({
    i0.Expression<String>? url,
    i0.Expression<String>? wanderJsUrl,
    i0.Expression<DateTime>? lastFetchedAt,
    i0.Expression<bool>? lastFetchFailed,
    i0.Expression<String>? discoveredFromUrl,
    i0.Expression<int>? source,
    i0.Expression<DateTime>? createdAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (url != null) 'url': url,
      if (wanderJsUrl != null) 'wander_js_url': wanderJsUrl,
      if (lastFetchedAt != null) 'last_fetched_at': lastFetchedAt,
      if (lastFetchFailed != null) 'last_fetch_failed': lastFetchFailed,
      if (discoveredFromUrl != null) 'discovered_from_url': discoveredFromUrl,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.WanderConsolesCompanion copyWith({
    i0.Value<Uri>? url,
    i0.Value<Uri>? wanderJsUrl,
    i0.Value<DateTime?>? lastFetchedAt,
    i0.Value<bool?>? lastFetchFailed,
    i0.Value<Uri?>? discoveredFromUrl,
    i0.Value<i5.WanderConsoleSource>? source,
    i0.Value<DateTime>? createdAt,
    i0.Value<int>? rowid,
  }) {
    return i1.WanderConsolesCompanion(
      url: url ?? this.url,
      wanderJsUrl: wanderJsUrl ?? this.wanderJsUrl,
      lastFetchedAt: lastFetchedAt ?? this.lastFetchedAt,
      lastFetchFailed: lastFetchFailed ?? this.lastFetchFailed,
      discoveredFromUrl: discoveredFromUrl ?? this.discoveredFromUrl,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (url.present) {
      map['url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterurl.toSql(url.value),
      );
    }
    if (wanderJsUrl.present) {
      map['wander_js_url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterwanderJsUrl.toSql(wanderJsUrl.value),
      );
    }
    if (lastFetchedAt.present) {
      map['last_fetched_at'] = i0.Variable<DateTime>(lastFetchedAt.value);
    }
    if (lastFetchFailed.present) {
      map['last_fetch_failed'] = i0.Variable<bool>(lastFetchFailed.value);
    }
    if (discoveredFromUrl.present) {
      map['discovered_from_url'] = i0.Variable<String>(
        i1.WanderConsoles.$converterdiscoveredFromUrl.toSql(
          discoveredFromUrl.value,
        ),
      );
    }
    if (source.present) {
      map['source'] = i0.Variable<int>(
        i1.WanderConsoles.$convertersource.toSql(source.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = i0.Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WanderConsolesCompanion(')
          ..write('url: $url, ')
          ..write('wanderJsUrl: $wanderJsUrl, ')
          ..write('lastFetchedAt: $lastFetchedAt, ')
          ..write('lastFetchFailed: $lastFetchFailed, ')
          ..write('discoveredFromUrl: $discoveredFromUrl, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class WanderConsoleNeighbors extends i0.Table
    with i0.TableInfo<WanderConsoleNeighbors, i1.WanderConsoleNeighbor> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  WanderConsoleNeighbors(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> sourceConsoleUrl =
      i0.GeneratedColumn<String>(
        'source_console_url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints:
            'NOT NULL REFERENCES wander_consoles(url)ON DELETE CASCADE',
      );
  late final i0.GeneratedColumn<String> targetConsoleUrl =
      i0.GeneratedColumn<String>(
        'target_console_url',
        aliasedName,
        false,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final i0.GeneratedColumn<DateTime> discoveredAt =
      i0.GeneratedColumn<DateTime>(
        'discovered_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    sourceConsoleUrl,
    targetConsoleUrl,
    discoveredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wander_console_neighbors';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {
    sourceConsoleUrl,
    targetConsoleUrl,
  };
  @override
  i1.WanderConsoleNeighbor map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.WanderConsoleNeighbor(
      sourceConsoleUrl: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}source_console_url'],
      )!,
      targetConsoleUrl: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}target_console_url'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      )!,
    );
  }

  @override
  WanderConsoleNeighbors createAlias(String alias) {
    return WanderConsoleNeighbors(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY(source_console_url, target_console_url)',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class WanderConsoleNeighbor extends i0.DataClass
    implements i0.Insertable<i1.WanderConsoleNeighbor> {
  final String sourceConsoleUrl;
  final String targetConsoleUrl;
  final DateTime discoveredAt;
  const WanderConsoleNeighbor({
    required this.sourceConsoleUrl,
    required this.targetConsoleUrl,
    required this.discoveredAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['source_console_url'] = i0.Variable<String>(sourceConsoleUrl);
    map['target_console_url'] = i0.Variable<String>(targetConsoleUrl);
    map['discovered_at'] = i0.Variable<DateTime>(discoveredAt);
    return map;
  }

  factory WanderConsoleNeighbor.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return WanderConsoleNeighbor(
      sourceConsoleUrl: serializer.fromJson<String>(json['source_console_url']),
      targetConsoleUrl: serializer.fromJson<String>(json['target_console_url']),
      discoveredAt: serializer.fromJson<DateTime>(json['discovered_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'source_console_url': serializer.toJson<String>(sourceConsoleUrl),
      'target_console_url': serializer.toJson<String>(targetConsoleUrl),
      'discovered_at': serializer.toJson<DateTime>(discoveredAt),
    };
  }

  i1.WanderConsoleNeighbor copyWith({
    String? sourceConsoleUrl,
    String? targetConsoleUrl,
    DateTime? discoveredAt,
  }) => i1.WanderConsoleNeighbor(
    sourceConsoleUrl: sourceConsoleUrl ?? this.sourceConsoleUrl,
    targetConsoleUrl: targetConsoleUrl ?? this.targetConsoleUrl,
    discoveredAt: discoveredAt ?? this.discoveredAt,
  );
  WanderConsoleNeighbor copyWithCompanion(
    i1.WanderConsoleNeighborsCompanion data,
  ) {
    return WanderConsoleNeighbor(
      sourceConsoleUrl: data.sourceConsoleUrl.present
          ? data.sourceConsoleUrl.value
          : this.sourceConsoleUrl,
      targetConsoleUrl: data.targetConsoleUrl.present
          ? data.targetConsoleUrl.value
          : this.targetConsoleUrl,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WanderConsoleNeighbor(')
          ..write('sourceConsoleUrl: $sourceConsoleUrl, ')
          ..write('targetConsoleUrl: $targetConsoleUrl, ')
          ..write('discoveredAt: $discoveredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(sourceConsoleUrl, targetConsoleUrl, discoveredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.WanderConsoleNeighbor &&
          other.sourceConsoleUrl == this.sourceConsoleUrl &&
          other.targetConsoleUrl == this.targetConsoleUrl &&
          other.discoveredAt == this.discoveredAt);
}

class WanderConsoleNeighborsCompanion
    extends i0.UpdateCompanion<i1.WanderConsoleNeighbor> {
  final i0.Value<String> sourceConsoleUrl;
  final i0.Value<String> targetConsoleUrl;
  final i0.Value<DateTime> discoveredAt;
  final i0.Value<int> rowid;
  const WanderConsoleNeighborsCompanion({
    this.sourceConsoleUrl = const i0.Value.absent(),
    this.targetConsoleUrl = const i0.Value.absent(),
    this.discoveredAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  WanderConsoleNeighborsCompanion.insert({
    required String sourceConsoleUrl,
    required String targetConsoleUrl,
    this.discoveredAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : sourceConsoleUrl = i0.Value(sourceConsoleUrl),
       targetConsoleUrl = i0.Value(targetConsoleUrl);
  static i0.Insertable<i1.WanderConsoleNeighbor> custom({
    i0.Expression<String>? sourceConsoleUrl,
    i0.Expression<String>? targetConsoleUrl,
    i0.Expression<DateTime>? discoveredAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (sourceConsoleUrl != null) 'source_console_url': sourceConsoleUrl,
      if (targetConsoleUrl != null) 'target_console_url': targetConsoleUrl,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.WanderConsoleNeighborsCompanion copyWith({
    i0.Value<String>? sourceConsoleUrl,
    i0.Value<String>? targetConsoleUrl,
    i0.Value<DateTime>? discoveredAt,
    i0.Value<int>? rowid,
  }) {
    return i1.WanderConsoleNeighborsCompanion(
      sourceConsoleUrl: sourceConsoleUrl ?? this.sourceConsoleUrl,
      targetConsoleUrl: targetConsoleUrl ?? this.targetConsoleUrl,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (sourceConsoleUrl.present) {
      map['source_console_url'] = i0.Variable<String>(sourceConsoleUrl.value);
    }
    if (targetConsoleUrl.present) {
      map['target_console_url'] = i0.Variable<String>(targetConsoleUrl.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = i0.Variable<DateTime>(discoveredAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WanderConsoleNeighborsCompanion(')
          ..write('sourceConsoleUrl: $sourceConsoleUrl, ')
          ..write('targetConsoleUrl: $targetConsoleUrl, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class SmallWebVisits extends i0.Table
    with i0.TableInfo<SmallWebVisits, i1.SmallWebVisit> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  SmallWebVisits(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> id = i0.GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  late final i0.GeneratedColumn<String> itemId = i0.GeneratedColumn<String>(
    'item_id',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES small_web_items(id)ON DELETE CASCADE',
  );
  late final i0.GeneratedColumnWithTypeConverter<i3.SmallWebSourceKind, int>
  sourceKind =
      i0.GeneratedColumn<int>(
        'source_kind',
        aliasedName,
        false,
        type: i0.DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<i3.SmallWebSourceKind>(
        i1.SmallWebVisits.$convertersourceKind,
      );
  late final i0.GeneratedColumn<String> mode = i0.GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumnWithTypeConverter<Uri?, String> consoleUrl =
      i0.GeneratedColumn<String>(
        'console_url',
        aliasedName,
        true,
        type: i0.DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(i1.SmallWebVisits.$converterconsoleUrl);
  late final i0.GeneratedColumn<DateTime> visitedAt =
      i0.GeneratedColumn<DateTime>(
        'visited_at',
        aliasedName,
        false,
        type: i0.DriftSqlType.dateTime,
        requiredDuringInsert: false,
        $customConstraints: 'NOT NULL DEFAULT CURRENT_TIMESTAMP',
        defaultValue: const i0.CustomExpression('CURRENT_TIMESTAMP'),
      );
  @override
  List<i0.GeneratedColumn> get $columns => [
    id,
    itemId,
    sourceKind,
    mode,
    consoleUrl,
    visitedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'small_web_visits';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => {id};
  @override
  i1.SmallWebVisit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.SmallWebVisit(
      id: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}item_id'],
      )!,
      sourceKind: i1.SmallWebVisits.$convertersourceKind.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.int,
          data['${effectivePrefix}source_kind'],
        )!,
      ),
      mode: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
      consoleUrl: i1.SmallWebVisits.$converterconsoleUrl.fromSql(
        attachedDatabase.typeMapping.read(
          i0.DriftSqlType.string,
          data['${effectivePrefix}console_url'],
        ),
      ),
      visitedAt: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.dateTime,
        data['${effectivePrefix}visited_at'],
      )!,
    );
  }

  @override
  SmallWebVisits createAlias(String alias) {
    return SmallWebVisits(attachedDatabase, alias);
  }

  static i0.JsonTypeConverter2<i3.SmallWebSourceKind, int, int>
  $convertersourceKind = const i0.EnumIndexConverter<i3.SmallWebSourceKind>(
    i3.SmallWebSourceKind.values,
  );
  static i0.TypeConverter<Uri?, String?> $converterconsoleUrl =
      const i2.UriConverterNullable();
  @override
  bool get dontWriteConstraints => true;
}

class SmallWebVisit extends i0.DataClass
    implements i0.Insertable<i1.SmallWebVisit> {
  final String id;
  final String itemId;
  final i3.SmallWebSourceKind sourceKind;
  final String? mode;
  final Uri? consoleUrl;
  final DateTime visitedAt;
  const SmallWebVisit({
    required this.id,
    required this.itemId,
    required this.sourceKind,
    this.mode,
    this.consoleUrl,
    required this.visitedAt,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['id'] = i0.Variable<String>(id);
    map['item_id'] = i0.Variable<String>(itemId);
    {
      map['source_kind'] = i0.Variable<int>(
        i1.SmallWebVisits.$convertersourceKind.toSql(sourceKind),
      );
    }
    if (!nullToAbsent || mode != null) {
      map['mode'] = i0.Variable<String>(mode);
    }
    if (!nullToAbsent || consoleUrl != null) {
      map['console_url'] = i0.Variable<String>(
        i1.SmallWebVisits.$converterconsoleUrl.toSql(consoleUrl),
      );
    }
    map['visited_at'] = i0.Variable<DateTime>(visitedAt);
    return map;
  }

  factory SmallWebVisit.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return SmallWebVisit(
      id: serializer.fromJson<String>(json['id']),
      itemId: serializer.fromJson<String>(json['item_id']),
      sourceKind: i1.SmallWebVisits.$convertersourceKind.fromJson(
        serializer.fromJson<int>(json['source_kind']),
      ),
      mode: serializer.fromJson<String?>(json['mode']),
      consoleUrl: serializer.fromJson<Uri?>(json['console_url']),
      visitedAt: serializer.fromJson<DateTime>(json['visited_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'item_id': serializer.toJson<String>(itemId),
      'source_kind': serializer.toJson<int>(
        i1.SmallWebVisits.$convertersourceKind.toJson(sourceKind),
      ),
      'mode': serializer.toJson<String?>(mode),
      'console_url': serializer.toJson<Uri?>(consoleUrl),
      'visited_at': serializer.toJson<DateTime>(visitedAt),
    };
  }

  i1.SmallWebVisit copyWith({
    String? id,
    String? itemId,
    i3.SmallWebSourceKind? sourceKind,
    i0.Value<String?> mode = const i0.Value.absent(),
    i0.Value<Uri?> consoleUrl = const i0.Value.absent(),
    DateTime? visitedAt,
  }) => i1.SmallWebVisit(
    id: id ?? this.id,
    itemId: itemId ?? this.itemId,
    sourceKind: sourceKind ?? this.sourceKind,
    mode: mode.present ? mode.value : this.mode,
    consoleUrl: consoleUrl.present ? consoleUrl.value : this.consoleUrl,
    visitedAt: visitedAt ?? this.visitedAt,
  );
  SmallWebVisit copyWithCompanion(i1.SmallWebVisitsCompanion data) {
    return SmallWebVisit(
      id: data.id.present ? data.id.value : this.id,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      mode: data.mode.present ? data.mode.value : this.mode,
      consoleUrl: data.consoleUrl.present
          ? data.consoleUrl.value
          : this.consoleUrl,
      visitedAt: data.visitedAt.present ? data.visitedAt.value : this.visitedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebVisit(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('mode: $mode, ')
          ..write('consoleUrl: $consoleUrl, ')
          ..write('visitedAt: $visitedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemId, sourceKind, mode, consoleUrl, visitedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.SmallWebVisit &&
          other.id == this.id &&
          other.itemId == this.itemId &&
          other.sourceKind == this.sourceKind &&
          other.mode == this.mode &&
          other.consoleUrl == this.consoleUrl &&
          other.visitedAt == this.visitedAt);
}

class SmallWebVisitsCompanion extends i0.UpdateCompanion<i1.SmallWebVisit> {
  final i0.Value<String> id;
  final i0.Value<String> itemId;
  final i0.Value<i3.SmallWebSourceKind> sourceKind;
  final i0.Value<String?> mode;
  final i0.Value<Uri?> consoleUrl;
  final i0.Value<DateTime> visitedAt;
  final i0.Value<int> rowid;
  const SmallWebVisitsCompanion({
    this.id = const i0.Value.absent(),
    this.itemId = const i0.Value.absent(),
    this.sourceKind = const i0.Value.absent(),
    this.mode = const i0.Value.absent(),
    this.consoleUrl = const i0.Value.absent(),
    this.visitedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  SmallWebVisitsCompanion.insert({
    required String id,
    required String itemId,
    required i3.SmallWebSourceKind sourceKind,
    this.mode = const i0.Value.absent(),
    this.consoleUrl = const i0.Value.absent(),
    this.visitedAt = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : id = i0.Value(id),
       itemId = i0.Value(itemId),
       sourceKind = i0.Value(sourceKind);
  static i0.Insertable<i1.SmallWebVisit> custom({
    i0.Expression<String>? id,
    i0.Expression<String>? itemId,
    i0.Expression<int>? sourceKind,
    i0.Expression<String>? mode,
    i0.Expression<String>? consoleUrl,
    i0.Expression<DateTime>? visitedAt,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemId != null) 'item_id': itemId,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (mode != null) 'mode': mode,
      if (consoleUrl != null) 'console_url': consoleUrl,
      if (visitedAt != null) 'visited_at': visitedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.SmallWebVisitsCompanion copyWith({
    i0.Value<String>? id,
    i0.Value<String>? itemId,
    i0.Value<i3.SmallWebSourceKind>? sourceKind,
    i0.Value<String?>? mode,
    i0.Value<Uri?>? consoleUrl,
    i0.Value<DateTime>? visitedAt,
    i0.Value<int>? rowid,
  }) {
    return i1.SmallWebVisitsCompanion(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      sourceKind: sourceKind ?? this.sourceKind,
      mode: mode ?? this.mode,
      consoleUrl: consoleUrl ?? this.consoleUrl,
      visitedAt: visitedAt ?? this.visitedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (id.present) {
      map['id'] = i0.Variable<String>(id.value);
    }
    if (itemId.present) {
      map['item_id'] = i0.Variable<String>(itemId.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = i0.Variable<int>(
        i1.SmallWebVisits.$convertersourceKind.toSql(sourceKind.value),
      );
    }
    if (mode.present) {
      map['mode'] = i0.Variable<String>(mode.value);
    }
    if (consoleUrl.present) {
      map['console_url'] = i0.Variable<String>(
        i1.SmallWebVisits.$converterconsoleUrl.toSql(consoleUrl.value),
      );
    }
    if (visitedAt.present) {
      map['visited_at'] = i0.Variable<DateTime>(visitedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SmallWebVisitsCompanion(')
          ..write('id: $id, ')
          ..write('itemId: $itemId, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('mode: $mode, ')
          ..write('consoleUrl: $consoleUrl, ')
          ..write('visitedAt: $visitedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

i0.Index get idxVisitMode => i0.Index(
  'idx_visit_mode',
  'CREATE INDEX idx_visit_mode ON small_web_visits (source_kind, mode, visited_at)',
);
i0.Index get idxVisitItem => i0.Index(
  'idx_visit_item',
  'CREATE INDEX idx_visit_item ON small_web_visits (item_id)',
);

class DefinitionsDrift extends i6.ModularAccessor {
  DefinitionsDrift(i0.GeneratedDatabase db) : super(db);
  i0.Selectable<i1.SmallWebItem> getDiscoverableKagiItems({
    required i3.SmallWebSourceKind sourceKind,
    String? mode,
    String? category,
  }) {
    return customSelect(
      'SELECT i.* FROM small_web_items AS i INNER JOIN small_web_memberships AS m ON m.item_id = i.id WHERE m.source_kind = ?1 AND m.mode = ?2 AND(?3 IS NULL OR EXISTS (SELECT 1 AS _c0 FROM json_each(m.categories)WHERE value = ?3))AND i.id NOT IN (SELECT v.item_id FROM small_web_visits AS v WHERE v.source_kind = ?1 AND v.mode = ?2 ORDER BY v.visited_at DESC LIMIT 20)',
      variables: [
        i0.Variable<int>(
          i1.SmallWebVisits.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(mode),
        i0.Variable<String>(category),
      ],
      readsFrom: {smallWebItems, smallWebMemberships, smallWebVisits},
    ).asyncMap(smallWebItems.mapFromRow);
  }

  i0.Selectable<GetRecentVisitsResult> getRecentVisits({
    required i3.SmallWebSourceKind sourceKind,
    String? mode,
    required int limit,
  }) {
    return customSelect(
      'SELECT v.*, i.url, i.title, i.domain FROM small_web_visits AS v INNER JOIN small_web_items AS i ON i.id = v.item_id WHERE v.source_kind = ?1 AND((?2 IS NULL AND v.mode IS NULL)OR v.mode = ?2)ORDER BY v.visited_at DESC LIMIT ?3',
      variables: [
        i0.Variable<int>(
          i1.SmallWebVisits.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(mode),
        i0.Variable<int>(limit),
      ],
      readsFrom: {smallWebItems, smallWebVisits},
    ).map(
      (i0.QueryRow row) => GetRecentVisitsResult(
        id: row.read<String>('id'),
        itemId: row.read<String>('item_id'),
        sourceKind: i1.SmallWebVisits.$convertersourceKind.fromSql(
          row.read<int>('source_kind'),
        ),
        mode: row.readNullable<String>('mode'),
        consoleUrl: i1.SmallWebVisits.$converterconsoleUrl.fromSql(
          row.readNullable<String>('console_url'),
        ),
        visitedAt: row.read<DateTime>('visited_at'),
        url: i1.SmallWebItems.$converterurl.fromSql(row.read<String>('url')),
        title: row.readNullable<String>('title'),
        domain: row.read<String>('domain'),
      ),
    );
  }

  i0.Selectable<Uri> getDiscoveredConsoleUrls({required int limit}) {
    return customSelect(
      'SELECT url FROM wander_consoles ORDER BY created_at DESC LIMIT ?1',
      variables: [i0.Variable<int>(limit)],
      readsFrom: {wanderConsoles},
    ).map(
      (i0.QueryRow row) =>
          i1.WanderConsoles.$converterurl.fromSql(row.read<String>('url')),
    );
  }

  i0.Selectable<i1.SmallWebItem> getWanderPagesForConsole({
    required i3.SmallWebSourceKind sourceKind,
    required String consoleUrl,
  }) {
    return customSelect(
      'SELECT i.* FROM small_web_items AS i INNER JOIN small_web_memberships AS m ON m.item_id = i.id WHERE m.source_kind = ?1 AND m.console_url = CAST(?2 AS TEXT)',
      variables: [
        i0.Variable<int>(
          i1.SmallWebMemberships.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(consoleUrl),
      ],
      readsFrom: {smallWebItems, smallWebMemberships},
    ).asyncMap(smallWebItems.mapFromRow);
  }

  i0.Selectable<int> getConsoleNeighborCount({required String consoleUrl}) {
    return customSelect(
      'SELECT COUNT(*) AS c FROM wander_console_neighbors WHERE source_console_url = ?1',
      variables: [i0.Variable<String>(consoleUrl)],
      readsFrom: {wanderConsoleNeighbors},
    ).map((i0.QueryRow row) => row.read<int>('c'));
  }

  i0.Selectable<GetAllModeItemCountsResult> getAllModeItemCounts() {
    return customSelect(
      'SELECT source_kind, mode, COUNT(*) AS c FROM small_web_memberships GROUP BY source_kind, mode',
      variables: [],
      readsFrom: {smallWebMemberships},
    ).map(
      (i0.QueryRow row) => GetAllModeItemCountsResult(
        sourceKind: i1.SmallWebMemberships.$convertersourceKind.fromSql(
          row.read<int>('source_kind'),
        ),
        mode: row.readNullable<String>('mode'),
        c: row.read<int>('c'),
      ),
    );
  }

  i0.Selectable<String> getRecentVisitItemIds({
    required i3.SmallWebSourceKind sourceKind,
    String? mode,
    required int limit,
  }) {
    return customSelect(
      'SELECT DISTINCT item_id FROM small_web_visits WHERE source_kind = ?1 AND((?2 IS NULL AND mode IS NULL)OR mode = ?2)ORDER BY visited_at DESC LIMIT ?3',
      variables: [
        i0.Variable<int>(
          i1.SmallWebVisits.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(mode),
        i0.Variable<int>(limit),
      ],
      readsFrom: {smallWebVisits},
    ).map((i0.QueryRow row) => row.read<String>('item_id'));
  }

  i0.Selectable<GetNeighborConsolesWithPageCountsResult>
  getNeighborConsolesWithPageCounts({
    required i3.SmallWebSourceKind sourceKind,
    required String sourceConsoleUrl,
  }) {
    return customSelect(
      'SELECT wc.url, wc.last_fetched_at, wc.last_fetch_failed, (SELECT COUNT(*) FROM small_web_memberships AS m WHERE m.source_kind = ?1 AND m.console_url = CAST(wc.url AS TEXT)) AS page_count FROM wander_console_neighbors AS n INNER JOIN wander_consoles AS wc ON CAST(wc.url AS TEXT) = n.target_console_url WHERE n.source_console_url = ?2 AND COALESCE(wc.last_fetch_failed, 0) = 0 ORDER BY page_count DESC',
      variables: [
        i0.Variable<int>(
          i1.SmallWebMemberships.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(sourceConsoleUrl),
      ],
      readsFrom: {wanderConsoles, smallWebMemberships, wanderConsoleNeighbors},
    ).map(
      (i0.QueryRow row) => GetNeighborConsolesWithPageCountsResult(
        url: i1.WanderConsoles.$converterurl.fromSql(row.read<String>('url')),
        lastFetchedAt: row.readNullable<DateTime>('last_fetched_at'),
        lastFetchFailed: row.readNullable<bool>('last_fetch_failed'),
        pageCount: row.read<int>('page_count'),
      ),
    );
  }

  i0.Selectable<GetAllConsolesWithPageCountsResult>
  getAllConsolesWithPageCounts({
    required i3.SmallWebSourceKind sourceKind,
    required String query,
  }) {
    return customSelect(
      'SELECT wc.url, wc.last_fetched_at, wc.last_fetch_failed, (SELECT COUNT(*) FROM small_web_memberships AS m WHERE m.source_kind = ?1 AND m.console_url = CAST(wc.url AS TEXT)) AS page_count FROM wander_consoles AS wc WHERE COALESCE(wc.last_fetch_failed, 0) = 0 AND(?2 = \'\' OR CAST(wc.url AS TEXT) LIKE \'%\' || ?2 || \'%\')ORDER BY page_count DESC',
      variables: [
        i0.Variable<int>(
          i1.SmallWebMemberships.$convertersourceKind.toSql(sourceKind),
        ),
        i0.Variable<String>(query),
      ],
      readsFrom: {wanderConsoles, smallWebMemberships},
    ).map(
      (i0.QueryRow row) => GetAllConsolesWithPageCountsResult(
        url: i1.WanderConsoles.$converterurl.fromSql(row.read<String>('url')),
        lastFetchedAt: row.readNullable<DateTime>('last_fetched_at'),
        lastFetchFailed: row.readNullable<bool>('last_fetch_failed'),
        pageCount: row.read<int>('page_count'),
      ),
    );
  }

  i1.SmallWebItems get smallWebItems => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.SmallWebItems>('small_web_items');
  i1.SmallWebMemberships get smallWebMemberships => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.SmallWebMemberships>('small_web_memberships');
  i1.SmallWebVisits get smallWebVisits => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.SmallWebVisits>('small_web_visits');
  i1.WanderConsoles get wanderConsoles => i6.ReadDatabaseContainer(
    attachedDatabase,
  ).resultSet<i1.WanderConsoles>('wander_consoles');
  i1.WanderConsoleNeighbors get wanderConsoleNeighbors =>
      i6.ReadDatabaseContainer(
        attachedDatabase,
      ).resultSet<i1.WanderConsoleNeighbors>('wander_console_neighbors');
}

class GetRecentVisitsResult {
  final String id;
  final String itemId;
  final i3.SmallWebSourceKind sourceKind;
  final String? mode;
  final Uri? consoleUrl;
  final DateTime visitedAt;
  final Uri url;
  final String? title;
  final String domain;
  GetRecentVisitsResult({
    required this.id,
    required this.itemId,
    required this.sourceKind,
    this.mode,
    this.consoleUrl,
    required this.visitedAt,
    required this.url,
    this.title,
    required this.domain,
  });
}

class GetAllModeItemCountsResult {
  final i3.SmallWebSourceKind sourceKind;
  final String? mode;
  final int c;
  GetAllModeItemCountsResult({
    required this.sourceKind,
    this.mode,
    required this.c,
  });
}

class GetNeighborConsolesWithPageCountsResult {
  final Uri url;
  final DateTime? lastFetchedAt;
  final bool? lastFetchFailed;
  final int pageCount;
  GetNeighborConsolesWithPageCountsResult({
    required this.url,
    this.lastFetchedAt,
    this.lastFetchFailed,
    required this.pageCount,
  });
}

class GetAllConsolesWithPageCountsResult {
  final Uri url;
  final DateTime? lastFetchedAt;
  final bool? lastFetchFailed;
  final int pageCount;
  GetAllConsolesWithPageCountsResult({
    required this.url,
    this.lastFetchedAt,
    this.lastFetchFailed,
    required this.pageCount,
  });
}
