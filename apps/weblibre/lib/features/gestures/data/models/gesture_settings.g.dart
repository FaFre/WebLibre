// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gesture_settings.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$GestureSettingsCWProxy {
  GestureSettings enabled(bool enabled);

  GestureSettings active(bool active);

  GestureSettings strokeSize(int strokeSize);

  GestureSettings timeoutMs(int timeoutMs);

  GestureSettings maxFingers(int maxFingers);

  GestureSettings intervalMs(int intervalMs);

  GestureSettings minStrokeIntervalMs(int minStrokeIntervalMs);

  GestureSettings showFeedback(bool showFeedback);

  GestureSettings suggestNext(bool suggestNext);

  GestureSettings minSuggestionStroke(int minSuggestionStroke);

  GestureSettings excludedSites(List<String> excludedSites);

  GestureSettings bindingOverrides(
    Map<String, BrowserAction?> bindingOverrides,
  );

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GestureSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GestureSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  GestureSettings call({
    bool enabled,
    bool active,
    int strokeSize,
    int timeoutMs,
    int maxFingers,
    int intervalMs,
    int minStrokeIntervalMs,
    bool showFeedback,
    bool suggestNext,
    int minSuggestionStroke,
    List<String> excludedSites,
    Map<String, BrowserAction?> bindingOverrides,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfGestureSettings.copyWith(...)` or call `instanceOfGestureSettings.copyWith.fieldName(value)` for a single field.
class _$GestureSettingsCWProxyImpl implements _$GestureSettingsCWProxy {
  const _$GestureSettingsCWProxyImpl(this._value);

  final GestureSettings _value;

  @override
  GestureSettings enabled(bool enabled) => call(enabled: enabled);

  @override
  GestureSettings active(bool active) => call(active: active);

  @override
  GestureSettings strokeSize(int strokeSize) => call(strokeSize: strokeSize);

  @override
  GestureSettings timeoutMs(int timeoutMs) => call(timeoutMs: timeoutMs);

  @override
  GestureSettings maxFingers(int maxFingers) => call(maxFingers: maxFingers);

  @override
  GestureSettings intervalMs(int intervalMs) => call(intervalMs: intervalMs);

  @override
  GestureSettings minStrokeIntervalMs(int minStrokeIntervalMs) =>
      call(minStrokeIntervalMs: minStrokeIntervalMs);

  @override
  GestureSettings showFeedback(bool showFeedback) =>
      call(showFeedback: showFeedback);

  @override
  GestureSettings suggestNext(bool suggestNext) =>
      call(suggestNext: suggestNext);

  @override
  GestureSettings minSuggestionStroke(int minSuggestionStroke) =>
      call(minSuggestionStroke: minSuggestionStroke);

  @override
  GestureSettings excludedSites(List<String> excludedSites) =>
      call(excludedSites: excludedSites);

  @override
  GestureSettings bindingOverrides(
    Map<String, BrowserAction?> bindingOverrides,
  ) => call(bindingOverrides: bindingOverrides);

  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GestureSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GestureSettings(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  GestureSettings call({
    Object? enabled = const $CopyWithPlaceholder(),
    Object? active = const $CopyWithPlaceholder(),
    Object? strokeSize = const $CopyWithPlaceholder(),
    Object? timeoutMs = const $CopyWithPlaceholder(),
    Object? maxFingers = const $CopyWithPlaceholder(),
    Object? intervalMs = const $CopyWithPlaceholder(),
    Object? minStrokeIntervalMs = const $CopyWithPlaceholder(),
    Object? showFeedback = const $CopyWithPlaceholder(),
    Object? suggestNext = const $CopyWithPlaceholder(),
    Object? minSuggestionStroke = const $CopyWithPlaceholder(),
    Object? excludedSites = const $CopyWithPlaceholder(),
    Object? bindingOverrides = const $CopyWithPlaceholder(),
  }) {
    return GestureSettings(
      enabled: enabled == const $CopyWithPlaceholder() || enabled == null
          ? _value.enabled
          // ignore: cast_nullable_to_non_nullable
          : enabled as bool,
      active: active == const $CopyWithPlaceholder() || active == null
          ? _value.active
          // ignore: cast_nullable_to_non_nullable
          : active as bool,
      strokeSize:
          strokeSize == const $CopyWithPlaceholder() || strokeSize == null
          ? _value.strokeSize
          // ignore: cast_nullable_to_non_nullable
          : strokeSize as int,
      timeoutMs: timeoutMs == const $CopyWithPlaceholder() || timeoutMs == null
          ? _value.timeoutMs
          // ignore: cast_nullable_to_non_nullable
          : timeoutMs as int,
      maxFingers:
          maxFingers == const $CopyWithPlaceholder() || maxFingers == null
          ? _value.maxFingers
          // ignore: cast_nullable_to_non_nullable
          : maxFingers as int,
      intervalMs:
          intervalMs == const $CopyWithPlaceholder() || intervalMs == null
          ? _value.intervalMs
          // ignore: cast_nullable_to_non_nullable
          : intervalMs as int,
      minStrokeIntervalMs:
          minStrokeIntervalMs == const $CopyWithPlaceholder() ||
              minStrokeIntervalMs == null
          ? _value.minStrokeIntervalMs
          // ignore: cast_nullable_to_non_nullable
          : minStrokeIntervalMs as int,
      showFeedback:
          showFeedback == const $CopyWithPlaceholder() || showFeedback == null
          ? _value.showFeedback
          // ignore: cast_nullable_to_non_nullable
          : showFeedback as bool,
      suggestNext:
          suggestNext == const $CopyWithPlaceholder() || suggestNext == null
          ? _value.suggestNext
          // ignore: cast_nullable_to_non_nullable
          : suggestNext as bool,
      minSuggestionStroke:
          minSuggestionStroke == const $CopyWithPlaceholder() ||
              minSuggestionStroke == null
          ? _value.minSuggestionStroke
          // ignore: cast_nullable_to_non_nullable
          : minSuggestionStroke as int,
      excludedSites:
          excludedSites == const $CopyWithPlaceholder() || excludedSites == null
          ? _value.excludedSites
          // ignore: cast_nullable_to_non_nullable
          : excludedSites as List<String>,
      bindingOverrides:
          bindingOverrides == const $CopyWithPlaceholder() ||
              bindingOverrides == null
          ? _value.bindingOverrides
          // ignore: cast_nullable_to_non_nullable
          : bindingOverrides as Map<String, BrowserAction?>,
    );
  }
}

extension $GestureSettingsCopyWith on GestureSettings {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfGestureSettings.copyWith(...)` or `instanceOfGestureSettings.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$GestureSettingsCWProxy get copyWith => _$GestureSettingsCWProxyImpl(this);
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GestureSettings _$GestureSettingsFromJson(Map<String, dynamic> json) =>
    GestureSettings.withDefaults(
      enabled: json['enabled'] as bool?,
      active: json['active'] as bool?,
      strokeSize: (json['strokeSize'] as num?)?.toInt(),
      timeoutMs: (json['timeoutMs'] as num?)?.toInt(),
      maxFingers: (json['maxFingers'] as num?)?.toInt(),
      intervalMs: (json['intervalMs'] as num?)?.toInt(),
      minStrokeIntervalMs: (json['minStrokeIntervalMs'] as num?)?.toInt(),
      showFeedback: json['showFeedback'] as bool?,
      suggestNext: json['suggestNext'] as bool?,
      minSuggestionStroke: (json['minSuggestionStroke'] as num?)?.toInt(),
      excludedSites: (json['excludedSites'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bindingOverrides: (json['bindingOverrides'] as Map<String, dynamic>?)
          ?.map(
            (k, e) =>
                MapEntry(k, $enumDecodeNullable(_$BrowserActionEnumMap, e)),
          ),
    );

Map<String, dynamic> _$GestureSettingsToJson(GestureSettings instance) =>
    <String, dynamic>{
      'enabled': instance.enabled,
      'active': instance.active,
      'strokeSize': instance.strokeSize,
      'timeoutMs': instance.timeoutMs,
      'maxFingers': instance.maxFingers,
      'intervalMs': instance.intervalMs,
      'minStrokeIntervalMs': instance.minStrokeIntervalMs,
      'showFeedback': instance.showFeedback,
      'suggestNext': instance.suggestNext,
      'minSuggestionStroke': instance.minSuggestionStroke,
      'excludedSites': instance.excludedSites,
      'bindingOverrides': instance.bindingOverrides.map(
        (k, e) => MapEntry(k, _$BrowserActionEnumMap[e]),
      ),
    };

const _$BrowserActionEnumMap = {
  BrowserAction.focusAddressBar: 'focusAddressBar',
  BrowserAction.back: 'back',
  BrowserAction.forward: 'forward',
  BrowserAction.reload: 'reload',
  BrowserAction.hardReload: 'hardReload',
  BrowserAction.scrollTop: 'scrollTop',
  BrowserAction.scrollBottom: 'scrollBottom',
  BrowserAction.pageUp: 'pageUp',
  BrowserAction.pageDown: 'pageDown',
  BrowserAction.newTab: 'newTab',
  BrowserAction.newPrivateTab: 'newPrivateTab',
  BrowserAction.closeTab: 'closeTab',
  BrowserAction.reopenClosedTab: 'reopenClosedTab',
  BrowserAction.duplicateTab: 'duplicateTab',
  BrowserAction.nextTab: 'nextTab',
  BrowserAction.previousTab: 'previousTab',
  BrowserAction.lastUsedTab: 'lastUsedTab',
  BrowserAction.selectTab1: 'selectTab1',
  BrowserAction.selectTab2: 'selectTab2',
  BrowserAction.selectTab3: 'selectTab3',
  BrowserAction.selectTab4: 'selectTab4',
  BrowserAction.selectTab5: 'selectTab5',
  BrowserAction.selectTab6: 'selectTab6',
  BrowserAction.selectTab7: 'selectTab7',
  BrowserAction.selectTab8: 'selectTab8',
  BrowserAction.selectLastTab: 'selectLastTab',
  BrowserAction.togglePinTab: 'togglePinTab',
  BrowserAction.moveTabBackward: 'moveTabBackward',
  BrowserAction.moveTabForward: 'moveTabForward',
  BrowserAction.moveTabToStart: 'moveTabToStart',
  BrowserAction.moveTabToEnd: 'moveTabToEnd',
  BrowserAction.nextContainer: 'nextContainer',
  BrowserAction.previousContainer: 'previousContainer',
  BrowserAction.toggleReaderMode: 'toggleReaderMode',
  BrowserAction.toggleDesktopMode: 'toggleDesktopMode',
  BrowserAction.findInPage: 'findInPage',
  BrowserAction.findNext: 'findNext',
  BrowserAction.findPrevious: 'findPrevious',
  BrowserAction.increaseFontSize: 'increaseFontSize',
  BrowserAction.decreaseFontSize: 'decreaseFontSize',
  BrowserAction.resetFontSize: 'resetFontSize',
  BrowserAction.toggleBookmark: 'toggleBookmark',
  BrowserAction.translatePage: 'translatePage',
  BrowserAction.printPage: 'printPage',
  BrowserAction.showHome: 'showHome',
  BrowserAction.showHistory: 'showHistory',
  BrowserAction.showBookmarks: 'showBookmarks',
  BrowserAction.showContainers: 'showContainers',
  BrowserAction.showTabView: 'showTabView',
  BrowserAction.showDownloads: 'showDownloads',
  BrowserAction.showAddons: 'showAddons',
  BrowserAction.openSettings: 'openSettings',
  BrowserAction.showKeyboardShortcuts: 'showKeyboardShortcuts',
  BrowserAction.toggleTabBar: 'toggleTabBar',
  BrowserAction.clearBrowsingData: 'clearBrowsingData',
  BrowserAction.moveToBackground: 'moveToBackground',
  BrowserAction.quitBrowser: 'quitBrowser',
};
