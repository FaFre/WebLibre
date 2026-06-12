// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_tab_selection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Queues the selection of a tab that exists in the local DB but has not
/// been delivered by the native session restore yet (placeholder chips at
/// cold start). The queued tab is selected as soon as its native state
/// arrives; the queue clears itself if restore finishes without it.

@ProviderFor(PendingTabSelection)
final pendingTabSelectionProvider = PendingTabSelectionProvider._();

/// Queues the selection of a tab that exists in the local DB but has not
/// been delivered by the native session restore yet (placeholder chips at
/// cold start). The queued tab is selected as soon as its native state
/// arrives; the queue clears itself if restore finishes without it.
final class PendingTabSelectionProvider
    extends $NotifierProvider<PendingTabSelection, String?> {
  /// Queues the selection of a tab that exists in the local DB but has not
  /// been delivered by the native session restore yet (placeholder chips at
  /// cold start). The queued tab is selected as soon as its native state
  /// arrives; the queue clears itself if restore finishes without it.
  PendingTabSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingTabSelectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingTabSelectionHash();

  @$internal
  @override
  PendingTabSelection create() => PendingTabSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingTabSelectionHash() =>
    r'761d5814b40b1003b59db09a0bb7ef370530b317';

/// Queues the selection of a tab that exists in the local DB but has not
/// been delivered by the native session restore yet (placeholder chips at
/// cold start). The queued tab is selected as soon as its native state
/// arrives; the queue clears itself if restore finishes without it.

abstract class _$PendingTabSelection extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
