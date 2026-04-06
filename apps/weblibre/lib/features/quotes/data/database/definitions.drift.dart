// dart format width=80
// ignore_for_file: type=lint
import 'package:drift/drift.dart' as i0;
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart'
    as i1;

typedef $QuotesCreateCompanionBuilder =
    i1.QuotesCompanion Function({
      required String author,
      required String quote,
      i0.Value<String?> source,
      i0.Value<String?> tags,
      i0.Value<int> rowid,
    });
typedef $QuotesUpdateCompanionBuilder =
    i1.QuotesCompanion Function({
      i0.Value<String> author,
      i0.Value<String> quote,
      i0.Value<String?> source,
      i0.Value<String?> tags,
      i0.Value<int> rowid,
    });

class $QuotesFilterComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Quotes> {
  $QuotesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnFilters(column),
  );

  i0.ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnFilters(column),
  );
}

class $QuotesOrderingComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Quotes> {
  $QuotesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get quote => $composableBuilder(
    column: $table.quote,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => i0.ColumnOrderings(column),
  );

  i0.ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => i0.ColumnOrderings(column),
  );
}

class $QuotesAnnotationComposer
    extends i0.Composer<i0.GeneratedDatabase, i1.Quotes> {
  $QuotesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  i0.GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  i0.GeneratedColumn<String> get quote =>
      $composableBuilder(column: $table.quote, builder: (column) => column);

  i0.GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  i0.GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $QuotesTableManager
    extends
        i0.RootTableManager<
          i0.GeneratedDatabase,
          i1.Quotes,
          i1.Quote,
          i1.$QuotesFilterComposer,
          i1.$QuotesOrderingComposer,
          i1.$QuotesAnnotationComposer,
          $QuotesCreateCompanionBuilder,
          $QuotesUpdateCompanionBuilder,
          (
            i1.Quote,
            i0.BaseReferences<i0.GeneratedDatabase, i1.Quotes, i1.Quote>,
          ),
          i1.Quote,
          i0.PrefetchHooks Function()
        > {
  $QuotesTableManager(i0.GeneratedDatabase db, i1.Quotes table)
    : super(
        i0.TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              i1.$QuotesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              i1.$QuotesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              i1.$QuotesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                i0.Value<String> author = const i0.Value.absent(),
                i0.Value<String> quote = const i0.Value.absent(),
                i0.Value<String?> source = const i0.Value.absent(),
                i0.Value<String?> tags = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.QuotesCompanion(
                author: author,
                quote: quote,
                source: source,
                tags: tags,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String author,
                required String quote,
                i0.Value<String?> source = const i0.Value.absent(),
                i0.Value<String?> tags = const i0.Value.absent(),
                i0.Value<int> rowid = const i0.Value.absent(),
              }) => i1.QuotesCompanion.insert(
                author: author,
                quote: quote,
                source: source,
                tags: tags,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), i0.BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $QuotesProcessedTableManager =
    i0.ProcessedTableManager<
      i0.GeneratedDatabase,
      i1.Quotes,
      i1.Quote,
      i1.$QuotesFilterComposer,
      i1.$QuotesOrderingComposer,
      i1.$QuotesAnnotationComposer,
      $QuotesCreateCompanionBuilder,
      $QuotesUpdateCompanionBuilder,
      (i1.Quote, i0.BaseReferences<i0.GeneratedDatabase, i1.Quotes, i1.Quote>),
      i1.Quote,
      i0.PrefetchHooks Function()
    >;

class Quotes extends i0.Table with i0.TableInfo<Quotes, i1.Quote> {
  @override
  final i0.GeneratedDatabase attachedDatabase;
  final String? _alias;
  Quotes(this.attachedDatabase, [this._alias]);
  late final i0.GeneratedColumn<String> author = i0.GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> quote = i0.GeneratedColumn<String>(
    'quote',
    aliasedName,
    false,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final i0.GeneratedColumn<String> source = i0.GeneratedColumn<String>(
    'source',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final i0.GeneratedColumn<String> tags = i0.GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: i0.DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<i0.GeneratedColumn> get $columns => [author, quote, source, tags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  Set<i0.GeneratedColumn> get $primaryKey => const {};
  @override
  i1.Quote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return i1.Quote(
      author: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      quote: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}quote'],
      )!,
      source: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}source'],
      ),
      tags: attachedDatabase.typeMapping.read(
        i0.DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
    );
  }

  @override
  Quotes createAlias(String alias) {
    return Quotes(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Quote extends i0.DataClass implements i0.Insertable<i1.Quote> {
  final String author;
  final String quote;
  final String? source;
  final String? tags;
  const Quote({
    required this.author,
    required this.quote,
    this.source,
    this.tags,
  });
  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    map['author'] = i0.Variable<String>(author);
    map['quote'] = i0.Variable<String>(quote);
    if (!nullToAbsent || source != null) {
      map['source'] = i0.Variable<String>(source);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = i0.Variable<String>(tags);
    }
    return map;
  }

  factory Quote.fromJson(
    Map<String, dynamic> json, {
    i0.ValueSerializer? serializer,
  }) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return Quote(
      author: serializer.fromJson<String>(json['author']),
      quote: serializer.fromJson<String>(json['quote']),
      source: serializer.fromJson<String?>(json['source']),
      tags: serializer.fromJson<String?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({i0.ValueSerializer? serializer}) {
    serializer ??= i0.driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'author': serializer.toJson<String>(author),
      'quote': serializer.toJson<String>(quote),
      'source': serializer.toJson<String?>(source),
      'tags': serializer.toJson<String?>(tags),
    };
  }

  i1.Quote copyWith({
    String? author,
    String? quote,
    i0.Value<String?> source = const i0.Value.absent(),
    i0.Value<String?> tags = const i0.Value.absent(),
  }) => i1.Quote(
    author: author ?? this.author,
    quote: quote ?? this.quote,
    source: source.present ? source.value : this.source,
    tags: tags.present ? tags.value : this.tags,
  );
  Quote copyWithCompanion(i1.QuotesCompanion data) {
    return Quote(
      author: data.author.present ? data.author.value : this.author,
      quote: data.quote.present ? data.quote.value : this.quote,
      source: data.source.present ? data.source.value : this.source,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quote(')
          ..write('author: $author, ')
          ..write('quote: $quote, ')
          ..write('source: $source, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(author, quote, source, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is i1.Quote &&
          other.author == this.author &&
          other.quote == this.quote &&
          other.source == this.source &&
          other.tags == this.tags);
}

class QuotesCompanion extends i0.UpdateCompanion<i1.Quote> {
  final i0.Value<String> author;
  final i0.Value<String> quote;
  final i0.Value<String?> source;
  final i0.Value<String?> tags;
  final i0.Value<int> rowid;
  const QuotesCompanion({
    this.author = const i0.Value.absent(),
    this.quote = const i0.Value.absent(),
    this.source = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  });
  QuotesCompanion.insert({
    required String author,
    required String quote,
    this.source = const i0.Value.absent(),
    this.tags = const i0.Value.absent(),
    this.rowid = const i0.Value.absent(),
  }) : author = i0.Value(author),
       quote = i0.Value(quote);
  static i0.Insertable<i1.Quote> custom({
    i0.Expression<String>? author,
    i0.Expression<String>? quote,
    i0.Expression<String>? source,
    i0.Expression<String>? tags,
    i0.Expression<int>? rowid,
  }) {
    return i0.RawValuesInsertable({
      if (author != null) 'author': author,
      if (quote != null) 'quote': quote,
      if (source != null) 'source': source,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  i1.QuotesCompanion copyWith({
    i0.Value<String>? author,
    i0.Value<String>? quote,
    i0.Value<String?>? source,
    i0.Value<String?>? tags,
    i0.Value<int>? rowid,
  }) {
    return i1.QuotesCompanion(
      author: author ?? this.author,
      quote: quote ?? this.quote,
      source: source ?? this.source,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, i0.Expression> toColumns(bool nullToAbsent) {
    final map = <String, i0.Expression>{};
    if (author.present) {
      map['author'] = i0.Variable<String>(author.value);
    }
    if (quote.present) {
      map['quote'] = i0.Variable<String>(quote.value);
    }
    if (source.present) {
      map['source'] = i0.Variable<String>(source.value);
    }
    if (tags.present) {
      map['tags'] = i0.Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = i0.Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('author: $author, ')
          ..write('quote: $quote, ')
          ..write('source: $source, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}
