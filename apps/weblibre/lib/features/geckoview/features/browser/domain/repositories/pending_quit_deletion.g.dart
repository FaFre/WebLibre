// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_quit_deletion.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// What explicit Quits set out to delete and has not been deleted yet: a
/// request per type, recorded before a Quit starts deleting and completed as
/// soon as that type is deleted, by the Quit or by a later start.
///
/// A Quit whose deletion failed, or whose process died half way, leaves
/// requests behind, and the next start finishes the job
/// (`StartupBrowsingDataCleanup`). Without it, a Quit-only automatic deletion
/// would silently keep whatever an interrupted Quit did not get to, and data
/// picked in the confirmation for that Quit only would never be deleted at all.
///
/// Requests are never replaced by a snapshot of the record. Every read and
/// change is serialized, and each change touches only its own requests: a Quit
/// adds without dropping what is outstanding, and the startup cleanup, which
/// may still be running during a Quit, completes only the requests it read.
///
/// Stored in the settings table but not a setting: it is never shown or
/// edited.

@ProviderFor(PendingQuitDeletionRepository)
final pendingQuitDeletionRepositoryProvider =
    PendingQuitDeletionRepositoryProvider._();

/// What explicit Quits set out to delete and has not been deleted yet: a
/// request per type, recorded before a Quit starts deleting and completed as
/// soon as that type is deleted, by the Quit or by a later start.
///
/// A Quit whose deletion failed, or whose process died half way, leaves
/// requests behind, and the next start finishes the job
/// (`StartupBrowsingDataCleanup`). Without it, a Quit-only automatic deletion
/// would silently keep whatever an interrupted Quit did not get to, and data
/// picked in the confirmation for that Quit only would never be deleted at all.
///
/// Requests are never replaced by a snapshot of the record. Every read and
/// change is serialized, and each change touches only its own requests: a Quit
/// adds without dropping what is outstanding, and the startup cleanup, which
/// may still be running during a Quit, completes only the requests it read.
///
/// Stored in the settings table but not a setting: it is never shown or
/// edited.
final class PendingQuitDeletionRepositoryProvider
    extends $NotifierProvider<PendingQuitDeletionRepository, void> {
  /// What explicit Quits set out to delete and has not been deleted yet: a
  /// request per type, recorded before a Quit starts deleting and completed as
  /// soon as that type is deleted, by the Quit or by a later start.
  ///
  /// A Quit whose deletion failed, or whose process died half way, leaves
  /// requests behind, and the next start finishes the job
  /// (`StartupBrowsingDataCleanup`). Without it, a Quit-only automatic deletion
  /// would silently keep whatever an interrupted Quit did not get to, and data
  /// picked in the confirmation for that Quit only would never be deleted at all.
  ///
  /// Requests are never replaced by a snapshot of the record. Every read and
  /// change is serialized, and each change touches only its own requests: a Quit
  /// adds without dropping what is outstanding, and the startup cleanup, which
  /// may still be running during a Quit, completes only the requests it read.
  ///
  /// Stored in the settings table but not a setting: it is never shown or
  /// edited.
  PendingQuitDeletionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingQuitDeletionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingQuitDeletionRepositoryHash();

  @$internal
  @override
  PendingQuitDeletionRepository create() => PendingQuitDeletionRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$pendingQuitDeletionRepositoryHash() =>
    r'0be63edfdd8db8927d0a48d03f3dc3d6099fa7bb';

/// What explicit Quits set out to delete and has not been deleted yet: a
/// request per type, recorded before a Quit starts deleting and completed as
/// soon as that type is deleted, by the Quit or by a later start.
///
/// A Quit whose deletion failed, or whose process died half way, leaves
/// requests behind, and the next start finishes the job
/// (`StartupBrowsingDataCleanup`). Without it, a Quit-only automatic deletion
/// would silently keep whatever an interrupted Quit did not get to, and data
/// picked in the confirmation for that Quit only would never be deleted at all.
///
/// Requests are never replaced by a snapshot of the record. Every read and
/// change is serialized, and each change touches only its own requests: a Quit
/// adds without dropping what is outstanding, and the startup cleanup, which
/// may still be running during a Quit, completes only the requests it read.
///
/// Stored in the settings table but not a setting: it is never shown or
/// edited.

abstract class _$PendingQuitDeletionRepository extends $Notifier<void> {
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
