// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_list_ui_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BookmarkListUiStateNotifier)
final bookmarkListUiStateProvider = BookmarkListUiStateNotifierProvider._();

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
    r'7c764fc2f1deb178063ca95764775ca237471f9f';

abstract class _$BookmarkListUiStateNotifier
    extends $Notifier<BookmarkListUiState> {
  BookmarkListUiState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<BookmarkListUiState, BookmarkListUiState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BookmarkListUiState, BookmarkListUiState>,
              BookmarkListUiState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
