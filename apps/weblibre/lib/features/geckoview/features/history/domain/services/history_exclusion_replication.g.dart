// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_exclusion_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Keeps the native history delegate's hard exclude-from-history set in sync
/// with WebLibre's containers, re-pushing whenever the container set changes.
/// Activated eagerly at startup (and once more before engine init) so an
/// excluded container never leaks a restored-tab visit to Places.

@ProviderFor(historyExclusionReplication)
final historyExclusionReplicationProvider =
    HistoryExclusionReplicationProvider._();

/// Keeps the native history delegate's hard exclude-from-history set in sync
/// with WebLibre's containers, re-pushing whenever the container set changes.
/// Activated eagerly at startup (and once more before engine init) so an
/// excluded container never leaks a restored-tab visit to Places.

final class HistoryExclusionReplicationProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Keeps the native history delegate's hard exclude-from-history set in sync
  /// with WebLibre's containers, re-pushing whenever the container set changes.
  /// Activated eagerly at startup (and once more before engine init) so an
  /// excluded container never leaks a restored-tab visit to Places.
  HistoryExclusionReplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'historyExclusionReplicationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$historyExclusionReplicationHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return historyExclusionReplication(ref);
  }
}

String _$historyExclusionReplicationHash() =>
    r'11eaf8bf0b4ef6e833a4b3659e1dbb3687b566be';
