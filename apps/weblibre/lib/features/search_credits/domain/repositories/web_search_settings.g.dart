// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_search_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebSearchSettingsController)
@JsonPersist()
final webSearchSettingsControllerProvider =
    WebSearchSettingsControllerProvider._();

@JsonPersist()
final class WebSearchSettingsControllerProvider
    extends $NotifierProvider<WebSearchSettingsController, WebSearchSettings> {
  WebSearchSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webSearchSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webSearchSettingsControllerHash();

  @$internal
  @override
  WebSearchSettingsController create() => WebSearchSettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebSearchSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebSearchSettings>(value),
    );
  }
}

String _$webSearchSettingsControllerHash() =>
    r'f21a6203fdb8b21c28b0ddd23f1b48768673138e';

@JsonPersist()
abstract class _$WebSearchSettingsControllerBase
    extends $Notifier<WebSearchSettings> {
  WebSearchSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<WebSearchSettings, WebSearchSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebSearchSettings, WebSearchSettings>,
              WebSearchSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

// **************************************************************************
// JsonGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
abstract class _$WebSearchSettingsController
    extends _$WebSearchSettingsControllerBase {
  /// The default key used by [persist].
  String get key {
    const resolvedKey = "WebSearchSettingsController";
    return resolvedKey;
  }

  /// A variant of [persist], for JSON-specific encoding.
  ///
  /// You can override [key] to customize the key used for storage.
  PersistResult persist(
    FutureOr<Storage<String, String>> storage, {
    String? key,
    String Function(WebSearchSettings state)? encode,
    WebSearchSettings Function(String encoded)? decode,
    StorageOptions options = const StorageOptions(),
  }) {
    return NotifierPersistX(this).persist<String, String>(
      storage,
      key: key ?? this.key,
      encode: encode ?? $jsonCodex.encode,
      decode:
          decode ??
          (encoded) {
            final e = $jsonCodex.decode(encoded);
            return WebSearchSettings.fromJson(e as Map<String, Object?>);
          },
      options: options,
    );
  }
}
