// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gecko_inference.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GeckoInferenceRepository)
const geckoInferenceRepositoryProvider = GeckoInferenceRepositoryProvider._();

final class GeckoInferenceRepositoryProvider
    extends $NotifierProvider<GeckoInferenceRepository, void> {
  const GeckoInferenceRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geckoInferenceRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geckoInferenceRepositoryHash();

  @$internal
  @override
  GeckoInferenceRepository create() => GeckoInferenceRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$geckoInferenceRepositoryHash() =>
    r'eb174c9f80f3537bc075ebbffcef787ec55ad217';

abstract class _$GeckoInferenceRepository extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}

@ProviderFor(containerTopic)
const containerTopicProvider = ContainerTopicFamily._();

final class ContainerTopicProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const ContainerTopicProvider._({
    required ContainerTopicFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'containerTopicProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTopicHash();

  @override
  String toString() {
    return r'containerTopicProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as String;
    return containerTopic(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTopicProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTopicHash() => r'dd2af0571a84f9cc2536af6a1079e7ee58e2a0a5';

final class ContainerTopicFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<String?>, String> {
  const ContainerTopicFamily._()
    : super(
        retry: null,
        name: r'containerTopicProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTopicProvider call(String containerId) =>
      ContainerTopicProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerTopicProvider';
}

@ProviderFor(suggestClusters)
const suggestClustersProvider = SuggestClustersProvider._();

final class SuggestClustersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<({List<String> tabIds, String? topic})>?>,
          List<({List<String> tabIds, String? topic})>?,
          FutureOr<List<({List<String> tabIds, String? topic})>?>
        >
    with
        $FutureModifier<List<({List<String> tabIds, String? topic})>?>,
        $FutureProvider<List<({List<String> tabIds, String? topic})>?> {
  const SuggestClustersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'suggestClustersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$suggestClustersHash();

  @$internal
  @override
  $FutureProviderElement<List<({List<String> tabIds, String? topic})>?>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<({List<String> tabIds, String? topic})>?> create(Ref ref) {
    return suggestClusters(ref);
  }
}

String _$suggestClustersHash() => r'592058ed092384c37a185dcd5657276a3dde5b4e';

@ProviderFor(containerTabSuggestions)
const containerTabSuggestionsProvider = ContainerTabSuggestionsFamily._();

final class ContainerTabSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>?>,
          List<String>?,
          FutureOr<List<String>?>
        >
    with $FutureModifier<List<String>?>, $FutureProvider<List<String>?> {
  const ContainerTabSuggestionsProvider._({
    required ContainerTabSuggestionsFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'containerTabSuggestionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$containerTabSuggestionsHash();

  @override
  String toString() {
    return r'containerTabSuggestionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>?> create(Ref ref) {
    final argument = this.argument as String?;
    return containerTabSuggestions(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ContainerTabSuggestionsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$containerTabSuggestionsHash() =>
    r'ab8e596f0c7e8562bf998c701145e48eb1e520d5';

final class ContainerTabSuggestionsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>?>, String?> {
  const ContainerTabSuggestionsFamily._()
    : super(
        retry: null,
        name: r'containerTabSuggestionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ContainerTabSuggestionsProvider call(String? containerId) =>
      ContainerTabSuggestionsProvider._(argument: containerId, from: this);

  @override
  String toString() => r'containerTabSuggestionsProvider';
}
