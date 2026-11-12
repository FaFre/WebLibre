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

/// A change signal for [origin]'s entry in the favicon cache.
///
/// Emits the cache's revision number whenever that origin's icon changes or the
/// whole cache is cleared, so a widget can key its icon lookup on this and be
/// rebuilt when — and only when — the icon actually changes.
///
/// This exists instead of a provider that watches the icon row itself. Every
/// row of every list renders a `UrlIcon`, so a reactive query here meant one
/// live SQLite watch per visible row, created and destroyed on every scroll
/// pass — against a table written only when a favicon is fetched. What is
/// emitted is deliberately just a number: the icon itself comes from
/// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
/// a warm icon costs no database read at all.
///
/// Not an `async*` generator, and with no initial value: a generator suspends
/// on its first `yield` before it reaches the subscription, and an invalidation
/// arriving in that window would be dropped. Returning the stream directly has
/// Riverpod subscribe while the provider is being built; readers treat "no
/// value yet" as "nothing has changed since I started looking".
///
/// See https://github.com/FaFre/WebLibre/issues/599.

@ProviderFor(iconCacheRevision)
final iconCacheRevisionProvider = IconCacheRevisionFamily._();

/// A change signal for [origin]'s entry in the favicon cache.
///
/// Emits the cache's revision number whenever that origin's icon changes or the
/// whole cache is cleared, so a widget can key its icon lookup on this and be
/// rebuilt when — and only when — the icon actually changes.
///
/// This exists instead of a provider that watches the icon row itself. Every
/// row of every list renders a `UrlIcon`, so a reactive query here meant one
/// live SQLite watch per visible row, created and destroyed on every scroll
/// pass — against a table written only when a favicon is fetched. What is
/// emitted is deliberately just a number: the icon itself comes from
/// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
/// a warm icon costs no database read at all.
///
/// Not an `async*` generator, and with no initial value: a generator suspends
/// on its first `yield` before it reaches the subscription, and an invalidation
/// arriving in that window would be dropped. Returning the stream directly has
/// Riverpod subscribe while the provider is being built; readers treat "no
/// value yet" as "nothing has changed since I started looking".
///
/// See https://github.com/FaFre/WebLibre/issues/599.

final class IconCacheRevisionProvider
    extends $FunctionalProvider<AsyncValue<int>, int, Stream<int>>
    with $FutureModifier<int>, $StreamProvider<int> {
  /// A change signal for [origin]'s entry in the favicon cache.
  ///
  /// Emits the cache's revision number whenever that origin's icon changes or the
  /// whole cache is cleared, so a widget can key its icon lookup on this and be
  /// rebuilt when — and only when — the icon actually changes.
  ///
  /// This exists instead of a provider that watches the icon row itself. Every
  /// row of every list renders a `UrlIcon`, so a reactive query here meant one
  /// live SQLite watch per visible row, created and destroyed on every scroll
  /// pass — against a table written only when a favicon is fetched. What is
  /// emitted is deliberately just a number: the icon itself comes from
  /// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
  /// a warm icon costs no database read at all.
  ///
  /// Not an `async*` generator, and with no initial value: a generator suspends
  /// on its first `yield` before it reaches the subscription, and an invalidation
  /// arriving in that window would be dropped. Returning the stream directly has
  /// Riverpod subscribe while the provider is being built; readers treat "no
  /// value yet" as "nothing has changed since I started looking".
  ///
  /// See https://github.com/FaFre/WebLibre/issues/599.
  IconCacheRevisionProvider._({
    required IconCacheRevisionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'iconCacheRevisionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$iconCacheRevisionHash();

  @override
  String toString() {
    return r'iconCacheRevisionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<int> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int> create(Ref ref) {
    final argument = this.argument as String;
    return iconCacheRevision(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IconCacheRevisionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$iconCacheRevisionHash() => r'4fcad249668b71f087c3f65e19c8bbd739b8f68f';

/// A change signal for [origin]'s entry in the favicon cache.
///
/// Emits the cache's revision number whenever that origin's icon changes or the
/// whole cache is cleared, so a widget can key its icon lookup on this and be
/// rebuilt when — and only when — the icon actually changes.
///
/// This exists instead of a provider that watches the icon row itself. Every
/// row of every list renders a `UrlIcon`, so a reactive query here meant one
/// live SQLite watch per visible row, created and destroyed on every scroll
/// pass — against a table written only when a favicon is fetched. What is
/// emitted is deliberately just a number: the icon itself comes from
/// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
/// a warm icon costs no database read at all.
///
/// Not an `async*` generator, and with no initial value: a generator suspends
/// on its first `yield` before it reaches the subscription, and an invalidation
/// arriving in that window would be dropped. Returning the stream directly has
/// Riverpod subscribe while the provider is being built; readers treat "no
/// value yet" as "nothing has changed since I started looking".
///
/// See https://github.com/FaFre/WebLibre/issues/599.

final class IconCacheRevisionFamily extends $Family
    with $FunctionalFamilyOverride<Stream<int>, String> {
  IconCacheRevisionFamily._()
    : super(
        retry: null,
        name: r'iconCacheRevisionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A change signal for [origin]'s entry in the favicon cache.
  ///
  /// Emits the cache's revision number whenever that origin's icon changes or the
  /// whole cache is cleared, so a widget can key its icon lookup on this and be
  /// rebuilt when — and only when — the icon actually changes.
  ///
  /// This exists instead of a provider that watches the icon row itself. Every
  /// row of every list renders a `UrlIcon`, so a reactive query here meant one
  /// live SQLite watch per visible row, created and destroyed on every scroll
  /// pass — against a table written only when a favicon is fetched. What is
  /// emitted is deliberately just a number: the icon itself comes from
  /// `GenericWebsiteService`'s in-memory cache, which this same signal evicts, so
  /// a warm icon costs no database read at all.
  ///
  /// Not an `async*` generator, and with no initial value: a generator suspends
  /// on its first `yield` before it reaches the subscription, and an invalidation
  /// arriving in that window would be dropped. Returning the stream directly has
  /// Riverpod subscribe while the provider is being built; readers treat "no
  /// value yet" as "nothing has changed since I started looking".
  ///
  /// See https://github.com/FaFre/WebLibre/issues/599.

  IconCacheRevisionProvider call(String origin) =>
      IconCacheRevisionProvider._(argument: origin, from: this);

  @override
  String toString() => r'iconCacheRevisionProvider';
}

/// [iconCacheRevision] of each of [origins], in order; 0 until one is
/// reported.

@ProviderFor(iconCacheRevisions)
final iconCacheRevisionsProvider = IconCacheRevisionsFamily._();

/// [iconCacheRevision] of each of [origins], in order; 0 until one is
/// reported.

final class IconCacheRevisionsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<int>>,
          EquatableValue<List<int>>,
          EquatableValue<List<int>>
        >
    with $Provider<EquatableValue<List<int>>> {
  /// [iconCacheRevision] of each of [origins], in order; 0 until one is
  /// reported.
  IconCacheRevisionsProvider._({
    required IconCacheRevisionsFamily super.from,
    required EquatableValue<List<String>> super.argument,
  }) : super(
         retry: null,
         name: r'iconCacheRevisionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$iconCacheRevisionsHash();

  @override
  String toString() {
    return r'iconCacheRevisionsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<int>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<int>> create(Ref ref) {
    final argument = this.argument as EquatableValue<List<String>>;
    return iconCacheRevisions(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<int>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<List<int>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is IconCacheRevisionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$iconCacheRevisionsHash() =>
    r'8284d4fe0ad12999c98beb71b7ea9f637f751bbd';

/// [iconCacheRevision] of each of [origins], in order; 0 until one is
/// reported.

final class IconCacheRevisionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<int>>,
          EquatableValue<List<String>>
        > {
  IconCacheRevisionsFamily._()
    : super(
        retry: null,
        name: r'iconCacheRevisionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [iconCacheRevision] of each of [origins], in order; 0 until one is
  /// reported.

  IconCacheRevisionsProvider call(EquatableValue<List<String>> origins) =>
      IconCacheRevisionsProvider._(argument: origins, from: this);

  @override
  String toString() => r'iconCacheRevisionsProvider';
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
    r'ed42b82b361521ea77d41fdab0e3e8bde69a9a78';

/// The stored per-target fingerprinting overrides, for their editor: while
/// they are hidden the engine applies the defaults (H1), but the editor shows
/// what was saved and comes back when they are shown.

@ProviderFor(fingerprintOverrideSettings)
final fingerprintOverrideSettingsProvider =
    FingerprintOverrideSettingsProvider._();

/// The stored per-target fingerprinting overrides, for their editor: while
/// they are hidden the engine applies the defaults (H1), but the editor shows
/// what was saved and comes back when they are shown.

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
  /// The stored per-target fingerprinting overrides, for their editor: while
  /// they are hidden the engine applies the defaults (H1), but the editor shows
  /// what was saved and comes back when they are shown.
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
    r'6cfe58cdbcc3090067c3d2cf1568d93d78e04af8';

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

/// Whether the profile switcher has anything to offer: another profile to
/// switch to, or the multiple-profiles controls shown so one can be added.
/// Without either, the profile entry opens this profile's own controls.

@ProviderFor(canSwitchProfiles)
final canSwitchProfilesProvider = CanSwitchProfilesProvider._();

/// Whether the profile switcher has anything to offer: another profile to
/// switch to, or the multiple-profiles controls shown so one can be added.
/// Without either, the profile entry opens this profile's own controls.

final class CanSwitchProfilesProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the profile switcher has anything to offer: another profile to
  /// switch to, or the multiple-profiles controls shown so one can be added.
  /// Without either, the profile entry opens this profile's own controls.
  CanSwitchProfilesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canSwitchProfilesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canSwitchProfilesHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return canSwitchProfiles(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$canSwitchProfilesHash() => r'8e8ef6c980d557096aa412560c8364ba8f2d29e6';

/// The backup folder's name as the user knows it, or null when none is chosen.
///
/// Asked from the provider first and read from the tree uri when that fails,
/// because the case worth naming the folder in is exactly the one where the
/// provider no longer answers for it.
///
/// For the folder row, which has to name the folder before anything has been
/// asked of it. Messages about a write check name the folder the check itself
/// reported (`BackupTreeProbe.folderName`): this may still hold the previous
/// folder's name for a moment after the folder changes.

@ProviderFor(backupFolderName)
final backupFolderNameProvider = BackupFolderNameProvider._();

/// The backup folder's name as the user knows it, or null when none is chosen.
///
/// Asked from the provider first and read from the tree uri when that fails,
/// because the case worth naming the folder in is exactly the one where the
/// provider no longer answers for it.
///
/// For the folder row, which has to name the folder before anything has been
/// asked of it. Messages about a write check name the folder the check itself
/// reported (`BackupTreeProbe.folderName`): this may still hold the previous
/// folder's name for a moment after the folder changes.

final class BackupFolderNameProvider
    extends $FunctionalProvider<AsyncValue<String?>, String?, FutureOr<String?>>
    with $FutureModifier<String?>, $FutureProvider<String?> {
  /// The backup folder's name as the user knows it, or null when none is chosen.
  ///
  /// Asked from the provider first and read from the tree uri when that fails,
  /// because the case worth naming the folder in is exactly the one where the
  /// provider no longer answers for it.
  ///
  /// For the folder row, which has to name the folder before anything has been
  /// asked of it. Messages about a write check name the folder the check itself
  /// reported (`BackupTreeProbe.folderName`): this may still hold the previous
  /// folder's name for a moment after the folder changes.
  BackupFolderNameProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupFolderNameProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupFolderNameHash();

  @$internal
  @override
  $FutureProviderElement<String?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String?> create(Ref ref) {
    return backupFolderName(ref);
  }
}

String _$backupFolderNameHash() => r'9c8fbc57b8eb5061028b2387d79ef46d38246ebe';

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

String _$backupListHash() => r'31bf550b5e4c016aff6869e0c2e9e3c53b2818d0';
