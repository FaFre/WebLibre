// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Container extends Table with TableInfo<Container, ContainerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Container(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumnWithTypeConverter<Color, int> color =
      GeneratedColumn<int>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<Color>(Container.$convertercolor);
  late final GeneratedColumnWithTypeConverter<ContainerMetadata?, String>
  metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  ).withConverter<ContainerMetadata?>(Container.$convertermetadatan);
  @override
  List<GeneratedColumn> get $columns => [id, name, color, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'container';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ContainerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContainerData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      ),
      color: Container.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}color'],
        )!,
      ),
      metadata: Container.$convertermetadatan.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metadata'],
        ),
      ),
    );
  }

  @override
  Container createAlias(String alias) {
    return Container(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $convertercolor = const ColorConverter();
  static TypeConverter<ContainerMetadata, String> $convertermetadata =
      const ContainerMetadataConverter();
  static TypeConverter<ContainerMetadata?, String?> $convertermetadatan =
      NullAwareTypeConverter.wrap($convertermetadata);
  @override
  bool get dontWriteConstraints => true;
}

class ContainerCompanion extends UpdateCompanion<ContainerData> {
  final Value<String> id;
  final Value<String?> name;
  final Value<Color> color;
  final Value<ContainerMetadata?> metadata;
  final Value<int> rowid;
  const ContainerCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContainerCompanion.insert({
    required String id,
    this.name = const Value.absent(),
    required Color color,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       color = Value(color);
  static Insertable<ContainerData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContainerCompanion copyWith({
    Value<String>? id,
    Value<String?>? name,
    Value<Color>? color,
    Value<ContainerMetadata?>? metadata,
    Value<int>? rowid,
  }) {
    return ContainerCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(
        Container.$convertercolor.toSql(color.value),
      );
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(
        Container.$convertermetadatan.toSql(metadata.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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

class Tab extends Table with TableInfo<Tab, TabData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Tab(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<String> containerId = GeneratedColumn<String>(
    'container_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES container(id)ON DELETE CASCADE',
  );
  late final GeneratedColumn<String> orderKey = GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<Uri?, String> url =
      GeneratedColumn<String>(
        'url',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      ).withConverter<Uri?>(Tab.$converterurln);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<bool> isProbablyReaderable = GeneratedColumn<bool>(
    'is_probably_readerable',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> extractedContentMarkdown =
      GeneratedColumn<String>(
        'extracted_content_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final GeneratedColumn<String> extractedContentPlain =
      GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final GeneratedColumn<String> fullContentMarkdown =
      GeneratedColumn<String>(
        'full_content_markdown',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  late final GeneratedColumn<String> fullContentPlain = GeneratedColumn<String>(
    'full_content_plain',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
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
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TabData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      containerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}container_id'],
      ),
      orderKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_key'],
      )!,
      url: Tab.$converterurln.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}url'],
        ),
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      isProbablyReaderable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_probably_readerable'],
      ),
      extractedContentMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_content_markdown'],
      ),
      extractedContentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      ),
      fullContentMarkdown: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_content_markdown'],
      ),
      fullContentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_content_plain'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}timestamp'],
      )!,
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  static TypeConverter<Uri, String> $converterurl = const UriConverter();
  static TypeConverter<Uri?, String?> $converterurln =
      NullAwareTypeConverter.wrap($converterurl);
  @override
  bool get dontWriteConstraints => true;
}

class TabData extends DataClass implements Insertable<TabData> {
  final String id;
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || containerId != null) {
      map['container_id'] = Variable<String>(containerId);
    }
    map['order_key'] = Variable<String>(orderKey);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(Tab.$converterurln.toSql(url));
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || isProbablyReaderable != null) {
      map['is_probably_readerable'] = Variable<bool>(isProbablyReaderable);
    }
    if (!nullToAbsent || extractedContentMarkdown != null) {
      map['extracted_content_markdown'] = Variable<String>(
        extractedContentMarkdown,
      );
    }
    if (!nullToAbsent || extractedContentPlain != null) {
      map['extracted_content_plain'] = Variable<String>(extractedContentPlain);
    }
    if (!nullToAbsent || fullContentMarkdown != null) {
      map['full_content_markdown'] = Variable<String>(fullContentMarkdown);
    }
    if (!nullToAbsent || fullContentPlain != null) {
      map['full_content_plain'] = Variable<String>(fullContentPlain);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  factory TabData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
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
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
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

  TabData copyWith({
    String? id,
    Value<String?> containerId = const Value.absent(),
    String? orderKey,
    Value<Uri?> url = const Value.absent(),
    Value<String?> title = const Value.absent(),
    Value<bool?> isProbablyReaderable = const Value.absent(),
    Value<String?> extractedContentMarkdown = const Value.absent(),
    Value<String?> extractedContentPlain = const Value.absent(),
    Value<String?> fullContentMarkdown = const Value.absent(),
    Value<String?> fullContentPlain = const Value.absent(),
    DateTime? timestamp,
  }) => TabData(
    id: id ?? this.id,
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
  TabData copyWithCompanion(TabCompanion data) {
    return TabData(
      id: data.id.present ? data.id.value : this.id,
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
      (other is TabData &&
          other.id == this.id &&
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

class TabCompanion extends UpdateCompanion<TabData> {
  final Value<String> id;
  final Value<String?> containerId;
  final Value<String> orderKey;
  final Value<Uri?> url;
  final Value<String?> title;
  final Value<bool?> isProbablyReaderable;
  final Value<String?> extractedContentMarkdown;
  final Value<String?> extractedContentPlain;
  final Value<String?> fullContentMarkdown;
  final Value<String?> fullContentPlain;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TabCompanion({
    this.id = const Value.absent(),
    this.containerId = const Value.absent(),
    this.orderKey = const Value.absent(),
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.isProbablyReaderable = const Value.absent(),
    this.extractedContentMarkdown = const Value.absent(),
    this.extractedContentPlain = const Value.absent(),
    this.fullContentMarkdown = const Value.absent(),
    this.fullContentPlain = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabCompanion.insert({
    required String id,
    this.containerId = const Value.absent(),
    required String orderKey,
    this.url = const Value.absent(),
    this.title = const Value.absent(),
    this.isProbablyReaderable = const Value.absent(),
    this.extractedContentMarkdown = const Value.absent(),
    this.extractedContentPlain = const Value.absent(),
    this.fullContentMarkdown = const Value.absent(),
    this.fullContentPlain = const Value.absent(),
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       orderKey = Value(orderKey),
       timestamp = Value(timestamp);
  static Insertable<TabData> custom({
    Expression<String>? id,
    Expression<String>? containerId,
    Expression<String>? orderKey,
    Expression<String>? url,
    Expression<String>? title,
    Expression<bool>? isProbablyReaderable,
    Expression<String>? extractedContentMarkdown,
    Expression<String>? extractedContentPlain,
    Expression<String>? fullContentMarkdown,
    Expression<String>? fullContentPlain,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
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

  TabCompanion copyWith({
    Value<String>? id,
    Value<String?>? containerId,
    Value<String>? orderKey,
    Value<Uri?>? url,
    Value<String?>? title,
    Value<bool?>? isProbablyReaderable,
    Value<String?>? extractedContentMarkdown,
    Value<String?>? extractedContentPlain,
    Value<String?>? fullContentMarkdown,
    Value<String?>? fullContentPlain,
    Value<DateTime>? timestamp,
    Value<int>? rowid,
  }) {
    return TabCompanion(
      id: id ?? this.id,
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (containerId.present) {
      map['container_id'] = Variable<String>(containerId.value);
    }
    if (orderKey.present) {
      map['order_key'] = Variable<String>(orderKey.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(Tab.$converterurln.toSql(url.value));
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isProbablyReaderable.present) {
      map['is_probably_readerable'] = Variable<bool>(
        isProbablyReaderable.value,
      );
    }
    if (extractedContentMarkdown.present) {
      map['extracted_content_markdown'] = Variable<String>(
        extractedContentMarkdown.value,
      );
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentMarkdown.present) {
      map['full_content_markdown'] = Variable<String>(
        fullContentMarkdown.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = Variable<String>(fullContentPlain.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TabCompanion(')
          ..write('id: $id, ')
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

class TabFts extends Table
    with TableInfo<TabFts, TabFt>, VirtualTableInfo<TabFts, TabFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TabFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
    'url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> extractedContentPlain =
      GeneratedColumn<String>(
        'extracted_content_plain',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: '',
      );
  late final GeneratedColumn<String> fullContentPlain = GeneratedColumn<String>(
    'full_content_plain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
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
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  TabFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TabFt(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      url: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url'],
      )!,
      extractedContentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}extracted_content_plain'],
      )!,
      fullContentPlain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
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

class TabFt extends DataClass implements Insertable<TabFt> {
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
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['extracted_content_plain'] = Variable<String>(extractedContentPlain);
    map['full_content_plain'] = Variable<String>(fullContentPlain);
    return map;
  }

  factory TabFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
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
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'extracted_content_plain': serializer.toJson<String>(
        extractedContentPlain,
      ),
      'full_content_plain': serializer.toJson<String>(fullContentPlain),
    };
  }

  TabFt copyWith({
    String? title,
    String? url,
    String? extractedContentPlain,
    String? fullContentPlain,
  }) => TabFt(
    title: title ?? this.title,
    url: url ?? this.url,
    extractedContentPlain: extractedContentPlain ?? this.extractedContentPlain,
    fullContentPlain: fullContentPlain ?? this.fullContentPlain,
  );
  TabFt copyWithCompanion(TabFtsCompanion data) {
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
      (other is TabFt &&
          other.title == this.title &&
          other.url == this.url &&
          other.extractedContentPlain == this.extractedContentPlain &&
          other.fullContentPlain == this.fullContentPlain);
}

class TabFtsCompanion extends UpdateCompanion<TabFt> {
  final Value<String> title;
  final Value<String> url;
  final Value<String> extractedContentPlain;
  final Value<String> fullContentPlain;
  final Value<int> rowid;
  const TabFtsCompanion({
    this.title = const Value.absent(),
    this.url = const Value.absent(),
    this.extractedContentPlain = const Value.absent(),
    this.fullContentPlain = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TabFtsCompanion.insert({
    required String title,
    required String url,
    required String extractedContentPlain,
    required String fullContentPlain,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       url = Value(url),
       extractedContentPlain = Value(extractedContentPlain),
       fullContentPlain = Value(fullContentPlain);
  static Insertable<TabFt> custom({
    Expression<String>? title,
    Expression<String>? url,
    Expression<String>? extractedContentPlain,
    Expression<String>? fullContentPlain,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (url != null) 'url': url,
      if (extractedContentPlain != null)
        'extracted_content_plain': extractedContentPlain,
      if (fullContentPlain != null) 'full_content_plain': fullContentPlain,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TabFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? url,
    Value<String>? extractedContentPlain,
    Value<String>? fullContentPlain,
    Value<int>? rowid,
  }) {
    return TabFtsCompanion(
      title: title ?? this.title,
      url: url ?? this.url,
      extractedContentPlain:
          extractedContentPlain ?? this.extractedContentPlain,
      fullContentPlain: fullContentPlain ?? this.fullContentPlain,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] = Variable<String>(
        extractedContentPlain.value,
      );
    }
    if (fullContentPlain.present) {
      map['full_content_plain'] = Variable<String>(fullContentPlain.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
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

abstract class _$TabDatabase extends GeneratedDatabase {
  _$TabDatabase(QueryExecutor e) : super(e);
  $TabDatabaseManager get managers => $TabDatabaseManager(this);
  late final Container container = Container(this);
  late final Tab tab = Tab(this);
  late final TabFts tabFts = TabFts(this);
  late final Trigger tabAfterInsert = Trigger(
    'CREATE TRIGGER tab_after_insert AFTER INSERT ON tab BEGIN INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
    'tab_after_insert',
  );
  late final Trigger tabAfterDelete = Trigger(
    'CREATE TRIGGER tab_after_delete AFTER DELETE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);END',
    'tab_after_delete',
  );
  late final Trigger tabAfterUpdate = Trigger(
    'CREATE TRIGGER tab_after_update AFTER UPDATE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
    'tab_after_update',
  );
  late final ContainerDao containerDao = ContainerDao(this as TabDatabase);
  late final TabDao tabDao = TabDao(this as TabDatabase);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO tab_fts (tab_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {tabFts},
    );
  }

  Selectable<ContainerDataWithCount> containersWithCount() {
    return customSelect(
      'SELECT container.*, tab_agg.tab_count FROM container LEFT JOIN (SELECT container_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY tab_agg.last_updated DESC NULLS LAST',
      variables: [],
      readsFrom: {container, tab},
    ).map(
      (QueryRow row) => ContainerDataWithCount(
        id: row.read<String>('id'),
        name: row.readNullable<String>('name'),
        color: Container.$convertercolor.fromSql(row.read<int>('color')),
        metadata: NullAwareTypeConverter.wrapFromSql(
          Container.$convertermetadata,
          row.readNullable<String>('metadata'),
        ),
        tabCount: row.readNullable<int>('tab_count'),
      ),
    );
  }

  Selectable<String> leadingOrderKey({
    required int bucket,
    String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [Variable<int>(bucket), Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> trailingOrderKey({
    required int bucket,
    String? containerId,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [Variable<int>(bucket), Variable<String>(containerId)],
      readsFrom: {tab},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> orderKeyAfterTab({
    String? containerId,
    required String tabId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
      variables: [Variable<String>(containerId), Variable<String>(tabId)],
      readsFrom: {tab},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<TabQueryResult> queryTabsBasic({required String query}) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight) SELECT t.id, t.title, CAST(t.url AS TEXT) AS url, t.url AS clean_url, bm25(tab_fts, weights.title_weight, weights.url_weight) AS weighted_rank FROM tab_fts AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights WHERE fts.title LIKE ?1 OR fts.url LIKE ?1 ORDER BY weighted_rank ASC, t.timestamp DESC',
      variables: [Variable<String>(query)],
      readsFrom: {tab, tabFts},
    ).map(
      (QueryRow row) => TabQueryResult(
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: NullAwareTypeConverter.wrapFromSql(
          Tab.$converterurl,
          row.readNullable<String>('clean_url'),
        ),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  Selectable<TabQueryResult> queryTabsFullContent({
    required String beforeMatch,
    required String afterMatch,
    required String ellipsis,
    required int snippetLength,
    required String query,
  }) {
    return customSelect(
      'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight, 3.0 AS extracted_weight, 1.0 AS full_weight) SELECT t.id, highlight(tab_fts, 0, ?1, ?2) AS title, highlight(tab_fts, 1, ?1, ?2) AS url, snippet(tab_fts, 2, ?1, ?2, ?3, ?4) AS extracted_content, snippet(tab_fts, 3, ?1, ?2, ?3, ?4) AS full_content, t.url AS clean_url,(bm25(tab_fts, weights.title_weight, weights.url_weight, weights.extracted_weight, weights.full_weight))AS weighted_rank FROM tab_fts(?5)AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights ORDER BY weighted_rank ASC, t.timestamp DESC',
      variables: [
        Variable<String>(beforeMatch),
        Variable<String>(afterMatch),
        Variable<String>(ellipsis),
        Variable<int>(snippetLength),
        Variable<String>(query),
      ],
      readsFrom: {tab, tabFts},
    ).map(
      (QueryRow row) => TabQueryResult(
        id: row.read<String>('id'),
        title: row.readNullable<String>('title'),
        url: row.readNullable<String>('url'),
        cleanUrl: NullAwareTypeConverter.wrapFromSql(
          Tab.$converterurl,
          row.readNullable<String>('clean_url'),
        ),
        extractedContent: row.readNullable<String>('extracted_content'),
        fullContent: row.readNullable<String>('full_content'),
        weightedRank: row.read<double>('weighted_rank'),
      ),
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    container,
    tab,
    tabFts,
    tabAfterInsert,
    tabAfterDelete,
    tabAfterUpdate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'container',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tab', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tab',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('tab_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tab',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('tab_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tab',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('tab_fts', kind: UpdateKind.insert)],
    ),
  ]);
}

typedef $ContainerCreateCompanionBuilder =
    ContainerCompanion Function({
      required String id,
      Value<String?> name,
      required Color color,
      Value<ContainerMetadata?> metadata,
      Value<int> rowid,
    });
typedef $ContainerUpdateCompanionBuilder =
    ContainerCompanion Function({
      Value<String> id,
      Value<String?> name,
      Value<Color> color,
      Value<ContainerMetadata?> metadata,
      Value<int> rowid,
    });

final class $ContainerReferences
    extends BaseReferences<_$TabDatabase, Container, ContainerData> {
  $ContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Tab, List<TabData>> _tabRefsTable(
    _$TabDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.tab,
    aliasName: $_aliasNameGenerator(db.container.id, db.tab.containerId),
  );

  $TabProcessedTableManager get tabRefs {
    final manager = $TabTableManager(
      $_db,
      $_db.tab,
    ).filter((f) => f.containerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ContainerFilterComposer extends Composer<_$TabDatabase, Container> {
  $ContainerFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Color, Color, int> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ContainerMetadata?, ContainerMetadata, String>
  get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> tabRefs(Expression<bool> Function($TabFilterComposer f) f) {
    final $TabFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tab,
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TabFilterComposer(
            $db: $db,
            $table: $db.tab,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ContainerOrderingComposer extends Composer<_$TabDatabase, Container> {
  $ContainerOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ContainerAnnotationComposer extends Composer<_$TabDatabase, Container> {
  $ContainerAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ContainerMetadata?, String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);

  Expression<T> tabRefs<T extends Object>(
    Expression<T> Function($TabAnnotationComposer a) f,
  ) {
    final $TabAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tab,
      getReferencedColumn: (t) => t.containerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $TabAnnotationComposer(
            $db: $db,
            $table: $db.tab,
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
        RootTableManager<
          _$TabDatabase,
          Container,
          ContainerData,
          $ContainerFilterComposer,
          $ContainerOrderingComposer,
          $ContainerAnnotationComposer,
          $ContainerCreateCompanionBuilder,
          $ContainerUpdateCompanionBuilder,
          (ContainerData, $ContainerReferences),
          ContainerData,
          PrefetchHooks Function({bool tabRefs})
        > {
  $ContainerTableManager(_$TabDatabase db, Container table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> name = const Value.absent(),
                Value<Color> color = const Value.absent(),
                Value<ContainerMetadata?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContainerCompanion(
                id: id,
                name: name,
                color: color,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> name = const Value.absent(),
                required Color color,
                Value<ContainerMetadata?> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContainerCompanion.insert(
                id: id,
                name: name,
                color: color,
                metadata: metadata,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $ContainerReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({tabRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tabRefs) db.tab],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabRefs)
                    await $_getPrefetchedData<
                      ContainerData,
                      Container,
                      TabData
                    >(
                      currentTable: table,
                      referencedTable: $ContainerReferences._tabRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $ContainerReferences(db, table, p0).tabRefs,
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
    ProcessedTableManager<
      _$TabDatabase,
      Container,
      ContainerData,
      $ContainerFilterComposer,
      $ContainerOrderingComposer,
      $ContainerAnnotationComposer,
      $ContainerCreateCompanionBuilder,
      $ContainerUpdateCompanionBuilder,
      (ContainerData, $ContainerReferences),
      ContainerData,
      PrefetchHooks Function({bool tabRefs})
    >;
typedef $TabCreateCompanionBuilder =
    TabCompanion Function({
      required String id,
      Value<String?> containerId,
      required String orderKey,
      Value<Uri?> url,
      Value<String?> title,
      Value<bool?> isProbablyReaderable,
      Value<String?> extractedContentMarkdown,
      Value<String?> extractedContentPlain,
      Value<String?> fullContentMarkdown,
      Value<String?> fullContentPlain,
      required DateTime timestamp,
      Value<int> rowid,
    });
typedef $TabUpdateCompanionBuilder =
    TabCompanion Function({
      Value<String> id,
      Value<String?> containerId,
      Value<String> orderKey,
      Value<Uri?> url,
      Value<String?> title,
      Value<bool?> isProbablyReaderable,
      Value<String?> extractedContentMarkdown,
      Value<String?> extractedContentPlain,
      Value<String?> fullContentMarkdown,
      Value<String?> fullContentPlain,
      Value<DateTime> timestamp,
      Value<int> rowid,
    });

final class $TabReferences extends BaseReferences<_$TabDatabase, Tab, TabData> {
  $TabReferences(super.$_db, super.$_table, super.$_typedResult);

  static Container _containerIdTable(_$TabDatabase db) => db.container
      .createAlias($_aliasNameGenerator(db.tab.containerId, db.container.id));

  $ContainerProcessedTableManager? get containerId {
    final $_column = $_itemColumn<String>('container_id');
    if ($_column == null) return null;
    final manager = $ContainerTableManager(
      $_db,
      $_db.container,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $TabFilterComposer extends Composer<_$TabDatabase, Tab> {
  $TabFilterComposer({
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

  ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Uri?, Uri, String> get url =>
      $composableBuilder(
        column: $table.url,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  $ContainerFilterComposer get containerId {
    final $ContainerFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: $db.container,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContainerFilterComposer(
            $db: $db,
            $table: $db.container,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabOrderingComposer extends Composer<_$TabDatabase, Tab> {
  $TabOrderingComposer({
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

  ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  $ContainerOrderingComposer get containerId {
    final $ContainerOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: $db.container,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContainerOrderingComposer(
            $db: $db,
            $table: $db.container,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $TabAnnotationComposer extends Composer<_$TabDatabase, Tab> {
  $TabAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Uri?, String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isProbablyReaderable => $composableBuilder(
    column: $table.isProbablyReaderable,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractedContentMarkdown => $composableBuilder(
    column: $table.extractedContentMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullContentMarkdown => $composableBuilder(
    column: $table.fullContentMarkdown,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $ContainerAnnotationComposer get containerId {
    final $ContainerAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.containerId,
      referencedTable: $db.container,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ContainerAnnotationComposer(
            $db: $db,
            $table: $db.container,
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
        RootTableManager<
          _$TabDatabase,
          Tab,
          TabData,
          $TabFilterComposer,
          $TabOrderingComposer,
          $TabAnnotationComposer,
          $TabCreateCompanionBuilder,
          $TabUpdateCompanionBuilder,
          (TabData, $TabReferences),
          TabData,
          PrefetchHooks Function({bool containerId})
        > {
  $TabTableManager(_$TabDatabase db, Tab table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> containerId = const Value.absent(),
                Value<String> orderKey = const Value.absent(),
                Value<Uri?> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<bool?> isProbablyReaderable = const Value.absent(),
                Value<String?> extractedContentMarkdown = const Value.absent(),
                Value<String?> extractedContentPlain = const Value.absent(),
                Value<String?> fullContentMarkdown = const Value.absent(),
                Value<String?> fullContentPlain = const Value.absent(),
                Value<DateTime> timestamp = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabCompanion(
                id: id,
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
                Value<String?> containerId = const Value.absent(),
                required String orderKey,
                Value<Uri?> url = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<bool?> isProbablyReaderable = const Value.absent(),
                Value<String?> extractedContentMarkdown = const Value.absent(),
                Value<String?> extractedContentPlain = const Value.absent(),
                Value<String?> fullContentMarkdown = const Value.absent(),
                Value<String?> fullContentPlain = const Value.absent(),
                required DateTime timestamp,
                Value<int> rowid = const Value.absent(),
              }) => TabCompanion.insert(
                id: id,
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
              .map((e) => (e.readTable(table), $TabReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({containerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (containerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.containerId,
                                referencedTable: $TabReferences
                                    ._containerIdTable(db),
                                referencedColumn: $TabReferences
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
    ProcessedTableManager<
      _$TabDatabase,
      Tab,
      TabData,
      $TabFilterComposer,
      $TabOrderingComposer,
      $TabAnnotationComposer,
      $TabCreateCompanionBuilder,
      $TabUpdateCompanionBuilder,
      (TabData, $TabReferences),
      TabData,
      PrefetchHooks Function({bool containerId})
    >;
typedef $TabFtsCreateCompanionBuilder =
    TabFtsCompanion Function({
      required String title,
      required String url,
      required String extractedContentPlain,
      required String fullContentPlain,
      Value<int> rowid,
    });
typedef $TabFtsUpdateCompanionBuilder =
    TabFtsCompanion Function({
      Value<String> title,
      Value<String> url,
      Value<String> extractedContentPlain,
      Value<String> fullContentPlain,
      Value<int> rowid,
    });

class $TabFtsFilterComposer extends Composer<_$TabDatabase, TabFts> {
  $TabFtsFilterComposer({
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

  ColumnFilters<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => ColumnFilters(column),
  );
}

class $TabFtsOrderingComposer extends Composer<_$TabDatabase, TabFts> {
  $TabFtsOrderingComposer({
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

  ColumnOrderings<String> get url => $composableBuilder(
    column: $table.url,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => ColumnOrderings(column),
  );
}

class $TabFtsAnnotationComposer extends Composer<_$TabDatabase, TabFts> {
  $TabFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
    column: $table.extractedContentPlain,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullContentPlain => $composableBuilder(
    column: $table.fullContentPlain,
    builder: (column) => column,
  );
}

class $TabFtsTableManager
    extends
        RootTableManager<
          _$TabDatabase,
          TabFts,
          TabFt,
          $TabFtsFilterComposer,
          $TabFtsOrderingComposer,
          $TabFtsAnnotationComposer,
          $TabFtsCreateCompanionBuilder,
          $TabFtsUpdateCompanionBuilder,
          (TabFt, BaseReferences<_$TabDatabase, TabFts, TabFt>),
          TabFt,
          PrefetchHooks Function()
        > {
  $TabFtsTableManager(_$TabDatabase db, TabFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TabFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TabFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TabFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> url = const Value.absent(),
                Value<String> extractedContentPlain = const Value.absent(),
                Value<String> fullContentPlain = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TabFtsCompanion(
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
                Value<int> rowid = const Value.absent(),
              }) => TabFtsCompanion.insert(
                title: title,
                url: url,
                extractedContentPlain: extractedContentPlain,
                fullContentPlain: fullContentPlain,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $TabFtsProcessedTableManager =
    ProcessedTableManager<
      _$TabDatabase,
      TabFts,
      TabFt,
      $TabFtsFilterComposer,
      $TabFtsOrderingComposer,
      $TabFtsAnnotationComposer,
      $TabFtsCreateCompanionBuilder,
      $TabFtsUpdateCompanionBuilder,
      (TabFt, BaseReferences<_$TabDatabase, TabFts, TabFt>),
      TabFt,
      PrefetchHooks Function()
    >;

class $TabDatabaseManager {
  final _$TabDatabase _db;
  $TabDatabaseManager(this._db);
  $ContainerTableManager get container =>
      $ContainerTableManager(_db, _db.container);
  $TabTableManager get tab => $TabTableManager(_db, _db.tab);
  $TabFtsTableManager get tabFts => $TabFtsTableManager(_db, _db.tabFts);
}
