// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_observer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferenceChangeListener)
final preferenceChangeListenerProvider = PreferenceChangeListenerProvider._();

final class PreferenceChangeListenerProvider
    extends $StreamNotifierProvider<PreferenceChangeListener, GeckoPref> {
  PreferenceChangeListenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceChangeListenerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferenceChangeListenerHash();

  @$internal
  @override
  PreferenceChangeListener create() => PreferenceChangeListener();
}

String _$preferenceChangeListenerHash() =>
    r'de9759b32a6a6b9bab5656137a365da78633f866';

abstract class _$PreferenceChangeListener extends $StreamNotifier<GeckoPref> {
  Stream<GeckoPref> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<GeckoPref>, GeckoPref>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GeckoPref>, GeckoPref>,
              AsyncValue<GeckoPref>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PreferenceFixator)
final preferenceFixatorProvider = PreferenceFixatorProvider._();

final class PreferenceFixatorProvider
    extends $NotifierProvider<PreferenceFixator, Map<String, Object>> {
  PreferenceFixatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceFixatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferenceFixatorHash();

  @$internal
  @override
  PreferenceFixator create() => PreferenceFixator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, Object> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, Object>>(value),
    );
  }
}

String _$preferenceFixatorHash() => r'c8d71966faf6b2feb9ac4e770297cd298edf5211';

abstract class _$PreferenceFixator extends $Notifier<Map<String, Object>> {
  Map<String, Object> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Map<String, Object>, Map<String, Object>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Object>, Map<String, Object>>,
              Map<String, Object>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
