// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppStateKey)
const appStateKeyProvider = AppStateKeyProvider._();

final class AppStateKeyProvider
    extends $NotifierProvider<AppStateKey, GlobalKey<State<StatefulWidget>>> {
  const AppStateKeyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appStateKeyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appStateKeyHash();

  @$internal
  @override
  AppStateKey create() => AppStateKey();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GlobalKey<State<StatefulWidget>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GlobalKey<State<StatefulWidget>>>(
        value,
      ),
    );
  }
}

String _$appStateKeyHash() => r'113c208139d84cdd52f623c2c6298b430fc1a889';

abstract class _$AppStateKey
    extends $Notifier<GlobalKey<State<StatefulWidget>>> {
  GlobalKey<State<StatefulWidget>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<
              GlobalKey<State<StatefulWidget>>,
              GlobalKey<State<StatefulWidget>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                GlobalKey<State<StatefulWidget>>,
                GlobalKey<State<StatefulWidget>>
              >,
              GlobalKey<State<StatefulWidget>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
