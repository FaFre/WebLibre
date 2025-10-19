// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preference_observer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PreferenceChangeListener)
const preferenceChangeListenerProvider = PreferenceChangeListenerProvider._();

final class PreferenceChangeListenerProvider
    extends $StreamNotifierProvider<PreferenceChangeListener, GeckoPref> {
  const PreferenceChangeListenerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceChangeListenerProvider',
        isAutoDispose: true,
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
    r'668c1bcd0636ec515a5e92ee5ba4ea7a67fa7a6d';

abstract class _$PreferenceChangeListener extends $StreamNotifier<GeckoPref> {
  Stream<GeckoPref> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<GeckoPref>, GeckoPref>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<GeckoPref>, GeckoPref>,
              AsyncValue<GeckoPref>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(PreferenceFixator)
const preferenceFixatorProvider = PreferenceFixatorProvider._();

final class PreferenceFixatorProvider
    extends $NotifierProvider<PreferenceFixator, Map<String, Object>> {
  const PreferenceFixatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferenceFixatorProvider',
        isAutoDispose: true,
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

String _$preferenceFixatorHash() => r'dfa323859c660d3db74dba7297e2a33b758ed78a';

abstract class _$PreferenceFixator extends $Notifier<Map<String, Object>> {
  Map<String, Object> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Map<String, Object>, Map<String, Object>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Map<String, Object>, Map<String, Object>>,
              Map<String, Object>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
