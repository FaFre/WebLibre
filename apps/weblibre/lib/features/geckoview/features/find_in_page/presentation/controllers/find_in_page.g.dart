// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindInPageController)
final findInPageControllerProvider = FindInPageControllerFamily._();

final class FindInPageControllerProvider
    extends $NotifierProvider<FindInPageController, FindInPageState> {
  FindInPageControllerProvider._({
    required FindInPageControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'findInPageControllerProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findInPageControllerHash();

  @override
  String toString() {
    return r'findInPageControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindInPageController create() => FindInPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindInPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindInPageState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findInPageControllerHash() =>
    r'd2b90ef0c6096e04ad4067f48fb5e5170268446b';

final class FindInPageControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindInPageController,
          FindInPageState,
          FindInPageState,
          FindInPageState,
          String
        > {
  FindInPageControllerFamily._()
    : super(
        retry: null,
        name: r'findInPageControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FindInPageControllerProvider call(String tabId) =>
      FindInPageControllerProvider._(argument: tabId, from: this);

  @override
  String toString() => r'findInPageControllerProvider';
}

abstract class _$FindInPageController extends $Notifier<FindInPageState> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  FindInPageState build(String tabId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<FindInPageState, FindInPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FindInPageState, FindInPageState>,
              FindInPageState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Whether find in page shows for [tabId]; never without a tab.

@ProviderFor(findInPageVisible)
final findInPageVisibleProvider = FindInPageVisibleFamily._();

/// Whether find in page shows for [tabId]; never without a tab.

final class FindInPageVisibleProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether find in page shows for [tabId]; never without a tab.
  FindInPageVisibleProvider._({
    required FindInPageVisibleFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'findInPageVisibleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findInPageVisibleHash();

  @override
  String toString() {
    return r'findInPageVisibleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String?;
    return findInPageVisible(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageVisibleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findInPageVisibleHash() => r'5b574d7a195125886535c92460a84caeed11f693';

/// Whether find in page shows for [tabId]; never without a tab.

final class FindInPageVisibleFamily extends $Family
    with $FunctionalFamilyOverride<bool, String?> {
  FindInPageVisibleFamily._()
    : super(
        retry: null,
        name: r'findInPageVisibleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether find in page shows for [tabId]; never without a tab.

  FindInPageVisibleProvider call(String? tabId) =>
      FindInPageVisibleProvider._(argument: tabId, from: this);

  @override
  String toString() => r'findInPageVisibleProvider';
}
