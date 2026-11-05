// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'browser_bar_tint.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The tint of the browser chrome: the selected tab's container color, or
/// null while no container is active or containers are hidden.

@ProviderFor(browserBarTint)
final browserBarTintProvider = BrowserBarTintProvider._();

/// The tint of the browser chrome: the selected tab's container color, or
/// null while no container is active or containers are hidden.

final class BrowserBarTintProvider
    extends
        $FunctionalProvider<BrowserBarTint?, BrowserBarTint?, BrowserBarTint?>
    with $Provider<BrowserBarTint?> {
  /// The tint of the browser chrome: the selected tab's container color, or
  /// null while no container is active or containers are hidden.
  BrowserBarTintProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserBarTintProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserBarTintHash();

  @$internal
  @override
  $ProviderElement<BrowserBarTint?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BrowserBarTint? create(Ref ref) {
    return browserBarTint(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BrowserBarTint? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BrowserBarTint?>(value),
    );
  }
}

String _$browserBarTintHash() => r'f4b61a4ea742eb5947d3f1cdac1b72afb3c5d9ae';
