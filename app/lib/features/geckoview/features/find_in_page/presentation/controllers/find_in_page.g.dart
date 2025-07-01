// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$findInPageControllerHash() =>
    r'da72e38225809af5c78a372e949a80207d7ce7c9';

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

abstract class _$FindInPageController
    extends BuildlessNotifier<FindInPageState> {
  late final String tabId;

  FindInPageState build(String tabId);
}

/// See also [FindInPageController].
@ProviderFor(FindInPageController)
const findInPageControllerProvider = FindInPageControllerFamily();

/// See also [FindInPageController].
class FindInPageControllerFamily extends Family<FindInPageState> {
  /// See also [FindInPageController].
  const FindInPageControllerFamily();

  /// See also [FindInPageController].
  FindInPageControllerProvider call(String tabId) {
    return FindInPageControllerProvider(tabId);
  }

  @override
  FindInPageControllerProvider getProviderOverride(
    covariant FindInPageControllerProvider provider,
  ) {
    return call(provider.tabId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'findInPageControllerProvider';
}

/// See also [FindInPageController].
class FindInPageControllerProvider
    extends NotifierProviderImpl<FindInPageController, FindInPageState> {
  /// See also [FindInPageController].
  FindInPageControllerProvider(String tabId)
    : this._internal(
        () => FindInPageController()..tabId = tabId,
        from: findInPageControllerProvider,
        name: r'findInPageControllerProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$findInPageControllerHash,
        dependencies: FindInPageControllerFamily._dependencies,
        allTransitiveDependencies:
            FindInPageControllerFamily._allTransitiveDependencies,
        tabId: tabId,
      );

  FindInPageControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.tabId,
  }) : super.internal();

  final String tabId;

  @override
  FindInPageState runNotifierBuild(covariant FindInPageController notifier) {
    return notifier.build(tabId);
  }

  @override
  Override overrideWith(FindInPageController Function() create) {
    return ProviderOverride(
      origin: this,
      override: FindInPageControllerProvider._internal(
        () => create()..tabId = tabId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        tabId: tabId,
      ),
    );
  }

  @override
  NotifierProviderElement<FindInPageController, FindInPageState>
  createElement() {
    return _FindInPageControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageControllerProvider && other.tabId == tabId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, tabId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FindInPageControllerRef on NotifierProviderRef<FindInPageState> {
  /// The parameter `tabId` of this provider.
  String get tabId;
}

class _FindInPageControllerProviderElement
    extends NotifierProviderElement<FindInPageController, FindInPageState>
    with FindInPageControllerRef {
  _FindInPageControllerProviderElement(super.provider);

  @override
  String get tabId => (origin as FindInPageControllerProvider).tabId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
