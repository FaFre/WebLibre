// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_view_native_sync.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The native split view host, registered for its events once.

@ProviderFor(splitViewService)
final splitViewServiceProvider = SplitViewServiceProvider._();

/// The native split view host, registered for its events once.

final class SplitViewServiceProvider
    extends
        $FunctionalProvider<
          GeckoSplitViewService,
          GeckoSplitViewService,
          GeckoSplitViewService
        >
    with $Provider<GeckoSplitViewService> {
  /// The native split view host, registered for its events once.
  SplitViewServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitViewServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitViewServiceHash();

  @$internal
  @override
  $ProviderElement<GeckoSplitViewService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeckoSplitViewService create(Ref ref) {
    return splitViewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeckoSplitViewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeckoSplitViewService>(value),
    );
  }
}

String _$splitViewServiceHash() => r'b5a4a98cb51345d9a722f9332e9cde496fc9b216';

/// Keeps native's split mirror equal to the Dart state.
///
/// Watches the pair, the content size, the keyboard, the members' identity
/// colors, the theme and the labels, and pushes a [SplitViewState] whenever the
/// value changes (by value; never per frame). Pushes are serialized and the
/// latest value wins.
///
/// Ordering across restarts: every instance picks its own epoch, and its
/// revisions count from one within it. Native accepts any new epoch, so a
/// restarted Dart half takes over with its first push.

@ProviderFor(SplitViewNativeSync)
final splitViewNativeSyncProvider = SplitViewNativeSyncProvider._();

/// Keeps native's split mirror equal to the Dart state.
///
/// Watches the pair, the content size, the keyboard, the members' identity
/// colors, the theme and the labels, and pushes a [SplitViewState] whenever the
/// value changes (by value; never per frame). Pushes are serialized and the
/// latest value wins.
///
/// Ordering across restarts: every instance picks its own epoch, and its
/// revisions count from one within it. Native accepts any new epoch, so a
/// restarted Dart half takes over with its first push.
final class SplitViewNativeSyncProvider
    extends $NotifierProvider<SplitViewNativeSync, SplitViewState> {
  /// Keeps native's split mirror equal to the Dart state.
  ///
  /// Watches the pair, the content size, the keyboard, the members' identity
  /// colors, the theme and the labels, and pushes a [SplitViewState] whenever the
  /// value changes (by value; never per frame). Pushes are serialized and the
  /// latest value wins.
  ///
  /// Ordering across restarts: every instance picks its own epoch, and its
  /// revisions count from one within it. Native accepts any new epoch, so a
  /// restarted Dart half takes over with its first push.
  SplitViewNativeSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitViewNativeSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitViewNativeSyncHash();

  @$internal
  @override
  SplitViewNativeSync create() => SplitViewNativeSync();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitViewState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitViewState>(value),
    );
  }
}

String _$splitViewNativeSyncHash() =>
    r'298a57ccf8267255f7ed138bb00c759dcb7b26aa';

/// Keeps native's split mirror equal to the Dart state.
///
/// Watches the pair, the content size, the keyboard, the members' identity
/// colors, the theme and the labels, and pushes a [SplitViewState] whenever the
/// value changes (by value; never per frame). Pushes are serialized and the
/// latest value wins.
///
/// Ordering across restarts: every instance picks its own epoch, and its
/// revisions count from one within it. Native accepts any new epoch, so a
/// restarted Dart half takes over with its first push.

abstract class _$SplitViewNativeSync extends $Notifier<SplitViewState> {
  SplitViewState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SplitViewState, SplitViewState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplitViewState, SplitViewState>,
              SplitViewState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
