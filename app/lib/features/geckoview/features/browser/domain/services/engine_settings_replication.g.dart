// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSettingsReplicationService)
const engineSettingsReplicationServiceProvider =
    EngineSettingsReplicationServiceProvider._();

final class EngineSettingsReplicationServiceProvider
    extends $NotifierProvider<EngineSettingsReplicationService, void> {
  const EngineSettingsReplicationServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'engineSettingsReplicationServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$engineSettingsReplicationServiceHash();

  @$internal
  @override
  EngineSettingsReplicationService create() =>
      EngineSettingsReplicationService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$engineSettingsReplicationServiceHash() =>
    r'd28cc58a94f45008a478bf52a9c40d61811b591d';

abstract class _$EngineSettingsReplicationService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
