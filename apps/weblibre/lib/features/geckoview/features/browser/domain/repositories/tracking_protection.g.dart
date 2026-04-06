// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_protection.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Repository for managing per-site Enhanced Tracking Protection exceptions
///
/// Wraps the GeckoTrackingProtectionApi and handles state invalidation
/// automatically after mutations.

@ProviderFor(TrackingProtectionRepository)
final trackingProtectionRepositoryProvider =
    TrackingProtectionRepositoryProvider._();

/// Repository for managing per-site Enhanced Tracking Protection exceptions
///
/// Wraps the GeckoTrackingProtectionApi and handles state invalidation
/// automatically after mutations.
final class TrackingProtectionRepositoryProvider
    extends
        $AsyncNotifierProvider<
          TrackingProtectionRepository,
          List<TrackingProtectionException>
        > {
  /// Repository for managing per-site Enhanced Tracking Protection exceptions
  ///
  /// Wraps the GeckoTrackingProtectionApi and handles state invalidation
  /// automatically after mutations.
  TrackingProtectionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackingProtectionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackingProtectionRepositoryHash();

  @$internal
  @override
  TrackingProtectionRepository create() => TrackingProtectionRepository();
}

String _$trackingProtectionRepositoryHash() =>
    r'f4b09ed513da6bd5a9f4d01833a2dbba990f59de';

/// Repository for managing per-site Enhanced Tracking Protection exceptions
///
/// Wraps the GeckoTrackingProtectionApi and handles state invalidation
/// automatically after mutations.

abstract class _$TrackingProtectionRepository
    extends $AsyncNotifier<List<TrackingProtectionException>> {
  FutureOr<List<TrackingProtectionException>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<TrackingProtectionException>>,
              List<TrackingProtectionException>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TrackingProtectionException>>,
                List<TrackingProtectionException>
              >,
              AsyncValue<List<TrackingProtectionException>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
