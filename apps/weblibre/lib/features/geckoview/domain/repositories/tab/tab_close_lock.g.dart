// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_close_lock.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tabs' close lock: every close, every tab lock change and every
/// container deletion holds it (`TabRepository`, `TabLocks`,
/// `ContainerDeletion`), so no close can fall between a lock's two writes,
/// and a close's preflight cannot disagree with native's removal.
///
/// Not reentrant: a method documented as running under it does not take it
/// itself, and asserts that it is held.

@ProviderFor(tabCloseLock)
final tabCloseLockProvider = TabCloseLockProvider._();

/// The tabs' close lock: every close, every tab lock change and every
/// container deletion holds it (`TabRepository`, `TabLocks`,
/// `ContainerDeletion`), so no close can fall between a lock's two writes,
/// and a close's preflight cannot disagree with native's removal.
///
/// Not reentrant: a method documented as running under it does not take it
/// itself, and asserts that it is held.

final class TabCloseLockProvider extends $FunctionalProvider<Lock, Lock, Lock>
    with $Provider<Lock> {
  /// The tabs' close lock: every close, every tab lock change and every
  /// container deletion holds it (`TabRepository`, `TabLocks`,
  /// `ContainerDeletion`), so no close can fall between a lock's two writes,
  /// and a close's preflight cannot disagree with native's removal.
  ///
  /// Not reentrant: a method documented as running under it does not take it
  /// itself, and asserts that it is held.
  TabCloseLockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tabCloseLockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tabCloseLockHash();

  @$internal
  @override
  $ProviderElement<Lock> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Lock create(Ref ref) {
    return tabCloseLock(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Lock value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Lock>(value),
    );
  }
}

String _$tabCloseLockHash() => r'e7a6d5dfb100cf557b5d59c58046301943d97b9b';
