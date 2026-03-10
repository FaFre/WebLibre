// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

@ProviderFor(pinnedTopSiteList)
final pinnedTopSiteListProvider = PinnedTopSiteListProvider._();

final class PinnedTopSiteListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<TopSiteItem>>,
          List<TopSiteItem>,
          Stream<List<TopSiteItem>>
        >
    with
        $FutureModifier<List<TopSiteItem>>,
        $StreamProvider<List<TopSiteItem>> {
  PinnedTopSiteListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedTopSiteListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedTopSiteListHash();

  @$internal
  @override
  $StreamProviderElement<List<TopSiteItem>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<TopSiteItem>> create(Ref ref) {
    return pinnedTopSiteList(ref);
  }
}

String _$pinnedTopSiteListHash() => r'83adb6584ef738be14a2e0b55b33986ebb4520a9';
