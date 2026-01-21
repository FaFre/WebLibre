// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_settings_badge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that determines whether to show the site settings badge on the tab icon.
/// Returns true if any site-specific setting has been altered from defaults.

@ProviderFor(showSiteSettingsBadge)
final showSiteSettingsBadgeProvider = ShowSiteSettingsBadgeProvider._();

/// Provider that determines whether to show the site settings badge on the tab icon.
/// Returns true if any site-specific setting has been altered from defaults.

final class ShowSiteSettingsBadgeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider that determines whether to show the site settings badge on the tab icon.
  /// Returns true if any site-specific setting has been altered from defaults.
  ShowSiteSettingsBadgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showSiteSettingsBadgeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showSiteSettingsBadgeHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return showSiteSettingsBadge(ref);
  }
}

String _$showSiteSettingsBadgeHash() =>
    r'8b759a67e5c8b0f49a5d38b793a3357576a2eb87';
