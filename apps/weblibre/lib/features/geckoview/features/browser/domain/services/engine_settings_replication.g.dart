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
    r'c38290a827a2f0b5fba0687892a28abd48f58d9b';

abstract class _$EngineSettingsReplicationService extends $Notifier<void> {
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
