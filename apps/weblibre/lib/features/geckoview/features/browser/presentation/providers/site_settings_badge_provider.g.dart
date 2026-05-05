// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_settings_badge_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that determines the site settings badge state on the tab icon.

@ProviderFor(showSiteSettingsBadge)
final showSiteSettingsBadgeProvider = ShowSiteSettingsBadgeProvider._();

/// Provider that determines the site settings badge state on the tab icon.

final class ShowSiteSettingsBadgeProvider
    extends
        $FunctionalProvider<
          AsyncValue<SiteSettingsBadgeState>,
          SiteSettingsBadgeState,
          FutureOr<SiteSettingsBadgeState>
        >
    with
        $FutureModifier<SiteSettingsBadgeState>,
        $FutureProvider<SiteSettingsBadgeState> {
  /// Provider that determines the site settings badge state on the tab icon.
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
  $FutureProviderElement<SiteSettingsBadgeState> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SiteSettingsBadgeState> create(Ref ref) {
    return showSiteSettingsBadge(ref);
  }
}

String _$showSiteSettingsBadgeHash() =>
    r'fbfe409cdd6656d5cd26e377a68acde6ff4294fa';
