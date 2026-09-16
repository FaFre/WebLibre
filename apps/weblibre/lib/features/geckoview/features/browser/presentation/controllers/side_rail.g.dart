// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'side_rail.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.

@ProviderFor(SideRailDragWidth)
final sideRailDragWidthProvider = SideRailDragWidthProvider._();

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.
final class SideRailDragWidthProvider
    extends $NotifierProvider<SideRailDragWidth, double?> {
  /// The width the side panel is being resized to, or null when the saved
  /// [GeneralSettings.sideRailWidth] is the whole truth.
  ///
  /// Kept past the end of a drag until the saved setting reports the released
  /// width. Clearing it on release would put the panel back at its old width for
  /// the frames the save takes, and every one of those frames resizes the page.
  SideRailDragWidthProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sideRailDragWidthProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sideRailDragWidthHash();

  @$internal
  @override
  SideRailDragWidth create() => SideRailDragWidth();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(double? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<double?>(value),
    );
  }
}

String _$sideRailDragWidthHash() => r'97c6a828366156fb99048e0ebb42873fdd06787b';

/// The width the side panel is being resized to, or null when the saved
/// [GeneralSettings.sideRailWidth] is the whole truth.
///
/// Kept past the end of a drag until the saved setting reports the released
/// width. Clearing it on release would put the panel back at its old width for
/// the frames the save takes, and every one of those frames resizes the page.

abstract class _$SideRailDragWidth extends $Notifier<double?> {
  double? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<double?, double?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<double?, double?>,
              double?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the auto-hiding side panel is currently slid in over the page.

@ProviderFor(SideRailRevealed)
final sideRailRevealedProvider = SideRailRevealedProvider._();

/// Whether the auto-hiding side panel is currently slid in over the page.
final class SideRailRevealedProvider
    extends $NotifierProvider<SideRailRevealed, bool> {
  /// Whether the auto-hiding side panel is currently slid in over the page.
  SideRailRevealedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sideRailRevealedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sideRailRevealedHash();

  @$internal
  @override
  SideRailRevealed create() => SideRailRevealed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$sideRailRevealedHash() => r'58351ad94f45d1fb8b3fe7cc28768d55e8006dfe';

/// Whether the auto-hiding side panel is currently slid in over the page.

abstract class _$SideRailRevealed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
