// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_callback_handler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Listens for account callback deep links and forwards handoff codes
/// to the account auth repository.
///
/// This provider must be watched during app initialization to activate
/// the callback listener.

@ProviderFor(accountCallbackHandler)
final accountCallbackHandlerProvider = AccountCallbackHandlerProvider._();

/// Listens for account callback deep links and forwards handoff codes
/// to the account auth repository.
///
/// This provider must be watched during app initialization to activate
/// the callback listener.

final class AccountCallbackHandlerProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Listens for account callback deep links and forwards handoff codes
  /// to the account auth repository.
  ///
  /// This provider must be watched during app initialization to activate
  /// the callback listener.
  AccountCallbackHandlerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountCallbackHandlerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountCallbackHandlerHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return accountCallbackHandler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$accountCallbackHandlerHash() =>
    r'8d8e627efed8c030a2a9fe179cc71bdc33dd79c0';
