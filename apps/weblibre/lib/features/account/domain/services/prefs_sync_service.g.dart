// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prefs_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PrefsSyncService)
final prefsSyncServiceProvider = PrefsSyncServiceProvider._();

final class PrefsSyncServiceProvider
    extends $NotifierProvider<PrefsSyncService, void> {
  PrefsSyncServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'prefsSyncServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$prefsSyncServiceHash();

  @$internal
  @override
  PrefsSyncService create() => PrefsSyncService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$prefsSyncServiceHash() => r'9e95a066d751c12dc2a46bbe041c49e0389a7874';

abstract class _$PrefsSyncService extends $Notifier<void> {
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
