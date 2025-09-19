// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_preferenceSettingContent)
const _preferenceSettingContentProvider = _PreferenceSettingContentProvider._();

final class _PreferenceSettingContentProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, dynamic>>,
          Map<String, dynamic>,
          FutureOr<Map<String, dynamic>>
        >
    with
        $FutureModifier<Map<String, dynamic>>,
        $FutureProvider<Map<String, dynamic>> {
  const _PreferenceSettingContentProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_preferenceSettingContentProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_preferenceSettingContentHash();

  @$internal
  @override
  $FutureProviderElement<Map<String, dynamic>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, dynamic>> create(Ref ref) {
    return _preferenceSettingContent(ref);
  }
}

String _$_preferenceSettingContentHash() =>
    r'a8a61fdf8800cb7adb365c100409ddce09c574b1';

@ProviderFor(_preferenceSettingGroups)
const _preferenceSettingGroupsProvider = _PreferenceSettingGroupsFamily._();

final class _PreferenceSettingGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, PreferenceSettingGroup>>,
          Map<String, PreferenceSettingGroup>,
          FutureOr<Map<String, PreferenceSettingGroup>>
        >
    with
        $FutureModifier<Map<String, PreferenceSettingGroup>>,
        $FutureProvider<Map<String, PreferenceSettingGroup>> {
  const _PreferenceSettingGroupsProvider._({
    required _PreferenceSettingGroupsFamily super.from,
    required PreferencePartition super.argument,
  }) : super(
         retry: null,
         name: r'_preferenceSettingGroupsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_preferenceSettingGroupsHash();

  @override
  String toString() {
    return r'_preferenceSettingGroupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, PreferenceSettingGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, PreferenceSettingGroup>> create(Ref ref) {
    final argument = this.argument as PreferencePartition;
    return _preferenceSettingGroups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is _PreferenceSettingGroupsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_preferenceSettingGroupsHash() =>
    r'd267dacf82a11568c9cf0cc864f434db35f93394';

final class _PreferenceSettingGroupsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, PreferenceSettingGroup>>,
          PreferencePartition
        > {
  const _PreferenceSettingGroupsFamily._()
    : super(
        retry: null,
        name: r'_preferenceSettingGroupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  _PreferenceSettingGroupsProvider call(PreferencePartition partition) =>
      _PreferenceSettingGroupsProvider._(argument: partition, from: this);

  @override
  String toString() => r'_preferenceSettingGroupsProvider';
}

@ProviderFor(_preferenceSettingGroup)
const _preferenceSettingGroupProvider = _PreferenceSettingGroupFamily._();

final class _PreferenceSettingGroupProvider
    extends
        $FunctionalProvider<
          AsyncValue<PreferenceSettingGroup>,
          PreferenceSettingGroup,
          FutureOr<PreferenceSettingGroup>
        >
    with
        $FutureModifier<PreferenceSettingGroup>,
        $FutureProvider<PreferenceSettingGroup> {
  const _PreferenceSettingGroupProvider._({
    required _PreferenceSettingGroupFamily super.from,
    required (PreferencePartition, String) super.argument,
  }) : super(
         retry: null,
         name: r'_preferenceSettingGroupProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$_preferenceSettingGroupHash();

  @override
  String toString() {
    return r'_preferenceSettingGroupProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PreferenceSettingGroup> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PreferenceSettingGroup> create(Ref ref) {
    final argument = this.argument as (PreferencePartition, String);
    return _preferenceSettingGroup(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is _PreferenceSettingGroupProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$_preferenceSettingGroupHash() =>
    r'64d80a37928d7e5aea7d3d567dde8ade7292cd5f';

final class _PreferenceSettingGroupFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PreferenceSettingGroup>,
          (PreferencePartition, String)
        > {
  const _PreferenceSettingGroupFamily._()
    : super(
        retry: null,
        name: r'_preferenceSettingGroupProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  _PreferenceSettingGroupProvider call(
    PreferencePartition partition,
    String groupName,
  ) => _PreferenceSettingGroupProvider._(
    argument: (partition, groupName),
    from: this,
  );

  @override
  String toString() => r'_preferenceSettingGroupProvider';
}

@ProviderFor(_PreferenceRepository)
const _preferenceRepositoryProvider = _PreferenceRepositoryProvider._();

final class _PreferenceRepositoryProvider
    extends
        $NotifierProvider<
          _PreferenceRepository,
          Raw<Stream<Map<String, Object>>>
        > {
  const _PreferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_preferenceRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_preferenceRepositoryHash();

  @$internal
  @override
  _PreferenceRepository create() => _PreferenceRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<Map<String, Object>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<Map<String, Object>>>>(
        value,
      ),
    );
  }
}

String _$_preferenceRepositoryHash() =>
    r'b2b7f75b3d30842b3006bb18af89f7ff90ba4ce7';

abstract class _$PreferenceRepository
    extends $Notifier<Raw<Stream<Map<String, Object>>>> {
  Raw<Stream<Map<String, Object>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Raw<Stream<Map<String, Object>>>,
              Raw<Stream<Map<String, Object>>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Raw<Stream<Map<String, Object>>>,
                Raw<Stream<Map<String, Object>>>
              >,
              Raw<Stream<Map<String, Object>>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(UnifiedPreferenceSettingsRepository)
const unifiedPreferenceSettingsRepositoryProvider =
    UnifiedPreferenceSettingsRepositoryFamily._();

final class UnifiedPreferenceSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<
          UnifiedPreferenceSettingsRepository,
          Map<String, PreferenceSettingGroup>
        > {
  const UnifiedPreferenceSettingsRepositoryProvider._({
    required UnifiedPreferenceSettingsRepositoryFamily super.from,
    required PreferencePartition super.argument,
  }) : super(
         retry: null,
         name: r'unifiedPreferenceSettingsRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$unifiedPreferenceSettingsRepositoryHash();

  @override
  String toString() {
    return r'unifiedPreferenceSettingsRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  UnifiedPreferenceSettingsRepository create() =>
      UnifiedPreferenceSettingsRepository();

  @override
  bool operator ==(Object other) {
    return other is UnifiedPreferenceSettingsRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$unifiedPreferenceSettingsRepositoryHash() =>
    r'35aa16ffa7aa1453c8331ed7470ef85a68d27178';

final class UnifiedPreferenceSettingsRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          UnifiedPreferenceSettingsRepository,
          AsyncValue<Map<String, PreferenceSettingGroup>>,
          Map<String, PreferenceSettingGroup>,
          Stream<Map<String, PreferenceSettingGroup>>,
          PreferencePartition
        > {
  const UnifiedPreferenceSettingsRepositoryFamily._()
    : super(
        retry: null,
        name: r'unifiedPreferenceSettingsRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  UnifiedPreferenceSettingsRepositoryProvider call(
    PreferencePartition partition,
  ) => UnifiedPreferenceSettingsRepositoryProvider._(
    argument: partition,
    from: this,
  );

  @override
  String toString() => r'unifiedPreferenceSettingsRepositoryProvider';
}

abstract class _$UnifiedPreferenceSettingsRepository
    extends $StreamNotifier<Map<String, PreferenceSettingGroup>> {
  late final _$args = ref.$arg as PreferencePartition;
  PreferencePartition get partition => _$args;

  Stream<Map<String, PreferenceSettingGroup>> build(
    PreferencePartition partition,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, PreferenceSettingGroup>>,
              Map<String, PreferenceSettingGroup>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, PreferenceSettingGroup>>,
                Map<String, PreferenceSettingGroup>
              >,
              AsyncValue<Map<String, PreferenceSettingGroup>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PreferenceSettingsGroupRepository)
const preferenceSettingsGroupRepositoryProvider =
    PreferenceSettingsGroupRepositoryFamily._();

final class PreferenceSettingsGroupRepositoryProvider
    extends
        $StreamNotifierProvider<
          PreferenceSettingsGroupRepository,
          PreferenceSettingGroup
        > {
  const PreferenceSettingsGroupRepositoryProvider._({
    required PreferenceSettingsGroupRepositoryFamily super.from,
    required (PreferencePartition, String) super.argument,
  }) : super(
         retry: null,
         name: r'preferenceSettingsGroupRepositoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$preferenceSettingsGroupRepositoryHash();

  @override
  String toString() {
    return r'preferenceSettingsGroupRepositoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  PreferenceSettingsGroupRepository create() =>
      PreferenceSettingsGroupRepository();

  @override
  bool operator ==(Object other) {
    return other is PreferenceSettingsGroupRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$preferenceSettingsGroupRepositoryHash() =>
    r'60f416ffe1cde4d535fb5b643a80aead20836bae';

final class PreferenceSettingsGroupRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          PreferenceSettingsGroupRepository,
          AsyncValue<PreferenceSettingGroup>,
          PreferenceSettingGroup,
          Stream<PreferenceSettingGroup>,
          (PreferencePartition, String)
        > {
  const PreferenceSettingsGroupRepositoryFamily._()
    : super(
        retry: null,
        name: r'preferenceSettingsGroupRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PreferenceSettingsGroupRepositoryProvider call(
    PreferencePartition partition,
    String groupName,
  ) => PreferenceSettingsGroupRepositoryProvider._(
    argument: (partition, groupName),
    from: this,
  );

  @override
  String toString() => r'preferenceSettingsGroupRepositoryProvider';
}

abstract class _$PreferenceSettingsGroupRepository
    extends $StreamNotifier<PreferenceSettingGroup> {
  late final _$args = ref.$arg as (PreferencePartition, String);
  PreferencePartition get partition => _$args.$1;
  String get groupName => _$args.$2;

  Stream<PreferenceSettingGroup> build(
    PreferencePartition partition,
    String groupName,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args.$1, _$args.$2);
    final ref =
        this.ref
            as $Ref<AsyncValue<PreferenceSettingGroup>, PreferenceSettingGroup>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PreferenceSettingGroup>,
                PreferenceSettingGroup
              >,
              AsyncValue<PreferenceSettingGroup>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
