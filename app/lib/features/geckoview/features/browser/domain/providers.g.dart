// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedBangDataHash() => r'd43e679c40d35c4f4c692ee286dc21789d7287dd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [selectedBangData].
@ProviderFor(selectedBangData)
const selectedBangDataProvider = SelectedBangDataFamily();

/// See also [selectedBangData].
class SelectedBangDataFamily extends Family<AsyncValue<BangData?>> {
  /// See also [selectedBangData].
  const SelectedBangDataFamily();

  /// See also [selectedBangData].
  SelectedBangDataProvider call({
    String? domain,
  }) {
    return SelectedBangDataProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangDataProvider getProviderOverride(
    covariant SelectedBangDataProvider provider,
  ) {
    return call(
      domain: provider.domain,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedBangDataProvider';
}

/// See also [selectedBangData].
class SelectedBangDataProvider extends AutoDisposeStreamProvider<BangData?> {
  /// See also [selectedBangData].
  SelectedBangDataProvider({
    String? domain,
  }) : this._internal(
          (ref) => selectedBangData(
            ref as SelectedBangDataRef,
            domain: domain,
          ),
          from: selectedBangDataProvider,
          name: r'selectedBangDataProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangDataHash,
          dependencies: SelectedBangDataFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangDataFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangDataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  Override overrideWith(
    Stream<BangData?> Function(SelectedBangDataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangDataProvider._internal(
        (ref) => create(ref as SelectedBangDataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<BangData?> createElement() {
    return _SelectedBangDataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangDataProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedBangDataRef on AutoDisposeStreamProviderRef<BangData?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangDataProviderElement
    extends AutoDisposeStreamProviderElement<BangData?>
    with SelectedBangDataRef {
  _SelectedBangDataProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangDataProvider).domain;
}

String _$availableTabIdsHash() => r'646d42c747d815496849c7342903caf48258a8ab';

/// See also [availableTabIds].
@ProviderFor(availableTabIds)
const availableTabIdsProvider = AvailableTabIdsFamily();

/// See also [availableTabIds].
class AvailableTabIdsFamily extends Family<List<String>> {
  /// See also [availableTabIds].
  const AvailableTabIdsFamily();

  /// See also [availableTabIds].
  AvailableTabIdsProvider call(
    String? containerId,
  ) {
    return AvailableTabIdsProvider(
      containerId,
    );
  }

  @override
  AvailableTabIdsProvider getProviderOverride(
    covariant AvailableTabIdsProvider provider,
  ) {
    return call(
      provider.containerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'availableTabIdsProvider';
}

/// See also [availableTabIds].
class AvailableTabIdsProvider extends AutoDisposeProvider<List<String>> {
  /// See also [availableTabIds].
  AvailableTabIdsProvider(
    String? containerId,
  ) : this._internal(
          (ref) => availableTabIds(
            ref as AvailableTabIdsRef,
            containerId,
          ),
          from: availableTabIdsProvider,
          name: r'availableTabIdsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$availableTabIdsHash,
          dependencies: AvailableTabIdsFamily._dependencies,
          allTransitiveDependencies:
              AvailableTabIdsFamily._allTransitiveDependencies,
          containerId: containerId,
        );

  AvailableTabIdsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String? containerId;

  @override
  Override overrideWith(
    List<String> Function(AvailableTabIdsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AvailableTabIdsProvider._internal(
        (ref) => create(ref as AvailableTabIdsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<String>> createElement() {
    return _AvailableTabIdsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AvailableTabIdsProvider && other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AvailableTabIdsRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `containerId` of this provider.
  String? get containerId;
}

class _AvailableTabIdsProviderElement
    extends AutoDisposeProviderElement<List<String>> with AvailableTabIdsRef {
  _AvailableTabIdsProviderElement(super.provider);

  @override
  String? get containerId => (origin as AvailableTabIdsProvider).containerId;
}

String _$seamlessFilteredTabsHash() =>
    r'1abfb0e9ae834cdde5ab64b6174f24f45f36a272';

/// See also [seamlessFilteredTabs].
@ProviderFor(seamlessFilteredTabs)
const seamlessFilteredTabsProvider = SeamlessFilteredTabsFamily();

/// See also [seamlessFilteredTabs].
class SeamlessFilteredTabsFamily extends Family<List<String>> {
  /// See also [seamlessFilteredTabs].
  const SeamlessFilteredTabsFamily();

  /// See also [seamlessFilteredTabs].
  SeamlessFilteredTabsProvider call(
    String? containerId,
  ) {
    return SeamlessFilteredTabsProvider(
      containerId,
    );
  }

  @override
  SeamlessFilteredTabsProvider getProviderOverride(
    covariant SeamlessFilteredTabsProvider provider,
  ) {
    return call(
      provider.containerId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'seamlessFilteredTabsProvider';
}

/// See also [seamlessFilteredTabs].
class SeamlessFilteredTabsProvider extends AutoDisposeProvider<List<String>> {
  /// See also [seamlessFilteredTabs].
  SeamlessFilteredTabsProvider(
    String? containerId,
  ) : this._internal(
          (ref) => seamlessFilteredTabs(
            ref as SeamlessFilteredTabsRef,
            containerId,
          ),
          from: seamlessFilteredTabsProvider,
          name: r'seamlessFilteredTabsProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$seamlessFilteredTabsHash,
          dependencies: SeamlessFilteredTabsFamily._dependencies,
          allTransitiveDependencies:
              SeamlessFilteredTabsFamily._allTransitiveDependencies,
          containerId: containerId,
        );

  SeamlessFilteredTabsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.containerId,
  }) : super.internal();

  final String? containerId;

  @override
  Override overrideWith(
    List<String> Function(SeamlessFilteredTabsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SeamlessFilteredTabsProvider._internal(
        (ref) => create(ref as SeamlessFilteredTabsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        containerId: containerId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<String>> createElement() {
    return _SeamlessFilteredTabsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SeamlessFilteredTabsProvider &&
        other.containerId == containerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, containerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SeamlessFilteredTabsRef on AutoDisposeProviderRef<List<String>> {
  /// The parameter `containerId` of this provider.
  String? get containerId;
}

class _SeamlessFilteredTabsProviderElement
    extends AutoDisposeProviderElement<List<String>>
    with SeamlessFilteredTabsRef {
  _SeamlessFilteredTabsProviderElement(super.provider);

  @override
  String? get containerId =>
      (origin as SeamlessFilteredTabsProvider).containerId;
}

String _$selectedBangTriggerHash() =>
    r'b0e12bc95e93d50d04f1c658230cea9f15ff0385';

abstract class _$SelectedBangTrigger extends BuildlessNotifier<String?> {
  late final String? domain;

  String? build({
    String? domain,
  });
}

/// See also [SelectedBangTrigger].
@ProviderFor(SelectedBangTrigger)
const selectedBangTriggerProvider = SelectedBangTriggerFamily();

/// See also [SelectedBangTrigger].
class SelectedBangTriggerFamily extends Family<String?> {
  /// See also [SelectedBangTrigger].
  const SelectedBangTriggerFamily();

  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider call({
    String? domain,
  }) {
    return SelectedBangTriggerProvider(
      domain: domain,
    );
  }

  @override
  SelectedBangTriggerProvider getProviderOverride(
    covariant SelectedBangTriggerProvider provider,
  ) {
    return call(
      domain: provider.domain,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'selectedBangTriggerProvider';
}

/// See also [SelectedBangTrigger].
class SelectedBangTriggerProvider
    extends NotifierProviderImpl<SelectedBangTrigger, String?> {
  /// See also [SelectedBangTrigger].
  SelectedBangTriggerProvider({
    String? domain,
  }) : this._internal(
          () => SelectedBangTrigger()..domain = domain,
          from: selectedBangTriggerProvider,
          name: r'selectedBangTriggerProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$selectedBangTriggerHash,
          dependencies: SelectedBangTriggerFamily._dependencies,
          allTransitiveDependencies:
              SelectedBangTriggerFamily._allTransitiveDependencies,
          domain: domain,
        );

  SelectedBangTriggerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.domain,
  }) : super.internal();

  final String? domain;

  @override
  String? runNotifierBuild(
    covariant SelectedBangTrigger notifier,
  ) {
    return notifier.build(
      domain: domain,
    );
  }

  @override
  Override overrideWith(SelectedBangTrigger Function() create) {
    return ProviderOverride(
      origin: this,
      override: SelectedBangTriggerProvider._internal(
        () => create()..domain = domain,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        domain: domain,
      ),
    );
  }

  @override
  NotifierProviderElement<SelectedBangTrigger, String?> createElement() {
    return _SelectedBangTriggerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SelectedBangTriggerProvider && other.domain == domain;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, domain.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SelectedBangTriggerRef on NotifierProviderRef<String?> {
  /// The parameter `domain` of this provider.
  String? get domain;
}

class _SelectedBangTriggerProviderElement
    extends NotifierProviderElement<SelectedBangTrigger, String?>
    with SelectedBangTriggerRef {
  _SelectedBangTriggerProviderElement(super.provider);

  @override
  String? get domain => (origin as SelectedBangTriggerProvider).domain;
}

String _$lastUsedAssistantModeHash() =>
    r'1255a2754a3ea5ea058d110fd9743897fe103a69';

/// See also [LastUsedAssistantMode].
@ProviderFor(LastUsedAssistantMode)
final lastUsedAssistantModeProvider =
    NotifierProvider<LastUsedAssistantMode, AssistantMode>.internal(
  LastUsedAssistantMode.new,
  name: r'lastUsedAssistantModeProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$lastUsedAssistantModeHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LastUsedAssistantMode = Notifier<AssistantMode>;
String _$activeResearchVariantHash() =>
    r'8c65a3f5ead6cc4f9e2af85b607b7a49b0764ee3';

/// See also [ActiveResearchVariant].
@ProviderFor(ActiveResearchVariant)
final activeResearchVariantProvider =
    NotifierProvider<ActiveResearchVariant, ResearchVariant>.internal(
  ActiveResearchVariant.new,
  name: r'activeResearchVariantProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeResearchVariantHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveResearchVariant = Notifier<ResearchVariant>;
String _$activeChatModelHash() => r'675f406af8b4aa92699d59e37b5805a81d03a799';

/// See also [ActiveChatModel].
@ProviderFor(ActiveChatModel)
final activeChatModelProvider =
    NotifierProvider<ActiveChatModel, ChatModel>.internal(
  ActiveChatModel.new,
  name: r'activeChatModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeChatModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveChatModel = Notifier<ChatModel>;
String _$showFindInPageHash() => r'7ee5703f7d0c7e8a8dd6b0849d7b1e0a41fe24d9';

/// See also [ShowFindInPage].
@ProviderFor(ShowFindInPage)
final showFindInPageProvider = NotifierProvider<ShowFindInPage, bool>.internal(
  ShowFindInPage.new,
  name: r'showFindInPageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$showFindInPageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShowFindInPage = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
