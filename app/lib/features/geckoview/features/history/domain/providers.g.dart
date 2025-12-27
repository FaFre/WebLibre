// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(HistoryFilter)
@JsonPersist()
const historyFilterProvider = HistoryFilterProvider._();

@JsonPersist()
final class HistoryFilterProvider
    extends $NotifierProvider<HistoryFilter, HistoryFilterOptions> {
  const HistoryFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyFilterHash();

  @$internal
  @override
  HistoryFilter create() => HistoryFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HistoryFilterOptions value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HistoryFilterOptions>(value),
    );
  }
}

String _$historyFilterHash() => r'685b92590011ec450ef0c19820e4a6750d26b79d';

@JsonPersist()
abstract class _$HistoryFilterBase extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(browsingHistory)
const browsingHistoryProvider = BrowsingHistoryProvider._();

final class BrowsingHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<VisitInfo>>,
          List<VisitInfo>,
          FutureOr<List<VisitInfo>>
        >
    with $FutureModifier<List<VisitInfo>>, $FutureProvider<List<VisitInfo>> {
  const BrowsingHistoryProvider._()
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

String _$browsingHistoryHash() => r'3b6ee5853387481d7544bc9733741a5519f84f40';

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$HistoryFilter extends _$HistoryFilterBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "HistoryFilter";
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
