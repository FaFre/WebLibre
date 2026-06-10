// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'display_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Always-mounted side-effect provider that pushes the configured
/// [RefreshRateMode] to the OS whenever it changes. Flutter does not request a
/// high refresh rate by default, so without this the app stays at 60Hz on many
/// devices even when the panel supports more.
///
/// Watched from the root widget so it stays alive for the whole app lifetime.
/// The body re-runs on every change of the setting (including the initial
/// build), so the mode is applied at startup as well as on later edits.

@ProviderFor(displayModeApplier)
final displayModeApplierProvider = DisplayModeApplierProvider._();

/// Always-mounted side-effect provider that pushes the configured
/// [RefreshRateMode] to the OS whenever it changes. Flutter does not request a
/// high refresh rate by default, so without this the app stays at 60Hz on many
/// devices even when the panel supports more.
///
/// Watched from the root widget so it stays alive for the whole app lifetime.
/// The body re-runs on every change of the setting (including the initial
/// build), so the mode is applied at startup as well as on later edits.

final class DisplayModeApplierProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Always-mounted side-effect provider that pushes the configured
  /// [RefreshRateMode] to the OS whenever it changes. Flutter does not request a
  /// high refresh rate by default, so without this the app stays at 60Hz on many
  /// devices even when the panel supports more.
  ///
  /// Watched from the root widget so it stays alive for the whole app lifetime.
  /// The body re-runs on every change of the setting (including the initial
  /// build), so the mode is applied at startup as well as on later edits.
  DisplayModeApplierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'displayModeApplierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$displayModeApplierHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return displayModeApplier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$displayModeApplierHash() =>
    r'10e3dab5052bed606d3fd02a08103d2ac3f99f13';
