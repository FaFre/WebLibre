// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visit_container_recorder.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Records the visit→container relation. Mozilla Places owns the visit itself;
/// on each Places visit the tab's native history delegate forwards the id of the
/// session that produced it, which this service maps to that tab's WebLibre
/// container and persists as a `visit_container` row (keyed on the visit's
/// canonical URL + time so the history UI can join it back to Places).
///
/// Graceful absence: a visit from a tab with no container — or from one WebLibre
/// holds no row for even after [VisitContainerRecorder._resolveAttempts], e.g. a
/// custom tab — writes no row and simply appears untagged. Activated eagerly at
/// startup.

@ProviderFor(VisitContainerRecorder)
final visitContainerRecorderProvider = VisitContainerRecorderProvider._();

/// Records the visit→container relation. Mozilla Places owns the visit itself;
/// on each Places visit the tab's native history delegate forwards the id of the
/// session that produced it, which this service maps to that tab's WebLibre
/// container and persists as a `visit_container` row (keyed on the visit's
/// canonical URL + time so the history UI can join it back to Places).
///
/// Graceful absence: a visit from a tab with no container — or from one WebLibre
/// holds no row for even after [VisitContainerRecorder._resolveAttempts], e.g. a
/// custom tab — writes no row and simply appears untagged. Activated eagerly at
/// startup.
final class VisitContainerRecorderProvider
    extends $NotifierProvider<VisitContainerRecorder, void> {
  /// Records the visit→container relation. Mozilla Places owns the visit itself;
  /// on each Places visit the tab's native history delegate forwards the id of the
  /// session that produced it, which this service maps to that tab's WebLibre
  /// container and persists as a `visit_container` row (keyed on the visit's
  /// canonical URL + time so the history UI can join it back to Places).
  ///
  /// Graceful absence: a visit from a tab with no container — or from one WebLibre
  /// holds no row for even after [VisitContainerRecorder._resolveAttempts], e.g. a
  /// custom tab — writes no row and simply appears untagged. Activated eagerly at
  /// startup.
  VisitContainerRecorderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'visitContainerRecorderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$visitContainerRecorderHash();

  @$internal
  @override
  VisitContainerRecorder create() => VisitContainerRecorder();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$visitContainerRecorderHash() =>
    r'2d2cd20544a40e59b370f77988340f441a7ce9b4';

/// Records the visit→container relation. Mozilla Places owns the visit itself;
/// on each Places visit the tab's native history delegate forwards the id of the
/// session that produced it, which this service maps to that tab's WebLibre
/// container and persists as a `visit_container` row (keyed on the visit's
/// canonical URL + time so the history UI can join it back to Places).
///
/// Graceful absence: a visit from a tab with no container — or from one WebLibre
/// holds no row for even after [VisitContainerRecorder._resolveAttempts], e.g. a
/// custom tab — writes no row and simply appears untagged. Activated eagerly at
/// startup.

abstract class _$VisitContainerRecorder extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
