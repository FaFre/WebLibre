// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryVisitsFilter)
@JsonPersist()
final historyVisitsFilterProvider = HistoryVisitsFilterProvider._();

@JsonPersist()
final class HistoryVisitsFilterProvider
    extends $NotifierProvider<HistoryVisitsFilter, HistoryFilterOptions> {
  HistoryVisitsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyVisitsFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyVisitsFilterHash();

  @$internal
  @override
  HistoryVisitsFilter create() => HistoryVisitsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilterOptions>(value),
    );
  }
}

String _$historyVisitsFilterHash() =>
    r'a4bf6c41c9180166365084cb7c7981558ac7ad36';

@JsonPersist()
abstract class _$HistoryVisitsFilterBase
    extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(HistoryDownloadsFilter)
@JsonPersist()
final historyDownloadsFilterProvider = HistoryDownloadsFilterProvider._();

@JsonPersist()
final class HistoryDownloadsFilterProvider
    extends $NotifierProvider<HistoryDownloadsFilter, HistoryFilterOptions> {
  HistoryDownloadsFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyDownloadsFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyDownloadsFilterHash();

  @$internal
  @override
  HistoryDownloadsFilter create() => HistoryDownloadsFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilterOptions>(value),
    );
  }
}

String _$historyDownloadsFilterHash() =>
    r'b44de5aced7dadba361fddf69b8462ff92252a99';

@JsonPersist()
abstract class _$HistoryDownloadsFilterBase
    extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(browsingHistory)
final browsingHistoryProvider = BrowsingHistoryProvider._();

final class BrowsingHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  BrowsingHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browsingHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browsingHistoryHash();

  @$internal
  @override
  $FutureProviderElement<List<VisitInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitInfo>> create(Ref ref) {
    return browsingHistory(ref);
  }
}

String _$browsingHistoryHash() => r'6f26228da28f6f67844551bf430025b161731bb2';

@ProviderFor(browsingDownloads)
final browsingDownloadsProvider = BrowsingDownloadsProvider._();

final class BrowsingDownloadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  BrowsingDownloadsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browsingDownloadsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browsingDownloadsHash();

  @$internal
  @override
  $FutureProviderElement<List<VisitInfo>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<VisitInfo>> create(Ref ref) {
    return browsingDownloads(ref);
  }
}

String _$browsingDownloadsHash() => r'd05e3c079c6de349ff9e910ca597ad7c78f87a16';

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$HistoryVisitsFilter extends _$HistoryVisitsFilterBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "HistoryVisitsFilter";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(HistoryFilterOptions state)? encode,
    HistoryFilterOptions Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return HistoryFilterOptions.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}

abstract class _$HistoryDownloadsFilter extends _$HistoryDownloadsFilterBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "HistoryDownloadsFilter";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(HistoryFilterOptions state)? encode,
    HistoryFilterOptions Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return HistoryFilterOptions.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
