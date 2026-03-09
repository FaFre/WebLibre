// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(topSiteDefaultSeeds)
final topSiteDefaultSeedsProvider = TopSiteDefaultSeedsProvider._();

final class TopSiteDefaultSeedsProvider
    extends
        $FunctionalProvider<
          List<({String title, Uri url})>,
          List<({String title, Uri url})>,
          List<({String title, Uri url})>
        >
    with $Provider<List<({String title, Uri url})>> {
  TopSiteDefaultSeedsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'topSiteDefaultSeedsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$topSiteDefaultSeedsHash();

  @$internal
  @override
  $ProviderElement<List<({String title, Uri url})>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<({String title, Uri url})> create(Ref ref) {
    return topSiteDefaultSeeds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<({String title, Uri url})> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<({String title, Uri url})>>(
        value,
      ),
    );
  }
}

String _$topSiteDefaultSeedsHash() =>
    r'd15156e1ebe1896a11dc2d983db9fb90a2222380';

@ProviderFor(topSiteList)
final topSiteListProvider = TopSiteListFamily._();

final class TopSiteListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TopSiteItem>>,
          List<TopSiteItem>,
          Stream<List<TopSiteItem>>
        >
    with
        $FutureModifier<List<TopSiteItem>>,
        $StreamProvider<List<TopSiteItem>> {
  TopSiteListProvider._({
    required TopSiteListFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'topSiteListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$topSiteListHash();

  @override
  String toString() {
    return r'topSiteListProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<TopSiteItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TopSiteItem>> create(Ref ref) {
    final argument = this.argument as int;
    return topSiteList(ref, limit: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is TopSiteListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$topSiteListHash() => r'c9cb226f7a4368b907b85230ef2e8a4e0c73a199';

final class TopSiteListFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<TopSiteItem>>, int> {
  TopSiteListFamily._()
    : super(
        retry: null,
        name: r'topSiteListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TopSiteListProvider call({int limit = 8}) =>
      TopSiteListProvider._(argument: limit, from: this);

  @override
  String toString() => r'topSiteListProvider';
}

@ProviderFor(persistedTopSiteList)
final persistedTopSiteListProvider = PersistedTopSiteListProvider._();

final class PersistedTopSiteListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TopSiteItem>>,
          List<TopSiteItem>,
          Stream<List<TopSiteItem>>
        >
    with
        $FutureModifier<List<TopSiteItem>>,
        $StreamProvider<List<TopSiteItem>> {
  PersistedTopSiteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'persistedTopSiteListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$persistedTopSiteListHash();

  @$internal
  @override
  $StreamProviderElement<List<TopSiteItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TopSiteItem>> create(Ref ref) {
    return persistedTopSiteList(ref);
  }
}

String _$persistedTopSiteListHash() =>
    r'f0f7f087dccc0cea8498811ea2ad2af5e6d3fbb8';
