// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class ChatData extends Table with TableInfo<ChatData, ChatDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatData(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumnWithTypeConverter<ChatMetadata, String> metadata =
      GeneratedColumn<String>(
        'metadata',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      ).withConverter<ChatMetadata>(ChatData.$convertermetadata);
  @override
  List<GeneratedColumn> get $columns => [chatId, metadata];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_data';
  @override
  Set<GeneratedColumn> get $primaryKey => {chatId};
  @override
  ChatDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatDataData(
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      metadata: ChatData.$convertermetadata.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}metadata'],
        )!,
      ),
    );
  }

  @override
  ChatData createAlias(String alias) {
    return ChatData(attachedDatabase, alias);
  }

  static TypeConverter<ChatMetadata, String> $convertermetadata =
      const ChatMetadataConverter();
  @override
  bool get dontWriteConstraints => true;
}

class ChatDataData extends DataClass implements Insertable<ChatDataData> {
  final String chatId;
  final ChatMetadata metadata;
  const ChatDataData({required this.chatId, required this.metadata});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chat_id'] = Variable<String>(chatId);
    {
      map['metadata'] = Variable<String>(
        ChatData.$convertermetadata.toSql(metadata),
      );
    }
    return map;
  }

  factory ChatDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatDataData(
      chatId: serializer.fromJson<String>(json['chat_id']),
      metadata: serializer.fromJson<ChatMetadata>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chat_id': serializer.toJson<String>(chatId),
      'metadata': serializer.toJson<ChatMetadata>(metadata),
    };
  }

  ChatDataData copyWith({String? chatId, ChatMetadata? metadata}) =>
      ChatDataData(
        chatId: chatId ?? this.chatId,
        metadata: metadata ?? this.metadata,
      );
  ChatDataData copyWithCompanion(ChatDataCompanion data) {
    return ChatDataData(
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatDataData(')
          ..write('chatId: $chatId, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chatId, metadata);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatDataData &&
          other.chatId == this.chatId &&
          other.metadata == this.metadata);
}

class ChatDataCompanion extends UpdateCompanion<ChatDataData> {
  final Value<String> chatId;
  final Value<ChatMetadata> metadata;
  final Value<int> rowid;
  const ChatDataCompanion({
    this.chatId = const Value.absent(),
    this.metadata = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatDataCompanion.insert({
    required String chatId,
    required ChatMetadata metadata,
    this.rowid = const Value.absent(),
  }) : chatId = Value(chatId),
       metadata = Value(metadata);
  static Insertable<ChatDataData> custom({
    Expression<String>? chatId,
    Expression<String>? metadata,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chatId != null) 'chat_id': chatId,
      if (metadata != null) 'metadata': metadata,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatDataCompanion copyWith({
    Value<String>? chatId,
    Value<ChatMetadata>? metadata,
    Value<int>? rowid,
  }) {
    return ChatDataCompanion(
      chatId: chatId ?? this.chatId,
      metadata: metadata ?? this.metadata,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(
        ChatData.$convertermetadata.toSql(metadata.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatDataCompanion(')
          ..write('chatId: $chatId, ')
          ..write('metadata: $metadata, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ChatMessage extends Table with TableInfo<ChatMessage, ChatMessageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ChatMessage(this.attachedDatabase, [this._alias]);
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'PRIMARY KEY NOT NULL',
  );
  late final GeneratedColumn<String> chatId = GeneratedColumn<String>(
    'chat_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> orderKey = GeneratedColumn<String>(
    'order_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  late final GeneratedColumn<String> messageJson = GeneratedColumn<String>(
    'message_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    messageId,
    chatId,
    orderKey,
    messageJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chat_message';
  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  ChatMessageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChatMessageData(
      messageId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_id'],
          )!,
      chatId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}chat_id'],
          )!,
      orderKey:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}order_key'],
          )!,
      messageJson:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}message_json'],
          )!,
    );
  }

  @override
  ChatMessage createAlias(String alias) {
    return ChatMessage(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ChatMessageData extends DataClass implements Insertable<ChatMessageData> {
  final String messageId;
  final String chatId;
  final String orderKey;
  final String messageJson;
  const ChatMessageData({
    required this.messageId,
    required this.chatId,
    required this.orderKey,
    required this.messageJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<String>(messageId);
    map['chat_id'] = Variable<String>(chatId);
    map['order_key'] = Variable<String>(orderKey);
    map['message_json'] = Variable<String>(messageJson);
    return map;
  }

  factory ChatMessageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChatMessageData(
      messageId: serializer.fromJson<String>(json['message_id']),
      chatId: serializer.fromJson<String>(json['chat_id']),
      orderKey: serializer.fromJson<String>(json['order_key']),
      messageJson: serializer.fromJson<String>(json['message_json']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'message_id': serializer.toJson<String>(messageId),
      'chat_id': serializer.toJson<String>(chatId),
      'order_key': serializer.toJson<String>(orderKey),
      'message_json': serializer.toJson<String>(messageJson),
    };
  }

  ChatMessageData copyWith({
    String? messageId,
    String? chatId,
    String? orderKey,
    String? messageJson,
  }) => ChatMessageData(
    messageId: messageId ?? this.messageId,
    chatId: chatId ?? this.chatId,
    orderKey: orderKey ?? this.orderKey,
    messageJson: messageJson ?? this.messageJson,
  );
  ChatMessageData copyWithCompanion(ChatMessageCompanion data) {
    return ChatMessageData(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      chatId: data.chatId.present ? data.chatId.value : this.chatId,
      orderKey: data.orderKey.present ? data.orderKey.value : this.orderKey,
      messageJson:
          data.messageJson.present ? data.messageJson.value : this.messageJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageData(')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('orderKey: $orderKey, ')
          ..write('messageJson: $messageJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(messageId, chatId, orderKey, messageJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChatMessageData &&
          other.messageId == this.messageId &&
          other.chatId == this.chatId &&
          other.orderKey == this.orderKey &&
          other.messageJson == this.messageJson);
}

class ChatMessageCompanion extends UpdateCompanion<ChatMessageData> {
  final Value<String> messageId;
  final Value<String> chatId;
  final Value<String> orderKey;
  final Value<String> messageJson;
  final Value<int> rowid;
  const ChatMessageCompanion({
    this.messageId = const Value.absent(),
    this.chatId = const Value.absent(),
    this.orderKey = const Value.absent(),
    this.messageJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChatMessageCompanion.insert({
    required String messageId,
    required String chatId,
    required String orderKey,
    required String messageJson,
    this.rowid = const Value.absent(),
  }) : messageId = Value(messageId),
       chatId = Value(chatId),
       orderKey = Value(orderKey),
       messageJson = Value(messageJson);
  static Insertable<ChatMessageData> custom({
    Expression<String>? messageId,
    Expression<String>? chatId,
    Expression<String>? orderKey,
    Expression<String>? messageJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (chatId != null) 'chat_id': chatId,
      if (orderKey != null) 'order_key': orderKey,
      if (messageJson != null) 'message_json': messageJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChatMessageCompanion copyWith({
    Value<String>? messageId,
    Value<String>? chatId,
    Value<String>? orderKey,
    Value<String>? messageJson,
    Value<int>? rowid,
  }) {
    return ChatMessageCompanion(
      messageId: messageId ?? this.messageId,
      chatId: chatId ?? this.chatId,
      orderKey: orderKey ?? this.orderKey,
      messageJson: messageJson ?? this.messageJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (chatId.present) {
      map['chat_id'] = Variable<String>(chatId.value);
    }
    if (orderKey.present) {
      map['order_key'] = Variable<String>(orderKey.value);
    }
    if (messageJson.present) {
      map['message_json'] = Variable<String>(messageJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChatMessageCompanion(')
          ..write('messageId: $messageId, ')
          ..write('chatId: $chatId, ')
          ..write('orderKey: $orderKey, ')
          ..write('messageJson: $messageJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ChatDatabase extends GeneratedDatabase {
  _$ChatDatabase(QueryExecutor e) : super(e);
  $ChatDatabaseManager get managers => $ChatDatabaseManager(this);
  late final ChatData chatData = ChatData(this);
  late final ChatMessage chatMessage = ChatMessage(this);
  late final Index groupOrderIdx = Index(
    'group_order_idx',
    'CREATE UNIQUE INDEX group_order_idx ON chat_message (chat_id, order_key)',
  );
  late final MessagesDao messagesDao = MessagesDao(this as ChatDatabase);
  late final MetadataDao metadataDao = MetadataDao(this as ChatDatabase);
  Selectable<String> leadingOrderKey({
    required int bucket,
    required String chatId,
  }) {
    return customSelect(
      'SELECT lexo_rank_previous(?1, (SELECT order_key FROM chat_message WHERE chat_id = ?2 ORDER BY order_key LIMIT 1)) AS _c0',
      variables: [Variable<int>(bucket), Variable<String>(chatId)],
      readsFrom: {chatMessage},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> trailingOrderKey({
    required int bucket,
    required String chatId,
  }) {
    return customSelect(
      'SELECT lexo_rank_next(?1, (SELECT order_key FROM chat_message WHERE chat_id = ?2 ORDER BY order_key DESC LIMIT 1)) AS _c0',
      variables: [Variable<int>(bucket), Variable<String>(chatId)],
      readsFrom: {chatMessage},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<String> orderKeyBeforeIndex({
    required String chatId,
    required int rowIdx,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT message_id, order_key, LEAD(order_key)OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS next_order_key, ROW_NUMBER()OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS row_idx, COUNT(*)OVER (RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS total_rows FROM chat_message WHERE chat_id = ?1) SELECT lexo_rank_reorder_after(order_key, next_order_key) AS _c0 FROM ordered_table WHERE row_idx = MIN(?2, total_rows)',
      variables: [Variable<String>(chatId), Variable<int>(rowIdx)],
      readsFrom: {chatMessage},
    ).map((QueryRow row) => row.read<String>('_c0'));
  }

  Selectable<int> messageIndex({
    required String chatId,
    required String messageId,
  }) {
    return customSelect(
      'WITH ordered_table AS (SELECT message_id, ROW_NUMBER()OVER (ORDER BY order_key RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW EXCLUDE NO OTHERS) AS row_idx FROM chat_message WHERE chat_id = ?1) SELECT row_idx FROM ordered_table WHERE message_id = ?2',
      variables: [Variable<String>(chatId), Variable<String>(messageId)],
      readsFrom: {chatMessage},
    ).map((QueryRow row) => row.read<int>('row_idx'));
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    chatData,
    chatMessage,
    groupOrderIdx,
  ];
}

typedef $ChatDataCreateCompanionBuilder =
    ChatDataCompanion Function({
      required String chatId,
      required ChatMetadata metadata,
      Value<int> rowid,
    });
typedef $ChatDataUpdateCompanionBuilder =
    ChatDataCompanion Function({
      Value<String> chatId,
      Value<ChatMetadata> metadata,
      Value<int> rowid,
    });

class $ChatDataFilterComposer extends Composer<_$ChatDatabase, ChatData> {
  $ChatDataFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<ChatMetadata, ChatMetadata, String>
  get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );
}

class $ChatDataOrderingComposer extends Composer<_$ChatDatabase, ChatData> {
  $ChatDataOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ChatDataAnnotationComposer extends Composer<_$ChatDatabase, ChatData> {
  $ChatDataAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ChatMetadata, String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $ChatDataTableManager
    extends
        RootTableManager<
          _$ChatDatabase,
          ChatData,
          ChatDataData,
          $ChatDataFilterComposer,
          $ChatDataOrderingComposer,
          $ChatDataAnnotationComposer,
          $ChatDataCreateCompanionBuilder,
          $ChatDataUpdateCompanionBuilder,
          (
            ChatDataData,
            BaseReferences<_$ChatDatabase, ChatData, ChatDataData>,
          ),
          ChatDataData,
          PrefetchHooks Function()
        > {
  $ChatDataTableManager(_$ChatDatabase db, ChatData table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $ChatDataFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $ChatDataOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $ChatDataAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chatId = const Value.absent(),
                Value<ChatMetadata> metadata = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatDataCompanion(
                chatId: chatId,
                metadata: metadata,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chatId,
                required ChatMetadata metadata,
                Value<int> rowid = const Value.absent(),
              }) => ChatDataCompanion.insert(
                chatId: chatId,
                metadata: metadata,
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

typedef $ChatDataProcessedTableManager =
    ProcessedTableManager<
      _$ChatDatabase,
      ChatData,
      ChatDataData,
      $ChatDataFilterComposer,
      $ChatDataOrderingComposer,
      $ChatDataAnnotationComposer,
      $ChatDataCreateCompanionBuilder,
      $ChatDataUpdateCompanionBuilder,
      (ChatDataData, BaseReferences<_$ChatDatabase, ChatData, ChatDataData>),
      ChatDataData,
      PrefetchHooks Function()
    >;
typedef $ChatMessageCreateCompanionBuilder =
    ChatMessageCompanion Function({
      required String messageId,
      required String chatId,
      required String orderKey,
      required String messageJson,
      Value<int> rowid,
    });
typedef $ChatMessageUpdateCompanionBuilder =
    ChatMessageCompanion Function({
      Value<String> messageId,
      Value<String> chatId,
      Value<String> orderKey,
      Value<String> messageJson,
      Value<int> rowid,
    });

class $ChatMessageFilterComposer extends Composer<_$ChatDatabase, ChatMessage> {
  $ChatMessageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $ChatMessageOrderingComposer
    extends Composer<_$ChatDatabase, ChatMessage> {
  $ChatMessageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chatId => $composableBuilder(
    column: $table.chatId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderKey => $composableBuilder(
    column: $table.orderKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ChatMessageAnnotationComposer
    extends Composer<_$ChatDatabase, ChatMessage> {
  $ChatMessageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get chatId =>
      $composableBuilder(column: $table.chatId, builder: (column) => column);

  GeneratedColumn<String> get orderKey =>
      $composableBuilder(column: $table.orderKey, builder: (column) => column);

  GeneratedColumn<String> get messageJson => $composableBuilder(
    column: $table.messageJson,
    builder: (column) => column,
  );
}

class $ChatMessageTableManager
    extends
        RootTableManager<
          _$ChatDatabase,
          ChatMessage,
          ChatMessageData,
          $ChatMessageFilterComposer,
          $ChatMessageOrderingComposer,
          $ChatMessageAnnotationComposer,
          $ChatMessageCreateCompanionBuilder,
          $ChatMessageUpdateCompanionBuilder,
          (
            ChatMessageData,
            BaseReferences<_$ChatDatabase, ChatMessage, ChatMessageData>,
          ),
          ChatMessageData,
          PrefetchHooks Function()
        > {
  $ChatMessageTableManager(_$ChatDatabase db, ChatMessage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $ChatMessageFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $ChatMessageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $ChatMessageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> messageId = const Value.absent(),
                Value<String> chatId = const Value.absent(),
                Value<String> orderKey = const Value.absent(),
                Value<String> messageJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChatMessageCompanion(
                messageId: messageId,
                chatId: chatId,
                orderKey: orderKey,
                messageJson: messageJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String messageId,
                required String chatId,
                required String orderKey,
                required String messageJson,
                Value<int> rowid = const Value.absent(),
              }) => ChatMessageCompanion.insert(
                messageId: messageId,
                chatId: chatId,
                orderKey: orderKey,
                messageJson: messageJson,
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

typedef $ChatMessageProcessedTableManager =
    ProcessedTableManager<
      _$ChatDatabase,
      ChatMessage,
      ChatMessageData,
      $ChatMessageFilterComposer,
      $ChatMessageOrderingComposer,
      $ChatMessageAnnotationComposer,
      $ChatMessageCreateCompanionBuilder,
      $ChatMessageUpdateCompanionBuilder,
      (
        ChatMessageData,
        BaseReferences<_$ChatDatabase, ChatMessage, ChatMessageData>,
      ),
      ChatMessageData,
      PrefetchHooks Function()
    >;

class $ChatDatabaseManager {
  final _$ChatDatabase _db;
  $ChatDatabaseManager(this._db);
  $ChatDataTableManager get chatData =>
      $ChatDataTableManager(_db, _db.chatData);
  $ChatMessageTableManager get chatMessage =>
      $ChatMessageTableManager(_db, _db.chatMessage);
}
