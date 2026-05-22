// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(iconCacheSizeMegabytes)
final iconCacheSizeMegabytesProvider = IconCacheSizeMegabytesProvider._();

final class IconCacheSizeMegabytesProvider
    extends $FunctionalProvider<AsyncValue<double>, double, Stream<double>>
    with $FutureModifier<double>, $StreamProvider<double> {
  IconCacheSizeMegabytesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iconCacheSizeMegabytesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iconCacheSizeMegabytesHash();

  @$internal
  @override
  $StreamProviderElement<double> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<double> create(Ref ref) {
    return iconCacheSizeMegabytes(ref);
  }
}

String _$iconCacheSizeMegabytesHash() =>
    r'5d7f5f6485060b08ce4fd8fa634f07bf8bfdbd2d';

@ProviderFor(watchCachedIconBytes)
final watchCachedIconBytesProvider = WatchCachedIconBytesFamily._();

final class WatchCachedIconBytesProvider
    extends
        $FunctionalProvider<
          AsyncValue<Uint8List?>,
          Uint8List?,
          Stream<Uint8List?>
        >
    with $FutureModifier<Uint8List?>, $StreamProvider<Uint8List?> {
  WatchCachedIconBytesProvider._({
    required WatchCachedIconBytesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchCachedIconBytesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchCachedIconBytesHash();

  @override
  String toString() {
    return r'watchCachedIconBytesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Uint8List?> create(Ref ref) {
    final argument = this.argument as String;
    return watchCachedIconBytes(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCachedIconBytesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchCachedIconBytesHash() =>
    r'65881670bd19f2d55e05e68118e1e23b28871c13';

final class WatchCachedIconBytesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Uint8List?>, String> {
  WatchCachedIconBytesFamily._()
    : super(
        retry: null,
        name: r'watchCachedIconBytesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchCachedIconBytesProvider call(String origin) =>
      WatchCachedIconBytesProvider._(argument: origin, from: this);

  @override
  String toString() => r'watchCachedIconBytesProvider';
}

@ProviderFor(incognitoModeEnabled)
final incognitoModeEnabledProvider = IncognitoModeEnabledProvider._();

final class IncognitoModeEnabledProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  IncognitoModeEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'incognitoModeEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$incognitoModeEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return incognitoModeEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$incognitoModeEnabledHash() =>
    r'36957b70a5261f9d3ad228e07cc8dd5c8f616082';

@ProviderFor(fingerprintOverrideSettings)
final fingerprintOverrideSettingsProvider =
    FingerprintOverrideSettingsProvider._();

final class FingerprintOverrideSettingsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Result<FingerprintOverrides>>,
          Result<FingerprintOverrides>,
          FutureOr<Result<FingerprintOverrides>>
        >
    with
        $FutureModifier<Result<FingerprintOverrides>>,
        $FutureProvider<Result<FingerprintOverrides>> {
  FingerprintOverrideSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'fingerprintOverrideSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$fingerprintOverrideSettingsHash();

  @$internal
  @override
  $FutureProviderElement<Result<FingerprintOverrides>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Result<FingerprintOverrides>> create(Ref ref) {
    return fingerprintOverrideSettings(ref);
  }
}

String _$fingerprintOverrideSettingsHash() =>
    r'd4d40ec425098fb1f5a2f0c4944f058829a41a0a';

@ProviderFor(selectedProfile)
final selectedProfileProvider = SelectedProfileProvider._();

final class SelectedProfileProvider
    extends $FunctionalProvider<AsyncValue<Profile>, Profile, FutureOr<Profile>>
    with $FutureModifier<Profile>, $FutureProvider<Profile> {
  SelectedProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile> create(Ref ref) {
    return selectedProfile(ref);
  }
}

String _$selectedProfileHash() => r'c703cad8f30abb4f5f42db0119756ee6791ac477';

@ProviderFor(backupList)
final backupListProvider = BackupListProvider._();

final class BackupListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SafDocumentFile>>,
          List<SafDocumentFile>,
          FutureOr<List<SafDocumentFile>>
        >
    with
        $FutureModifier<List<SafDocumentFile>>,
        $FutureProvider<List<SafDocumentFile>> {
  BackupListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupListHash();

  @$internal
  @override
  $FutureProviderElement<List<SafDocumentFile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SafDocumentFile>> create(Ref ref) {
    return backupList(ref);
  }
}

String _$backupListHash() => r'527bfdab7b537b08764ff77dd69de14d38846d41';
