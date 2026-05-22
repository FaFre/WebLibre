// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_credits_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchCreditsRepository)
final searchCreditsRepositoryProvider = SearchCreditsRepositoryProvider._();

final class SearchCreditsRepositoryProvider
    extends
        $AsyncNotifierProvider<SearchCreditsRepository, SearchCreditsStatus> {
  SearchCreditsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchCreditsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchCreditsRepositoryHash();

  @$internal
  @override
  SearchCreditsRepository create() => SearchCreditsRepository();
}

String _$searchCreditsRepositoryHash() =>
    r'e351ac000fa2da31e513f5a9817ac81897199df5';

abstract class _$SearchCreditsRepository
    extends $AsyncNotifier<SearchCreditsStatus> {
  FutureOr<SearchCreditsStatus> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SearchCreditsStatus>, SearchCreditsStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchCreditsStatus>, SearchCreditsStatus>,
              AsyncValue<SearchCreditsStatus>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
