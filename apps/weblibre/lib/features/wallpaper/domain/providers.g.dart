// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wallpaperStore)
final wallpaperStoreProvider = WallpaperStoreProvider._();

final class WallpaperStoreProvider
    extends $FunctionalProvider<WallpaperStore, WallpaperStore, WallpaperStore>
    with $Provider<WallpaperStore> {
  WallpaperStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallpaperStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallpaperStoreHash();

  @$internal
  @override
  $ProviderElement<WallpaperStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WallpaperStore create(Ref ref) {
    return wallpaperStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WallpaperStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WallpaperStore>(value),
    );
  }
}

String _$wallpaperStoreHash() => r'1ee1636c844531bf0ef984e0740dfbabcbbd523f';

/// The wallpaper to draw behind the home surface right now, or null when there
/// is none.
///
/// The selected container's own wallpaper wins over the profile-wide one; its
/// blur and dim fall back to the profile's values when unset, so a container
/// that only wants a different picture does not have to restate the treatment.

@ProviderFor(resolvedHomeWallpaper)
final resolvedHomeWallpaperProvider = ResolvedHomeWallpaperProvider._();

/// The wallpaper to draw behind the home surface right now, or null when there
/// is none.
///
/// The selected container's own wallpaper wins over the profile-wide one; its
/// blur and dim fall back to the profile's values when unset, so a container
/// that only wants a different picture does not have to restate the treatment.

final class ResolvedHomeWallpaperProvider
    extends $FunctionalProvider<HomeWallpaper?, HomeWallpaper?, HomeWallpaper?>
    with $Provider<HomeWallpaper?> {
  /// The wallpaper to draw behind the home surface right now, or null when there
  /// is none.
  ///
  /// The selected container's own wallpaper wins over the profile-wide one; its
  /// blur and dim fall back to the profile's values when unset, so a container
  /// that only wants a different picture does not have to restate the treatment.
  ResolvedHomeWallpaperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resolvedHomeWallpaperProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resolvedHomeWallpaperHash();

  @$internal
  @override
  $ProviderElement<HomeWallpaper?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeWallpaper? create(Ref ref) {
    return resolvedHomeWallpaper(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeWallpaper? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeWallpaper?>(value),
    );
  }
}

String _$resolvedHomeWallpaperHash() =>
    r'd8510f49d8911ed78981e1adc0f5201a40461498';

/// Deletes wallpapers nothing points at any more.
///
/// Nothing else reclaims them: replacing a wallpaper, cancelling a container
/// edit that imported one, and deleting a container all leave a file behind on
/// purpose, because the writer cannot tell whether some other setting still
/// refers to it. Restoring a profile from an archive can leave some too.
///
/// Run at startup, from the browser view's housekeeping — the one moment when
/// no picker can be holding an import that has not been saved yet.

@ProviderFor(WallpaperSweeper)
final wallpaperSweeperProvider = WallpaperSweeperProvider._();

/// Deletes wallpapers nothing points at any more.
///
/// Nothing else reclaims them: replacing a wallpaper, cancelling a container
/// edit that imported one, and deleting a container all leave a file behind on
/// purpose, because the writer cannot tell whether some other setting still
/// refers to it. Restoring a profile from an archive can leave some too.
///
/// Run at startup, from the browser view's housekeeping — the one moment when
/// no picker can be holding an import that has not been saved yet.
final class WallpaperSweeperProvider
    extends $NotifierProvider<WallpaperSweeper, void> {
  /// Deletes wallpapers nothing points at any more.
  ///
  /// Nothing else reclaims them: replacing a wallpaper, cancelling a container
  /// edit that imported one, and deleting a container all leave a file behind on
  /// purpose, because the writer cannot tell whether some other setting still
  /// refers to it. Restoring a profile from an archive can leave some too.
  ///
  /// Run at startup, from the browser view's housekeeping — the one moment when
  /// no picker can be holding an import that has not been saved yet.
  WallpaperSweeperProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wallpaperSweeperProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wallpaperSweeperHash();

  @$internal
  @override
  WallpaperSweeper create() => WallpaperSweeper();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$wallpaperSweeperHash() => r'ad06884d37124c39dd50407b0cc924c395ec3dc3';

/// Deletes wallpapers nothing points at any more.
///
/// Nothing else reclaims them: replacing a wallpaper, cancelling a container
/// edit that imported one, and deleting a container all leave a file behind on
/// purpose, because the writer cannot tell whether some other setting still
/// refers to it. Restoring a profile from an archive can leave some too.
///
/// Run at startup, from the browser view's housekeeping — the one moment when
/// no picker can be holding an import that has not been saved yet.

abstract class _$WallpaperSweeper extends $Notifier<void> {
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
