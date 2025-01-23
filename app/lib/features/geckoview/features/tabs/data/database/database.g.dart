// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class Container extends Table with TableInfo<Container, ContainerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Container(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> contextualIdentity =
      GeneratedColumn<String>('contextual_identity', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumnWithTypeConverter<Color, int> color =
      GeneratedColumn<int>('color', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<Color>(Container.$convertercolor);
  late final GeneratedColumnWithTypeConverter<IconData?, String> icon =
      GeneratedColumn<String>('icon', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<IconData?>(Container.$convertericonn);
  @override
  List<GeneratedColumn> get $columns =>
      [id, contextualIdentity, name, color, icon];
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      contextualIdentity: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}contextual_identity']),
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      color: Container.$convertercolor.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!),
      icon: Container.$convertericonn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon'])),
    );
  }

  @override
  Container createAlias(String alias) {
    return Container(attachedDatabase, alias);
  }

  static TypeConverter<Color, int> $convertercolor = const ColorConverter();
  static TypeConverter<IconData, String> $convertericon =
      const IconDataTypeConverter();
  static TypeConverter<IconData?, String?> $convertericonn =
      NullAwareTypeConverter.wrap($convertericon);
  @override
  bool get dontWriteConstraints => true;
}

class ContainerCompanion extends UpdateCompanion<ContainerData> {
  final Value<String> id;
  final Value<String?> contextualIdentity;
  final Value<String?> name;
  final Value<Color> color;
  final Value<IconData?> icon;
  final Value<int> rowid;
  const ContainerCompanion({
    this.id = const Value.absent(),
    this.contextualIdentity = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContainerCompanion.insert({
    required String id,
    this.contextualIdentity = const Value.absent(),
    this.name = const Value.absent(),
    required Color color,
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        color = Value(color);
  static Insertable<ContainerData> custom({
    Expression<String>? id,
    Expression<String>? contextualIdentity,
    Expression<String>? name,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contextualIdentity != null) 'contextual_identity': contextualIdentity,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContainerCompanion copyWith(
      {Value<String>? id,
      Value<String?>? contextualIdentity,
      Value<String?>? name,
      Value<Color>? color,
      Value<IconData?>? icon,
      Value<int>? rowid}) {
    return ContainerCompanion(
      id: id ?? this.id,
      contextualIdentity: contextualIdentity ?? this.contextualIdentity,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contextualIdentity.present) {
      map['contextual_identity'] = Variable<String>(contextualIdentity.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] =
          Variable<int>(Container.$convertercolor.toSql(color.value));
    }
    if (icon.present) {
      map['icon'] =
          Variable<String>(Container.$convertericonn.toSql(icon.value));
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
          ..write('contextualIdentity: $contextualIdentity, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
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
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumn<String> containerId = GeneratedColumn<String>(
      'container_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: 'REFERENCES container(id)ON DELETE CASCADE');
  late final GeneratedColumn<String> orderKey = GeneratedColumn<String>(
      'order_key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<bool> isProbablyReaderable = GeneratedColumn<bool>(
      'is_probably_readerable', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> extractedContentMarkdown =
      GeneratedColumn<String>('extracted_content_markdown', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  late final GeneratedColumn<String> extractedContentPlain =
      GeneratedColumn<String>('extracted_content_plain', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  late final GeneratedColumn<String> fullContentMarkdown =
      GeneratedColumn<String>('full_content_markdown', aliasedName, true,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          $customConstraints: '');
  late final GeneratedColumn<String> fullContentPlain = GeneratedColumn<String>(
      'full_content_plain', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
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
        timestamp
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
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      containerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}container_id']),
      orderKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}order_key'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      isProbablyReaderable: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_probably_readerable']),
      extractedContentMarkdown: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extracted_content_markdown']),
      extractedContentPlain: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extracted_content_plain']),
      fullContentMarkdown: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}full_content_markdown']),
      fullContentPlain: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}full_content_plain']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  Tab createAlias(String alias) {
    return Tab(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TabData extends DataClass implements Insertable<TabData> {
  final String id;
  final String? containerId;
  final String orderKey;
  final String? url;
  final String? title;
  final bool? isProbablyReaderable;
  final String? extractedContentMarkdown;
  final String? extractedContentPlain;
  final String? fullContentMarkdown;
  final String? fullContentPlain;
  final DateTime timestamp;
  const TabData(
      {required this.id,
      this.containerId,
      required this.orderKey,
      this.url,
      this.title,
      this.isProbablyReaderable,
      this.extractedContentMarkdown,
      this.extractedContentPlain,
      this.fullContentMarkdown,
      this.fullContentPlain,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || containerId != null) {
      map['container_id'] = Variable<String>(containerId);
    }
    map['order_key'] = Variable<String>(orderKey);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || isProbablyReaderable != null) {
      map['is_probably_readerable'] = Variable<bool>(isProbablyReaderable);
    }
    if (!nullToAbsent || extractedContentMarkdown != null) {
      map['extracted_content_markdown'] =
          Variable<String>(extractedContentMarkdown);
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

  factory TabData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabData(
      id: serializer.fromJson<String>(json['id']),
      containerId: serializer.fromJson<String?>(json['container_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      url: serializer.fromJson<String?>(json['url']),
      title: serializer.fromJson<String?>(json['title']),
      isProbablyReaderable:
          serializer.fromJson<bool?>(json['is_probably_readerable']),
      extractedContentMarkdown:
          serializer.fromJson<String?>(json['extracted_content_markdown']),
      extractedContentPlain:
          serializer.fromJson<String?>(json['extracted_content_plain']),
      fullContentMarkdown:
          serializer.fromJson<String?>(json['full_content_markdown']),
      fullContentPlain:
          serializer.fromJson<String?>(json['full_content_plain']),
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
      'url': serializer.toJson<String?>(url),
      'title': serializer.toJson<String?>(title),
      'is_probably_readerable': serializer.toJson<bool?>(isProbablyReaderable),
      'extracted_content_markdown':
          serializer.toJson<String?>(extractedContentMarkdown),
      'extracted_content_plain':
          serializer.toJson<String?>(extractedContentPlain),
      'full_content_markdown': serializer.toJson<String?>(fullContentMarkdown),
      'full_content_plain': serializer.toJson<String?>(fullContentPlain),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TabData copyWith(
          {String? id,
          Value<String?> containerId = const Value.absent(),
          String? orderKey,
          Value<String?> url = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<bool?> isProbablyReaderable = const Value.absent(),
          Value<String?> extractedContentMarkdown = const Value.absent(),
          Value<String?> extractedContentPlain = const Value.absent(),
          Value<String?> fullContentMarkdown = const Value.absent(),
          Value<String?> fullContentPlain = const Value.absent(),
          DateTime? timestamp}) =>
      TabData(
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
      containerId:
          data.containerId.present ? data.containerId.value : this.containerId,
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
      timestamp);
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
  final Value<String?> url;
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
  })  : id = Value(id),
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

  TabCompanion copyWith(
      {Value<String>? id,
      Value<String?>? containerId,
      Value<String>? orderKey,
      Value<String?>? url,
      Value<String?>? title,
      Value<bool?>? isProbablyReaderable,
      Value<String?>? extractedContentMarkdown,
      Value<String?>? extractedContentPlain,
      Value<String?>? fullContentMarkdown,
      Value<String?>? fullContentPlain,
      Value<DateTime>? timestamp,
      Value<int>? rowid}) {
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
      map['url'] = Variable<String>(url.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (isProbablyReaderable.present) {
      map['is_probably_readerable'] =
          Variable<bool>(isProbablyReaderable.value);
    }
    if (extractedContentMarkdown.present) {
      map['extracted_content_markdown'] =
          Variable<String>(extractedContentMarkdown.value);
    }
    if (extractedContentPlain.present) {
      map['extracted_content_plain'] =
          Variable<String>(extractedContentPlain.value);
    }
    if (fullContentMarkdown.present) {
      map['full_content_markdown'] =
          Variable<String>(fullContentMarkdown.value);
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

class Document extends Table with TableInfo<Document, DocumentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Document(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> documentId = GeneratedColumn<String>(
      'document_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumn<String> mainDocumentId = GeneratedColumn<String>(
      'main_document_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
      'context_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
      'content_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
      'metadata', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [documentId, mainDocumentId, contextId, content, contentHash, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document';
  @override
  Set<GeneratedColumn> get $primaryKey => {documentId};
  @override
  DocumentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentData(
      documentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}document_id'])!,
      mainDocumentId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}main_document_id']),
      contextId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_id']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      contentHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_hash'])!,
      metadata: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}metadata']),
    );
  }

  @override
  Document createAlias(String alias) {
    return Document(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DocumentData extends DataClass implements Insertable<DocumentData> {
  final String documentId;
  final String? mainDocumentId;
  final String? contextId;
  final String content;
  final String contentHash;
  final String? metadata;
  const DocumentData(
      {required this.documentId,
      this.mainDocumentId,
      this.contextId,
      required this.content,
      required this.contentHash,
      this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['document_id'] = Variable<String>(documentId);
    if (!nullToAbsent || mainDocumentId != null) {
      map['main_document_id'] = Variable<String>(mainDocumentId);
    }
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    map['content'] = Variable<String>(content);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  factory DocumentData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentData(
      documentId: serializer.fromJson<String>(json['document_id']),
      mainDocumentId: serializer.fromJson<String?>(json['main_document_id']),
      contextId: serializer.fromJson<String?>(json['context_id']),
      content: serializer.fromJson<String>(json['content']),
      contentHash: serializer.fromJson<String>(json['content_hash']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'document_id': serializer.toJson<String>(documentId),
      'main_document_id': serializer.toJson<String?>(mainDocumentId),
      'context_id': serializer.toJson<String?>(contextId),
      'content': serializer.toJson<String>(content),
      'content_hash': serializer.toJson<String>(contentHash),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  DocumentData copyWith(
          {String? documentId,
          Value<String?> mainDocumentId = const Value.absent(),
          Value<String?> contextId = const Value.absent(),
          String? content,
          String? contentHash,
          Value<String?> metadata = const Value.absent()}) =>
      DocumentData(
        documentId: documentId ?? this.documentId,
        mainDocumentId:
            mainDocumentId.present ? mainDocumentId.value : this.mainDocumentId,
        contextId: contextId.present ? contextId.value : this.contextId,
        content: content ?? this.content,
        contentHash: contentHash ?? this.contentHash,
        metadata: metadata.present ? metadata.value : this.metadata,
      );
  DocumentData copyWithCompanion(DocumentCompanion data) {
    return DocumentData(
      documentId:
          data.documentId.present ? data.documentId.value : this.documentId,
      mainDocumentId: data.mainDocumentId.present
          ? data.mainDocumentId.value
          : this.mainDocumentId,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      content: data.content.present ? data.content.value : this.content,
      contentHash:
          data.contentHash.present ? data.contentHash.value : this.contentHash,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentData(')
          ..write('documentId: $documentId, ')
          ..write('mainDocumentId: $mainDocumentId, ')
          ..write('contextId: $contextId, ')
          ..write('content: $content, ')
          ..write('contentHash: $contentHash, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      documentId, mainDocumentId, contextId, content, contentHash, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentData &&
          other.documentId == this.documentId &&
          other.mainDocumentId == this.mainDocumentId &&
          other.contextId == this.contextId &&
          other.content == this.content &&
          other.contentHash == this.contentHash &&
          other.metadata == this.metadata);
}

class DocumentCompanion extends UpdateCompanion<DocumentData> {
  final Value<String> documentId;
  final Value<String?> mainDocumentId;
  final Value<String?> contextId;
  final Value<String> content;
  final Value<String> contentHash;
  final Value<String?> metadata;
  final Value<int> rowid;
  const DocumentCompanion({
    this.documentId = const Value.absent(),
    this.mainDocumentId = const Value.absent(),
    this.contextId = const Value.absent(),
    this.content = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentCompanion.insert({
    required String documentId,
    this.mainDocumentId = const Value.absent(),
    this.contextId = const Value.absent(),
    required String content,
    required String contentHash,
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : documentId = Value(documentId),
        content = Value(content),
        contentHash = Value(contentHash);
  static Insertable<DocumentData> custom({
    Expression<String>? documentId,
    Expression<String>? mainDocumentId,
    Expression<String>? contextId,
    Expression<String>? content,
    Expression<String>? contentHash,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (documentId != null) 'document_id': documentId,
      if (mainDocumentId != null) 'main_document_id': mainDocumentId,
      if (contextId != null) 'context_id': contextId,
      if (content != null) 'content': content,
      if (contentHash != null) 'content_hash': contentHash,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentCompanion copyWith(
      {Value<String>? documentId,
      Value<String?>? mainDocumentId,
      Value<String?>? contextId,
      Value<String>? content,
      Value<String>? contentHash,
      Value<String?>? metadata,
      Value<int>? rowid}) {
    return DocumentCompanion(
      documentId: documentId ?? this.documentId,
      mainDocumentId: mainDocumentId ?? this.mainDocumentId,
      contextId: contextId ?? this.contextId,
      content: content ?? this.content,
      contentHash: contentHash ?? this.contentHash,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (documentId.present) {
      map['document_id'] = Variable<String>(documentId.value);
    }
    if (mainDocumentId.present) {
      map['main_document_id'] = Variable<String>(mainDocumentId.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentCompanion(')
          ..write('documentId: $documentId, ')
          ..write('mainDocumentId: $mainDocumentId, ')
          ..write('contextId: $contextId, ')
          ..write('content: $content, ')
          ..write('contentHash: $contentHash, ')
          ..write('metadata: $metadata, ')
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
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  late final GeneratedColumn<String> extractedContentPlain =
      GeneratedColumn<String>('extracted_content_plain', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: true,
          $customConstraints: '');
  late final GeneratedColumn<String> fullContentPlain = GeneratedColumn<String>(
      'full_content_plain', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [title, url, extractedContentPlain, fullContentPlain];
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
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      extractedContentPlain: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}extracted_content_plain'])!,
      fullContentPlain: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}full_content_plain'])!,
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
  const TabFt(
      {required this.title,
      required this.url,
      required this.extractedContentPlain,
      required this.fullContentPlain});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['url'] = Variable<String>(url);
    map['extracted_content_plain'] = Variable<String>(extractedContentPlain);
    map['full_content_plain'] = Variable<String>(fullContentPlain);
    return map;
  }

  factory TabFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TabFt(
      title: serializer.fromJson<String>(json['title']),
      url: serializer.fromJson<String>(json['url']),
      extractedContentPlain:
          serializer.fromJson<String>(json['extracted_content_plain']),
      fullContentPlain: serializer.fromJson<String>(json['full_content_plain']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'url': serializer.toJson<String>(url),
      'extracted_content_plain':
          serializer.toJson<String>(extractedContentPlain),
      'full_content_plain': serializer.toJson<String>(fullContentPlain),
    };
  }

  TabFt copyWith(
          {String? title,
          String? url,
          String? extractedContentPlain,
          String? fullContentPlain}) =>
      TabFt(
        title: title ?? this.title,
        url: url ?? this.url,
        extractedContentPlain:
            extractedContentPlain ?? this.extractedContentPlain,
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
  })  : title = Value(title),
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

  TabFtsCompanion copyWith(
      {Value<String>? title,
      Value<String>? url,
      Value<String>? extractedContentPlain,
      Value<String>? fullContentPlain,
      Value<int>? rowid}) {
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
      map['extracted_content_plain'] =
          Variable<String>(extractedContentPlain.value);
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

class DocumentVec extends Table with TableInfo<DocumentVec, DocumentVecData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DocumentVec(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  late final GeneratedColumn<String> mainDocumentId = GeneratedColumn<String>(
      'main_document_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> contextId = GeneratedColumn<String>(
      'context_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<Uint8List> embedding = GeneratedColumn<Uint8List>(
      'embedding', aliasedName, false,
      type: DriftSqlType.blob,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
      'content_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<double> distance = GeneratedColumn<double>(
      'distance', aliasedName, true,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<int> k = GeneratedColumn<int>(
      'k', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns =>
      [id, mainDocumentId, contextId, embedding, contentHash, distance, k];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_vec';
  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DocumentVecData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentVecData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      mainDocumentId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}main_document_id']),
      contextId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}context_id']),
      embedding: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}embedding'])!,
      contentHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content_hash'])!,
      distance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}distance']),
      k: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}k']),
    );
  }

  @override
  DocumentVec createAlias(String alias) {
    return DocumentVec(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DocumentVecData extends DataClass implements Insertable<DocumentVecData> {
  /// dummy definition of virtual table
  /// keep in sync with defined table definition
  final String id;
  final String? mainDocumentId;
  final String? contextId;
  final Uint8List embedding;
  final String contentHash;
  final double? distance;
  final int? k;
  const DocumentVecData(
      {required this.id,
      this.mainDocumentId,
      this.contextId,
      required this.embedding,
      required this.contentHash,
      this.distance,
      this.k});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mainDocumentId != null) {
      map['main_document_id'] = Variable<String>(mainDocumentId);
    }
    if (!nullToAbsent || contextId != null) {
      map['context_id'] = Variable<String>(contextId);
    }
    map['embedding'] = Variable<Uint8List>(embedding);
    map['content_hash'] = Variable<String>(contentHash);
    if (!nullToAbsent || distance != null) {
      map['distance'] = Variable<double>(distance);
    }
    if (!nullToAbsent || k != null) {
      map['k'] = Variable<int>(k);
    }
    return map;
  }

  factory DocumentVecData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentVecData(
      id: serializer.fromJson<String>(json['id']),
      mainDocumentId: serializer.fromJson<String?>(json['main_document_id']),
      contextId: serializer.fromJson<String?>(json['context_id']),
      embedding: serializer.fromJson<Uint8List>(json['embedding']),
      contentHash: serializer.fromJson<String>(json['content_hash']),
      distance: serializer.fromJson<double?>(json['distance']),
      k: serializer.fromJson<int?>(json['k']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'main_document_id': serializer.toJson<String?>(mainDocumentId),
      'context_id': serializer.toJson<String?>(contextId),
      'embedding': serializer.toJson<Uint8List>(embedding),
      'content_hash': serializer.toJson<String>(contentHash),
      'distance': serializer.toJson<double?>(distance),
      'k': serializer.toJson<int?>(k),
    };
  }

  DocumentVecData copyWith(
          {String? id,
          Value<String?> mainDocumentId = const Value.absent(),
          Value<String?> contextId = const Value.absent(),
          Uint8List? embedding,
          String? contentHash,
          Value<double?> distance = const Value.absent(),
          Value<int?> k = const Value.absent()}) =>
      DocumentVecData(
        id: id ?? this.id,
        mainDocumentId:
            mainDocumentId.present ? mainDocumentId.value : this.mainDocumentId,
        contextId: contextId.present ? contextId.value : this.contextId,
        embedding: embedding ?? this.embedding,
        contentHash: contentHash ?? this.contentHash,
        distance: distance.present ? distance.value : this.distance,
        k: k.present ? k.value : this.k,
      );
  DocumentVecData copyWithCompanion(DocumentVecCompanion data) {
    return DocumentVecData(
      id: data.id.present ? data.id.value : this.id,
      mainDocumentId: data.mainDocumentId.present
          ? data.mainDocumentId.value
          : this.mainDocumentId,
      contextId: data.contextId.present ? data.contextId.value : this.contextId,
      embedding: data.embedding.present ? data.embedding.value : this.embedding,
      contentHash:
          data.contentHash.present ? data.contentHash.value : this.contentHash,
      distance: data.distance.present ? data.distance.value : this.distance,
      k: data.k.present ? data.k.value : this.k,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentVecData(')
          ..write('id: $id, ')
          ..write('mainDocumentId: $mainDocumentId, ')
          ..write('contextId: $contextId, ')
          ..write('embedding: $embedding, ')
          ..write('contentHash: $contentHash, ')
          ..write('distance: $distance, ')
          ..write('k: $k')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, mainDocumentId, contextId,
      $driftBlobEquality.hash(embedding), contentHash, distance, k);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentVecData &&
          other.id == this.id &&
          other.mainDocumentId == this.mainDocumentId &&
          other.contextId == this.contextId &&
          $driftBlobEquality.equals(other.embedding, this.embedding) &&
          other.contentHash == this.contentHash &&
          other.distance == this.distance &&
          other.k == this.k);
}

class DocumentVecCompanion extends UpdateCompanion<DocumentVecData> {
  final Value<String> id;
  final Value<String?> mainDocumentId;
  final Value<String?> contextId;
  final Value<Uint8List> embedding;
  final Value<String> contentHash;
  final Value<double?> distance;
  final Value<int?> k;
  final Value<int> rowid;
  const DocumentVecCompanion({
    this.id = const Value.absent(),
    this.mainDocumentId = const Value.absent(),
    this.contextId = const Value.absent(),
    this.embedding = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.distance = const Value.absent(),
    this.k = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DocumentVecCompanion.insert({
    required String id,
    this.mainDocumentId = const Value.absent(),
    this.contextId = const Value.absent(),
    required Uint8List embedding,
    required String contentHash,
    this.distance = const Value.absent(),
    this.k = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        embedding = Value(embedding),
        contentHash = Value(contentHash);
  static Insertable<DocumentVecData> custom({
    Expression<String>? id,
    Expression<String>? mainDocumentId,
    Expression<String>? contextId,
    Expression<Uint8List>? embedding,
    Expression<String>? contentHash,
    Expression<double>? distance,
    Expression<int>? k,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mainDocumentId != null) 'main_document_id': mainDocumentId,
      if (contextId != null) 'context_id': contextId,
      if (embedding != null) 'embedding': embedding,
      if (contentHash != null) 'content_hash': contentHash,
      if (distance != null) 'distance': distance,
      if (k != null) 'k': k,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DocumentVecCompanion copyWith(
      {Value<String>? id,
      Value<String?>? mainDocumentId,
      Value<String?>? contextId,
      Value<Uint8List>? embedding,
      Value<String>? contentHash,
      Value<double?>? distance,
      Value<int?>? k,
      Value<int>? rowid}) {
    return DocumentVecCompanion(
      id: id ?? this.id,
      mainDocumentId: mainDocumentId ?? this.mainDocumentId,
      contextId: contextId ?? this.contextId,
      embedding: embedding ?? this.embedding,
      contentHash: contentHash ?? this.contentHash,
      distance: distance ?? this.distance,
      k: k ?? this.k,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mainDocumentId.present) {
      map['main_document_id'] = Variable<String>(mainDocumentId.value);
    }
    if (contextId.present) {
      map['context_id'] = Variable<String>(contextId.value);
    }
    if (embedding.present) {
      map['embedding'] = Variable<Uint8List>(embedding.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (distance.present) {
      map['distance'] = Variable<double>(distance.value);
    }
    if (k.present) {
      map['k'] = Variable<int>(k.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentVecCompanion(')
          ..write('id: $id, ')
          ..write('mainDocumentId: $mainDocumentId, ')
          ..write('contextId: $contextId, ')
          ..write('embedding: $embedding, ')
          ..write('contentHash: $contentHash, ')
          ..write('distance: $distance, ')
          ..write('k: $k, ')
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
  late final Document document = Document(this);
  late final Trigger tabDocumentDelete = Trigger(
      'CREATE TRIGGER tab_document_delete AFTER DELETE ON tab BEGIN DELETE FROM document WHERE main_document_id = old.id;END',
      'tab_document_delete');
  late final TabFts tabFts = TabFts(this);
  late final Trigger tabAfterInsert = Trigger(
      'CREATE TRIGGER tab_after_insert AFTER INSERT ON tab BEGIN INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
      'tab_after_insert');
  late final Trigger tabAfterDelete = Trigger(
      'CREATE TRIGGER tab_after_delete AFTER DELETE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);END',
      'tab_after_delete');
  late final Trigger tabAfterUpdate = Trigger(
      'CREATE TRIGGER tab_after_update AFTER UPDATE ON tab BEGIN INSERT INTO tab_fts (tab_fts, "rowid", title, url, extracted_content_plain, full_content_plain) VALUES (\'delete\', old."rowid", old.title, old.url, old.extracted_content_plain, old.full_content_plain);INSERT INTO tab_fts ("rowid", title, url, extracted_content_plain, full_content_plain) VALUES (new."rowid", new.title, new.url, new.extracted_content_plain, new.full_content_plain);END',
      'tab_after_update');
  late final Index documentMainDocumentId = Index('document_main_document_id',
      'CREATE INDEX document_main_document_id ON document (main_document_id)');
  late final Index documentContextId = Index('document_context_id',
      'CREATE INDEX document_context_id ON document (context_id)');
  late final DocumentVec documentVec = DocumentVec(this);
  late final Trigger documentDelete = Trigger(
      'CREATE TRIGGER document_delete AFTER DELETE ON document BEGIN DELETE FROM document_vec WHERE id = old.document_id;END',
      'document_delete');
  late final Trigger documentUpdateDelete = Trigger(
      'CREATE TRIGGER document_update_delete AFTER UPDATE ON document BEGIN DELETE FROM document_vec WHERE id = new.document_id AND content_hash != new.content_hash;END',
      'document_update_delete');
  late final ContainerDao containerDao = ContainerDao(this as TabDatabase);
  late final TabDao tabDao = TabDao(this as TabDatabase);
  late final VectorDao vectorDao = VectorDao(this as TabDatabase);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO tab_fts (tab_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {tabFts},
    );
  }

  Selectable<ContainerDataWithCount> containersWithCount() {
    return customSelect(
        'SELECT container.*, tab_agg.tab_count FROM container LEFT JOIN (SELECT container_id, COUNT(*) AS tab_count, MAX(timestamp) AS last_updated FROM tab GROUP BY container_id) AS tab_agg ON container.id = tab_agg.container_id ORDER BY tab_agg.last_updated DESC NULLS FIRST',
        variables: [],
        readsFrom: {
          container,
          tab,
        }).map((QueryRow row) => ContainerDataWithCount(
          id: row.read<String>('id'),
          contextualIdentity: row.readNullable<String>('contextual_identity'),
          name: row.readNullable<String>('name'),
          color: Container.$convertercolor.fromSql(row.read<int>('color')),
          icon: NullAwareTypeConverter.wrapFromSql(
              Container.$convertericon, row.readNullable<String>('icon')),
          tabCount: row.readNullable<int>('tab_count'),
        ));
  }

  Selectable<String> leadingOrderKey(
      {required int bucket, String? containerId}) {
    return customSelect(
        'SELECT lexo_rank_previous(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key LIMIT 1)) AS _c0',
        variables: [
          Variable<int>(bucket),
          Variable<String>(containerId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> trailingOrderKey(
      {required int bucket, String? containerId}) {
    return customSelect(
        'SELECT lexo_rank_next(?1, (SELECT order_key FROM tab WHERE container_id IS ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
        variables: [
          Variable<int>(bucket),
          Variable<String>(containerId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> orderKeyAfterTab(
      {String? containerId, required String tabId}) {
    return customSelect(
        'WITH ordered_table AS (SELECT id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key FROM tab WHERE container_id IS ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE id = ?2',
        variables: [
          Variable<String>(containerId),
          Variable<String>(tabId)
        ],
        readsFrom: {
          tab,
        }).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<TabQueryResult> queryTabsBasic(
      {required String beforeMatch,
      required String afterMatch,
      required String query}) {
    return customSelect(
        'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight) SELECT t.id, highlight(tab_fts, 0, ?1, ?2) AS title, highlight(tab_fts, 1, ?1, ?2) AS url, bm25(tab_fts, weights.title_weight, weights.url_weight) AS weighted_rank FROM tab_fts AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights WHERE fts.title LIKE ?3 OR fts.url LIKE ?3 ORDER BY weighted_rank ASC, t.timestamp DESC',
        variables: [
          Variable<String>(beforeMatch),
          Variable<String>(afterMatch),
          Variable<String>(query)
        ],
        readsFrom: {
          tab,
          tabFts,
        }).map((QueryRow row) => TabQueryResult(
          id: row.read<String>('id'),
          title: row.readNullable<String>('title'),
          url: row.readNullable<String>('url'),
          weightedRank: row.read<double>('weighted_rank'),
        ));
  }

  Selectable<TabQueryResult> queryTabsFullContent(
      {required String beforeMatch,
      required String afterMatch,
      required String ellipsis,
      required int snippetLength,
      required String query}) {
    return customSelect(
        'WITH weights AS (SELECT 10.0 AS title_weight, 5.0 AS url_weight, 3.0 AS extracted_weight, 1.0 AS full_weight) SELECT t.id, highlight(tab_fts, 0, ?1, ?2) AS title, highlight(tab_fts, 1, ?1, ?2) AS url, snippet(tab_fts, 2, ?1, ?2, ?3, ?4) AS extracted_content, snippet(tab_fts, 3, ?1, ?2, ?3, ?4) AS full_content,(bm25(tab_fts, weights.title_weight, weights.url_weight, weights.extracted_weight, weights.full_weight))AS weighted_rank FROM tab_fts(?5)AS fts INNER JOIN tab AS t ON t."rowid" = fts."rowid" CROSS JOIN weights ORDER BY weighted_rank ASC, t.timestamp DESC',
        variables: [
          Variable<String>(beforeMatch),
          Variable<String>(afterMatch),
          Variable<String>(ellipsis),
          Variable<int>(snippetLength),
          Variable<String>(query)
        ],
        readsFrom: {
          tab,
          tabFts,
        }).map((QueryRow row) => TabQueryResult(
          id: row.read<String>('id'),
          title: row.readNullable<String>('title'),
          url: row.readNullable<String>('url'),
          extractedContent: row.readNullable<String>('extracted_content'),
          fullContent: row.readNullable<String>('full_content'),
          weightedRank: row.read<double>('weighted_rank'),
        ));
  }

  Selectable<DocumentData> missingDocumentEmbeddings(
      {String? mainDocumentId, String? contextId}) {
    return customSelect(
        'SELECT doc.* FROM document AS doc WHERE doc.main_document_id IS COALESCE(?1, doc.main_document_id) AND doc.context_id IS COALESCE(?2, doc.context_id) AND NOT EXISTS (SELECT 1 AS _c0 FROM document_vec AS vec WHERE vec.id = doc.document_id)',
        variables: [
          Variable<String>(mainDocumentId),
          Variable<String>(contextId)
        ],
        readsFrom: {
          document,
          documentVec,
        }).asyncMap(document.mapFromRow);
  }

  Selectable<VectorResult> queryVectors(
      {required Uint8List searchVectors,
      int? k,
      String? mainDocumentId,
      String? contextId}) {
    return customSelect(
        'SELECT vec.id, doc.main_document_id, doc.context_id, doc.content, doc.metadata, vec.distance FROM document_vec AS vec INNER JOIN document AS doc ON doc.document_id = vec.id WHERE vec.embedding MATCH ?1 AND vec.k = ?2 AND vec.main_document_id IS COALESCE(?3, vec.main_document_id) AND vec.context_id IS COALESCE(?4, vec.context_id) ORDER BY vec.distance',
        variables: [
          Variable<Uint8List>(searchVectors),
          Variable<int>(k),
          Variable<String>(mainDocumentId),
          Variable<String>(contextId)
        ],
        readsFrom: {
          documentVec,
          document,
        }).map((QueryRow row) => VectorResult(
          id: row.read<String>('id'),
          mainDocumentId: row.readNullable<String>('main_document_id'),
          contextId: row.readNullable<String>('context_id'),
          content: row.read<String>('content'),
          metadata: row.readNullable<String>('metadata'),
          distance: row.readNullable<double>('distance'),
        ));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        container,
        tab,
        document,
        tabDocumentDelete,
        tabFts,
        tabAfterInsert,
        tabAfterDelete,
        tabAfterUpdate,
        documentMainDocumentId,
        documentContextId,
        documentVec,
        documentDelete,
        documentUpdateDelete
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('container',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tab', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tab',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('document', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tab',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('tab_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tab',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('tab_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('tab',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('tab_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('document',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('document_vec', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('document',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('document_vec', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $ContainerCreateCompanionBuilder = ContainerCompanion Function({
  required String id,
  Value<String?> contextualIdentity,
  Value<String?> name,
  required Color color,
  Value<IconData?> icon,
  Value<int> rowid,
});
typedef $ContainerUpdateCompanionBuilder = ContainerCompanion Function({
  Value<String> id,
  Value<String?> contextualIdentity,
  Value<String?> name,
  Value<Color> color,
  Value<IconData?> icon,
  Value<int> rowid,
});

final class $ContainerReferences
    extends BaseReferences<_$TabDatabase, Container, ContainerData> {
  $ContainerReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<Tab, List<TabData>> _tabRefsTable(
          _$TabDatabase db) =>
      MultiTypedResultKey.fromTable(db.tab,
          aliasName: $_aliasNameGenerator(db.container.id, db.tab.containerId));

  $TabProcessedTableManager get tabRefs {
    final manager = $TabTableManager($_db, $_db.tab)
        .filter((f) => f.containerId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tabRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Color, Color, int> get color =>
      $composableBuilder(
          column: $table.color,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnWithTypeConverterFilters<IconData?, IconData, String> get icon =>
      $composableBuilder(
          column: $table.icon,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> tabRefs(Expression<bool> Function($TabFilterComposer f) f) {
    final $TabFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tab,
        getReferencedColumn: (t) => t.containerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TabFilterComposer(
              $db: $db,
              $table: $db.tab,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));
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

  GeneratedColumn<String> get contextualIdentity => $composableBuilder(
      column: $table.contextualIdentity, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Color, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<IconData?, String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  Expression<T> tabRefs<T extends Object>(
      Expression<T> Function($TabAnnotationComposer a) f) {
    final $TabAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.tab,
        getReferencedColumn: (t) => t.containerId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $TabAnnotationComposer(
              $db: $db,
              $table: $db.tab,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $ContainerTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool tabRefs})> {
  $ContainerTableManager(_$TabDatabase db, Container table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ContainerFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ContainerOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ContainerAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> contextualIdentity = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<Color> color = const Value.absent(),
            Value<IconData?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerCompanion(
            id: id,
            contextualIdentity: contextualIdentity,
            name: name,
            color: color,
            icon: icon,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> contextualIdentity = const Value.absent(),
            Value<String?> name = const Value.absent(),
            required Color color,
            Value<IconData?> icon = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContainerCompanion.insert(
            id: id,
            contextualIdentity: contextualIdentity,
            name: name,
            color: color,
            icon: icon,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $ContainerReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({tabRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (tabRefs) db.tab],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (tabRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $ContainerReferences._tabRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $ContainerReferences(db, table, p0).tabRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.containerId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $ContainerProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool tabRefs})>;
typedef $TabCreateCompanionBuilder = TabCompanion Function({
  required String id,
  Value<String?> containerId,
  required String orderKey,
  Value<String?> url,
  Value<String?> title,
  Value<bool?> isProbablyReaderable,
  Value<String?> extractedContentMarkdown,
  Value<String?> extractedContentPlain,
  Value<String?> fullContentMarkdown,
  Value<String?> fullContentPlain,
  required DateTime timestamp,
  Value<int> rowid,
});
typedef $TabUpdateCompanionBuilder = TabCompanion Function({
  Value<String> id,
  Value<String?> containerId,
  Value<String> orderKey,
  Value<String?> url,
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
    final manager = $ContainerTableManager($_db, $_db.container)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_containerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
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
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get orderKey => $composableBuilder(
      column: $table.orderKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isProbablyReaderable => $composableBuilder(
      column: $table.isProbablyReaderable,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedContentMarkdown => $composableBuilder(
      column: $table.extractedContentMarkdown,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedContentPlain => $composableBuilder(
      column: $table.extractedContentPlain,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullContentMarkdown => $composableBuilder(
      column: $table.fullContentMarkdown,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  $ContainerFilterComposer get containerId {
    final $ContainerFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerFilterComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get orderKey => $composableBuilder(
      column: $table.orderKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isProbablyReaderable => $composableBuilder(
      column: $table.isProbablyReaderable,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedContentMarkdown => $composableBuilder(
      column: $table.extractedContentMarkdown,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
      column: $table.extractedContentPlain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullContentMarkdown => $composableBuilder(
      column: $table.fullContentMarkdown,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  $ContainerOrderingComposer get containerId {
    final $ContainerOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerOrderingComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
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

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<bool> get isProbablyReaderable => $composableBuilder(
      column: $table.isProbablyReaderable, builder: (column) => column);

  GeneratedColumn<String> get extractedContentMarkdown => $composableBuilder(
      column: $table.extractedContentMarkdown, builder: (column) => column);

  GeneratedColumn<String> get extractedContentPlain => $composableBuilder(
      column: $table.extractedContentPlain, builder: (column) => column);

  GeneratedColumn<String> get fullContentMarkdown => $composableBuilder(
      column: $table.fullContentMarkdown, builder: (column) => column);

  GeneratedColumn<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  $ContainerAnnotationComposer get containerId {
    final $ContainerAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.containerId,
        referencedTable: $db.container,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $ContainerAnnotationComposer(
              $db: $db,
              $table: $db.container,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $TabTableManager extends RootTableManager<
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
    PrefetchHooks Function({bool containerId})> {
  $TabTableManager(_$TabDatabase db, Tab table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TabFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TabOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TabAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> containerId = const Value.absent(),
            Value<String> orderKey = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<bool?> isProbablyReaderable = const Value.absent(),
            Value<String?> extractedContentMarkdown = const Value.absent(),
            Value<String?> extractedContentPlain = const Value.absent(),
            Value<String?> fullContentMarkdown = const Value.absent(),
            Value<String?> fullContentPlain = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion(
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
          createCompanionCallback: ({
            required String id,
            Value<String?> containerId = const Value.absent(),
            required String orderKey,
            Value<String?> url = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<bool?> isProbablyReaderable = const Value.absent(),
            Value<String?> extractedContentMarkdown = const Value.absent(),
            Value<String?> extractedContentPlain = const Value.absent(),
            Value<String?> fullContentMarkdown = const Value.absent(),
            Value<String?> fullContentPlain = const Value.absent(),
            required DateTime timestamp,
            Value<int> rowid = const Value.absent(),
          }) =>
              TabCompanion.insert(
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
                      dynamic>>(state) {
                if (containerId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.containerId,
                    referencedTable: $TabReferences._containerIdTable(db),
                    referencedColumn: $TabReferences._containerIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $TabProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function({bool containerId})>;
typedef $DocumentCreateCompanionBuilder = DocumentCompanion Function({
  required String documentId,
  Value<String?> mainDocumentId,
  Value<String?> contextId,
  required String content,
  required String contentHash,
  Value<String?> metadata,
  Value<int> rowid,
});
typedef $DocumentUpdateCompanionBuilder = DocumentCompanion Function({
  Value<String> documentId,
  Value<String?> mainDocumentId,
  Value<String?> contextId,
  Value<String> content,
  Value<String> contentHash,
  Value<String?> metadata,
  Value<int> rowid,
});

class $DocumentFilterComposer extends Composer<_$TabDatabase, Document> {
  $DocumentFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnFilters(column));
}

class $DocumentOrderingComposer extends Composer<_$TabDatabase, Document> {
  $DocumentOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get metadata => $composableBuilder(
      column: $table.metadata, builder: (column) => ColumnOrderings(column));
}

class $DocumentAnnotationComposer extends Composer<_$TabDatabase, Document> {
  $DocumentAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get documentId => $composableBuilder(
      column: $table.documentId, builder: (column) => column);

  GeneratedColumn<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId, builder: (column) => column);

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => column);

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $DocumentTableManager extends RootTableManager<
    _$TabDatabase,
    Document,
    DocumentData,
    $DocumentFilterComposer,
    $DocumentOrderingComposer,
    $DocumentAnnotationComposer,
    $DocumentCreateCompanionBuilder,
    $DocumentUpdateCompanionBuilder,
    (DocumentData, BaseReferences<_$TabDatabase, Document, DocumentData>),
    DocumentData,
    PrefetchHooks Function()> {
  $DocumentTableManager(_$TabDatabase db, Document table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DocumentFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DocumentOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DocumentAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> documentId = const Value.absent(),
            Value<String?> mainDocumentId = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String> contentHash = const Value.absent(),
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentCompanion(
            documentId: documentId,
            mainDocumentId: mainDocumentId,
            contextId: contextId,
            content: content,
            contentHash: contentHash,
            metadata: metadata,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String documentId,
            Value<String?> mainDocumentId = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            required String content,
            required String contentHash,
            Value<String?> metadata = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentCompanion.insert(
            documentId: documentId,
            mainDocumentId: mainDocumentId,
            contextId: contextId,
            content: content,
            contentHash: contentHash,
            metadata: metadata,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $DocumentProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    Document,
    DocumentData,
    $DocumentFilterComposer,
    $DocumentOrderingComposer,
    $DocumentAnnotationComposer,
    $DocumentCreateCompanionBuilder,
    $DocumentUpdateCompanionBuilder,
    (DocumentData, BaseReferences<_$TabDatabase, Document, DocumentData>),
    DocumentData,
    PrefetchHooks Function()>;
typedef $TabFtsCreateCompanionBuilder = TabFtsCompanion Function({
  required String title,
  required String url,
  required String extractedContentPlain,
  required String fullContentPlain,
  Value<int> rowid,
});
typedef $TabFtsUpdateCompanionBuilder = TabFtsCompanion Function({
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
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extractedContentPlain => $composableBuilder(
      column: $table.extractedContentPlain,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain,
      builder: (column) => ColumnFilters(column));
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
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extractedContentPlain => $composableBuilder(
      column: $table.extractedContentPlain,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain,
      builder: (column) => ColumnOrderings(column));
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
      column: $table.extractedContentPlain, builder: (column) => column);

  GeneratedColumn<String> get fullContentPlain => $composableBuilder(
      column: $table.fullContentPlain, builder: (column) => column);
}

class $TabFtsTableManager extends RootTableManager<
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
    PrefetchHooks Function()> {
  $TabFtsTableManager(_$TabDatabase db, TabFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $TabFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $TabFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $TabFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> title = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<String> extractedContentPlain = const Value.absent(),
            Value<String> fullContentPlain = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TabFtsCompanion(
            title: title,
            url: url,
            extractedContentPlain: extractedContentPlain,
            fullContentPlain: fullContentPlain,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String title,
            required String url,
            required String extractedContentPlain,
            required String fullContentPlain,
            Value<int> rowid = const Value.absent(),
          }) =>
              TabFtsCompanion.insert(
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
        ));
}

typedef $TabFtsProcessedTableManager = ProcessedTableManager<
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
    PrefetchHooks Function()>;
typedef $DocumentVecCreateCompanionBuilder = DocumentVecCompanion Function({
  required String id,
  Value<String?> mainDocumentId,
  Value<String?> contextId,
  required Uint8List embedding,
  required String contentHash,
  Value<double?> distance,
  Value<int?> k,
  Value<int> rowid,
});
typedef $DocumentVecUpdateCompanionBuilder = DocumentVecCompanion Function({
  Value<String> id,
  Value<String?> mainDocumentId,
  Value<String?> contextId,
  Value<Uint8List> embedding,
  Value<String> contentHash,
  Value<double?> distance,
  Value<int?> k,
  Value<int> rowid,
});

class $DocumentVecFilterComposer extends Composer<_$TabDatabase, DocumentVec> {
  $DocumentVecFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnFilters(column));

  ColumnFilters<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get k => $composableBuilder(
      column: $table.k, builder: (column) => ColumnFilters(column));
}

class $DocumentVecOrderingComposer
    extends Composer<_$TabDatabase, DocumentVec> {
  $DocumentVecOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contextId => $composableBuilder(
      column: $table.contextId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<Uint8List> get embedding => $composableBuilder(
      column: $table.embedding, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get distance => $composableBuilder(
      column: $table.distance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get k => $composableBuilder(
      column: $table.k, builder: (column) => ColumnOrderings(column));
}

class $DocumentVecAnnotationComposer
    extends Composer<_$TabDatabase, DocumentVec> {
  $DocumentVecAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mainDocumentId => $composableBuilder(
      column: $table.mainDocumentId, builder: (column) => column);

  GeneratedColumn<String> get contextId =>
      $composableBuilder(column: $table.contextId, builder: (column) => column);

  GeneratedColumn<Uint8List> get embedding =>
      $composableBuilder(column: $table.embedding, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
      column: $table.contentHash, builder: (column) => column);

  GeneratedColumn<double> get distance =>
      $composableBuilder(column: $table.distance, builder: (column) => column);

  GeneratedColumn<int> get k =>
      $composableBuilder(column: $table.k, builder: (column) => column);
}

class $DocumentVecTableManager extends RootTableManager<
    _$TabDatabase,
    DocumentVec,
    DocumentVecData,
    $DocumentVecFilterComposer,
    $DocumentVecOrderingComposer,
    $DocumentVecAnnotationComposer,
    $DocumentVecCreateCompanionBuilder,
    $DocumentVecUpdateCompanionBuilder,
    (
      DocumentVecData,
      BaseReferences<_$TabDatabase, DocumentVec, DocumentVecData>
    ),
    DocumentVecData,
    PrefetchHooks Function()> {
  $DocumentVecTableManager(_$TabDatabase db, DocumentVec table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DocumentVecFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DocumentVecOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DocumentVecAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> mainDocumentId = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            Value<Uint8List> embedding = const Value.absent(),
            Value<String> contentHash = const Value.absent(),
            Value<double?> distance = const Value.absent(),
            Value<int?> k = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentVecCompanion(
            id: id,
            mainDocumentId: mainDocumentId,
            contextId: contextId,
            embedding: embedding,
            contentHash: contentHash,
            distance: distance,
            k: k,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> mainDocumentId = const Value.absent(),
            Value<String?> contextId = const Value.absent(),
            required Uint8List embedding,
            required String contentHash,
            Value<double?> distance = const Value.absent(),
            Value<int?> k = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DocumentVecCompanion.insert(
            id: id,
            mainDocumentId: mainDocumentId,
            contextId: contextId,
            embedding: embedding,
            contentHash: contentHash,
            distance: distance,
            k: k,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $DocumentVecProcessedTableManager = ProcessedTableManager<
    _$TabDatabase,
    DocumentVec,
    DocumentVecData,
    $DocumentVecFilterComposer,
    $DocumentVecOrderingComposer,
    $DocumentVecAnnotationComposer,
    $DocumentVecCreateCompanionBuilder,
    $DocumentVecUpdateCompanionBuilder,
    (
      DocumentVecData,
      BaseReferences<_$TabDatabase, DocumentVec, DocumentVecData>
    ),
    DocumentVecData,
    PrefetchHooks Function()>;

class $TabDatabaseManager {
  final _$TabDatabase _db;
  $TabDatabaseManager(this._db);
  $ContainerTableManager get container =>
      $ContainerTableManager(_db, _db.container);
  $TabTableManager get tab => $TabTableManager(_db, _db.tab);
  $DocumentTableManager get document =>
      $DocumentTableManager(_db, _db.document);
  $TabFtsTableManager get tabFts => $TabFtsTableManager(_db, _db.tabFts);
  $DocumentVecTableManager get documentVec =>
      $DocumentVecTableManager(_db, _db.documentVec);
}
