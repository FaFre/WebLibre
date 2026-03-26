// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'engine_settings_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EngineSettingsReplicationService)
final engineSettingsReplicationServiceProvider =
    EngineSettingsReplicationServiceProvider._();

final class EngineSettingsReplicationServiceProvider
    extends $NotifierProvider<EngineSettingsReplicationService, void> {
  EngineSettingsReplicationServiceProvider._()
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
    r'81443c37d18ad82f0694cd0e1115ccdf8a0f4c06';

abstract class _$EngineSettingsReplicationService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
