// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blocked_trackers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The trackers blocked on the page in [tabId] so far.
///
/// There is no event per blocked tracker to follow, so the log is read again
/// whenever the page changes or starts or finishes loading — the points where
/// it can have grown.

@ProviderFor(pageTrackers)
final pageTrackersProvider = PageTrackersFamily._();

/// The trackers blocked on the page in [tabId] so far.
///
/// There is no event per blocked tracker to follow, so the log is read again
/// whenever the page changes or starts or finishes loading — the points where
/// it can have grown.

final class PageTrackersProvider
    extends
        $FunctionalProvider<
          AsyncValue<PageTrackers>,
          PageTrackers,
          FutureOr<PageTrackers>
        >
    with $FutureModifier<PageTrackers>, $FutureProvider<PageTrackers> {
  /// The trackers blocked on the page in [tabId] so far.
  ///
  /// There is no event per blocked tracker to follow, so the log is read again
  /// whenever the page changes or starts or finishes loading — the points where
  /// it can have grown.
  PageTrackersProvider._({
    required PageTrackersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'pageTrackersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pageTrackersHash();

  @override
  String toString() {
    return r'pageTrackersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PageTrackers> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PageTrackers> create(Ref ref) {
    final argument = this.argument as String;
    return pageTrackers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PageTrackersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pageTrackersHash() => r'2babfe904a9726de05bb5da17f133a4108779953';

/// The trackers blocked on the page in [tabId] so far.
///
/// There is no event per blocked tracker to follow, so the log is read again
/// whenever the page changes or starts or finishes loading — the points where
/// it can have grown.

final class PageTrackersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PageTrackers>, String> {
  PageTrackersFamily._()
    : super(
        retry: null,
        name: r'pageTrackersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The trackers blocked on the page in [tabId] so far.
  ///
  /// There is no event per blocked tracker to follow, so the log is read again
  /// whenever the page changes or starts or finishes loading — the points where
  /// it can have grown.

  PageTrackersProvider call(String tabId) =>
      PageTrackersProvider._(argument: tabId, from: this);

  @override
  String toString() => r'pageTrackersProvider';
}

/// The tracker-statistics database, summed for display. Read once per watcher,
/// so it is current whenever a screen showing it opens.

@ProviderFor(trackerStatistics)
final trackerStatisticsProvider = TrackerStatisticsProvider._();

/// The tracker-statistics database, summed for display. Read once per watcher,
/// so it is current whenever a screen showing it opens.

final class TrackerStatisticsProvider
    extends
        $FunctionalProvider<
          AsyncValue<TrackerStatisticsSummary>,
          TrackerStatisticsSummary,
          FutureOr<TrackerStatisticsSummary>
        >
    with
        $FutureModifier<TrackerStatisticsSummary>,
        $FutureProvider<TrackerStatisticsSummary> {
  /// The tracker-statistics database, summed for display. Read once per watcher,
  /// so it is current whenever a screen showing it opens.
  TrackerStatisticsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'trackerStatisticsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$trackerStatisticsHash();

  @$internal
  @override
  $FutureProviderElement<TrackerStatisticsSummary> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TrackerStatisticsSummary> create(Ref ref) {
    return trackerStatistics(ref);
  }
}

String _$trackerStatisticsHash() => r'beb9d44fb539c5e5f8d1a23d844f6bea57588e38';
