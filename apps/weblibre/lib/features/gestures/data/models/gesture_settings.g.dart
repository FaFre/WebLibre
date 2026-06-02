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

  GestureSettings bindings(Map<String, GestureAction> bindings);

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
    Map<String, GestureAction> bindings,
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
  GestureSettings bindings(Map<String, GestureAction> bindings) =>
      call(bindings: bindings);

  @override
  /// Creates a new instance with the provided field values.
  /// Passing `null` to a nullable field nullifies it, while `null` for a non-nullable field is ignored. To update a single field use `GestureSettings(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// GestureSettings(...).copyWith(id: 12, name: "My name")
  /// ```
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
    Object? bindings = const $CopyWithPlaceholder(),
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
      bindings: bindings == const $CopyWithPlaceholder() || bindings == null
          ? _value.bindings
          // ignore: cast_nullable_to_non_nullable
          : bindings as Map<String, GestureAction>,
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
      bindings: (json['bindings'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$GestureActionEnumMap, e)),
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
      'bindings': instance.bindings.map(
        (k, e) => MapEntry(k, _$GestureActionEnumMap[e]!),
      ),
    };

const _$GestureActionEnumMap = {
  GestureAction.back: 'back',
  GestureAction.forward: 'forward',
  GestureAction.reload: 'reload',
  GestureAction.scrollTop: 'scrollTop',
  GestureAction.scrollBottom: 'scrollBottom',
  GestureAction.pageUp: 'pageUp',
  GestureAction.pageDown: 'pageDown',
  GestureAction.newTab: 'newTab',
  GestureAction.closeTab: 'closeTab',
  GestureAction.duplicateTab: 'duplicateTab',
  GestureAction.nextTab: 'nextTab',
  GestureAction.previousTab: 'previousTab',
  GestureAction.lastUsedTab: 'lastUsedTab',
  GestureAction.togglePinTab: 'togglePinTab',
  GestureAction.toggleReaderMode: 'toggleReaderMode',
  GestureAction.toggleDesktopMode: 'toggleDesktopMode',
  GestureAction.findInPage: 'findInPage',
  GestureAction.increaseFontSize: 'increaseFontSize',
  GestureAction.decreaseFontSize: 'decreaseFontSize',
  GestureAction.toggleBookmark: 'toggleBookmark',
  GestureAction.translatePage: 'translatePage',
  GestureAction.showHistory: 'showHistory',
  GestureAction.showBookmarks: 'showBookmarks',
  GestureAction.moveToBackground: 'moveToBackground',
  GestureAction.quitBrowser: 'quitBrowser',
};
