// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'action_search_sources.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The containers, profiles and feeds the Actions section matches a query
/// against.
///
/// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
/// only, so opening it starts none of these streams. Containers are left out
/// while the Containers feature is hidden.

@ProviderFor(actionSearchSources)
final actionSearchSourcesProvider = ActionSearchSourcesFamily._();

/// The containers, profiles and feeds the Actions section matches a query
/// against.
///
/// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
/// only, so opening it starts none of these streams. Containers are left out
/// while the Containers feature is hidden.

final class ActionSearchSourcesProvider
    extends
        $FunctionalProvider<
          ActionSearchSources,
          ActionSearchSources,
          ActionSearchSources
        >
    with $Provider<ActionSearchSources> {
  /// The containers, profiles and feeds the Actions section matches a query
  /// against.
  ///
  /// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
  /// only, so opening it starts none of these streams. Containers are left out
  /// while the Containers feature is hidden.
  ActionSearchSourcesProvider._({
    required ActionSearchSourcesFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'actionSearchSourcesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$actionSearchSourcesHash();

  @override
  String toString() {
    return r'actionSearchSourcesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<ActionSearchSources> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ActionSearchSources create(Ref ref) {
    final argument = this.argument as bool;
    return actionSearchSources(ref, hasQuery: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActionSearchSources value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActionSearchSources>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ActionSearchSourcesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$actionSearchSourcesHash() =>
    r'717c4043256087051828856589d39e7526a59ba0';

/// The containers, profiles and feeds the Actions section matches a query
/// against.
///
/// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
/// only, so opening it starts none of these streams. Containers are left out
/// while the Containers feature is hidden.

final class ActionSearchSourcesFamily extends $Family
    with $FunctionalFamilyOverride<ActionSearchSources, bool> {
  ActionSearchSourcesFamily._()
    : super(
        retry: null,
        name: r'actionSearchSourcesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The containers, profiles and feeds the Actions section matches a query
  /// against.
  ///
  /// Nothing is watched until [hasQuery]: the new-tab page lists browser actions
  /// only, so opening it starts none of these streams. Containers are left out
  /// while the Containers feature is hidden.

  ActionSearchSourcesProvider call({required bool hasQuery}) =>
      ActionSearchSourcesProvider._(argument: hasQuery, from: this);

  @override
  String toString() => r'actionSearchSourcesProvider';
}
