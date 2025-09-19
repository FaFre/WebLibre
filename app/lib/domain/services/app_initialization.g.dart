// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppInitializationService)
const appInitializationServiceProvider = AppInitializationServiceProvider._();

final class AppInitializationServiceProvider
    extends
        $NotifierProvider<
          AppInitializationService,
          Result<({List<ErrorMessage> errors, bool initialized, String? stage})>
        > {
  const AppInitializationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appInitializationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appInitializationServiceHash();

  @$internal
  @override
  AppInitializationService create() => AppInitializationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    Result<({List<ErrorMessage> errors, bool initialized, String? stage})>
    value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            Result<
              ({List<ErrorMessage> errors, bool initialized, String? stage})
            >
          >(value),
    );
  }
}

String _$appInitializationServiceHash() =>
    r'9966be978ea4990c56a3aba347e7979921bf6b2b';

abstract class _$AppInitializationService
    extends
        $Notifier<
          Result<({List<ErrorMessage> errors, bool initialized, String? stage})>
        > {
  Result<({List<ErrorMessage> errors, bool initialized, String? stage})>
  build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              Result<
                ({List<ErrorMessage> errors, bool initialized, String? stage})
              >,
              Result<
                ({List<ErrorMessage> errors, bool initialized, String? stage})
              >
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Result<
                  ({List<ErrorMessage> errors, bool initialized, String? stage})
                >,
                Result<
                  ({List<ErrorMessage> errors, bool initialized, String? stage})
                >
              >,
              Result<
                ({List<ErrorMessage> errors, bool initialized, String? stage})
              >,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
