// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(_preferenceSettingContent)
final _preferenceSettingContentProvider = _PreferenceSettingContentProvider._();

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
  _PreferenceSettingContentProvider._()
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
final _preferenceSettingGroupsProvider = _PreferenceSettingGroupsFamily._();

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
  _PreferenceSettingGroupsProvider._({
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
  _PreferenceSettingGroupsFamily._()
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
final _preferenceSettingGroupProvider = _PreferenceSettingGroupFamily._();

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
  _PreferenceSettingGroupProvider._({
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
    r'df85cf2207411a89b4c379e24989857f81d04011';

final class _PreferenceSettingGroupFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PreferenceSettingGroup>,
          (PreferencePartition, String)
        > {
  _PreferenceSettingGroupFamily._()
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
final _preferenceRepositoryProvider = _PreferenceRepositoryProvider._();

final class _PreferenceRepositoryProvider
    extends
        $NotifierProvider<
          _PreferenceRepository,
          Raw<Stream<Map<String, GeckoPref>>>
        > {
  _PreferenceRepositoryProvider._()
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
  Override overrideWithValue(Raw<Stream<Map<String, GeckoPref>>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<Stream<Map<String, GeckoPref>>>>(
        value,
      ),
    );
  }
}

String _$_preferenceRepositoryHash() =>
    r'0f6812988a23407f6648e32fb1585984d2433bbc';

abstract class _$PreferenceRepository
    extends $Notifier<Raw<Stream<Map<String, GeckoPref>>>> {
  Raw<Stream<Map<String, GeckoPref>>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Raw<Stream<Map<String, GeckoPref>>>,
              Raw<Stream<Map<String, GeckoPref>>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Raw<Stream<Map<String, GeckoPref>>>,
                Raw<Stream<Map<String, GeckoPref>>>
              >,
              Raw<Stream<Map<String, GeckoPref>>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(UnifiedPreferenceSettingsRepository)
final unifiedPreferenceSettingsRepositoryProvider =
    UnifiedPreferenceSettingsRepositoryFamily._();

final class UnifiedPreferenceSettingsRepositoryProvider
    extends
        $StreamNotifierProvider<
          UnifiedPreferenceSettingsRepository,
          Map<String, PreferenceSettingGroup>
        > {
  UnifiedPreferenceSettingsRepositoryProvider._({
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
    r'800e74a051113b4ebc3631b6ade55d66cb7e1af1';

final class UnifiedPreferenceSettingsRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          UnifiedPreferenceSettingsRepository,
          AsyncValue<Map<String, PreferenceSettingGroup>>,
          Map<String, PreferenceSettingGroup>,
          Stream<Map<String, PreferenceSettingGroup>>,
          PreferencePartition
        > {
  UnifiedPreferenceSettingsRepositoryFamily._()
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
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(PreferenceSettingsGroupRepository)
final preferenceSettingsGroupRepositoryProvider =
    PreferenceSettingsGroupRepositoryFamily._();

final class PreferenceSettingsGroupRepositoryProvider
    extends
        $StreamNotifierProvider<
          PreferenceSettingsGroupRepository,
          PreferenceSettingGroup
        > {
  PreferenceSettingsGroupRepositoryProvider._({
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
    r'8e025cdea5cef8a6ea029db6f9ebcd86abf906d8';

final class PreferenceSettingsGroupRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          PreferenceSettingsGroupRepository,
          AsyncValue<PreferenceSettingGroup>,
          PreferenceSettingGroup,
          Stream<PreferenceSettingGroup>,
          (PreferencePartition, String)
        > {
  PreferenceSettingsGroupRepositoryFamily._()
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
    element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}
