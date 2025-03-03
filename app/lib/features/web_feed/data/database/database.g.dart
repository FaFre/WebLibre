// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Feed extends Table with TableInfo<Feed, FeedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Feed(this.attachedDatabase, [this._alias]);
  late final GeneratedColumnWithTypeConverter<Uri, String> url =
      GeneratedColumn<String>(
        'url',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'PRIMARY KEY NOT NULL',
      ).withConverter<Uri>(Feed.$converterurl);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<Uri?, String> icon =
      GeneratedColumn<String>(
        'icon',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(Feed.$convertericonn);
  late final GeneratedColumnWithTypeConverter<Uri?, String> siteLink =
      GeneratedColumn<String>(
        'site_link',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(Feed.$convertersiteLinkn);
  late final GeneratedColumnWithTypeConverter<List<FeedAuthor>?, String>
  authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<FeedAuthor>?>(Feed.$converterauthorsn);
  late final GeneratedColumnWithTypeConverter<List<FeedCategory>?, String>
  tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<FeedCategory>?>(Feed.$convertertagsn);
  late final GeneratedColumn<DateTime> lastFetched = GeneratedColumn<DateTime>(
    'last_fetched',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    url,
    title,
    description,
    icon,
    siteLink,
    authors,
    tags,
    lastFetched,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'feed';
  @override
  Set<GeneratedColumn> get $primaryKey => {url};
  @override
  FeedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedData(
      url: Feed.$converterurl.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}url'],
        )!,
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      icon: Feed.$convertericonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}icon'],
        ),
      ),
      siteLink: Feed.$convertersiteLinkn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}site_link'],
        ),
      ),
      authors: Feed.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: Feed.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      lastFetched: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_fetched'],
      ),
    );
  }

  @override
  Feed createAlias(String alias) {
    return Feed(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterurl = const UriConverter();
  static TypeConverter<Uri, String> $convertericon = const UriConverter();
  static TypeConverter<Uri?, String?> $convertericonn =
      NullAwareTypeConverter.wrap($convertericon);
  static TypeConverter<Uri, String> $convertersiteLink = const UriConverter();
  static TypeConverter<Uri?, String?> $convertersiteLinkn =
      NullAwareTypeConverter.wrap($convertersiteLink);
  static TypeConverter<List<FeedAuthor>, String> $converterauthors =
      const FeedAuthorsConverter();
  static TypeConverter<List<FeedAuthor>?, String?> $converterauthorsn =
      NullAwareTypeConverter.wrap($converterauthors);
  static TypeConverter<List<FeedCategory>, String> $convertertags =
      const FeedCategoriesConverter();
  static TypeConverter<List<FeedCategory>?, String?> $convertertagsn =
      NullAwareTypeConverter.wrap($convertertags);
  @override
  bool get dontWriteConstraints => true;
}

class FeedData extends DataClass implements Insertable<FeedData> {
  final Uri url;
  final String? title;
  final String? description;
  final Uri? icon;
  final Uri? siteLink;
  final List<FeedAuthor>? authors;
  final List<FeedCategory>? tags;
  final DateTime? lastFetched;
  const FeedData({
    required this.url,
    this.title,
    this.description,
    this.icon,
    this.siteLink,
    this.authors,
    this.tags,
    this.lastFetched,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['url'] = Variable<String>(Feed.$converterurl.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(Feed.$convertericonn.toSql(icon));
    }
    if (!nullToAbsent || siteLink != null) {
      map['site_link'] = Variable<String>(
        Feed.$convertersiteLinkn.toSql(siteLink),
      );
    }
    if (!nullToAbsent || authors != null) {
      map['authors'] = Variable<String>(Feed.$converterauthorsn.toSql(authors));
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(Feed.$convertertagsn.toSql(tags));
    }
    if (!nullToAbsent || lastFetched != null) {
      map['last_fetched'] = Variable<DateTime>(lastFetched);
    }
    return map;
  }

  factory FeedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FeedData(
      url: serializer.fromJson<Uri>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      icon: serializer.fromJson<Uri?>(json['icon']),
      siteLink: serializer.fromJson<Uri?>(json['site_link']),
      authors: serializer.fromJson<List<FeedAuthor>?>(json['authors']),
      tags: serializer.fromJson<List<FeedCategory>?>(json['tags']),
      lastFetched: serializer.fromJson<DateTime?>(json['last_fetched']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'url': serializer.toJson<Uri>(url),
      'title': serializer.toJson<String?>(title),
      'description': serializer.toJson<String?>(description),
      'icon': serializer.toJson<Uri?>(icon),
      'site_link': serializer.toJson<Uri?>(siteLink),
      'authors': serializer.toJson<List<FeedAuthor>?>(authors),
      'tags': serializer.toJson<List<FeedCategory>?>(tags),
      'last_fetched': serializer.toJson<DateTime?>(lastFetched),
    };
  }

  FeedData copyWith({
    Uri? url,
    Value<String?> title = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<Uri?> icon = const Value.absent(),
    Value<Uri?> siteLink = const Value.absent(),
    Value<List<FeedAuthor>?> authors = const Value.absent(),
    Value<List<FeedCategory>?> tags = const Value.absent(),
    Value<DateTime?> lastFetched = const Value.absent(),
  }) => FeedData(
    url: url ?? this.url,
    title: title.present ? title.value : this.title,
    description: description.present ? description.value : this.description,
    icon: icon.present ? icon.value : this.icon,
    siteLink: siteLink.present ? siteLink.value : this.siteLink,
    authors: authors.present ? authors.value : this.authors,
    tags: tags.present ? tags.value : this.tags,
    lastFetched: lastFetched.present ? lastFetched.value : this.lastFetched,
  );
  FeedData copyWithCompanion(FeedCompanion data) {
    return FeedData(
      url: data.url.present ? data.url.value : this.url,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      icon: data.icon.present ? data.icon.value : this.icon,
      siteLink: data.siteLink.present ? data.siteLink.value : this.siteLink,
      authors: data.authors.present ? data.authors.value : this.authors,
      tags: data.tags.present ? data.tags.value : this.tags,
      lastFetched:
          data.lastFetched.present ? data.lastFetched.value : this.lastFetched,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FeedData(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('siteLink: $siteLink, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('lastFetched: $lastFetched')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    url,
    title,
    description,
    icon,
    siteLink,
    authors,
    tags,
    lastFetched,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FeedData &&
          other.url == this.url &&
          other.title == this.title &&
          other.description == this.description &&
          other.icon == this.icon &&
          other.siteLink == this.siteLink &&
          other.authors == this.authors &&
          other.tags == this.tags &&
          other.lastFetched == this.lastFetched);
}

class FeedCompanion extends UpdateCompanion<FeedData> {
  final Value<Uri> url;
  final Value<String?> title;
  final Value<String?> description;
  final Value<Uri?> icon;
  final Value<Uri?> siteLink;
  final Value<List<FeedAuthor>?> authors;
  final Value<List<FeedCategory>?> tags;
  final Value<DateTime?> lastFetched;
  final Value<int> rowid;
  const FeedCompanion({
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.siteLink = const Value.absent(),
    this.authors = const Value.absent(),
    this.tags = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FeedCompanion.insert({
    required Uri url,
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.icon = const Value.absent(),
    this.siteLink = const Value.absent(),
    this.authors = const Value.absent(),
    this.tags = const Value.absent(),
    this.lastFetched = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : url = Value(url);
  static Insertable<FeedData> custom({
    Expression<String>? url,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? icon,
    Expression<String>? siteLink,
    Expression<String>? authors,
    Expression<String>? tags,
    Expression<DateTime>? lastFetched,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (url != null) 'url': url,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (icon != null) 'icon': icon,
      if (siteLink != null) 'site_link': siteLink,
      if (authors != null) 'authors': authors,
      if (tags != null) 'tags': tags,
      if (lastFetched != null) 'last_fetched': lastFetched,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FeedCompanion copyWith({
    Value<Uri>? url,
    Value<String?>? title,
    Value<String?>? description,
    Value<Uri?>? icon,
    Value<Uri?>? siteLink,
    Value<List<FeedAuthor>?>? authors,
    Value<List<FeedCategory>?>? tags,
    Value<DateTime?>? lastFetched,
    Value<int>? rowid,
  }) {
    return FeedCompanion(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      siteLink: siteLink ?? this.siteLink,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      lastFetched: lastFetched ?? this.lastFetched,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (url.present) {
      map['url'] = Variable<String>(Feed.$converterurl.toSql(url.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(Feed.$convertericonn.toSql(icon.value));
    }
    if (siteLink.present) {
      map['site_link'] = Variable<String>(
        Feed.$convertersiteLinkn.toSql(siteLink.value),
      );
    }
    if (authors.present) {
      map['authors'] = Variable<String>(
        Feed.$converterauthorsn.toSql(authors.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(Feed.$convertertagsn.toSql(tags.value));
    }
    if (lastFetched.present) {
      map['last_fetched'] = Variable<DateTime>(lastFetched.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FeedCompanion(')
          ..write('url: $url, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('icon: $icon, ')
          ..write('siteLink: $siteLink, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('lastFetched: $lastFetched, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Article extends Table with TableInfo<Article, FeedArticle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Article(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<Uri, String> feedId =
      GeneratedColumn<String>(
        'feed_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL REFERENCES feed(url)ON DELETE CASCADE',
      ).withConverter<Uri>(Article.$converterfeedId);
  late final GeneratedColumn<DateTime> fetched = GeneratedColumn<DateTime>(
    'fetched',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<DateTime> lastRead = GeneratedColumn<DateTime>(
    'last_read',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<List<FeedAuthor>?, String>
  authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<FeedAuthor>?>(Article.$converterauthorsn);
  late final GeneratedColumnWithTypeConverter<List<FeedCategory>?, String>
  tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<List<FeedCategory>?>(Article.$convertertagsn);
  late final GeneratedColumnWithTypeConverter<List<FeedLink>?, String> links =
      GeneratedColumn<String>(
        'links',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<List<FeedLink>?>(Article.$converterlinksn);
  late final GeneratedColumn<String> summaryMarkdown = GeneratedColumn<String>(
    'summaryMarkdown',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> summaryPlain = GeneratedColumn<String>(
    'summaryPlain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> contentMarkdown = GeneratedColumn<String>(
    'contentMarkdown',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> contentPlain = GeneratedColumn<String>(
    'contentPlain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryMarkdown,
    summaryPlain,
    contentMarkdown,
    contentPlain,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FeedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedArticle(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      feedId: Article.$converterfeedId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feed_id'],
        )!,
      ),
      fetched:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}fetched'],
          )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      authors: Article.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: Article.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      links: Article.$converterlinksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}links'],
        ),
      ),
      summaryMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summaryMarkdown'],
      ),
      summaryPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      ),
      contentMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contentMarkdown'],
      ),
      contentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contentPlain'],
      ),
    );
  }

  @override
  Article createAlias(String alias) {
    return Article(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterfeedId = const UriConverter();
  static TypeConverter<List<FeedAuthor>, String> $converterauthors =
      const FeedAuthorsConverter();
  static TypeConverter<List<FeedAuthor>?, String?> $converterauthorsn =
      NullAwareTypeConverter.wrap($converterauthors);
  static TypeConverter<List<FeedCategory>, String> $convertertags =
      const FeedCategoriesConverter();
  static TypeConverter<List<FeedCategory>?, String?> $convertertagsn =
      NullAwareTypeConverter.wrap($convertertags);
  static TypeConverter<List<FeedLink>, String> $converterlinks =
      const FeedLinksConverter();
  static TypeConverter<List<FeedLink>?, String?> $converterlinksn =
      NullAwareTypeConverter.wrap($converterlinks);
  @override
  bool get dontWriteConstraints => true;
}

class ArticleCompanion extends UpdateCompanion<FeedArticle> {
  final Value<String> id;
  final Value<Uri> feedId;
  final Value<DateTime> fetched;
  final Value<DateTime?> created;
  final Value<DateTime?> updated;
  final Value<DateTime?> lastRead;
  final Value<String?> title;
  final Value<List<FeedAuthor>?> authors;
  final Value<List<FeedCategory>?> tags;
  final Value<List<FeedLink>?> links;
  final Value<String?> summaryMarkdown;
  final Value<String?> summaryPlain;
  final Value<String?> contentMarkdown;
  final Value<String?> contentPlain;
  final Value<int> rowid;
  const ArticleCompanion({
    this.id = const Value.absent(),
    this.feedId = const Value.absent(),
    this.fetched = const Value.absent(),
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.tags = const Value.absent(),
    this.links = const Value.absent(),
    this.summaryMarkdown = const Value.absent(),
    this.summaryPlain = const Value.absent(),
    this.contentMarkdown = const Value.absent(),
    this.contentPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleCompanion.insert({
    required String id,
    required Uri feedId,
    required DateTime fetched,
    this.created = const Value.absent(),
    this.updated = const Value.absent(),
    this.lastRead = const Value.absent(),
    this.title = const Value.absent(),
    this.authors = const Value.absent(),
    this.tags = const Value.absent(),
    this.links = const Value.absent(),
    this.summaryMarkdown = const Value.absent(),
    this.summaryPlain = const Value.absent(),
    this.contentMarkdown = const Value.absent(),
    this.contentPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       feedId = Value(feedId),
       fetched = Value(fetched);
  static Insertable<FeedArticle> custom({
    Expression<String>? id,
    Expression<String>? feedId,
    Expression<DateTime>? fetched,
    Expression<DateTime>? created,
    Expression<DateTime>? updated,
    Expression<DateTime>? lastRead,
    Expression<String>? title,
    Expression<String>? authors,
    Expression<String>? tags,
    Expression<String>? links,
    Expression<String>? summaryMarkdown,
    Expression<String>? summaryPlain,
    Expression<String>? contentMarkdown,
    Expression<String>? contentPlain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (feedId != null) 'feed_id': feedId,
      if (fetched != null) 'fetched': fetched,
      if (created != null) 'created': created,
      if (updated != null) 'updated': updated,
      if (lastRead != null) 'last_read': lastRead,
      if (title != null) 'title': title,
      if (authors != null) 'authors': authors,
      if (tags != null) 'tags': tags,
      if (links != null) 'links': links,
      if (summaryMarkdown != null) 'summaryMarkdown': summaryMarkdown,
      if (summaryPlain != null) 'summaryPlain': summaryPlain,
      if (contentMarkdown != null) 'contentMarkdown': contentMarkdown,
      if (contentPlain != null) 'contentPlain': contentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleCompanion copyWith({
    Value<String>? id,
    Value<Uri>? feedId,
    Value<DateTime>? fetched,
    Value<DateTime?>? created,
    Value<DateTime?>? updated,
    Value<DateTime?>? lastRead,
    Value<String?>? title,
    Value<List<FeedAuthor>?>? authors,
    Value<List<FeedCategory>?>? tags,
    Value<List<FeedLink>?>? links,
    Value<String?>? summaryMarkdown,
    Value<String?>? summaryPlain,
    Value<String?>? contentMarkdown,
    Value<String?>? contentPlain,
    Value<int>? rowid,
  }) {
    return ArticleCompanion(
      id: id ?? this.id,
      feedId: feedId ?? this.feedId,
      fetched: fetched ?? this.fetched,
      created: created ?? this.created,
      updated: updated ?? this.updated,
      lastRead: lastRead ?? this.lastRead,
      title: title ?? this.title,
      authors: authors ?? this.authors,
      tags: tags ?? this.tags,
      links: links ?? this.links,
      summaryMarkdown: summaryMarkdown ?? this.summaryMarkdown,
      summaryPlain: summaryPlain ?? this.summaryPlain,
      contentMarkdown: contentMarkdown ?? this.contentMarkdown,
      contentPlain: contentPlain ?? this.contentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (feedId.present) {
      map['feed_id'] = Variable<String>(
        Article.$converterfeedId.toSql(feedId.value),
      );
    }
    if (fetched.present) {
      map['fetched'] = Variable<DateTime>(fetched.value);
    }
    if (created.present) {
      map['created'] = Variable<DateTime>(created.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (lastRead.present) {
      map['last_read'] = Variable<DateTime>(lastRead.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(
        Article.$converterauthorsn.toSql(authors.value),
      );
    }
    if (tags.present) {
      map['tags'] = Variable<String>(Article.$convertertagsn.toSql(tags.value));
    }
    if (links.present) {
      map['links'] = Variable<String>(
        Article.$converterlinksn.toSql(links.value),
      );
    }
    if (summaryMarkdown.present) {
      map['summaryMarkdown'] = Variable<String>(summaryMarkdown.value);
    }
    if (summaryPlain.present) {
      map['summaryPlain'] = Variable<String>(summaryPlain.value);
    }
    if (contentMarkdown.present) {
      map['contentMarkdown'] = Variable<String>(contentMarkdown.value);
    }
    if (contentPlain.present) {
      map['contentPlain'] = Variable<String>(contentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleCompanion(')
          ..write('id: $id, ')
          ..write('feedId: $feedId, ')
          ..write('fetched: $fetched, ')
          ..write('created: $created, ')
          ..write('updated: $updated, ')
          ..write('lastRead: $lastRead, ')
          ..write('title: $title, ')
          ..write('authors: $authors, ')
          ..write('tags: $tags, ')
          ..write('links: $links, ')
          ..write('summaryMarkdown: $summaryMarkdown, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentMarkdown: $contentMarkdown, ')
          ..write('contentPlain: $contentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ArticleView extends ViewInfo<ArticleView, FeedArticle>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$FeedDatabase attachedDatabase;
  ArticleView(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    feedId,
    fetched,
    created,
    updated,
    lastRead,
    title,
    authors,
    tags,
    links,
    summaryMarkdown,
    summaryPlain,
    contentMarkdown,
    contentPlain,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'article_view';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite:
        'CREATE VIEW article_view AS SELECT a.*, f.icon FROM article AS a INNER JOIN feed AS f ON f.url = a.feed_id',
  };
  @override
  ArticleView get asDslTable => this;
  @override
  FeedArticle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FeedArticle(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      feedId: Article.$converterfeedId.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}feed_id'],
        )!,
      ),
      fetched:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}fetched'],
          )!,
      created: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created'],
      ),
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      ),
      lastRead: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_read'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      authors: Article.$converterauthorsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}authors'],
        ),
      ),
      tags: Article.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
      links: Article.$converterlinksn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}links'],
        ),
      ),
      summaryMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summaryMarkdown'],
      ),
      summaryPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summaryPlain'],
      ),
      contentMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contentMarkdown'],
      ),
      contentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contentPlain'],
      ),
      icon: Feed.$convertericonn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}icon'],
        ),
      ),
    );
  }

  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumnWithTypeConverter<Uri, String> feedId =
      GeneratedColumn<String>(
        'feed_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
      ).withConverter<Uri>(Article.$converterfeedId);
  late final GeneratedColumn<DateTime> fetched = GeneratedColumn<DateTime>(
    'fetched',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
  );
  late final GeneratedColumn<DateTime> created = GeneratedColumn<DateTime>(
    'created',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
  );
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
  );
  late final GeneratedColumn<DateTime> lastRead = GeneratedColumn<DateTime>(
    'last_read',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
  );
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumnWithTypeConverter<List<FeedAuthor>?, String>
  authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    true,
    type: DriftSqlType.string,
  ).withConverter<List<FeedAuthor>?>(Article.$converterauthorsn);
  late final GeneratedColumnWithTypeConverter<List<FeedCategory>?, String>
  tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
  ).withConverter<List<FeedCategory>?>(Article.$convertertagsn);
  late final GeneratedColumnWithTypeConverter<List<FeedLink>?, String> links =
      GeneratedColumn<String>(
        'links',
        aliasedName,
        true,
        type: DriftSqlType.string,
      ).withConverter<List<FeedLink>?>(Article.$converterlinksn);
  late final GeneratedColumn<String> summaryMarkdown = GeneratedColumn<String>(
    'summaryMarkdown',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> summaryPlain = GeneratedColumn<String>(
    'summaryPlain',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> contentMarkdown = GeneratedColumn<String>(
    'contentMarkdown',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> contentPlain = GeneratedColumn<String>(
    'contentPlain',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumnWithTypeConverter<Uri?, String> icon =
      GeneratedColumn<String>(
        'icon',
        aliasedName,
        true,
        type: DriftSqlType.string,
      ).withConverter<Uri?>(Feed.$convertericonn);
  @override
  ArticleView createAlias(String alias) {
    return ArticleView(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {'article', 'feed'};
}

class ArticleFts extends Table
    with
        TableInfo<ArticleFts, ArticleFt>,
        VirtualTableInfo<ArticleFts, ArticleFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ArticleFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> summaryPlain = GeneratedColumn<String>(
    'summaryPlain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> contentPlain = GeneratedColumn<String>(
    'contentPlain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [title, summaryPlain, contentPlain];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'article_fts';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ArticleFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArticleFt(
      title:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}title'],
          )!,
      summaryPlain:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}summaryPlain'],
          )!,
      contentPlain:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}contentPlain'],
          )!,
    );
  }

  @override
  ArticleFts createAlias(String alias) {
    return ArticleFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, summaryPlain, contentPlain, content=article, tokenize="trigram")';
}

class ArticleFt extends DataClass implements Insertable<ArticleFt> {
  final String title;
  final String summaryPlain;
  final String contentPlain;
  const ArticleFt({
    required this.title,
    required this.summaryPlain,
    required this.contentPlain,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['summaryPlain'] = Variable<String>(summaryPlain);
    map['contentPlain'] = Variable<String>(contentPlain);
    return map;
  }

  factory ArticleFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArticleFt(
      title: serializer.fromJson<String>(json['title']),
      summaryPlain: serializer.fromJson<String>(json['summaryPlain']),
      contentPlain: serializer.fromJson<String>(json['contentPlain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'summaryPlain': serializer.toJson<String>(summaryPlain),
      'contentPlain': serializer.toJson<String>(contentPlain),
    };
  }

  ArticleFt copyWith({
    String? title,
    String? summaryPlain,
    String? contentPlain,
  }) => ArticleFt(
    title: title ?? this.title,
    summaryPlain: summaryPlain ?? this.summaryPlain,
    contentPlain: contentPlain ?? this.contentPlain,
  );
  ArticleFt copyWithCompanion(ArticleFtsCompanion data) {
    return ArticleFt(
      title: data.title.present ? data.title.value : this.title,
      summaryPlain:
          data.summaryPlain.present
              ? data.summaryPlain.value
              : this.summaryPlain,
      contentPlain:
          data.contentPlain.present
              ? data.contentPlain.value
              : this.contentPlain,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArticleFt(')
          ..write('title: $title, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentPlain: $contentPlain')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, summaryPlain, contentPlain);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArticleFt &&
          other.title == this.title &&
          other.summaryPlain == this.summaryPlain &&
          other.contentPlain == this.contentPlain);
}

class ArticleFtsCompanion extends UpdateCompanion<ArticleFt> {
  final Value<String> title;
  final Value<String> summaryPlain;
  final Value<String> contentPlain;
  final Value<int> rowid;
  const ArticleFtsCompanion({
    this.title = const Value.absent(),
    this.summaryPlain = const Value.absent(),
    this.contentPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ArticleFtsCompanion.insert({
    required String title,
    required String summaryPlain,
    required String contentPlain,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       summaryPlain = Value(summaryPlain),
       contentPlain = Value(contentPlain);
  static Insertable<ArticleFt> custom({
    Expression<String>? title,
    Expression<String>? summaryPlain,
    Expression<String>? contentPlain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (summaryPlain != null) 'summaryPlain': summaryPlain,
      if (contentPlain != null) 'contentPlain': contentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ArticleFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? summaryPlain,
    Value<String>? contentPlain,
    Value<int>? rowid,
  }) {
    return ArticleFtsCompanion(
      title: title ?? this.title,
      summaryPlain: summaryPlain ?? this.summaryPlain,
      contentPlain: contentPlain ?? this.contentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summaryPlain.present) {
      map['summaryPlain'] = Variable<String>(summaryPlain.value);
    }
    if (contentPlain.present) {
      map['contentPlain'] = Variable<String>(contentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArticleFtsCompanion(')
          ..write('title: $title, ')
          ..write('summaryPlain: $summaryPlain, ')
          ..write('contentPlain: $contentPlain, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FeedDatabase extends GeneratedDatabase {
  _$FeedDatabase(QueryExecutor e) : super(e);
  $FeedDatabaseManager get managers => $FeedDatabaseManager(this);
  late final Feed feed = Feed(this);
  late final Article article = Article(this);
  late final ArticleView articleView = ArticleView(this);
  late final Index articleFeedId = Index(
    'article_feed_id',
    'CREATE INDEX article_feed_id ON article (feed_id)',
  );
  late final ArticleFts articleFts = ArticleFts(this);
  late final Trigger articleAfterInsert = Trigger(
    'CREATE TRIGGER article_after_insert AFTER INSERT ON article BEGIN INSERT INTO article_fts ("rowid", title, summaryPlain, contentPlain) VALUES (new."rowid", new.title, new.summaryPlain, new.contentPlain);END',
    'article_after_insert',
  );
  late final Trigger articleAfterDelete = Trigger(
    'CREATE TRIGGER article_after_delete AFTER DELETE ON article BEGIN INSERT INTO article_fts (article_fts, "rowid", title, summaryPlain, contentPlain) VALUES (\'delete\', old."rowid", old.title, old.summaryPlain, old.contentPlain);END',
    'article_after_delete',
  );
  late final Trigger articleAfterUpdate = Trigger(
    'CREATE TRIGGER article_after_update AFTER UPDATE ON article BEGIN INSERT INTO article_fts (article_fts, "rowid", title, summaryPlain, contentPlain) VALUES (\'delete\', old."rowid", old.title, old.summaryPlain, old.contentPlain);INSERT INTO article_fts ("rowid", title, summaryPlain, contentPlain) VALUES (new."rowid", new.title, new.summaryPlain, new.contentPlain);END',
    'article_after_update',
  );
  late final ArticleDao articleDao = ArticleDao(this as FeedDatabase);
  late final FeedDao feedDao = FeedDao(this as FeedDatabase);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO article_fts (article_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {articleFts},
    );
  }

  Selectable<FeedArticleQueryResult> queryArticlesBasic({
    required String query,
    String? feedId,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 1.0 AS title_weight) SELECT a.*, f.icon,(bm25(article_fts, weights.title_weight))AS weighted_rank FROM article_fts AS fts INNER JOIN article AS a ON a."rowid" = fts."rowid" INNER JOIN feed AS f ON f.url = a.feed_id CROSS JOIN weights WHERE fts.title LIKE ?1 AND(?2 IS NULL OR a.feed_id = ?2)ORDER BY weighted_rank ASC, a.created DESC NULLS LAST',
      variables: [Variable<String>(query), Variable<String>(feedId)],
      readsFrom: {feed, articleFts, article},
    ).map(
      (QueryRow row) => FeedArticleQueryResult(
        id: row.read<String>('id'),
        feedId: Article.$converterfeedId.fromSql(row.read<String>('feed_id')),
        fetched: row.read<DateTime>('fetched'),
        weightedRank: row.read<double>('weighted_rank'),
        created: row.readNullable<DateTime>('created'),
        updated: row.readNullable<DateTime>('updated'),
        lastRead: row.readNullable<DateTime>('last_read'),
        title: row.readNullable<String>('title'),
        authors: NullAwareTypeConverter.wrapFromSql(
          Article.$converterauthors,
          row.readNullable<String>('authors'),
        ),
        tags: NullAwareTypeConverter.wrapFromSql(
          Article.$convertertags,
          row.readNullable<String>('tags'),
        ),
        links: NullAwareTypeConverter.wrapFromSql(
          Article.$converterlinks,
          row.readNullable<String>('links'),
        ),
        summaryMarkdown: row.readNullable<String>('summaryMarkdown'),
        summaryPlain: row.readNullable<String>('summaryPlain'),
        contentMarkdown: row.readNullable<String>('contentMarkdown'),
        contentPlain: row.readNullable<String>('contentPlain'),
        icon: NullAwareTypeConverter.wrapFromSql(
          Feed.$convertericon,
          row.readNullable<String>('icon'),
        ),
      ),
    );
  }

  Selectable<FeedArticleQueryResult> queryArticlesFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
    String? feedId,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 3.0 AS summary_weight, 1.0 AS content_weight) SELECT a.*, f.icon, highlight(article_fts, 0, ?1, ?2) AS title_highlight, snippet(article_fts, 1, ?1, ?2, ?3, ?4) AS summary_snippet, snippet(article_fts, 2, ?1, ?2, ?3, ?4) AS content_snippet,(bm25(article_fts, weights.title_weight, weights.summary_weight, weights.content_weight))AS weighted_rank FROM article_fts(?5)AS fts INNER JOIN article AS a ON a."rowid" = fts."rowid" INNER JOIN feed AS f ON f.url = a.feed_id CROSS JOIN weights WHERE ?6 IS NULL OR a.feed_id = ?6 ORDER BY weighted_rank ASC, a.created DESC NULLS LAST',
      variables: [
        Variable<String>(beforeMatch),
        Variable<String>(afterMatch),
        Variable<String>(ellipsis),
        Variable<int>(snippetLength),
        Variable<String>(query),
        Variable<String>(feedId),
      ],
      readsFrom: {feed, articleFts, article},
    ).map(
      (QueryRow row) => FeedArticleQueryResult(
        id: row.read<String>('id'),
        feedId: Article.$converterfeedId.fromSql(row.read<String>('feed_id')),
        fetched: row.read<DateTime>('fetched'),
        weightedRank: row.read<double>('weighted_rank'),
        created: row.readNullable<DateTime>('created'),
        updated: row.readNullable<DateTime>('updated'),
        lastRead: row.readNullable<DateTime>('last_read'),
        title: row.readNullable<String>('title'),
        authors: NullAwareTypeConverter.wrapFromSql(
          Article.$converterauthors,
          row.readNullable<String>('authors'),
        ),
        tags: NullAwareTypeConverter.wrapFromSql(
          Article.$convertertags,
          row.readNullable<String>('tags'),
        ),
        links: NullAwareTypeConverter.wrapFromSql(
          Article.$converterlinks,
          row.readNullable<String>('links'),
        ),
        summaryMarkdown: row.readNullable<String>('summaryMarkdown'),
        summaryPlain: row.readNullable<String>('summaryPlain'),
        contentMarkdown: row.readNullable<String>('contentMarkdown'),
        contentPlain: row.readNullable<String>('contentPlain'),
        icon: NullAwareTypeConverter.wrapFromSql(
          Feed.$convertericon,
          row.readNullable<String>('icon'),
        ),
        titleHighlight: row.readNullable<String>('title_highlight'),
        summarySnippet: row.readNullable<String>('summary_snippet'),
        contentSnippet: row.readNullable<String>('content_snippet'),
      ),
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    feed,
    article,
    articleView,
    articleFeedId,
    articleFts,
    articleAfterInsert,
    articleAfterDelete,
    articleAfterUpdate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'feed',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'article',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('article_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'article',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('article_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'article',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('article_fts', kind: UpdateKind.insert)],
    ),
  ]);
}

typedef $FeedCreateCompanionBuilder =
    FeedCompanion Function({
      required Uri url,
      Value<String?> title,
      Value<String?> description,
      Value<Uri?> icon,
      Value<Uri?> siteLink,
      Value<List<FeedAuthor>?> authors,
      Value<List<FeedCategory>?> tags,
      Value<DateTime?> lastFetched,
      Value<int> rowid,
    });
typedef $FeedUpdateCompanionBuilder =
    FeedCompanion Function({
      Value<Uri> url,
      Value<String?> title,
      Value<String?> description,
      Value<Uri?> icon,
      Value<Uri?> siteLink,
      Value<List<FeedAuthor>?> authors,
      Value<List<FeedCategory>?> tags,
      Value<DateTime?> lastFetched,
      Value<int> rowid,
    });

final class $FeedReferences
    extends BaseReferences<_$FeedDatabase, Feed, FeedData> {
  $FeedReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Article, List<FeedArticle>> _articleRefsTable(
    _$FeedDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.article,
    aliasName: $_aliasNameGenerator(db.feed.url, db.article.feedId),
  );

  $ArticleProcessedTableManager get articleRefs {
    final manager = $ArticleTableManager(
      $_db,
      $_db.article,
    ).filter((f) => f.feedId.url.sqlEquals($_itemColumn<String>('url')!));

    final cache = $_typedResult.readTableOrNull(_articleRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $FeedFilterComposer extends Composer<_$FeedDatabase, Feed> {
  $FeedFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<Uri, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Uri?, Uri, String> get icon =>
      $composableBuilder(
        column: $table.icon,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Uri?, Uri, String> get siteLink =>
      $composableBuilder(
        column: $table.siteLink,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<List<FeedAuthor>?, List<FeedAuthor>, String>
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<FeedCategory>?,
    List<FeedCategory>,
    String
  >
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> articleRefs(
    Expression<bool> Function($ArticleFilterComposer f) f,
  ) {
    final $ArticleFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.article,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ArticleFilterComposer(
            $db: $db,
            $table: $db.article,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeedOrderingComposer extends Composer<_$FeedDatabase, Feed> {
  $FeedOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get siteLink => $composableBuilder(
    column: $table.siteLink,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => ColumnOrderings(column),
  );
}

class $FeedAnnotationComposer extends Composer<_$FeedDatabase, Feed> {
  $FeedAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<Uri, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Uri?, String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Uri?, String> get siteLink =>
      $composableBuilder(column: $table.siteLink, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<FeedAuthor>?, String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<FeedCategory>?, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<DateTime> get lastFetched => $composableBuilder(
    column: $table.lastFetched,
    builder: (column) => column,
  );

  Expression<T> articleRefs<T extends Object>(
    Expression<T> Function($ArticleAnnotationComposer a) f,
  ) {
    final $ArticleAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.url,
      referencedTable: $db.article,
      getReferencedColumn: (t) => t.feedId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ArticleAnnotationComposer(
            $db: $db,
            $table: $db.article,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $FeedTableManager
    extends
        RootTableManager<
          _$FeedDatabase,
          Feed,
          FeedData,
          $FeedFilterComposer,
          $FeedOrderingComposer,
          $FeedAnnotationComposer,
          $FeedCreateCompanionBuilder,
          $FeedUpdateCompanionBuilder,
          (FeedData, $FeedReferences),
          FeedData,
          PrefetchHooks Function({bool articleRefs})
        > {
  $FeedTableManager(_$FeedDatabase db, Feed table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $FeedFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $FeedOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $FeedAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<Uri> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<Uri?> icon = const Value.absent(),
                Value<Uri?> siteLink = const Value.absent(),
                Value<List<FeedAuthor>?> authors = const Value.absent(),
                Value<List<FeedCategory>?> tags = const Value.absent(),
                Value<DateTime?> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCompanion(
                url: url,
                title: title,
                description: description,
                icon: icon,
                siteLink: siteLink,
                authors: authors,
                tags: tags,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required Uri url,
                Value<String?> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<Uri?> icon = const Value.absent(),
                Value<Uri?> siteLink = const Value.absent(),
                Value<List<FeedAuthor>?> authors = const Value.absent(),
                Value<List<FeedCategory>?> tags = const Value.absent(),
                Value<DateTime?> lastFetched = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FeedCompanion.insert(
                url: url,
                title: title,
                description: description,
                icon: icon,
                siteLink: siteLink,
                authors: authors,
                tags: tags,
                lastFetched: lastFetched,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $FeedReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({articleRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (articleRefs) db.article],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (articleRefs)
                    await $_getPrefetchedData<FeedData, Feed, FeedArticle>(
                      currentTable: table,
                      referencedTable: $FeedReferences._articleRefsTable(db),
                      managerFromTypedResult:
                          (p0) => $FeedReferences(db, table, p0).articleRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.feedId == item.url,
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

typedef $FeedProcessedTableManager =
    ProcessedTableManager<
      _$FeedDatabase,
      Feed,
      FeedData,
      $FeedFilterComposer,
      $FeedOrderingComposer,
      $FeedAnnotationComposer,
      $FeedCreateCompanionBuilder,
      $FeedUpdateCompanionBuilder,
      (FeedData, $FeedReferences),
      FeedData,
      PrefetchHooks Function({bool articleRefs})
    >;
typedef $ArticleCreateCompanionBuilder =
    ArticleCompanion Function({
      required String id,
      required Uri feedId,
      required DateTime fetched,
      Value<DateTime?> created,
      Value<DateTime?> updated,
      Value<DateTime?> lastRead,
      Value<String?> title,
      Value<List<FeedAuthor>?> authors,
      Value<List<FeedCategory>?> tags,
      Value<List<FeedLink>?> links,
      Value<String?> summaryMarkdown,
      Value<String?> summaryPlain,
      Value<String?> contentMarkdown,
      Value<String?> contentPlain,
      Value<int> rowid,
    });
typedef $ArticleUpdateCompanionBuilder =
    ArticleCompanion Function({
      Value<String> id,
      Value<Uri> feedId,
      Value<DateTime> fetched,
      Value<DateTime?> created,
      Value<DateTime?> updated,
      Value<DateTime?> lastRead,
      Value<String?> title,
      Value<List<FeedAuthor>?> authors,
      Value<List<FeedCategory>?> tags,
      Value<List<FeedLink>?> links,
      Value<String?> summaryMarkdown,
      Value<String?> summaryPlain,
      Value<String?> contentMarkdown,
      Value<String?> contentPlain,
      Value<int> rowid,
    });

final class $ArticleReferences
    extends BaseReferences<_$FeedDatabase, Article, FeedArticle> {
  $ArticleReferences(super.$_db, super.$_table, super.$_typedResult);

  static Feed _feedIdTable(_$FeedDatabase db) =>
      db.feed.createAlias($_aliasNameGenerator(db.article.feedId, db.feed.url));

  $FeedProcessedTableManager get feedId {
    final $_column = $_itemColumn<String>('feed_id')!;

    final manager = $FeedTableManager(
      $_db,
      $_db.feed,
    ).filter((f) => f.url.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_feedIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ArticleFilterComposer extends Composer<_$FeedDatabase, Article> {
  $ArticleFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetched => $composableBuilder(
    column: $table.fetched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<FeedAuthor>?, List<FeedAuthor>, String>
  get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<
    List<FeedCategory>?,
    List<FeedCategory>,
    String
  >
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<List<FeedLink>?, List<FeedLink>, String>
  get links => $composableBuilder(
    column: $table.links,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => ColumnFilters(column),
  );

  $FeedFilterComposer get feedId {
    final $FeedFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feed,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeedFilterComposer(
            $db: $db,
            $table: $db.feed,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleOrderingComposer extends Composer<_$FeedDatabase, Article> {
  $ArticleOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetched => $composableBuilder(
    column: $table.fetched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get created => $composableBuilder(
    column: $table.created,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastRead => $composableBuilder(
    column: $table.lastRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get links => $composableBuilder(
    column: $table.links,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => ColumnOrderings(column),
  );

  $FeedOrderingComposer get feedId {
    final $FeedOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feed,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeedOrderingComposer(
            $db: $db,
            $table: $db.feed,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleAnnotationComposer extends Composer<_$FeedDatabase, Article> {
  $ArticleAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get fetched =>
      $composableBuilder(column: $table.fetched, builder: (column) => column);

  GeneratedColumn<DateTime> get created =>
      $composableBuilder(column: $table.created, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);

  GeneratedColumn<DateTime> get lastRead =>
      $composableBuilder(column: $table.lastRead, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<FeedAuthor>?, String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<FeedCategory>?, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<FeedLink>?, String> get links =>
      $composableBuilder(column: $table.links, builder: (column) => column);

  GeneratedColumn<String> get summaryMarkdown => $composableBuilder(
    column: $table.summaryMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentMarkdown => $composableBuilder(
    column: $table.contentMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => column,
  );

  $FeedAnnotationComposer get feedId {
    final $FeedAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.feedId,
      referencedTable: $db.feed,
      getReferencedColumn: (t) => t.url,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $FeedAnnotationComposer(
            $db: $db,
            $table: $db.feed,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ArticleTableManager
    extends
        RootTableManager<
          _$FeedDatabase,
          Article,
          FeedArticle,
          $ArticleFilterComposer,
          $ArticleOrderingComposer,
          $ArticleAnnotationComposer,
          $ArticleCreateCompanionBuilder,
          $ArticleUpdateCompanionBuilder,
          (FeedArticle, $ArticleReferences),
          FeedArticle,
          PrefetchHooks Function({bool feedId})
        > {
  $ArticleTableManager(_$FeedDatabase db, Article table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $ArticleFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $ArticleOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $ArticleAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<Uri> feedId = const Value.absent(),
                Value<DateTime> fetched = const Value.absent(),
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime?> lastRead = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<List<FeedAuthor>?> authors = const Value.absent(),
                Value<List<FeedCategory>?> tags = const Value.absent(),
                Value<List<FeedLink>?> links = const Value.absent(),
                Value<String?> summaryMarkdown = const Value.absent(),
                Value<String?> summaryPlain = const Value.absent(),
                Value<String?> contentMarkdown = const Value.absent(),
                Value<String?> contentPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleCompanion(
                id: id,
                feedId: feedId,
                fetched: fetched,
                created: created,
                updated: updated,
                lastRead: lastRead,
                title: title,
                authors: authors,
                tags: tags,
                links: links,
                summaryMarkdown: summaryMarkdown,
                summaryPlain: summaryPlain,
                contentMarkdown: contentMarkdown,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required Uri feedId,
                required DateTime fetched,
                Value<DateTime?> created = const Value.absent(),
                Value<DateTime?> updated = const Value.absent(),
                Value<DateTime?> lastRead = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<List<FeedAuthor>?> authors = const Value.absent(),
                Value<List<FeedCategory>?> tags = const Value.absent(),
                Value<List<FeedLink>?> links = const Value.absent(),
                Value<String?> summaryMarkdown = const Value.absent(),
                Value<String?> summaryPlain = const Value.absent(),
                Value<String?> contentMarkdown = const Value.absent(),
                Value<String?> contentPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleCompanion.insert(
                id: id,
                feedId: feedId,
                fetched: fetched,
                created: created,
                updated: updated,
                lastRead: lastRead,
                title: title,
                authors: authors,
                tags: tags,
                links: links,
                summaryMarkdown: summaryMarkdown,
                summaryPlain: summaryPlain,
                contentMarkdown: contentMarkdown,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $ArticleReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({feedId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
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
                if (feedId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.feedId,
                            referencedTable: $ArticleReferences._feedIdTable(
                              db,
                            ),
                            referencedColumn:
                                $ArticleReferences._feedIdTable(db).url,
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

typedef $ArticleProcessedTableManager =
    ProcessedTableManager<
      _$FeedDatabase,
      Article,
      FeedArticle,
      $ArticleFilterComposer,
      $ArticleOrderingComposer,
      $ArticleAnnotationComposer,
      $ArticleCreateCompanionBuilder,
      $ArticleUpdateCompanionBuilder,
      (FeedArticle, $ArticleReferences),
      FeedArticle,
      PrefetchHooks Function({bool feedId})
    >;
typedef $ArticleFtsCreateCompanionBuilder =
    ArticleFtsCompanion Function({
      required String title,
      required String summaryPlain,
      required String contentPlain,
      Value<int> rowid,
    });
typedef $ArticleFtsUpdateCompanionBuilder =
    ArticleFtsCompanion Function({
      Value<String> title,
      Value<String> summaryPlain,
      Value<String> contentPlain,
      Value<int> rowid,
    });

class $ArticleFtsFilterComposer extends Composer<_$FeedDatabase, ArticleFts> {
  $ArticleFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => ColumnFilters(column),
  );
}

class $ArticleFtsOrderingComposer extends Composer<_$FeedDatabase, ArticleFts> {
  $ArticleFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ArticleFtsAnnotationComposer
    extends Composer<_$FeedDatabase, ArticleFts> {
  $ArticleFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summaryPlain => $composableBuilder(
    column: $table.summaryPlain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentPlain => $composableBuilder(
    column: $table.contentPlain,
    builder: (column) => column,
  );
}

class $ArticleFtsTableManager
    extends
        RootTableManager<
          _$FeedDatabase,
          ArticleFts,
          ArticleFt,
          $ArticleFtsFilterComposer,
          $ArticleFtsOrderingComposer,
          $ArticleFtsAnnotationComposer,
          $ArticleFtsCreateCompanionBuilder,
          $ArticleFtsUpdateCompanionBuilder,
          (ArticleFt, BaseReferences<_$FeedDatabase, ArticleFts, ArticleFt>),
          ArticleFt,
          PrefetchHooks Function()
        > {
  $ArticleFtsTableManager(_$FeedDatabase db, ArticleFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $ArticleFtsFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $ArticleFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $ArticleFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> summaryPlain = const Value.absent(),
                Value<String> contentPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ArticleFtsCompanion(
                title: title,
                summaryPlain: summaryPlain,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String summaryPlain,
                required String contentPlain,
                Value<int> rowid = const Value.absent(),
              }) => ArticleFtsCompanion.insert(
                title: title,
                summaryPlain: summaryPlain,
                contentPlain: contentPlain,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ArticleFtsProcessedTableManager =
    ProcessedTableManager<
      _$FeedDatabase,
      ArticleFts,
      ArticleFt,
      $ArticleFtsFilterComposer,
      $ArticleFtsOrderingComposer,
      $ArticleFtsAnnotationComposer,
      $ArticleFtsCreateCompanionBuilder,
      $ArticleFtsUpdateCompanionBuilder,
      (ArticleFt, BaseReferences<_$FeedDatabase, ArticleFts, ArticleFt>),
      ArticleFt,
      PrefetchHooks Function()
    >;

class $FeedDatabaseManager {
  final _$FeedDatabase _db;
  $FeedDatabaseManager(this._db);
  $FeedTableManager get feed => $FeedTableManager(_db, _db.feed);
  $ArticleTableManager get article => $ArticleTableManager(_db, _db.article);
  $ArticleFtsTableManager get articleFts =>
      $ArticleFtsTableManager(_db, _db.articleFts);
}
