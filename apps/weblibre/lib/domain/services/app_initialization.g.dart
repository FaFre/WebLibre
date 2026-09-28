// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppInitializationService)
final appInitializationServiceProvider = AppInitializationServiceProvider._();

final class AppInitializationServiceProvider
    extends
        $NotifierProvider<
          AppInitializationService,
          Result<
            ({
              List<ErrorMessage> errors,
              bool initialized,
              AppInitializationStage? stage,
            })
          >
        > {
  AppInitializationServiceProvider._()
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
    Result<
      ({
        List<ErrorMessage> errors,
        bool initialized,
        AppInitializationStage? stage,
      })
    >
    value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<
            Result<
              ({
                List<ErrorMessage> errors,
                bool initialized,
                AppInitializationStage? stage,
              })
            >
          >(value),
    );
  }
}

String _$appInitializationServiceHash() =>
    r'714ebc2573a1e19f45cfbd038c425c21bfaa3a3d';

abstract class _$AppInitializationService
    extends
        $Notifier<
          Result<
            ({
              List<ErrorMessage> errors,
              bool initialized,
              AppInitializationStage? stage,
            })
          >
        > {
  Result<
    ({
      List<ErrorMessage> errors,
      bool initialized,
      AppInitializationStage? stage,
    })
  >
  build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              Result<
                ({
                  List<ErrorMessage> errors,
                  bool initialized,
                  AppInitializationStage? stage,
                })
              >,
              Result<
                ({
                  List<ErrorMessage> errors,
                  bool initialized,
                  AppInitializationStage? stage,
                })
              >
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Result<
                  ({
                    List<ErrorMessage> errors,
                    bool initialized,
                    AppInitializationStage? stage,
                  })
                >,
                Result<
                  ({
                    List<ErrorMessage> errors,
                    bool initialized,
                    AppInitializationStage? stage,
                  })
                >
              >,
              Result<
                ({
                  List<ErrorMessage> errors,
                  bool initialized,
                  AppInitializationStage? stage,
                })
              >,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
