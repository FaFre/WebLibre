// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_adoption_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
    r'35fb8010ba6bae178ac1499902b134067f198220';

/// Claims the record for the active profile and signs in with it.

@ProviderFor(AccountAdoption)
final accountAdoptionProvider = AccountAdoptionProvider._();

/// Claims the record for the active profile and signs in with it.
final class AccountAdoptionProvider
    extends $NotifierProvider<AccountAdoption, void> {
  /// Claims the record for the active profile and signs in with it.
  AccountAdoptionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountAdoptionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountAdoptionHash();

  @$internal
  @override
  AccountAdoption create() => AccountAdoption();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$accountAdoptionHash() => r'b6c407387d97794d9e8f42678680d43bff5906d2';

/// Claims the record for the active profile and signs in with it.

abstract class _$AccountAdoption extends $Notifier<void> {
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
