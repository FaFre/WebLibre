// dart format width=80
import 'dart:typed_data' as i2;
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Setting extends Table with TableInfo<Setting, SettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Setting(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<String> partitionKey = GeneratedColumn<String>(
    'partition_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<DriftAny> value = GeneratedColumn<DriftAny>(
    'value',
    aliasedName,
    true,
    type: DriftSqlType.any,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [key, partitionKey, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting';
  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      partitionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partition_key'],
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.any,
        data['${effectivePrefix}value'],
      ),
    );
  }

  @override
  Setting createAlias(String alias) {
    return Setting(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
  @override
  bool get dontWriteConstraints => true;
}

class SettingData extends DataClass implements Insertable<SettingData> {
  final String key;
  final String? partitionKey;
  final DriftAny? value;
  const SettingData({required this.key, this.partitionKey, this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || partitionKey != null) {
      map['partition_key'] = Variable<String>(partitionKey);
    }
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<DriftAny>(value);
    }
    return map;
  }

  factory SettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingData(
      key: serializer.fromJson<String>(json['key']),
      partitionKey: serializer.fromJson<String?>(json['partitionKey']),
      value: serializer.fromJson<DriftAny?>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'partitionKey': serializer.toJson<String?>(partitionKey),
      'value': serializer.toJson<DriftAny?>(value),
    };
  }

  SettingData copyWith({
    String? key,
    Value<String?> partitionKey = const Value.absent(),
    Value<DriftAny?> value = const Value.absent(),
  }) => SettingData(
    key: key ?? this.key,
    partitionKey: partitionKey.present ? partitionKey.value : this.partitionKey,
    value: value.present ? value.value : this.value,
  );
  SettingData copyWithCompanion(SettingCompanion data) {
    return SettingData(
      key: data.key.present ? data.key.value : this.key,
      partitionKey: data.partitionKey.present
          ? data.partitionKey.value
          : this.partitionKey,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingData(')
          ..write('key: $key, ')
          ..write('partitionKey: $partitionKey, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, partitionKey, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingData &&
          other.key == this.key &&
          other.partitionKey == this.partitionKey &&
          other.value == this.value);
}

class SettingCompanion extends UpdateCompanion<SettingData> {
  final Value<String> key;
  final Value<String?> partitionKey;
  final Value<DriftAny?> value;
  final Value<int> rowid;
  const SettingCompanion({
    this.key = const Value.absent(),
    this.partitionKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingCompanion.insert({
    required String key,
    this.partitionKey = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<SettingData> custom({
    Expression<String>? key,
    Expression<String>? partitionKey,
    Expression<DriftAny>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (partitionKey != null) 'partition_key': partitionKey,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingCompanion copyWith({
    Value<String>? key,
    Value<String?>? partitionKey,
    Value<DriftAny?>? value,
    Value<int>? rowid,
  }) {
    return SettingCompanion(
      key: key ?? this.key,
      partitionKey: partitionKey ?? this.partitionKey,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (partitionKey.present) {
      map['partition_key'] = Variable<String>(partitionKey.value);
    }
    if (value.present) {
      map['value'] = Variable<DriftAny>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingCompanion(')
          ..write('key: $key, ')
          ..write('partitionKey: $partitionKey, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class IconCache extends Table with TableInfo<IconCache, IconCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  IconCache(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> origin = GeneratedColumn<String>(
    'origin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<i2.Uint8List> iconData =
      GeneratedColumn<i2.Uint8List>(
        'icon_data',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  late final GeneratedColumn<DateTime> fetchDate = GeneratedColumn<DateTime>(
    'fetch_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [origin, iconData, fetchDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'icon_cache';
  @override
  Set<GeneratedColumn> get $primaryKey => {origin};
  @override
  IconCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IconCacheData(
      origin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origin'],
      )!,
      iconData: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}icon_data'],
      )!,
      fetchDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetch_date'],
      )!,
    );
  }

  @override
  IconCache createAlias(String alias) {
    return IconCache(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class IconCacheData extends DataClass implements Insertable<IconCacheData> {
  final String origin;
  final i2.Uint8List iconData;
  final DateTime fetchDate;
  const IconCacheData({
    required this.origin,
    required this.iconData,
    required this.fetchDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['origin'] = Variable<String>(origin);
    map['icon_data'] = Variable<i2.Uint8List>(iconData);
    map['fetch_date'] = Variable<DateTime>(fetchDate);
    return map;
  }

  factory IconCacheData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IconCacheData(
      origin: serializer.fromJson<String>(json['origin']),
      iconData: serializer.fromJson<i2.Uint8List>(json['iconData']),
      fetchDate: serializer.fromJson<DateTime>(json['fetchDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'origin': serializer.toJson<String>(origin),
      'iconData': serializer.toJson<i2.Uint8List>(iconData),
      'fetchDate': serializer.toJson<DateTime>(fetchDate),
    };
  }

  IconCacheData copyWith({
    String? origin,
    i2.Uint8List? iconData,
    DateTime? fetchDate,
  }) => IconCacheData(
    origin: origin ?? this.origin,
    iconData: iconData ?? this.iconData,
    fetchDate: fetchDate ?? this.fetchDate,
  );
  IconCacheData copyWithCompanion(IconCacheCompanion data) {
    return IconCacheData(
      origin: data.origin.present ? data.origin.value : this.origin,
      iconData: data.iconData.present ? data.iconData.value : this.iconData,
      fetchDate: data.fetchDate.present ? data.fetchDate.value : this.fetchDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IconCacheData(')
          ..write('origin: $origin, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(origin, $driftBlobEquality.hash(iconData), fetchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IconCacheData &&
          other.origin == this.origin &&
          $driftBlobEquality.equals(other.iconData, this.iconData) &&
          other.fetchDate == this.fetchDate);
}

class IconCacheCompanion extends UpdateCompanion<IconCacheData> {
  final Value<String> origin;
  final Value<i2.Uint8List> iconData;
  final Value<DateTime> fetchDate;
  final Value<int> rowid;
  const IconCacheCompanion({
    this.origin = const Value.absent(),
    this.iconData = const Value.absent(),
    this.fetchDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IconCacheCompanion.insert({
    required String origin,
    required i2.Uint8List iconData,
    required DateTime fetchDate,
    this.rowid = const Value.absent(),
  }) : origin = Value(origin),
       iconData = Value(iconData),
       fetchDate = Value(fetchDate);
  static Insertable<IconCacheData> custom({
    Expression<String>? origin,
    Expression<i2.Uint8List>? iconData,
    Expression<DateTime>? fetchDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (origin != null) 'origin': origin,
      if (iconData != null) 'icon_data': iconData,
      if (fetchDate != null) 'fetch_date': fetchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IconCacheCompanion copyWith({
    Value<String>? origin,
    Value<i2.Uint8List>? iconData,
    Value<DateTime>? fetchDate,
    Value<int>? rowid,
  }) {
    return IconCacheCompanion(
      origin: origin ?? this.origin,
      iconData: iconData ?? this.iconData,
      fetchDate: fetchDate ?? this.fetchDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (origin.present) {
      map['origin'] = Variable<String>(origin.value);
    }
    if (iconData.present) {
      map['icon_data'] = Variable<i2.Uint8List>(iconData.value);
    }
    if (fetchDate.present) {
      map['fetch_date'] = Variable<DateTime>(fetchDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IconCacheCompanion(')
          ..write('origin: $origin, ')
          ..write('iconData: $iconData, ')
          ..write('fetchDate: $fetchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Onboarding extends Table with TableInfo<Onboarding, OnboardingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Onboarding(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<DateTime> completionDate =
      GeneratedColumn<DateTime>(
        'completion_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  @override
  List<GeneratedColumn> get $columns => [revision, completionDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'onboarding';
  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  OnboardingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OnboardingData(
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
      completionDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completion_date'],
      )!,
    );
  }

  @override
  Onboarding createAlias(String alias) {
    return Onboarding(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class OnboardingData extends DataClass implements Insertable<OnboardingData> {
  final int revision;
  final DateTime completionDate;
  const OnboardingData({required this.revision, required this.completionDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['revision'] = Variable<int>(revision);
    map['completion_date'] = Variable<DateTime>(completionDate);
    return map;
  }

  factory OnboardingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OnboardingData(
      revision: serializer.fromJson<int>(json['revision']),
      completionDate: serializer.fromJson<DateTime>(json['completionDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'revision': serializer.toJson<int>(revision),
      'completionDate': serializer.toJson<DateTime>(completionDate),
    };
  }

  OnboardingData copyWith({int? revision, DateTime? completionDate}) =>
      OnboardingData(
        revision: revision ?? this.revision,
        completionDate: completionDate ?? this.completionDate,
      );
  OnboardingData copyWithCompanion(OnboardingCompanion data) {
    return OnboardingData(
      revision: data.revision.present ? data.revision.value : this.revision,
      completionDate: data.completionDate.present
          ? data.completionDate.value
          : this.completionDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingData(')
          ..write('revision: $revision, ')
          ..write('completionDate: $completionDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(revision, completionDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OnboardingData &&
          other.revision == this.revision &&
          other.completionDate == this.completionDate);
}

class OnboardingCompanion extends UpdateCompanion<OnboardingData> {
  final Value<int> revision;
  final Value<DateTime> completionDate;
  final Value<int> rowid;
  const OnboardingCompanion({
    this.revision = const Value.absent(),
    this.completionDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OnboardingCompanion.insert({
    required int revision,
    required DateTime completionDate,
    this.rowid = const Value.absent(),
  }) : revision = Value(revision),
       completionDate = Value(completionDate);
  static Insertable<OnboardingData> custom({
    Expression<int>? revision,
    Expression<DateTime>? completionDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (revision != null) 'revision': revision,
      if (completionDate != null) 'completion_date': completionDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OnboardingCompanion copyWith({
    Value<int>? revision,
    Value<DateTime>? completionDate,
    Value<int>? rowid,
  }) {
    return OnboardingCompanion(
      revision: revision ?? this.revision,
      completionDate: completionDate ?? this.completionDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (completionDate.present) {
      map['completion_date'] = Variable<DateTime>(completionDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OnboardingCompanion(')
          ..write('revision: $revision, ')
          ..write('completionDate: $completionDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class DatabaseAtV1 extends GeneratedDatabase {
  DatabaseAtV1(QueryExecutor e) : super(e);
  late final Setting setting = Setting(this);
  late final IconCache iconCache = IconCache(this);
  late final Onboarding onboarding = Onboarding(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    setting,
    iconCache,
    onboarding,
  ];
  @override
  int get schemaVersion => 1;
}
