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
    r'5f99fd1e46a8ae291b63df044fe11917cd5d415c';

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

String _$containerTopicHash() => r'c6e4cc316d3f05d0316909ec0bb58a95ad2fd57c';

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

@ProviderFor(tabsTopic)
const tabsTopicProvider = TabsTopicFamily._();

final class TabsTopicProvider
    extends
        $FunctionalProvider<
          AsyncValue<String?>,
          AsyncValue<String?>,
          AsyncValue<String?>
        >
    with $Provider<AsyncValue<String?>> {
  const TabsTopicProvider._({
    required TabsTopicFamily super.from,
    required EquatableValue<Set<String>> super.argument,
  }) : super(
         retry: null,
         name: r'tabsTopicProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabsTopicHash();

  @override
  String toString() {
    return r'tabsTopicProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<String?> create(Ref ref) {
    final argument = this.argument as EquatableValue<Set<String>>;
    return tabsTopic(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabsTopicProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabsTopicHash() => r'b144f86782510333a48e92c4a2c70ac285da6bcb';

final class TabsTopicFamily extends $Family
    with
        $FunctionalFamilyOverride<
          AsyncValue<String?>,
          EquatableValue<Set<String>>
        > {
  const TabsTopicFamily._()
    : super(
        retry: null,
        name: r'tabsTopicProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TabsTopicProvider call(EquatableValue<Set<String>> tabIds) =>
      TabsTopicProvider._(argument: tabIds, from: this);

  @override
  String toString() => r'tabsTopicProvider';
}

@ProviderFor(topicSuggestion)
const topicSuggestionProvider = TopicSuggestionFamily._();

final class TopicSuggestionProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  const TopicSuggestionProvider._({
    required TopicSuggestionFamily super.from,
    required EquatableValue<Set<String>> super.argument,
  }) : super(
         retry: null,
         name: r'topicSuggestionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topicSuggestionHash();

  @override
  String toString() {
    return r'topicSuggestionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    final argument = this.argument as EquatableValue<Set<String>>;
    return topicSuggestion(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopicSuggestionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topicSuggestionHash() => r'5401b1cd91e53be6ad1b4c7a39a5253d380e05d4';

final class TopicSuggestionFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<String?>,
          EquatableValue<Set<String>>
        > {
  const TopicSuggestionFamily._()
    : super(
        retry: null,
        name: r'topicSuggestionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopicSuggestionProvider call(EquatableValue<Set<String>> titles) =>
      TopicSuggestionProvider._(argument: titles, from: this);

  @override
  String toString() => r'topicSuggestionProvider';
}

@ProviderFor(suggestClusters)
const suggestClustersProvider = SuggestClustersProvider._();

final class SuggestClustersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SuggestedContainer>?>,
          List<SuggestedContainer>?,
          FutureOr<List<SuggestedContainer>?>
        >
    with
        $FutureModifier<List<SuggestedContainer>?>,
        $FutureProvider<List<SuggestedContainer>?> {
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
  $FutureProviderElement<List<SuggestedContainer>?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SuggestedContainer>?> create(Ref ref) {
    return suggestClusters(ref);
  }
}

String _$suggestClustersHash() => r'694b401ddd6ce68084f79883e67fda4b44607ef0';

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
    r'9e7e9b9d245959fcf8c87cb8822313ded801ebc0';

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
