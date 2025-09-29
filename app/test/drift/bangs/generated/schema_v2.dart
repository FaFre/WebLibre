// dart format width=80
// GENERATED CODE, DO NOT EDIT BY HAND.
// ignore_for_file: type=lint
import 'package:drift/drift.dart';

class Bang extends Table with TableInfo<Bang, BangData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Bang(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> group = GeneratedColumn<int>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
    'website_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
    'url_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
    'sub_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
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
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger, group};
  @override
  BangData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangData(
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group'],
      )!,
      websiteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      urlTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_template'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
    );
  }

  @override
  Bang createAlias(String alias) {
    return Bang(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("trigger", "group")',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangData extends DataClass implements Insertable<BangData> {
  final String trigger;
  final int group;
  final String websiteName;
  final String domain;
  final String urlTemplate;
  final String? category;
  final String? subCategory;
  final String? format;
  const BangData({
    required this.trigger,
    required this.group,
    required this.websiteName,
    required this.domain,
    required this.urlTemplate,
    this.category,
    this.subCategory,
    this.format,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['group'] = Variable<int>(group);
    map['website_name'] = Variable<String>(websiteName);
    map['domain'] = Variable<String>(domain);
    map['url_template'] = Variable<String>(urlTemplate);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || subCategory != null) {
      map['sub_category'] = Variable<String>(subCategory);
    }
    if (!nullToAbsent || format != null) {
      map['format'] = Variable<String>(format);
    }
    return map;
  }

  factory BangData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangData(
      trigger: serializer.fromJson<String>(json['trigger']),
      group: serializer.fromJson<int>(json['group']),
      websiteName: serializer.fromJson<String>(json['websiteName']),
      domain: serializer.fromJson<String>(json['domain']),
      urlTemplate: serializer.fromJson<String>(json['urlTemplate']),
      category: serializer.fromJson<String?>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      format: serializer.fromJson<String?>(json['format']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(group),
      'websiteName': serializer.toJson<String>(websiteName),
      'domain': serializer.toJson<String>(domain),
      'urlTemplate': serializer.toJson<String>(urlTemplate),
      'category': serializer.toJson<String?>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'format': serializer.toJson<String?>(format),
    };
  }

  BangData copyWith({
    String? trigger,
    int? group,
    String? websiteName,
    String? domain,
    String? urlTemplate,
    Value<String?> category = const Value.absent(),
    Value<String?> subCategory = const Value.absent(),
    Value<String?> format = const Value.absent(),
  }) => BangData(
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    websiteName: websiteName ?? this.websiteName,
    domain: domain ?? this.domain,
    urlTemplate: urlTemplate ?? this.urlTemplate,
    category: category.present ? category.value : this.category,
    subCategory: subCategory.present ? subCategory.value : this.subCategory,
    format: format.present ? format.value : this.format,
  );
  BangData copyWithCompanion(BangCompanion data) {
    return BangData(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      group: data.group.present ? data.group.value : this.group,
      websiteName: data.websiteName.present
          ? data.websiteName.value
          : this.websiteName,
      domain: data.domain.present ? data.domain.value : this.domain,
      urlTemplate: data.urlTemplate.present
          ? data.urlTemplate.value
          : this.urlTemplate,
      category: data.category.present ? data.category.value : this.category,
      subCategory: data.subCategory.present
          ? data.subCategory.value
          : this.subCategory,
      format: data.format.present ? data.format.value : this.format,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangData(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('websiteName: $websiteName, ')
          ..write('domain: $domain, ')
          ..write('urlTemplate: $urlTemplate, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('format: $format')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trigger,
    group,
    websiteName,
    domain,
    urlTemplate,
    category,
    subCategory,
    format,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangData &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.websiteName == this.websiteName &&
          other.domain == this.domain &&
          other.urlTemplate == this.urlTemplate &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.format == this.format);
}

class BangCompanion extends UpdateCompanion<BangData> {
  final Value<String> trigger;
  final Value<int> group;
  final Value<String> websiteName;
  final Value<String> domain;
  final Value<String> urlTemplate;
  final Value<String?> category;
  final Value<String?> subCategory;
  final Value<String?> format;
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
    required int group,
    required String websiteName,
    required String domain,
    required String urlTemplate,
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.format = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : trigger = Value(trigger),
       group = Value(group),
       websiteName = Value(websiteName),
       domain = Value(domain),
       urlTemplate = Value(urlTemplate);
  static Insertable<BangData> custom({
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

  BangCompanion copyWith({
    Value<String>? trigger,
    Value<int>? group,
    Value<String>? websiteName,
    Value<String>? domain,
    Value<String>? urlTemplate,
    Value<String?>? category,
    Value<String?>? subCategory,
    Value<String?>? format,
    Value<int>? rowid,
  }) {
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
      map['group'] = Variable<int>(group.value);
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
      map['format'] = Variable<String>(format.value);
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
  late final GeneratedColumn<int> group = GeneratedColumn<int>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<DateTime> lastSync = GeneratedColumn<DateTime>(
    'last_sync',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
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
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group'],
      )!,
      lastSync: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync'],
      )!,
    );
  }

  @override
  BangSync createAlias(String alias) {
    return BangSync(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class BangSyncData extends DataClass implements Insertable<BangSyncData> {
  final int group;
  final DateTime lastSync;
  const BangSyncData({required this.group, required this.lastSync});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group'] = Variable<int>(group);
    map['last_sync'] = Variable<DateTime>(lastSync);
    return map;
  }

  factory BangSyncData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangSyncData(
      group: serializer.fromJson<int>(json['group']),
      lastSync: serializer.fromJson<DateTime>(json['lastSync']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'group': serializer.toJson<int>(group),
      'lastSync': serializer.toJson<DateTime>(lastSync),
    };
  }

  BangSyncData copyWith({int? group, DateTime? lastSync}) => BangSyncData(
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
  final Value<int> group;
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

  BangSyncCompanion copyWith({Value<int>? group, Value<DateTime>? lastSync}) {
    return BangSyncCompanion(
      group: group ?? this.group,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (group.present) {
      map['group'] = Variable<int>(group.value);
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
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> group = GeneratedColumn<int>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
    'last_used',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [trigger, group, frequency, lastUsed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bang_frequency';
  @override
  Set<GeneratedColumn> get $primaryKey => {trigger, group};
  @override
  BangFrequencyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFrequencyData(
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      )!,
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      )!,
    );
  }

  @override
  BangFrequency createAlias(String alias) {
    return BangFrequency(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'PRIMARY KEY("trigger", "group")',
    'FOREIGN KEY("trigger", "group")REFERENCES bang("trigger", "group")ON DELETE CASCADE',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangFrequencyData extends DataClass
    implements Insertable<BangFrequencyData> {
  final String trigger;
  final int group;
  final int frequency;
  final DateTime lastUsed;
  const BangFrequencyData({
    required this.trigger,
    required this.group,
    required this.frequency,
    required this.lastUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['group'] = Variable<int>(group);
    map['frequency'] = Variable<int>(frequency);
    map['last_used'] = Variable<DateTime>(lastUsed);
    return map;
  }

  factory BangFrequencyData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFrequencyData(
      trigger: serializer.fromJson<String>(json['trigger']),
      group: serializer.fromJson<int>(json['group']),
      frequency: serializer.fromJson<int>(json['frequency']),
      lastUsed: serializer.fromJson<DateTime>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(group),
      'frequency': serializer.toJson<int>(frequency),
      'lastUsed': serializer.toJson<DateTime>(lastUsed),
    };
  }

  BangFrequencyData copyWith({
    String? trigger,
    int? group,
    int? frequency,
    DateTime? lastUsed,
  }) => BangFrequencyData(
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    frequency: frequency ?? this.frequency,
    lastUsed: lastUsed ?? this.lastUsed,
  );
  BangFrequencyData copyWithCompanion(BangFrequencyCompanion data) {
    return BangFrequencyData(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      group: data.group.present ? data.group.value : this.group,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFrequencyData(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trigger, group, frequency, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangFrequencyData &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.frequency == this.frequency &&
          other.lastUsed == this.lastUsed);
}

class BangFrequencyCompanion extends UpdateCompanion<BangFrequencyData> {
  final Value<String> trigger;
  final Value<int> group;
  final Value<int> frequency;
  final Value<DateTime> lastUsed;
  final Value<int> rowid;
  const BangFrequencyCompanion({
    this.trigger = const Value.absent(),
    this.group = const Value.absent(),
    this.frequency = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangFrequencyCompanion.insert({
    required String trigger,
    required int group,
    required int frequency,
    required DateTime lastUsed,
    this.rowid = const Value.absent(),
  }) : trigger = Value(trigger),
       group = Value(group),
       frequency = Value(frequency),
       lastUsed = Value(lastUsed);
  static Insertable<BangFrequencyData> custom({
    Expression<String>? trigger,
    Expression<int>? group,
    Expression<int>? frequency,
    Expression<DateTime>? lastUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (frequency != null) 'frequency': frequency,
      if (lastUsed != null) 'last_used': lastUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangFrequencyCompanion copyWith({
    Value<String>? trigger,
    Value<int>? group,
    Value<int>? frequency,
    Value<DateTime>? lastUsed,
    Value<int>? rowid,
  }) {
    return BangFrequencyCompanion(
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
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
    if (group.present) {
      map['group'] = Variable<int>(group.value);
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
          ..write('group: $group, ')
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
    'search_query',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
  );
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<int> group = GeneratedColumn<int>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<DateTime> searchDate = GeneratedColumn<DateTime>(
    'search_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    searchQuery,
    trigger,
    group,
    searchDate,
  ];
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
      searchQuery: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}search_query'],
      )!,
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group'],
      )!,
      searchDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}search_date'],
      )!,
    );
  }

  @override
  BangHistory createAlias(String alias) {
    return BangHistory(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const [
    'FOREIGN KEY("trigger", "group")REFERENCES bang("trigger", "group")',
  ];
  @override
  bool get dontWriteConstraints => true;
}

class BangHistoryData extends DataClass implements Insertable<BangHistoryData> {
  final String searchQuery;
  final String trigger;
  final int group;
  final DateTime searchDate;
  const BangHistoryData({
    required this.searchQuery,
    required this.trigger,
    required this.group,
    required this.searchDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['search_query'] = Variable<String>(searchQuery);
    map['trigger'] = Variable<String>(trigger);
    map['group'] = Variable<int>(group);
    map['search_date'] = Variable<DateTime>(searchDate);
    return map;
  }

  factory BangHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangHistoryData(
      searchQuery: serializer.fromJson<String>(json['searchQuery']),
      trigger: serializer.fromJson<String>(json['trigger']),
      group: serializer.fromJson<int>(json['group']),
      searchDate: serializer.fromJson<DateTime>(json['searchDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'searchQuery': serializer.toJson<String>(searchQuery),
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(group),
      'searchDate': serializer.toJson<DateTime>(searchDate),
    };
  }

  BangHistoryData copyWith({
    String? searchQuery,
    String? trigger,
    int? group,
    DateTime? searchDate,
  }) => BangHistoryData(
    searchQuery: searchQuery ?? this.searchQuery,
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    searchDate: searchDate ?? this.searchDate,
  );
  BangHistoryData copyWithCompanion(BangHistoryCompanion data) {
    return BangHistoryData(
      searchQuery: data.searchQuery.present
          ? data.searchQuery.value
          : this.searchQuery,
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      group: data.group.present ? data.group.value : this.group,
      searchDate: data.searchDate.present
          ? data.searchDate.value
          : this.searchDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangHistoryData(')
          ..write('searchQuery: $searchQuery, ')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('searchDate: $searchDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(searchQuery, trigger, group, searchDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangHistoryData &&
          other.searchQuery == this.searchQuery &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.searchDate == this.searchDate);
}

class BangHistoryCompanion extends UpdateCompanion<BangHistoryData> {
  final Value<String> searchQuery;
  final Value<String> trigger;
  final Value<int> group;
  final Value<DateTime> searchDate;
  final Value<int> rowid;
  const BangHistoryCompanion({
    this.searchQuery = const Value.absent(),
    this.trigger = const Value.absent(),
    this.group = const Value.absent(),
    this.searchDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BangHistoryCompanion.insert({
    required String searchQuery,
    required String trigger,
    required int group,
    required DateTime searchDate,
    this.rowid = const Value.absent(),
  }) : searchQuery = Value(searchQuery),
       trigger = Value(trigger),
       group = Value(group),
       searchDate = Value(searchDate);
  static Insertable<BangHistoryData> custom({
    Expression<String>? searchQuery,
    Expression<String>? trigger,
    Expression<int>? group,
    Expression<DateTime>? searchDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (searchQuery != null) 'search_query': searchQuery,
      if (trigger != null) 'trigger': trigger,
      if (group != null) 'group': group,
      if (searchDate != null) 'search_date': searchDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BangHistoryCompanion copyWith({
    Value<String>? searchQuery,
    Value<String>? trigger,
    Value<int>? group,
    Value<DateTime>? searchDate,
    Value<int>? rowid,
  }) {
    return BangHistoryCompanion(
      searchQuery: searchQuery ?? this.searchQuery,
      trigger: trigger ?? this.trigger,
      group: group ?? this.group,
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
    if (group.present) {
      map['group'] = Variable<int>(group.value);
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
          ..write('group: $group, ')
          ..write('searchDate: $searchDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BangFts extends Table
    with
        TableInfo<BangFts, BangFtsData>,
        VirtualTableInfo<BangFts, BangFtsData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BangFts(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
    'website_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
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
  BangFtsData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangFtsData(
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      websiteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
    );
  }

  @override
  BangFts createAlias(String alias) {
    return BangFts(attachedDatabase, alias);
  }

  @override
  String get moduleAndArgs =>
      'fts5(trigger, website_name, content=bang, prefix=\'2 3\')';
}

class BangFtsData extends DataClass implements Insertable<BangFtsData> {
  final String trigger;
  final String websiteName;
  const BangFtsData({required this.trigger, required this.websiteName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['trigger'] = Variable<String>(trigger);
    map['website_name'] = Variable<String>(websiteName);
    return map;
  }

  factory BangFtsData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangFtsData(
      trigger: serializer.fromJson<String>(json['trigger']),
      websiteName: serializer.fromJson<String>(json['websiteName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'websiteName': serializer.toJson<String>(websiteName),
    };
  }

  BangFtsData copyWith({String? trigger, String? websiteName}) => BangFtsData(
    trigger: trigger ?? this.trigger,
    websiteName: websiteName ?? this.websiteName,
  );
  BangFtsData copyWithCompanion(BangFtsCompanion data) {
    return BangFtsData(
      trigger: data.trigger.present ? data.trigger.value : this.trigger,
      websiteName: data.websiteName.present
          ? data.websiteName.value
          : this.websiteName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BangFtsData(')
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
      (other is BangFtsData &&
          other.trigger == this.trigger &&
          other.websiteName == this.websiteName);
}

class BangFtsCompanion extends UpdateCompanion<BangFtsData> {
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
  }) : trigger = Value(trigger),
       websiteName = Value(websiteName);
  static Insertable<BangFtsData> custom({
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

  BangFtsCompanion copyWith({
    Value<String>? trigger,
    Value<String>? websiteName,
    Value<int>? rowid,
  }) {
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

class BangDataViewData extends DataClass {
  final String trigger;
  final int group;
  final String websiteName;
  final String domain;
  final String urlTemplate;
  final String? category;
  final String? subCategory;
  final String? format;
  final int? frequency;
  final DateTime? lastUsed;
  const BangDataViewData({
    required this.trigger,
    required this.group,
    required this.websiteName,
    required this.domain,
    required this.urlTemplate,
    this.category,
    this.subCategory,
    this.format,
    this.frequency,
    this.lastUsed,
  });
  factory BangDataViewData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BangDataViewData(
      trigger: serializer.fromJson<String>(json['trigger']),
      group: serializer.fromJson<int>(json['group']),
      websiteName: serializer.fromJson<String>(json['websiteName']),
      domain: serializer.fromJson<String>(json['domain']),
      urlTemplate: serializer.fromJson<String>(json['urlTemplate']),
      category: serializer.fromJson<String?>(json['category']),
      subCategory: serializer.fromJson<String?>(json['subCategory']),
      format: serializer.fromJson<String?>(json['format']),
      frequency: serializer.fromJson<int?>(json['frequency']),
      lastUsed: serializer.fromJson<DateTime?>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trigger': serializer.toJson<String>(trigger),
      'group': serializer.toJson<int>(group),
      'websiteName': serializer.toJson<String>(websiteName),
      'domain': serializer.toJson<String>(domain),
      'urlTemplate': serializer.toJson<String>(urlTemplate),
      'category': serializer.toJson<String?>(category),
      'subCategory': serializer.toJson<String?>(subCategory),
      'format': serializer.toJson<String?>(format),
      'frequency': serializer.toJson<int?>(frequency),
      'lastUsed': serializer.toJson<DateTime?>(lastUsed),
    };
  }

  BangDataViewData copyWith({
    String? trigger,
    int? group,
    String? websiteName,
    String? domain,
    String? urlTemplate,
    Value<String?> category = const Value.absent(),
    Value<String?> subCategory = const Value.absent(),
    Value<String?> format = const Value.absent(),
    Value<int?> frequency = const Value.absent(),
    Value<DateTime?> lastUsed = const Value.absent(),
  }) => BangDataViewData(
    trigger: trigger ?? this.trigger,
    group: group ?? this.group,
    websiteName: websiteName ?? this.websiteName,
    domain: domain ?? this.domain,
    urlTemplate: urlTemplate ?? this.urlTemplate,
    category: category.present ? category.value : this.category,
    subCategory: subCategory.present ? subCategory.value : this.subCategory,
    format: format.present ? format.value : this.format,
    frequency: frequency.present ? frequency.value : this.frequency,
    lastUsed: lastUsed.present ? lastUsed.value : this.lastUsed,
  );
  @override
  String toString() {
    return (StringBuffer('BangDataViewData(')
          ..write('trigger: $trigger, ')
          ..write('group: $group, ')
          ..write('websiteName: $websiteName, ')
          ..write('domain: $domain, ')
          ..write('urlTemplate: $urlTemplate, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('format: $format, ')
          ..write('frequency: $frequency, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trigger,
    group,
    websiteName,
    domain,
    urlTemplate,
    category,
    subCategory,
    format,
    frequency,
    lastUsed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BangDataViewData &&
          other.trigger == this.trigger &&
          other.group == this.group &&
          other.websiteName == this.websiteName &&
          other.domain == this.domain &&
          other.urlTemplate == this.urlTemplate &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.format == this.format &&
          other.frequency == this.frequency &&
          other.lastUsed == this.lastUsed);
}

class BangDataView extends ViewInfo<BangDataView, BangDataViewData>
    implements HasResultSet {
  final String? _alias;
  @override
  final DatabaseAtV2 attachedDatabase;
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
    lastUsed,
  ];
  @override
  String get aliasedName => _alias ?? entityName;
  @override
  String get entityName => 'bang_data_view';
  @override
  Map<SqlDialect, String> get createViewStatements => {
    SqlDialect.sqlite:
        'CREATE VIEW bang_data_view AS SELECT b.*, bf.frequency, bf.last_used FROM bang AS b LEFT JOIN bang_frequency AS bf ON b."trigger" = bf."trigger" AND b."group" = bf."group";',
  };
  @override
  BangDataView get asDslTable => this;
  @override
  BangDataViewData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BangDataViewData(
      trigger: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger'],
      )!,
      group: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}group'],
      )!,
      websiteName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_name'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      urlTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}url_template'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      subCategory: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sub_category'],
      ),
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      ),
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}frequency'],
      ),
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      ),
    );
  }

  late final GeneratedColumn<String> trigger = GeneratedColumn<String>(
    'trigger',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<int> group = GeneratedColumn<int>(
    'group',
    aliasedName,
    false,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<String> websiteName = GeneratedColumn<String>(
    'website_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> urlTemplate = GeneratedColumn<String>(
    'url_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
    'sub_category',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    true,
    type: DriftSqlType.string,
  );
  late final GeneratedColumn<int> frequency = GeneratedColumn<int>(
    'frequency',
    aliasedName,
    true,
    type: DriftSqlType.int,
  );
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
    'last_used',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
  );
  @override
  BangDataView createAlias(String alias) {
    return BangDataView(attachedDatabase, alias);
  }

  @override
  Query? get query => null;
  @override
  Set<String> get readTables => const {};
}

class DatabaseAtV2 extends GeneratedDatabase {
  DatabaseAtV2(QueryExecutor e) : super(e);
  late final Bang bang = Bang(this);
  late final BangSync bangSync = BangSync(this);
  late final BangFrequency bangFrequency = BangFrequency(this);
  late final BangHistory bangHistory = BangHistory(this);
  late final BangFts bangFts = BangFts(this);
  late final BangDataView bangDataView = BangDataView(this);
  late final Trigger bangAfterInsert = Trigger(
    'CREATE TRIGGER bang_after_insert AFTER INSERT ON bang BEGIN INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
    'bang_after_insert',
  );
  late final Trigger bangAfterDelete = Trigger(
    'CREATE TRIGGER bang_after_delete AFTER DELETE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);END',
    'bang_after_delete',
  );
  late final Trigger bangAfterUpdate = Trigger(
    'CREATE TRIGGER bang_after_update AFTER UPDATE ON bang BEGIN INSERT INTO bang_fts (bang_fts, "rowid", "trigger", website_name) VALUES (\'delete\', old."rowid", old."trigger", old.website_name);INSERT INTO bang_fts ("rowid", "trigger", website_name) VALUES (new."rowid", new."trigger", new.website_name);END',
    'bang_after_update',
  );
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
    bangAfterUpdate,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'bang',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
  ]);
  @override
  int get schemaVersion => 2;
}
