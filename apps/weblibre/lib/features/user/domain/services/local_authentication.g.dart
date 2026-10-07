// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_authentication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocalAuthenticationService)
final localAuthenticationServiceProvider =
    LocalAuthenticationServiceProvider._();

final class LocalAuthenticationServiceProvider
    extends $AsyncNotifierProvider<LocalAuthenticationService, bool> {
  LocalAuthenticationServiceProvider._()
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
    r'2e201c4a7892b866fd8c0ffd5755d9ca419b838b';

abstract class _$LocalAuthenticationService extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
