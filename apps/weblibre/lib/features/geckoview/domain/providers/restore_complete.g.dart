// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restore_complete.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mirrors the native `BrowserState.restoreComplete` flag: false until the
/// session restore has dispatched all persisted tabs into the BrowserStore.
/// While false, DB-cached tabs without a native state are rendered as
/// placeholders and the destructive tab DB sync is deferred.

@ProviderFor(BrowserRestoreComplete)
final browserRestoreCompleteProvider = BrowserRestoreCompleteProvider._();

/// Mirrors the native `BrowserState.restoreComplete` flag: false until the
/// session restore has dispatched all persisted tabs into the BrowserStore.
/// While false, DB-cached tabs without a native state are rendered as
/// placeholders and the destructive tab DB sync is deferred.
final class BrowserRestoreCompleteProvider
    extends $NotifierProvider<BrowserRestoreComplete, bool> {
  /// Mirrors the native `BrowserState.restoreComplete` flag: false until the
  /// session restore has dispatched all persisted tabs into the BrowserStore.
  /// While false, DB-cached tabs without a native state are rendered as
  /// placeholders and the destructive tab DB sync is deferred.
  BrowserRestoreCompleteProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserRestoreCompleteProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserRestoreCompleteHash();

  @$internal
  @override
  BrowserRestoreComplete create() => BrowserRestoreComplete();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$browserRestoreCompleteHash() =>
    r'971ce7722781b3cb581cfa9ada0884e91f723b85';

/// Mirrors the native `BrowserState.restoreComplete` flag: false until the
/// session restore has dispatched all persisted tabs into the BrowserStore.
/// While false, DB-cached tabs without a native state are rendered as
/// placeholders and the destructive tab DB sync is deferred.

abstract class _$BrowserRestoreComplete extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
