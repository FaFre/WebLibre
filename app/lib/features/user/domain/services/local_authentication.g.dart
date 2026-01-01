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
    r'1aab9214af5487dc770658c7be6f66083f5d6931';

abstract class _$LocalAuthenticationService extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
