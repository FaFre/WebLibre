// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_list_ui_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarkListUiStateNotifier)
@JsonPersist()
final bookmarkListUiStateProvider = BookmarkListUiStateNotifierProvider._();

@JsonPersist()
final class BookmarkListUiStateNotifierProvider
    extends
        $NotifierProvider<BookmarkListUiStateNotifier, BookmarkListUiState> {
  BookmarkListUiStateNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookmarkListUiStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookmarkListUiStateNotifierHash();

  @$internal
  @override
  BookmarkListUiStateNotifier create() => BookmarkListUiStateNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BookmarkListUiState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BookmarkListUiState>(value),
    );
  }
}

String _$bookmarkListUiStateNotifierHash() =>
    r'13f01daba9d1591c700e956428f0e0e8cb2bfe92';

@JsonPersist()
abstract class _$BookmarkListUiStateNotifierBase
    extends $Notifier<BookmarkListUiState> {
  BookmarkListUiState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BookmarkListUiState, BookmarkListUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookmarkListUiState, BookmarkListUiState>,
              BookmarkListUiState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$BookmarkListUiStateNotifier
    extends _$BookmarkListUiStateNotifierBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "BookmarkListUiStateNotifier";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(BookmarkListUiState state)? encode,
    BookmarkListUiState Function(String encoded)? decode,
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
            return BookmarkListUiState.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
