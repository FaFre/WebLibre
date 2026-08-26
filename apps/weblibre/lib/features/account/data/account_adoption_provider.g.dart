// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_adoption_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The profile an adoption files the record under.
///
/// Read through a provider rather than straight off [filesystem] so the
/// controller can be driven in a test without activating the process-wide
/// profile singleton. In the app it is exactly `filesystem.selectedProfile`, and
/// it cannot change while the process lives — `activate` refuses to rebind.

@ProviderFor(adoptingProfileId)
final adoptingProfileIdProvider = AdoptingProfileIdProvider._();

/// The profile an adoption files the record under.
///
/// Read through a provider rather than straight off [filesystem] so the
/// controller can be driven in a test without activating the process-wide
/// profile singleton. In the app it is exactly `filesystem.selectedProfile`, and
/// it cannot change while the process lives — `activate` refuses to rebind.

final class AdoptingProfileIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// The profile an adoption files the record under.
  ///
  /// Read through a provider rather than straight off [filesystem] so the
  /// controller can be driven in a test without activating the process-wide
  /// profile singleton. In the app it is exactly `filesystem.selectedProfile`, and
  /// it cannot change while the process lives — `activate` refuses to rebind.
  AdoptingProfileIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adoptingProfileIdProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adoptingProfileIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return adoptingProfileId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$adoptingProfileIdHash() => r'db202c8d1e22df7fe5bd0cdce0fec72e783cc82d';

/// The account session waiting to be claimed, if there is one.
///
/// Auto-disposed and re-read rather than kept: it is answered once and then
/// stops existing, and a cached "yes" would outlive the adoption that resolved
/// it.

@ProviderFor(unclaimedAccountRecord)
final unclaimedAccountRecordProvider = UnclaimedAccountRecordProvider._();

/// The account session waiting to be claimed, if there is one.
///
/// Auto-disposed and re-read rather than kept: it is answered once and then
/// stops existing, and a cached "yes" would outlive the adoption that resolved
/// it.

final class UnclaimedAccountRecordProvider
    extends
        $FunctionalProvider<
          AsyncValue<UnclaimedAccountRecord?>,
          UnclaimedAccountRecord?,
          FutureOr<UnclaimedAccountRecord?>
        >
    with
        $FutureModifier<UnclaimedAccountRecord?>,
        $FutureProvider<UnclaimedAccountRecord?> {
  /// The account session waiting to be claimed, if there is one.
  ///
  /// Auto-disposed and re-read rather than kept: it is answered once and then
  /// stops existing, and a cached "yes" would outlive the adoption that resolved
  /// it.
  UnclaimedAccountRecordProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unclaimedAccountRecordProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unclaimedAccountRecordHash();

  @$internal
  @override
  $FutureProviderElement<UnclaimedAccountRecord?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UnclaimedAccountRecord?> create(Ref ref) {
    return unclaimedAccountRecord(ref);
  }
}

String _$unclaimedAccountRecordHash() =>
    r'6f35b16b9982f749047cfe56d56c69c092cd659c';

/// Claims the record for the active profile and signs in with it.
///
/// `keepAlive`, and that is the whole point rather than an optimisation. The
/// tile invokes this through `ref.read(...notifier)`, which holds no
/// subscription; an auto-disposed notifier is therefore scheduled for disposal
/// at the end of the very next event loop — long before a secure-storage
/// platform round trip returns. Every `ref` use after that first `await` threw
/// `UnmountedRefException`, so the record moved to its new key and *nothing
/// else happened*: no provider was invalidated, the signed-out card stayed on
/// screen, and the error surfaced only as an unhandled async throw. To the user
/// that is a button that does nothing.
///
/// Holding [AsyncValue] state also gives the tile something to render: the
/// operation takes a storage round trip plus a network session restore, and it
/// can fail.

@ProviderFor(AccountAdoption)
final accountAdoptionProvider = AccountAdoptionProvider._();

/// Claims the record for the active profile and signs in with it.
///
/// `keepAlive`, and that is the whole point rather than an optimisation. The
/// tile invokes this through `ref.read(...notifier)`, which holds no
/// subscription; an auto-disposed notifier is therefore scheduled for disposal
/// at the end of the very next event loop — long before a secure-storage
/// platform round trip returns. Every `ref` use after that first `await` threw
/// `UnmountedRefException`, so the record moved to its new key and *nothing
/// else happened*: no provider was invalidated, the signed-out card stayed on
/// screen, and the error surfaced only as an unhandled async throw. To the user
/// that is a button that does nothing.
///
/// Holding [AsyncValue] state also gives the tile something to render: the
/// operation takes a storage round trip plus a network session restore, and it
/// can fail.
final class AccountAdoptionProvider
    extends $NotifierProvider<AccountAdoption, AsyncValue<void>> {
  /// Claims the record for the active profile and signs in with it.
  ///
  /// `keepAlive`, and that is the whole point rather than an optimisation. The
  /// tile invokes this through `ref.read(...notifier)`, which holds no
  /// subscription; an auto-disposed notifier is therefore scheduled for disposal
  /// at the end of the very next event loop — long before a secure-storage
  /// platform round trip returns. Every `ref` use after that first `await` threw
  /// `UnmountedRefException`, so the record moved to its new key and *nothing
  /// else happened*: no provider was invalidated, the signed-out card stayed on
  /// screen, and the error surfaced only as an unhandled async throw. To the user
  /// that is a button that does nothing.
  ///
  /// Holding [AsyncValue] state also gives the tile something to render: the
  /// operation takes a storage round trip plus a network session restore, and it
  /// can fail.
  AccountAdoptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountAdoptionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountAdoptionHash();

  @$internal
  @override
  AccountAdoption create() => AccountAdoption();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$accountAdoptionHash() => r'a33dc47233341b638e7923826e50b27264c87370';

/// Claims the record for the active profile and signs in with it.
///
/// `keepAlive`, and that is the whole point rather than an optimisation. The
/// tile invokes this through `ref.read(...notifier)`, which holds no
/// subscription; an auto-disposed notifier is therefore scheduled for disposal
/// at the end of the very next event loop — long before a secure-storage
/// platform round trip returns. Every `ref` use after that first `await` threw
/// `UnmountedRefException`, so the record moved to its new key and *nothing
/// else happened*: no provider was invalidated, the signed-out card stayed on
/// screen, and the error surfaced only as an unhandled async throw. To the user
/// that is a button that does nothing.
///
/// Holding [AsyncValue] state also gives the tile something to render: the
/// operation takes a storage round trip plus a network session restore, and it
/// can fail.

abstract class _$AccountAdoption extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
