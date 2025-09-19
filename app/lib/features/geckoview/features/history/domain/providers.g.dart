// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$browsingHistoryHash() => r'6447fd4d8209c3befb07f2d82fa41a24bd3accb1';

/// See also [browsingHistory].
@ProviderFor(browsingHistory)
final browsingHistoryProvider =
    AutoDisposeFutureProvider<List<VisitInfo>>.internal(
      browsingHistory,
      name: r'browsingHistoryProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$browsingHistoryHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BrowsingHistoryRef = AutoDisposeFutureProviderRef<List<VisitInfo>>;
String _$historyFilterHash() => r'68a604fe857476f7c15be89352a7b10bc456c3d6';

/// See also [HistoryFilter].
@ProviderFor(HistoryFilter)
final historyFilterProvider =
    NotifierProvider<HistoryFilter, HistoryFilterOptions>.internal(
      HistoryFilter.new,
      name: r'historyFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$historyFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$HistoryFilter = Notifier<HistoryFilterOptions>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
