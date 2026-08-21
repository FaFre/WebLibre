// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'startup_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one writer for `startup_config.json`.
///
/// Global rather than per-profile on purpose: it decides which profile starts, so
/// storing it inside a profile would make the answer depend on the question. It
/// is deliberately not a `riverpod_persist` setting for the same reason — those
/// live in the profile's database, which is not open when this is read.

@ProviderFor(startupConfigStore)
final startupConfigStoreProvider = StartupConfigStoreProvider._();

/// The one writer for `startup_config.json`.
///
/// Global rather than per-profile on purpose: it decides which profile starts, so
/// storing it inside a profile would make the answer depend on the question. It
/// is deliberately not a `riverpod_persist` setting for the same reason — those
/// live in the profile's database, which is not open when this is read.

final class StartupConfigStoreProvider
    extends
        $FunctionalProvider<
          StartupConfigStore,
          StartupConfigStore,
          StartupConfigStore
        >
    with $Provider<StartupConfigStore> {
  /// The one writer for `startup_config.json`.
  ///
  /// Global rather than per-profile on purpose: it decides which profile starts, so
  /// storing it inside a profile would make the answer depend on the question. It
  /// is deliberately not a `riverpod_persist` setting for the same reason — those
  /// live in the profile's database, which is not open when this is read.
  StartupConfigStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'startupConfigStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$startupConfigStoreHash();

  @$internal
  @override
  $ProviderElement<StartupConfigStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  StartupConfigStore create(Ref ref) {
    return startupConfigStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(StartupConfigStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<StartupConfigStore>(value),
    );
  }
}

String _$startupConfigStoreHash() =>
    r'27015eacb5d1644acf5d452242b8ceb35c00e391';

/// Whether startup asks which profile to open.

@ProviderFor(ProfilePromptSetting)
final profilePromptSettingProvider = ProfilePromptSettingProvider._();

/// Whether startup asks which profile to open.
final class ProfilePromptSettingProvider
    extends $AsyncNotifierProvider<ProfilePromptSetting, ProfilePromptMode> {
  /// Whether startup asks which profile to open.
  ProfilePromptSettingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profilePromptSettingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profilePromptSettingHash();

  @$internal
  @override
  ProfilePromptSetting create() => ProfilePromptSetting();
}

String _$profilePromptSettingHash() =>
    r'0b7e13737e74a34bdca6608d466062f48a2500ec';

/// Whether startup asks which profile to open.

abstract class _$ProfilePromptSetting
    extends $AsyncNotifier<ProfilePromptMode> {
  FutureOr<ProfilePromptMode> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ProfilePromptMode>, ProfilePromptMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ProfilePromptMode>, ProfilePromptMode>,
              AsyncValue<ProfilePromptMode>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
