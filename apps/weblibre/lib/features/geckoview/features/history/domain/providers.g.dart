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
    r'c6cf13530b8e2e40eae170aaea584eb1483343e3';

@JsonPersist()
abstract class _$HistoryVisitsFilterBase
    extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
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
    r'30514069187520cf003759ba3f406a0adf9c5620';

@JsonPersist()
abstract class _$HistoryDownloadsFilterBase
    extends $Notifier<HistoryFilterOptions> {
  HistoryFilterOptions build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HistoryFilterOptions, HistoryFilterOptions>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HistoryFilterOptions, HistoryFilterOptions>,
              HistoryFilterOptions,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(browsingHistory)
final browsingHistoryProvider = BrowsingHistoryProvider._();

final class BrowsingHistoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          List<HistoryEntry>,
          FutureOr<List<HistoryEntry>>
        >
    with
        $FutureModifier<List<HistoryEntry>>,
        $FutureProvider<List<HistoryEntry>> {
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
  $FutureProviderElement<List<HistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryEntry>> create(Ref ref) {
    return browsingHistory(ref);
  }
}

String _$browsingHistoryHash() => r'6d663f4d9502c5a808fa8f0fd1cc9ff87dbd4381';

@ProviderFor(browsingDownloads)
final browsingDownloadsProvider = BrowsingDownloadsProvider._();

final class BrowsingDownloadsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          List<HistoryEntry>,
          FutureOr<List<HistoryEntry>>
        >
    with
        $FutureModifier<List<HistoryEntry>>,
        $FutureProvider<List<HistoryEntry>> {
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
  $FutureProviderElement<List<HistoryEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<HistoryEntry>> create(Ref ref) {
    return browsingDownloads(ref);
  }
}

String _$browsingDownloadsHash() => r'a526dab6915085e6fb47a33d5acc892c3f8e17b2';

/// The entries a history screen lists: [browsingDownloads] on the downloads
/// screen, [browsingHistory] otherwise. Only the one shown is queried.

@ProviderFor(historyScreenEntries)
final historyScreenEntriesProvider = HistoryScreenEntriesFamily._();

/// The entries a history screen lists: [browsingDownloads] on the downloads
/// screen, [browsingHistory] otherwise. Only the one shown is queried.

final class HistoryScreenEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<HistoryEntry>>,
          AsyncValue<List<HistoryEntry>>,
          AsyncValue<List<HistoryEntry>>
        >
    with $Provider<AsyncValue<List<HistoryEntry>>> {
  /// The entries a history screen lists: [browsingDownloads] on the downloads
  /// screen, [browsingHistory] otherwise. Only the one shown is queried.
  HistoryScreenEntriesProvider._({
    required HistoryScreenEntriesFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'historyScreenEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyScreenEntriesHash();

  @override
  String toString() {
    return r'historyScreenEntriesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AsyncValue<List<HistoryEntry>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<HistoryEntry>> create(Ref ref) {
    final argument = this.argument as bool;
    return historyScreenEntries(ref, downloads: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<HistoryEntry>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<HistoryEntry>>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryScreenEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyScreenEntriesHash() =>
    r'a72ecffb1d2cd69ee77c7195a36a112884a8b48e';

/// The entries a history screen lists: [browsingDownloads] on the downloads
/// screen, [browsingHistory] otherwise. Only the one shown is queried.

final class HistoryScreenEntriesFamily extends $Family
    with $FunctionalFamilyOverride<AsyncValue<List<HistoryEntry>>, bool> {
  HistoryScreenEntriesFamily._()
    : super(
        retry: null,
        name: r'historyScreenEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The entries a history screen lists: [browsingDownloads] on the downloads
  /// screen, [browsingHistory] otherwise. Only the one shown is queried.

  HistoryScreenEntriesProvider call({required bool downloads}) =>
      HistoryScreenEntriesProvider._(argument: downloads, from: this);

  @override
  String toString() => r'historyScreenEntriesProvider';
}

/// How many recently closed tabs the history screen offers to reopen; the
/// downloads screen offers none, and does not read them.

@ProviderFor(historyScreenRecentlyClosedCount)
final historyScreenRecentlyClosedCountProvider =
    HistoryScreenRecentlyClosedCountFamily._();

/// How many recently closed tabs the history screen offers to reopen; the
/// downloads screen offers none, and does not read them.

final class HistoryScreenRecentlyClosedCountProvider
    extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  /// How many recently closed tabs the history screen offers to reopen; the
  /// downloads screen offers none, and does not read them.
  HistoryScreenRecentlyClosedCountProvider._({
    required HistoryScreenRecentlyClosedCountFamily super.from,
    required bool super.argument,
  }) : super(
         retry: null,
         name: r'historyScreenRecentlyClosedCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$historyScreenRecentlyClosedCountHash();

  @override
  String toString() {
    return r'historyScreenRecentlyClosedCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as bool;
    return historyScreenRecentlyClosedCount(ref, downloads: argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HistoryScreenRecentlyClosedCountProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$historyScreenRecentlyClosedCountHash() =>
    r'fe1b3755a145acb2d5669ea2536a7c65757d452f';

/// How many recently closed tabs the history screen offers to reopen; the
/// downloads screen offers none, and does not read them.

final class HistoryScreenRecentlyClosedCountFamily extends $Family
    with $FunctionalFamilyOverride<int, bool> {
  HistoryScreenRecentlyClosedCountFamily._()
    : super(
        retry: null,
        name: r'historyScreenRecentlyClosedCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// How many recently closed tabs the history screen offers to reopen; the
  /// downloads screen offers none, and does not read them.

  HistoryScreenRecentlyClosedCountProvider call({required bool downloads}) =>
      HistoryScreenRecentlyClosedCountProvider._(
        argument: downloads,
        from: this,
      );

  @override
  String toString() => r'historyScreenRecentlyClosedCountProvider';
}

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
