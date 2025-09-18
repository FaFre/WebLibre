// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$browsingHistoryHash() => r'a684c34fc370474a771c5fcc7982a200de2294e5';

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
String _$historyFilterHash() => r'271d60ce79f96ac49d450f01d21cbfdad684ce53';

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
