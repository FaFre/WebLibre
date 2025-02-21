// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_extensions_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$webExtensionsStateHash() =>
    r'9382461e7e72c31946a5308642baaac307977a15';

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

abstract class _$WebExtensionsState
    extends BuildlessNotifier<Map<String, WebExtensionState>> {
  late final WebExtensionActionType actionType;

  Map<String, WebExtensionState> build(
    WebExtensionActionType actionType,
  );
}

/// See also [WebExtensionsState].
@ProviderFor(WebExtensionsState)
const webExtensionsStateProvider = WebExtensionsStateFamily();

/// See also [WebExtensionsState].
class WebExtensionsStateFamily extends Family<Map<String, WebExtensionState>> {
  /// See also [WebExtensionsState].
  const WebExtensionsStateFamily();

  /// See also [WebExtensionsState].
  WebExtensionsStateProvider call(
    WebExtensionActionType actionType,
  ) {
    return WebExtensionsStateProvider(
      actionType,
    );
  }

  @override
  WebExtensionsStateProvider getProviderOverride(
    covariant WebExtensionsStateProvider provider,
  ) {
    return call(
      provider.actionType,
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
  String? get name => r'webExtensionsStateProvider';
}

/// See also [WebExtensionsState].
class WebExtensionsStateProvider extends NotifierProviderImpl<
    WebExtensionsState, Map<String, WebExtensionState>> {
  /// See also [WebExtensionsState].
  WebExtensionsStateProvider(
    WebExtensionActionType actionType,
  ) : this._internal(
          () => WebExtensionsState()..actionType = actionType,
          from: webExtensionsStateProvider,
          name: r'webExtensionsStateProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$webExtensionsStateHash,
          dependencies: WebExtensionsStateFamily._dependencies,
          allTransitiveDependencies:
              WebExtensionsStateFamily._allTransitiveDependencies,
          actionType: actionType,
        );

  WebExtensionsStateProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.actionType,
  }) : super.internal();

  final WebExtensionActionType actionType;

  @override
  Map<String, WebExtensionState> runNotifierBuild(
    covariant WebExtensionsState notifier,
  ) {
    return notifier.build(
      actionType,
    );
  }

  @override
  Override overrideWith(WebExtensionsState Function() create) {
    return ProviderOverride(
      origin: this,
      override: WebExtensionsStateProvider._internal(
        () => create()..actionType = actionType,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        actionType: actionType,
      ),
    );
  }

  @override
  NotifierProviderElement<WebExtensionsState, Map<String, WebExtensionState>>
      createElement() {
    return _WebExtensionsStateProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WebExtensionsStateProvider &&
        other.actionType == actionType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, actionType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WebExtensionsStateRef
    on NotifierProviderRef<Map<String, WebExtensionState>> {
  /// The parameter `actionType` of this provider.
  WebExtensionActionType get actionType;
}

class _WebExtensionsStateProviderElement extends NotifierProviderElement<
    WebExtensionsState,
    Map<String, WebExtensionState>> with WebExtensionsStateRef {
  _WebExtensionsStateProviderElement(super.provider);

  @override
  WebExtensionActionType get actionType =>
      (origin as WebExtensionsStateProvider).actionType;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
