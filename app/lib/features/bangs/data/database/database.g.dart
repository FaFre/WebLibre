// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class BangTable extends Table with TableInfo<BangTable, Bang> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangTable(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'PRIMARY KEY NOT NULL');
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: true,
              $customConstraints: 'NOT NULL')
          .withConverter<BangGroup>(BangTable.$convertergroup);
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
      'url_template', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      $customConstraints: '');
  late final GeneratedColumnWithTypeConverter<Set<BangFormat>?, String> format =
      GeneratedColumn<String>('format', aliasedName, true,
              type: DriftSqlType.string,
              requiredDuringInsert: false,
              $customConstraints: '')
          .withConverter<Set<BangFormat>?>(BangTable.$converterformat);
  @override
  List<GeneratedColumn> get $columns => [
        trigger,
        group,
        websiteName,
        domain,
        urlTemplate,
        category,
        subCategory,
        format
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger};
  @override
  Bang map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bang(
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      urlTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url_template'])!,
      group: BangTable.$convertergroup.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group'])!),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      format: BangTable.$converterformat.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])),
    );
  }

  @override
  BangTable createAlias(String alias) {
    return BangTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BangGroup, int, int> $convertergroup =
      const EnumIndexConverter<BangGroup>(BangGroup.values);
  static TypeConverter<Set<BangFormat>?, String?> $converterformat =
      const BangFormatConverter();
  @override
  bool get dontWriteConstraints => true;
}

class BangCompanion extends UpdateCompanion<Bang> {
  final Value<String> trigger;
  final Value<BangGroup> group;
  final Value<String> websiteName;
  final Value<String> domain;
  final Value<String> urlTemplate;
  final Value<String?> category;
  final Value<String?> subCategory;
  final Value<Set<BangFormat>?> format;
  final Value<int> rowid;
  const BangCompanion({
    this.trigger = const Value.absent(),
    this.group = const Value.absent(),
    this.websiteName = const Value.absent(),
    this.domain = const Value.absent(),
    this.urlTemplate = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.format = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangCompanion.insert({
    required String trigger,
    required BangGroup group,
    required String websiteName,
    required String domain,
    required String urlTemplate,
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.format = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        group = Value(group),
        websiteName = Value(websiteName),
        domain = Value(domain),
        urlTemplate = Value(urlTemplate);
  static Insertable<Bang> custom({
    Expression<String>? trigger,
    Expression<int>? group,
    Expression<String>? websiteName,
    Expression<String>? domain,
    Expression<String>? urlTemplate,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? format,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (websiteName != null) 'website_name': websiteName,
      if (domain != null) 'domain': domain,
      if (urlTemplate != null) 'url_template': urlTemplate,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (format != null) 'format': format,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangCompanion copyWith(
      {Value<String>? trigger,
      Value<BangGroup>? group,
      Value<String>? websiteName,
      Value<String>? domain,
      Value<String>? urlTemplate,
      Value<String?>? category,
      Value<String?>? subCategory,
      Value<Set<BangFormat>?>? format,
      Value<int>? rowid}) {
    return BangCompanion(
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
      websiteName: websiteName ?? this.websiteName,
      domain: domain ?? this.domain,
      urlTemplate: urlTemplate ?? this.urlTemplate,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      format: format ?? this.format,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (group.present) {
      map['group'] =
          Variable<int>(BangTable.$convertergroup.toSql(group.value));
    }
    if (websiteName.present) {
      map['website_name'] = Variable<String>(websiteName.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (urlTemplate.present) {
      map['url_template'] = Variable<String>(urlTemplate.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (format.present) {
      map['format'] =
          Variable<String>(BangTable.$converterformat.toSql(format.value));
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangCompanion(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('websiteName: $websiteName, ')
          ..write('domain: $domain, ')
          ..write('urlTemplate: $urlTemplate, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('format: $format, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangSync extends Table with TableInfo<BangSync, BangSyncData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangSync(this.attachedDatabase, [this._alias]);
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false,
              type: DriftSqlType.int,
              requiredDuringInsert: false,
              $customConstraints: 'PRIMARY KEY NOT NULL')
          .withConverter<BangGroup>(BangSync.$convertergroup);
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
      'last_sync', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [group, lastSync];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_sync';
  @override
  Set<GeneratedColumn> get $primaryKey => {group};
  @override
  BangSyncData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangSyncData(
      group: BangSync.$convertergroup.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group'])!),
      lastSync: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_sync'])!,
    );
  }

  @override
  BangSync createAlias(String alias) {
    return BangSync(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BangGroup, int, int> $convertergroup =
      const EnumIndexConverter<BangGroup>(BangGroup.values);
  @override
  bool get dontWriteConstraints => true;
}

class BangSyncData extends DataClass implements Insertable<BangSyncData> {
  final BangGroup group;
  final DateTime lastSync;
  const BangSyncData({required this.group, required this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      map['group'] = Variable<int>(BangSync.$convertergroup.toSql(group));
    }
    map['last_sync'] = Variable<DateTime>(lastSync);
    return map;
  }

  factory BangSyncData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangSyncData(
      group: BangSync.$convertergroup
          .fromJson(serializer.fromJson<int>(json['group'])),
      lastSync: serializer.fromJson<DateTime>(json['last_sync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'group': serializer.toJson<int>(BangSync.$convertergroup.toJson(group)),
      'last_sync': serializer.toJson<DateTime>(lastSync),
    };
  }

  BangSyncData copyWith({BangGroup? group, DateTime? lastSync}) => BangSyncData(
        group: group ?? this.group,
        lastSync: lastSync ?? this.lastSync,
      );
  BangSyncData copyWithCompanion(BangSyncCompanion data) {
    return BangSyncData(
      group: data.group.present ? data.group.value : this.group,
      lastSync: data.lastSync.present ? data.lastSync.value : this.lastSync,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangSyncData(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(group, lastSync);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangSyncData &&
          other.group == this.group &&
          other.lastSync == this.lastSync);
}

class BangSyncCompanion extends UpdateCompanion<BangSyncData> {
  final Value<BangGroup> group;
  final Value<DateTime> lastSync;
  const BangSyncCompanion({
    this.group = const Value.absent(),
    this.lastSync = const Value.absent(),
  });
  BangSyncCompanion.insert({
    this.group = const Value.absent(),
    required DateTime lastSync,
  }) : lastSync = Value(lastSync);
  static Insertable<BangSyncData> custom({
    Expression<int>? group,
    Expression<DateTime>? lastSync,
  }) {
    return RawValuesInsertable({
      if (group != null) 'group': group,
      if (lastSync != null) 'last_sync': lastSync,
    });
  }

  BangSyncCompanion copyWith(
      {Value<BangGroup>? group, Value<DateTime>? lastSync}) {
    return BangSyncCompanion(
      group: group ?? this.group,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (group.present) {
      map['group'] = Variable<int>(BangSync.$convertergroup.toSql(group.value));
    }
    if (lastSync.present) {
      map['last_sync'] = Variable<DateTime>(lastSync.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangSyncCompanion(')
          ..write('group: $group, ')
          ..write('lastSync: $lastSync')
          ..write(')'))
        .toString();
  }
}

class BangFrequency extends Table
    with TableInfo<BangFrequency, BangFrequencyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFrequency(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'PRIMARY KEY NOT NULL REFERENCES bang("trigger")ON DELETE CASCADE');
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [trigger, frequency, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_frequency';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger};
  @override
  BangFrequencyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFrequencyData(
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency'])!,
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used'])!,
    );
  }

  @override
  BangFrequency createAlias(String alias) {
    return BangFrequency(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BangFrequencyData extends DataClass
    implements Insertable<BangFrequencyData> {
  final String trigger;
  final int frequency;
  final DateTime lastUsed;
  const BangFrequencyData(
      {required this.trigger, required this.frequency, required this.lastUsed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['frequency'] = Variable<int>(frequency);
    map['last_used'] = Variable<DateTime>(lastUsed);
    return map;
  }

  factory BangFrequencyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFrequencyData(
      trigger: serializer.fromJson<String>(json['trigger']),
      frequency: serializer.fromJson<int>(json['frequency']),
      lastUsed: serializer.fromJson<DateTime>(json['last_used']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'frequency': serializer.toJson<int>(frequency),
      'last_used': serializer.toJson<DateTime>(lastUsed),
    };
  }

  BangFrequencyData copyWith(
          {String? trigger, int? frequency, DateTime? lastUsed}) =>
      BangFrequencyData(
        trigger: trigger ?? this.trigger,
        frequency: frequency ?? this.frequency,
        lastUsed: lastUsed ?? this.lastUsed,
      );
  BangFrequencyData copyWithCompanion(BangFrequencyCompanion data) {
    return BangFrequencyData(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyData(')
          ..write('trigger: $trigger, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, frequency, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangFrequencyData &&
          other.trigger == this.trigger &&
          other.frequency == this.frequency &&
          other.lastUsed == this.lastUsed);
}

class BangFrequencyCompanion extends UpdateCompanion<BangFrequencyData> {
  final Value<String> trigger;
  final Value<int> frequency;
  final Value<DateTime> lastUsed;
  final Value<int> rowid;
  const BangFrequencyCompanion({
    this.trigger = const Value.absent(),
    this.frequency = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangFrequencyCompanion.insert({
    required String trigger,
    required int frequency,
    required DateTime lastUsed,
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        frequency = Value(frequency),
        lastUsed = Value(lastUsed);
  static Insertable<BangFrequencyData> custom({
    Expression<String>? trigger,
    Expression<int>? frequency,
    Expression<DateTime>? lastUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (frequency != null) 'frequency': frequency,
      if (lastUsed != null) 'last_used': lastUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangFrequencyCompanion copyWith(
      {Value<String>? trigger,
      Value<int>? frequency,
      Value<DateTime>? lastUsed,
      Value<int>? rowid}) {
    return BangFrequencyCompanion(
      trigger: trigger ?? this.trigger,
      frequency: frequency ?? this.frequency,
      lastUsed: lastUsed ?? this.lastUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<int>(frequency.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyCompanion(')
          ..write('trigger: $trigger, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangHistory extends Table with TableInfo<BangHistory, BangHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangHistory(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> searchQuery = GeneratedColumn<String>(
      'search_query', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'UNIQUE NOT NULL');
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL REFERENCES bang("trigger")');
  late final GeneratedColumn<DateTime> searchDate = GeneratedColumn<DateTime>(
      'search_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [searchQuery, trigger, searchDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_history';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  BangHistoryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangHistoryData(
      searchQuery: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}search_query'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      searchDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}search_date'])!,
    );
  }

  @override
  BangHistory createAlias(String alias) {
    return BangHistory(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BangHistoryData extends DataClass implements Insertable<BangHistoryData> {
  final String searchQuery;
  final String trigger;
  final DateTime searchDate;
  const BangHistoryData(
      {required this.searchQuery,
      required this.trigger,
      required this.searchDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['search_query'] = Variable<String>(searchQuery);
    map['trigger'] = Variable<String>(trigger);
    map['search_date'] = Variable<DateTime>(searchDate);
    return map;
  }

  factory BangHistoryData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangHistoryData(
      searchQuery: serializer.fromJson<String>(json['search_query']),
      trigger: serializer.fromJson<String>(json['trigger']),
      searchDate: serializer.fromJson<DateTime>(json['search_date']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'search_query': serializer.toJson<String>(searchQuery),
      'trigger': serializer.toJson<String>(trigger),
      'search_date': serializer.toJson<DateTime>(searchDate),
    };
  }

  BangHistoryData copyWith(
          {String? searchQuery, String? trigger, DateTime? searchDate}) =>
      BangHistoryData(
        searchQuery: searchQuery ?? this.searchQuery,
        trigger: trigger ?? this.trigger,
        searchDate: searchDate ?? this.searchDate,
      );
  BangHistoryData copyWithCompanion(BangHistoryCompanion data) {
    return BangHistoryData(
      searchQuery:
          data.searchQuery.present ? data.searchQuery.value : this.searchQuery,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      searchDate:
          data.searchDate.present ? data.searchDate.value : this.searchDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangHistoryData(')
          ..write('searchQuery: $searchQuery, ')
          ..write('trigger: $trigger, ')
          ..write('searchDate: $searchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(searchQuery, trigger, searchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangHistoryData &&
          other.searchQuery == this.searchQuery &&
          other.trigger == this.trigger &&
          other.searchDate == this.searchDate);
}

class BangHistoryCompanion extends UpdateCompanion<BangHistoryData> {
  final Value<String> searchQuery;
  final Value<String> trigger;
  final Value<DateTime> searchDate;
  final Value<int> rowid;
  const BangHistoryCompanion({
    this.searchQuery = const Value.absent(),
    this.trigger = const Value.absent(),
    this.searchDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangHistoryCompanion.insert({
    required String searchQuery,
    required String trigger,
    required DateTime searchDate,
    this.rowid = const Value.absent(),
  })  : searchQuery = Value(searchQuery),
        trigger = Value(trigger),
        searchDate = Value(searchDate);
  static Insertable<BangHistoryData> custom({
    Expression<String>? searchQuery,
    Expression<String>? trigger,
    Expression<DateTime>? searchDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (searchQuery != null) 'search_query': searchQuery,
      if (trigger != null) 'trigger': trigger,
      if (searchDate != null) 'search_date': searchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangHistoryCompanion copyWith(
      {Value<String>? searchQuery,
      Value<String>? trigger,
      Value<DateTime>? searchDate,
      Value<int>? rowid}) {
    return BangHistoryCompanion(
      searchQuery: searchQuery ?? this.searchQuery,
      trigger: trigger ?? this.trigger,
      searchDate: searchDate ?? this.searchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (searchQuery.present) {
      map['search_query'] = Variable<String>(searchQuery.value);
    }
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (searchDate.present) {
      map['search_date'] = Variable<DateTime>(searchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangHistoryCompanion(')
          ..write('searchQuery: $searchQuery, ')
          ..write('trigger: $trigger, ')
          ..write('searchDate: $searchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangFts extends Table
    with TableInfo<BangFts, BangFt>, VirtualTableInfo<BangFts, BangFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: '');
  @override
  List<GeneratedColumn> get $columns => [trigger, websiteName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_fts';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  BangFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFt(
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
    );
  }

  @override
  BangFts createAlias(String alias) {
    return BangFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(trigger, website_name, content=bang, prefix=\'2 3\')';
}

class BangFt extends DataClass implements Insertable<BangFt> {
  final String trigger;
  final String websiteName;
  const BangFt({required this.trigger, required this.websiteName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['website_name'] = Variable<String>(websiteName);
    return map;
  }

  factory BangFt.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFt(
      trigger: serializer.fromJson<String>(json['trigger']),
      websiteName: serializer.fromJson<String>(json['website_name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'website_name': serializer.toJson<String>(websiteName),
    };
  }

  BangFt copyWith({String? trigger, String? websiteName}) => BangFt(
        trigger: trigger ?? this.trigger,
        websiteName: websiteName ?? this.websiteName,
      );
  BangFt copyWithCompanion(BangFtsCompanion data) {
    return BangFt(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      websiteName:
          data.websiteName.present ? data.websiteName.value : this.websiteName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFt(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, websiteName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangFt &&
          other.trigger == this.trigger &&
          other.websiteName == this.websiteName);
}

class BangFtsCompanion extends UpdateCompanion<BangFt> {
  final Value<String> trigger;
  final Value<String> websiteName;
  final Value<int> rowid;
  const BangFtsCompanion({
    this.trigger = const Value.absent(),
    this.websiteName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangFtsCompanion.insert({
    required String trigger,
    required String websiteName,
    this.rowid = const Value.absent(),
  })  : trigger = Value(trigger),
        websiteName = Value(websiteName);
  static Insertable<BangFt> custom({
    Expression<String>? trigger,
    Expression<String>? websiteName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (websiteName != null) 'website_name': websiteName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangFtsCompanion copyWith(
      {Value<String>? trigger, Value<String>? websiteName, Value<int>? rowid}) {
    return BangFtsCompanion(
      trigger: trigger ?? this.trigger,
      websiteName: websiteName ?? this.websiteName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trigger.present) {
      map['trigger'] = Variable<String>(trigger.value);
    }
    if (websiteName.present) {
      map['website_name'] = Variable<String>(websiteName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BangFtsCompanion(')
          ..write('trigger: $trigger, ')
          ..write('websiteName: $websiteName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangDataView extends ViewInfo<BangDataView, BangData>
    implements HasResultSet {
  final String? _alias;
  @override
  final _$BangDatabase attachedDatabase;
  BangDataView(this.attachedDatabase, [this._alias]);
  @override
  List<GeneratedColumn> get $columns => [
        trigger,
        group,
        websiteName,
        domain,
        urlTemplate,
        category,
        subCategory,
        format,
        frequency,
        lastUsed
      ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'bang_data_view';
  @override
  Map<SqlDialect, String> get createViewStatements => {
        SqlDialect.sqlite:
            'CREATE VIEW bang_data_view AS SELECT b.*, bf.frequency, bf.last_used FROM bang AS b LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger"',
      };
  @override
  BangDataView get asDslTable => this;
  @override
  BangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangData(
      websiteName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website_name'])!,
      domain: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}domain'])!,
      trigger: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}trigger'])!,
      urlTemplate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url_template'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category']),
      format: BangTable.$converterformat.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}format'])),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}frequency']),
      lastUsed: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_used']),
    );
  }

  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
      'trigger', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumnWithTypeConverter<BangGroup, int> group =
      GeneratedColumn<int>('group', aliasedName, false, type: DriftSqlType.int)
          .withConverter<BangGroup>(BangTable.$convertergroup);
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
      'website_name', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
      'domain', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
      'url_template', aliasedName, false,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string);
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, true,
      type: DriftSqlType.string);
  late final GeneratedColumnWithTypeConverter<Set<BangFormat>?, String> format =
      GeneratedColumn<String>('format', aliasedName, true,
              type: DriftSqlType.string)
          .withConverter<Set<BangFormat>?>(BangTable.$converterformat);
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
      'frequency', aliasedName, true,
      type: DriftSqlType.int);
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
      'last_used', aliasedName, true,
      type: DriftSqlType.dateTime);
  @override
  BangDataView createAlias(String alias) {
    return BangDataView(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {'bang', 'bang_frequency'};
}

abstract class _$BangDatabase extends GeneratedDatabase {
  _$BangDatabase(QueryExecutor e) : super(e);
  $BangDatabaseManager get managers => $BangDatabaseManager(this);
  late final BangTable bang = BangTable(this);
  late final BangSync bangSync = BangSync(this);
  late final BangFrequency bangFrequency = BangFrequency(this);
  late final BangHistory bangHistory = BangHistory(this);
  late final BangFts bangFts = BangFts(this);
  late final BangDataView bangDataView = BangDataView(this);
  late final Trigger bangAfterInsert = Trigger(
      'CREATE TRIGGER bang_after_insert AFTER INSERT ON bang BEGIN INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
      'bang_after_insert');
  late final Trigger bangAfterDelete = Trigger(
      'CREATE TRIGGER bang_after_delete AFTER DELETE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);END',
      'bang_after_delete');
  late final Trigger bangAfterUpdate = Trigger(
      'CREATE TRIGGER bang_after_update AFTER UPDATE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
      'bang_after_update');
  late final BangDao bangDao = BangDao(this as BangDatabase);
  late final SyncDao syncDao = SyncDao(this as BangDatabase);
  Future<int> optimizeFtsIndex() {
    return customInsert(
      'INSERT INTO bang_fts (bang_fts) VALUES (\'optimize\')',
      variables: [],
      updates: {bangFts},
    );
  }

  Selectable<BangData> queryBangs({required String query}) {
    return customSelect(
        'WITH weights AS (SELECT 10.0 AS "trigger", 5.0 AS website_name) SELECT b.*, bf.frequency, bf.last_used, bm25(bang_fts, weights."trigger", weights.website_name) AS weighted_rank FROM bang_fts(?1)AS fts INNER JOIN bang AS b ON b."rowid" = fts."rowid" LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" CROSS JOIN weights ORDER BY weighted_rank ASC, bf.frequency NULLS LAST',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          bangFrequency,
          bangFts,
          bang,
        }).map((QueryRow row) => BangData(
          websiteName: row.read<String>('website_name'),
          domain: row.read<String>('domain'),
          trigger: row.read<String>('trigger'),
          urlTemplate: row.read<String>('url_template'),
          category: row.readNullable<String>('category'),
          subCategory: row.readNullable<String>('sub_category'),
          format: BangTable.$converterformat
              .fromSql(row.readNullable<String>('format')),
          frequency: row.readNullable<int>('frequency'),
          lastUsed: row.readNullable<DateTime>('last_used'),
        ));
  }

  Selectable<BangData> queryBangsBasic({required String query}) {
    return customSelect(
        'WITH weights AS (SELECT 10.0 AS "trigger", 5.0 AS website_name) SELECT b.*, bf.frequency, bf.last_used, bm25(bang_fts, weights."trigger", weights.website_name) AS weighted_rank FROM bang_fts AS fts INNER JOIN bang AS b ON b."rowid" = fts."rowid" LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" CROSS JOIN weights WHERE fts."trigger" LIKE ?1 OR fts.website_name LIKE ?1 ORDER BY weighted_rank ASC, bf.frequency NULLS LAST',
        variables: [
          Variable<String>(query)
        ],
        readsFrom: {
          bangFrequency,
          bangFts,
          bang,
        }).map((QueryRow row) => BangData(
          websiteName: row.read<String>('website_name'),
          domain: row.read<String>('domain'),
          trigger: row.read<String>('trigger'),
          urlTemplate: row.read<String>('url_template'),
          category: row.readNullable<String>('category'),
          subCategory: row.readNullable<String>('sub_category'),
          format: BangTable.$converterformat
              .fromSql(row.readNullable<String>('format')),
          frequency: row.readNullable<int>('frequency'),
          lastUsed: row.readNullable<DateTime>('last_used'),
        ));
  }

  Selectable<String> categoriesJson() {
    return customSelect(
        'WITH categories AS (SELECT b.category, json_group_array(DISTINCT b.sub_category ORDER BY b.sub_category)AS sub_categories FROM bang AS b WHERE b.category IS NOT NULL AND b.sub_category IS NOT NULL GROUP BY b.category ORDER BY b.category) SELECT json_group_object(c.category, json(c.sub_categories)) AS categories_json FROM categories AS c',
        variables: [],
        readsFrom: {
          bang,
        }).map((QueryRow row) => row.read<String>('categories_json'));
  }

  Selectable<SearchHistoryEntry> searchHistoryEntries({required int limit}) {
    return customSelect(
        'SELECT * FROM bang_history ORDER BY search_date DESC LIMIT ?1',
        variables: [
          Variable<int>(limit)
        ],
        readsFrom: {
          bangHistory,
        }).map((QueryRow row) => SearchHistoryEntry(
          searchQuery: row.read<String>('search_query'),
          trigger: row.read<String>('trigger'),
          searchDate: row.read<DateTime>('search_date'),
        ));
  }

  Future<int> evictHistoryEntries({required int limit}) {
    return customUpdate(
      'DELETE FROM bang_history WHERE "rowid" IN (SELECT "rowid" FROM bang_history ORDER BY search_date DESC LIMIT -1 OFFSET ?1)',
      variables: [Variable<int>(limit)],
      updates: {bangHistory},
      updateKind: UpdateKind.delete,
    );
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        bang,
        bangSync,
        bangFrequency,
        bangHistory,
        bangFts,
        bangDataView,
        bangAfterInsert,
        bangAfterDelete,
        bangAfterUpdate
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bang_frequency', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.insert),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('bang',
                limitUpdateKind: UpdateKind.update),
            result: [
              TableUpdate('bang_fts', kind: UpdateKind.insert),
            ],
          ),
        ],
      );
}

typedef $BangTableCreateCompanionBuilder = BangCompanion Function({
  required String trigger,
  required BangGroup group,
  required String websiteName,
  required String domain,
  required String urlTemplate,
  Value<String?> category,
  Value<String?> subCategory,
  Value<Set<BangFormat>?> format,
  Value<int> rowid,
});
typedef $BangTableUpdateCompanionBuilder = BangCompanion Function({
  Value<String> trigger,
  Value<BangGroup> group,
  Value<String> websiteName,
  Value<String> domain,
  Value<String> urlTemplate,
  Value<String?> category,
  Value<String?> subCategory,
  Value<Set<BangFormat>?> format,
  Value<int> rowid,
});

final class $BangTableReferences
    extends BaseReferences<_$BangDatabase, BangTable, Bang> {
  $BangTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<BangFrequency, List<BangFrequencyData>>
      _bangFrequencyRefsTable(_$BangDatabase db) =>
          MultiTypedResultKey.fromTable(db.bangFrequency,
              aliasName: $_aliasNameGenerator(
                  db.bang.trigger, db.bangFrequency.trigger));

  $BangFrequencyProcessedTableManager get bangFrequencyRefs {
    final manager = $BangFrequencyTableManager($_db, $_db.bangFrequency).filter(
        (f) => f.trigger.trigger.sqlEquals($_itemColumn<String>('trigger')!));

    final cache = $_typedResult.readTableOrNull(_bangFrequencyRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<BangHistory, List<BangHistoryData>>
      _bangHistoryRefsTable(_$BangDatabase db) => MultiTypedResultKey.fromTable(
          db.bangHistory,
          aliasName:
              $_aliasNameGenerator(db.bang.trigger, db.bangHistory.trigger));

  $BangHistoryProcessedTableManager get bangHistoryRefs {
    final manager = $BangHistoryTableManager($_db, $_db.bangHistory).filter(
        (f) => f.trigger.trigger.sqlEquals($_itemColumn<String>('trigger')!));

    final cache = $_typedResult.readTableOrNull(_bangHistoryRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $BangTableFilterComposer extends Composer<_$BangDatabase, BangTable> {
  $BangTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<BangGroup, BangGroup, int> get group =>
      $composableBuilder(
          column: $table.group,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get urlTemplate => $composableBuilder(
      column: $table.urlTemplate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnWithTypeConverterFilters<Set<BangFormat>?, Set<BangFormat>, String>
      get format => $composableBuilder(
          column: $table.format,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  Expression<bool> bangFrequencyRefs(
      Expression<bool> Function($BangFrequencyFilterComposer f) f) {
    final $BangFrequencyFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bangFrequency,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangFrequencyFilterComposer(
              $db: $db,
              $table: $db.bangFrequency,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> bangHistoryRefs(
      Expression<bool> Function($BangHistoryFilterComposer f) f) {
    final $BangHistoryFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bangHistory,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangHistoryFilterComposer(
              $db: $db,
              $table: $db.bangHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $BangTableOrderingComposer extends Composer<_$BangDatabase, BangTable> {
  $BangTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get domain => $composableBuilder(
      column: $table.domain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get urlTemplate => $composableBuilder(
      column: $table.urlTemplate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get format => $composableBuilder(
      column: $table.format, builder: (column) => ColumnOrderings(column));
}

class $BangTableAnnotationComposer extends Composer<_$BangDatabase, BangTable> {
  $BangTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get urlTemplate => $composableBuilder(
      column: $table.urlTemplate, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Set<BangFormat>?, String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  Expression<T> bangFrequencyRefs<T extends Object>(
      Expression<T> Function($BangFrequencyAnnotationComposer a) f) {
    final $BangFrequencyAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bangFrequency,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangFrequencyAnnotationComposer(
              $db: $db,
              $table: $db.bangFrequency,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> bangHistoryRefs<T extends Object>(
      Expression<T> Function($BangHistoryAnnotationComposer a) f) {
    final $BangHistoryAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bangHistory,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangHistoryAnnotationComposer(
              $db: $db,
              $table: $db.bangHistory,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $BangTableTableManager extends RootTableManager<
    _$BangDatabase,
    BangTable,
    Bang,
    $BangTableFilterComposer,
    $BangTableOrderingComposer,
    $BangTableAnnotationComposer,
    $BangTableCreateCompanionBuilder,
    $BangTableUpdateCompanionBuilder,
    (Bang, $BangTableReferences),
    Bang,
    PrefetchHooks Function({bool bangFrequencyRefs, bool bangHistoryRefs})> {
  $BangTableTableManager(_$BangDatabase db, BangTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BangTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BangTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BangTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> trigger = const Value.absent(),
            Value<BangGroup> group = const Value.absent(),
            Value<String> websiteName = const Value.absent(),
            Value<String> domain = const Value.absent(),
            Value<String> urlTemplate = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> subCategory = const Value.absent(),
            Value<Set<BangFormat>?> format = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangCompanion(
            trigger: trigger,
            group: group,
            websiteName: websiteName,
            domain: domain,
            urlTemplate: urlTemplate,
            category: category,
            subCategory: subCategory,
            format: format,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String trigger,
            required BangGroup group,
            required String websiteName,
            required String domain,
            required String urlTemplate,
            Value<String?> category = const Value.absent(),
            Value<String?> subCategory = const Value.absent(),
            Value<Set<BangFormat>?> format = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangCompanion.insert(
            trigger: trigger,
            group: group,
            websiteName: websiteName,
            domain: domain,
            urlTemplate: urlTemplate,
            category: category,
            subCategory: subCategory,
            format: format,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $BangTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {bangFrequencyRefs = false, bangHistoryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (bangFrequencyRefs) db.bangFrequency,
                if (bangHistoryRefs) db.bangHistory
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bangFrequencyRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $BangTableReferences._bangFrequencyRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $BangTableReferences(db, table, p0)
                                .bangFrequencyRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.trigger == item.trigger),
                        typedResults: items),
                  if (bangHistoryRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $BangTableReferences._bangHistoryRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $BangTableReferences(db, table, p0).bangHistoryRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.trigger == item.trigger),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $BangTableProcessedTableManager = ProcessedTableManager<
    _$BangDatabase,
    BangTable,
    Bang,
    $BangTableFilterComposer,
    $BangTableOrderingComposer,
    $BangTableAnnotationComposer,
    $BangTableCreateCompanionBuilder,
    $BangTableUpdateCompanionBuilder,
    (Bang, $BangTableReferences),
    Bang,
    PrefetchHooks Function({bool bangFrequencyRefs, bool bangHistoryRefs})>;
typedef $BangSyncCreateCompanionBuilder = BangSyncCompanion Function({
  Value<BangGroup> group,
  required DateTime lastSync,
});
typedef $BangSyncUpdateCompanionBuilder = BangSyncCompanion Function({
  Value<BangGroup> group,
  Value<DateTime> lastSync,
});

class $BangSyncFilterComposer extends Composer<_$BangDatabase, BangSync> {
  $BangSyncFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnWithTypeConverterFilters<BangGroup, BangGroup, int> get group =>
      $composableBuilder(
          column: $table.group,
          builder: (column) => ColumnWithTypeConverterFilters(column));

  ColumnFilters<DateTime> get lastSync => $composableBuilder(
      column: $table.lastSync, builder: (column) => ColumnFilters(column));
}

class $BangSyncOrderingComposer extends Composer<_$BangDatabase, BangSync> {
  $BangSyncOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get group => $composableBuilder(
      column: $table.group, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastSync => $composableBuilder(
      column: $table.lastSync, builder: (column) => ColumnOrderings(column));
}

class $BangSyncAnnotationComposer extends Composer<_$BangDatabase, BangSync> {
  $BangSyncAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumnWithTypeConverter<BangGroup, int> get group =>
      $composableBuilder(column: $table.group, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSync =>
      $composableBuilder(column: $table.lastSync, builder: (column) => column);
}

class $BangSyncTableManager extends RootTableManager<
    _$BangDatabase,
    BangSync,
    BangSyncData,
    $BangSyncFilterComposer,
    $BangSyncOrderingComposer,
    $BangSyncAnnotationComposer,
    $BangSyncCreateCompanionBuilder,
    $BangSyncUpdateCompanionBuilder,
    (BangSyncData, BaseReferences<_$BangDatabase, BangSync, BangSyncData>),
    BangSyncData,
    PrefetchHooks Function()> {
  $BangSyncTableManager(_$BangDatabase db, BangSync table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BangSyncFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BangSyncOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BangSyncAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<BangGroup> group = const Value.absent(),
            Value<DateTime> lastSync = const Value.absent(),
          }) =>
              BangSyncCompanion(
            group: group,
            lastSync: lastSync,
          ),
          createCompanionCallback: ({
            Value<BangGroup> group = const Value.absent(),
            required DateTime lastSync,
          }) =>
              BangSyncCompanion.insert(
            group: group,
            lastSync: lastSync,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $BangSyncProcessedTableManager = ProcessedTableManager<
    _$BangDatabase,
    BangSync,
    BangSyncData,
    $BangSyncFilterComposer,
    $BangSyncOrderingComposer,
    $BangSyncAnnotationComposer,
    $BangSyncCreateCompanionBuilder,
    $BangSyncUpdateCompanionBuilder,
    (BangSyncData, BaseReferences<_$BangDatabase, BangSync, BangSyncData>),
    BangSyncData,
    PrefetchHooks Function()>;
typedef $BangFrequencyCreateCompanionBuilder = BangFrequencyCompanion Function({
  required String trigger,
  required int frequency,
  required DateTime lastUsed,
  Value<int> rowid,
});
typedef $BangFrequencyUpdateCompanionBuilder = BangFrequencyCompanion Function({
  Value<String> trigger,
  Value<int> frequency,
  Value<DateTime> lastUsed,
  Value<int> rowid,
});

final class $BangFrequencyReferences
    extends BaseReferences<_$BangDatabase, BangFrequency, BangFrequencyData> {
  $BangFrequencyReferences(super.$_db, super.$_table, super.$_typedResult);

  static BangTable _triggerTable(_$BangDatabase db) => db.bang.createAlias(
      $_aliasNameGenerator(db.bangFrequency.trigger, db.bang.trigger));

  $BangTableProcessedTableManager get trigger {
    final $_column = $_itemColumn<String>('trigger')!;

    final manager = $BangTableTableManager($_db, $_db.bang)
        .filter((f) => f.trigger.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_triggerTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $BangFrequencyFilterComposer
    extends Composer<_$BangDatabase, BangFrequency> {
  $BangFrequencyFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnFilters(column));

  $BangTableFilterComposer get trigger {
    final $BangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableFilterComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangFrequencyOrderingComposer
    extends Composer<_$BangDatabase, BangFrequency> {
  $BangFrequencyOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
      column: $table.lastUsed, builder: (column) => ColumnOrderings(column));

  $BangTableOrderingComposer get trigger {
    final $BangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableOrderingComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangFrequencyAnnotationComposer
    extends Composer<_$BangDatabase, BangFrequency> {
  $BangFrequencyAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);

  $BangTableAnnotationComposer get trigger {
    final $BangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableAnnotationComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangFrequencyTableManager extends RootTableManager<
    _$BangDatabase,
    BangFrequency,
    BangFrequencyData,
    $BangFrequencyFilterComposer,
    $BangFrequencyOrderingComposer,
    $BangFrequencyAnnotationComposer,
    $BangFrequencyCreateCompanionBuilder,
    $BangFrequencyUpdateCompanionBuilder,
    (BangFrequencyData, $BangFrequencyReferences),
    BangFrequencyData,
    PrefetchHooks Function({bool trigger})> {
  $BangFrequencyTableManager(_$BangDatabase db, BangFrequency table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BangFrequencyFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BangFrequencyOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BangFrequencyAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> trigger = const Value.absent(),
            Value<int> frequency = const Value.absent(),
            Value<DateTime> lastUsed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFrequencyCompanion(
            trigger: trigger,
            frequency: frequency,
            lastUsed: lastUsed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String trigger,
            required int frequency,
            required DateTime lastUsed,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFrequencyCompanion.insert(
            trigger: trigger,
            frequency: frequency,
            lastUsed: lastUsed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $BangFrequencyReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({trigger = false}) {
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
                if (trigger) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.trigger,
                    referencedTable: $BangFrequencyReferences._triggerTable(db),
                    referencedColumn:
                        $BangFrequencyReferences._triggerTable(db).trigger,
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

typedef $BangFrequencyProcessedTableManager = ProcessedTableManager<
    _$BangDatabase,
    BangFrequency,
    BangFrequencyData,
    $BangFrequencyFilterComposer,
    $BangFrequencyOrderingComposer,
    $BangFrequencyAnnotationComposer,
    $BangFrequencyCreateCompanionBuilder,
    $BangFrequencyUpdateCompanionBuilder,
    (BangFrequencyData, $BangFrequencyReferences),
    BangFrequencyData,
    PrefetchHooks Function({bool trigger})>;
typedef $BangHistoryCreateCompanionBuilder = BangHistoryCompanion Function({
  required String searchQuery,
  required String trigger,
  required DateTime searchDate,
  Value<int> rowid,
});
typedef $BangHistoryUpdateCompanionBuilder = BangHistoryCompanion Function({
  Value<String> searchQuery,
  Value<String> trigger,
  Value<DateTime> searchDate,
  Value<int> rowid,
});

final class $BangHistoryReferences
    extends BaseReferences<_$BangDatabase, BangHistory, BangHistoryData> {
  $BangHistoryReferences(super.$_db, super.$_table, super.$_typedResult);

  static BangTable _triggerTable(_$BangDatabase db) => db.bang.createAlias(
      $_aliasNameGenerator(db.bangHistory.trigger, db.bang.trigger));

  $BangTableProcessedTableManager get trigger {
    final $_column = $_itemColumn<String>('trigger')!;

    final manager = $BangTableTableManager($_db, $_db.bang)
        .filter((f) => f.trigger.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_triggerTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $BangHistoryFilterComposer extends Composer<_$BangDatabase, BangHistory> {
  $BangHistoryFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get searchQuery => $composableBuilder(
      column: $table.searchQuery, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get searchDate => $composableBuilder(
      column: $table.searchDate, builder: (column) => ColumnFilters(column));

  $BangTableFilterComposer get trigger {
    final $BangTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableFilterComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangHistoryOrderingComposer
    extends Composer<_$BangDatabase, BangHistory> {
  $BangHistoryOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get searchQuery => $composableBuilder(
      column: $table.searchQuery, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get searchDate => $composableBuilder(
      column: $table.searchDate, builder: (column) => ColumnOrderings(column));

  $BangTableOrderingComposer get trigger {
    final $BangTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableOrderingComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangHistoryAnnotationComposer
    extends Composer<_$BangDatabase, BangHistory> {
  $BangHistoryAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get searchQuery => $composableBuilder(
      column: $table.searchQuery, builder: (column) => column);

  GeneratedColumn<DateTime> get searchDate => $composableBuilder(
      column: $table.searchDate, builder: (column) => column);

  $BangTableAnnotationComposer get trigger {
    final $BangTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.trigger,
        referencedTable: $db.bang,
        getReferencedColumn: (t) => t.trigger,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $BangTableAnnotationComposer(
              $db: $db,
              $table: $db.bang,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $BangHistoryTableManager extends RootTableManager<
    _$BangDatabase,
    BangHistory,
    BangHistoryData,
    $BangHistoryFilterComposer,
    $BangHistoryOrderingComposer,
    $BangHistoryAnnotationComposer,
    $BangHistoryCreateCompanionBuilder,
    $BangHistoryUpdateCompanionBuilder,
    (BangHistoryData, $BangHistoryReferences),
    BangHistoryData,
    PrefetchHooks Function({bool trigger})> {
  $BangHistoryTableManager(_$BangDatabase db, BangHistory table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BangHistoryFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BangHistoryOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BangHistoryAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> searchQuery = const Value.absent(),
            Value<String> trigger = const Value.absent(),
            Value<DateTime> searchDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangHistoryCompanion(
            searchQuery: searchQuery,
            trigger: trigger,
            searchDate: searchDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String searchQuery,
            required String trigger,
            required DateTime searchDate,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangHistoryCompanion.insert(
            searchQuery: searchQuery,
            trigger: trigger,
            searchDate: searchDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $BangHistoryReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({trigger = false}) {
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
                if (trigger) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.trigger,
                    referencedTable: $BangHistoryReferences._triggerTable(db),
                    referencedColumn:
                        $BangHistoryReferences._triggerTable(db).trigger,
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

typedef $BangHistoryProcessedTableManager = ProcessedTableManager<
    _$BangDatabase,
    BangHistory,
    BangHistoryData,
    $BangHistoryFilterComposer,
    $BangHistoryOrderingComposer,
    $BangHistoryAnnotationComposer,
    $BangHistoryCreateCompanionBuilder,
    $BangHistoryUpdateCompanionBuilder,
    (BangHistoryData, $BangHistoryReferences),
    BangHistoryData,
    PrefetchHooks Function({bool trigger})>;
typedef $BangFtsCreateCompanionBuilder = BangFtsCompanion Function({
  required String trigger,
  required String websiteName,
  Value<int> rowid,
});
typedef $BangFtsUpdateCompanionBuilder = BangFtsCompanion Function({
  Value<String> trigger,
  Value<String> websiteName,
  Value<int> rowid,
});

class $BangFtsFilterComposer extends Composer<_$BangDatabase, BangFts> {
  $BangFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => ColumnFilters(column));
}

class $BangFtsOrderingComposer extends Composer<_$BangDatabase, BangFts> {
  $BangFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trigger => $composableBuilder(
      column: $table.trigger, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => ColumnOrderings(column));
}

class $BangFtsAnnotationComposer extends Composer<_$BangDatabase, BangFts> {
  $BangFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trigger =>
      $composableBuilder(column: $table.trigger, builder: (column) => column);

  GeneratedColumn<String> get websiteName => $composableBuilder(
      column: $table.websiteName, builder: (column) => column);
}

class $BangFtsTableManager extends RootTableManager<
    _$BangDatabase,
    BangFts,
    BangFt,
    $BangFtsFilterComposer,
    $BangFtsOrderingComposer,
    $BangFtsAnnotationComposer,
    $BangFtsCreateCompanionBuilder,
    $BangFtsUpdateCompanionBuilder,
    (BangFt, BaseReferences<_$BangDatabase, BangFts, BangFt>),
    BangFt,
    PrefetchHooks Function()> {
  $BangFtsTableManager(_$BangDatabase db, BangFts table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BangFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BangFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BangFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> trigger = const Value.absent(),
            Value<String> websiteName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFtsCompanion(
            trigger: trigger,
            websiteName: websiteName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String trigger,
            required String websiteName,
            Value<int> rowid = const Value.absent(),
          }) =>
              BangFtsCompanion.insert(
            trigger: trigger,
            websiteName: websiteName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $BangFtsProcessedTableManager = ProcessedTableManager<
    _$BangDatabase,
    BangFts,
    BangFt,
    $BangFtsFilterComposer,
    $BangFtsOrderingComposer,
    $BangFtsAnnotationComposer,
    $BangFtsCreateCompanionBuilder,
    $BangFtsUpdateCompanionBuilder,
    (BangFt, BaseReferences<_$BangDatabase, BangFts, BangFt>),
    BangFt,
    PrefetchHooks Function()>;

class $BangDatabaseManager {
  final _$BangDatabase _db;
  $BangDatabaseManager(this._db);
  $BangTableTableManager get bang => $BangTableTableManager(_db, _db.bang);
  $BangSyncTableManager get bangSync =>
      $BangSyncTableManager(_db, _db.bangSync);
  $BangFrequencyTableManager get bangFrequency =>
      $BangFrequencyTableManager(_db, _db.bangFrequency);
  $BangHistoryTableManager get bangHistory =>
      $BangHistoryTableManager(_db, _db.bangHistory);
  $BangFtsTableManager get bangFts => $BangFtsTableManager(_db, _db.bangFts);
}
