// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recently_closed_tabs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The engine's recently closed list (Fenix's "Recently closed tabs"), newest
/// close first.

@ProviderFor(RecentlyClosedTabsRepository)
final recentlyClosedTabsRepositoryProvider =
    RecentlyClosedTabsRepositoryProvider._();

/// The engine's recently closed list (Fenix's "Recently closed tabs"), newest
/// close first.
final class RecentlyClosedTabsRepositoryProvider
    extends
        $AsyncNotifierProvider<
          RecentlyClosedTabsRepository,
          List<RecentlyClosedTabEntry>
        > {
  /// The engine's recently closed list (Fenix's "Recently closed tabs"), newest
  /// close first.
  RecentlyClosedTabsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentlyClosedTabsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentlyClosedTabsRepositoryHash();

  @$internal
  @override
  RecentlyClosedTabsRepository create() => RecentlyClosedTabsRepository();
}

String _$recentlyClosedTabsRepositoryHash() =>
    r'ee56694276131b70fb5be3e288bad0064f45c58e';

/// The engine's recently closed list (Fenix's "Recently closed tabs"), newest
/// close first.

abstract class _$RecentlyClosedTabsRepository
    extends $AsyncNotifier<List<RecentlyClosedTabEntry>> {
  FutureOr<List<RecentlyClosedTabEntry>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<RecentlyClosedTabEntry>>,
              List<RecentlyClosedTabEntry>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RecentlyClosedTabEntry>>,
                List<RecentlyClosedTabEntry>
              >,
              AsyncValue<List<RecentlyClosedTabEntry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
