// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_layout.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$MenuItemEntryCWProxy {
  MenuItemEntry visible(bool visible);

  MenuItemEntry items(List<MenuItemEntry> items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MenuItemEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MenuItemEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  MenuItemEntry call({bool visible, List<MenuItemEntry> items});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMenuItemEntry.copyWith(...)` or call `instanceOfMenuItemEntry.copyWith.fieldName(value)` for a single field.
class _$MenuItemEntryCWProxyImpl implements _$MenuItemEntryCWProxy {
  const _$MenuItemEntryCWProxyImpl(this._value);

  final MenuItemEntry _value;

  @override
  MenuItemEntry visible(bool visible) => call(visible: visible);

  @override
  MenuItemEntry items(List<MenuItemEntry> items) => call(items: items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MenuItemEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MenuItemEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MenuItemEntry call({
    Object? visible = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return MenuItemEntry(
      type: _value.type,
      visible: visible == const $CopyWithPlaceholder() || visible == null
          ? _value.visible
          // ignore: cast_nullable_to_non_nullable
          : visible as bool,
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<MenuItemEntry>,
    );
  }
}

extension $MenuItemEntryCopyWith on MenuItemEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMenuItemEntry.copyWith(...)` or `instanceOfMenuItemEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MenuItemEntryCWProxy get copyWith => _$MenuItemEntryCWProxyImpl(this);
}

abstract class _$MenuSectionEntryCWProxy {
  MenuSectionEntry visible(bool visible);

  MenuSectionEntry items(List<MenuItemEntry> items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MenuSectionEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MenuSectionEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  MenuSectionEntry call({bool visible, List<MenuItemEntry> items});
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfMenuSectionEntry.copyWith(...)` or call `instanceOfMenuSectionEntry.copyWith.fieldName(value)` for a single field.
class _$MenuSectionEntryCWProxyImpl implements _$MenuSectionEntryCWProxy {
  const _$MenuSectionEntryCWProxyImpl(this._value);

  final MenuSectionEntry _value;

  @override
  MenuSectionEntry visible(bool visible) => call(visible: visible);

  @override
  MenuSectionEntry items(List<MenuItemEntry> items) => call(items: items);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `MenuSectionEntry(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// MenuSectionEntry(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  MenuSectionEntry call({
    Object? visible = const $CopyWithPlaceholder(),
    Object? items = const $CopyWithPlaceholder(),
  }) {
    return MenuSectionEntry(
      type: _value.type,
      visible: visible == const $CopyWithPlaceholder() || visible == null
          ? _value.visible
          // ignore: cast_nullable_to_non_nullable
          : visible as bool,
      items: items == const $CopyWithPlaceholder() || items == null
          ? _value.items
          // ignore: cast_nullable_to_non_nullable
          : items as List<MenuItemEntry>,
    );
  }
}

extension $MenuSectionEntryCopyWith on MenuSectionEntry {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfMenuSectionEntry.copyWith(...)` or `instanceOfMenuSectionEntry.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$MenuSectionEntryCWProxy get copyWith => _$MenuSectionEntryCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItemEntry _$MenuItemEntryFromJson(Map<String, dynamic> json) =>
    MenuItemEntry(
      type: $enumDecode(_$MenuItemTypeEnumMap, json['type']),
      visible: json['visible'] as bool,
      items: json['items'] == null
          ? const []
          : menuItemEntriesFromJson(json['items']),
    );

Map<String, dynamic> _$MenuItemEntryToJson(MenuItemEntry instance) =>
    <String, dynamic>{
      'type': _$MenuItemTypeEnumMap[instance.type]!,
      'visible': instance.visible,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

const _$MenuItemTypeEnumMap = {
  MenuItemType.desktopMode: 'desktopMode',
  MenuItemType.readerMode: 'readerMode',
  MenuItemType.gestures: 'gestures',
  MenuItemType.addBookmark: 'addBookmark',
  MenuItemType.findInPage: 'findInPage',
  MenuItemType.translatePage: 'translatePage',
  MenuItemType.addToHomeScreen: 'addToHomeScreen',
  MenuItemType.openInApp: 'openInApp',
  MenuItemType.containers: 'containers',
  MenuItemType.manageContainers: 'manageContainers',
  MenuItemType.assignContainer: 'assignContainer',
  MenuItemType.assignUrlToContainer: 'assignUrlToContainer',
  MenuItemType.unassignUrlFromContainer: 'unassignUrlFromContainer',
  MenuItemType.unassignContainer: 'unassignContainer',
  MenuItemType.share: 'share',
  MenuItemType.copyAddress: 'copyAddress',
  MenuItemType.shareScreenshot: 'shareScreenshot',
  MenuItemType.shareLink: 'shareLink',
  MenuItemType.sendToDevice: 'sendToDevice',
  MenuItemType.showQrCode: 'showQrCode',
  MenuItemType.moreDisclosure: 'moreDisclosure',
  MenuItemType.cloneTab: 'cloneTab',
  MenuItemType.cloneRegularTab: 'cloneRegularTab',
  MenuItemType.clonePrivateTab: 'clonePrivateTab',
  MenuItemType.cloneIsolatedTab: 'cloneIsolatedTab',
  MenuItemType.export: 'export',
  MenuItemType.copyAsMarkdown: 'copyAsMarkdown',
  MenuItemType.exportAsMarkdown: 'exportAsMarkdown',
  MenuItemType.exportAsPdf: 'exportAsPdf',
  MenuItemType.exportAsPng: 'exportAsPng',
  MenuItemType.printPage: 'printPage',
  MenuItemType.pinTopSite: 'pinTopSite',
  MenuItemType.fetchFeeds: 'fetchFeeds',
  MenuItemType.history: 'history',
  MenuItemType.bookmarks: 'bookmarks',
  MenuItemType.downloads: 'downloads',
  MenuItemType.bangs: 'bangs',
  MenuItemType.feeds: 'feeds',
  MenuItemType.smallWeb: 'smallWeb',
  MenuItemType.clearData: 'clearData',
  MenuItemType.profileSwitch: 'profileSwitch',
  MenuItemType.syncNow: 'syncNow',
  MenuItemType.appSettings: 'appSettings',
  MenuItemType.quitBrowser: 'quitBrowser',
  MenuItemType.about: 'about',
};

MenuSectionEntry _$MenuSectionEntryFromJson(Map<String, dynamic> json) =>
    MenuSectionEntry(
      type: $enumDecode(_$MenuSectionTypeEnumMap, json['type']),
      visible: json['visible'] as bool,
      items: json['items'] == null
          ? const []
          : menuItemEntriesFromJson(json['items']),
    );

Map<String, dynamic> _$MenuSectionEntryToJson(MenuSectionEntry instance) =>
    <String, dynamic>{
      'type': _$MenuSectionTypeEnumMap[instance.type]!,
      'visible': instance.visible,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

const _$MenuSectionTypeEnumMap = {
  MenuSectionType.quickToggles: 'quickToggles',
  MenuSectionType.pageActions: 'pageActions',
  MenuSectionType.extensions: 'extensions',
  MenuSectionType.tabActions: 'tabActions',
  MenuSectionType.quickLinks: 'quickLinks',
  MenuSectionType.connection: 'connection',
  MenuSectionType.profile: 'profile',
  MenuSectionType.about: 'about',
};
