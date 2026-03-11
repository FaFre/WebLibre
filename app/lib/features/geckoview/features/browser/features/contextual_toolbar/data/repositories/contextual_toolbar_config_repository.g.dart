// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contextual_toolbar_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(contextualToolbarConfigRepository)
final contextualToolbarConfigRepositoryProvider =
    ContextualToolbarConfigRepositoryProvider._();

final class ContextualToolbarConfigRepositoryProvider
    extends
        $FunctionalProvider<
          ContextualToolbarConfigRepository,
          ContextualToolbarConfigRepository,
          ContextualToolbarConfigRepository
        >
    with $Provider<ContextualToolbarConfigRepository> {
  ContextualToolbarConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'contextualToolbarConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$contextualToolbarConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContextualToolbarConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContextualToolbarConfigRepository create(Ref ref) {
    return contextualToolbarConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContextualToolbarConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContextualToolbarConfigRepository>(
        value,
      ),
    );
  }
}

String _$contextualToolbarConfigRepositoryHash() =>
    r'96bb0c00019e076ef65d3e901ba850de0fccbb1b';
