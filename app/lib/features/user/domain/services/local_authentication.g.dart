// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_authentication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalAuthenticationService)
const localAuthenticationServiceProvider =
    LocalAuthenticationServiceProvider._();

final class LocalAuthenticationServiceProvider
    extends $AsyncNotifierProvider<LocalAuthenticationService, bool> {
  const LocalAuthenticationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localAuthenticationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localAuthenticationServiceHash();

  @$internal
  @override
  LocalAuthenticationService create() => LocalAuthenticationService();
}

String _$localAuthenticationServiceHash() =>
    r'4893be7a11833d77a575f7aa248a9ba65d6717da';

abstract class _$LocalAuthenticationService extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
