/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/gestures/data/models/gesture_action.dart';
import 'package:weblibre/utils/uri_input_parser.dart';

part 'gesture_settings.g.dart';

const defaultGestureStrokeSize = 50;
const minGestureStrokeSize = 20;
const maxGestureStrokeSize = 100;

const defaultGestureTimeoutMs = 1500;
const minGestureTimeoutMs = 500;
const maxGestureTimeoutMs = 3000;

const defaultGestureMaxFingers = 1;

const defaultGestureIntervalMs = 0;
const minGestureIntervalMs = 0;
const maxGestureIntervalMs = 2000;

/// Minimum number of strokes drawn before the live overlay starts suggesting
/// the other possible completions (mirrors the reference add-on's
/// `toastMinStroke`).
const defaultGestureMinSuggestionStroke = 2;
const minGestureMinSuggestionStroke = 1;
const maxGestureMinSuggestionStroke = 5;

/// Default gesture-to-action bindings, aligned with the reference add-on's
/// defaults for the actions WebLibre currently supports.
const defaultGestureBindings = <String, GestureAction>{
  'D-L': GestureAction.forward,
  'D-R': GestureAction.back,
  'R-D': GestureAction.scrollTop,
  'R-U': GestureAction.scrollBottom,
  'D-R-U': GestureAction.reload,
  'L-D-R': GestureAction.closeTab,
};

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class GestureSettings with FastEquatable {
  /// Master switch. When false, gesture recognition is fully disabled and the
  /// quick toggles ([active]) have no effect.
  final bool enabled;

  /// Runtime toggle exposed via the quick toggles (menu sheet tile, contextual
  /// toolbar button). Lets the user suspend gestures without touching the
  /// master switch. The recognizer runs only when [enabled] && [active].
  final bool active;

  /// Base stroke length in logical pixels (scaled to the screen by native).
  final int strokeSize;

  /// Milliseconds of inactivity after which an in-progress gesture is dropped.
  final int timeoutMs;

  /// Maximum simultaneous pointers a gesture may use.
  final int maxFingers;

  /// Cooldown in milliseconds after a gesture fires, during which further
  /// gestures are ignored. 0 disables the cooldown.
  final int intervalMs;

  /// Whether to show the live feedback overlay while a stroke is being drawn
  /// (the in-progress arrows plus the matching/possible actions).
  final bool showFeedback;

  /// Within the live overlay, also suggest the other possible completions once
  /// at least [minSuggestionStroke] strokes have been drawn.
  final bool suggestNext;

  /// Minimum strokes drawn before [suggestNext] kicks in.
  final int minSuggestionStroke;

  /// Hosts on which gestures are disabled. A page is excluded when its host
  /// equals or is a subdomain of any entry (see `isGestureSiteExcluded`).
  final List<String> excludedSites;

  /// Canonical gesture key → action. Keys follow the grammar documented on
  /// [GestureStroke].
  final Map<String, GestureAction> bindings;

  GestureSettings({
    required this.enabled,
    required this.active,
    required this.strokeSize,
    required this.timeoutMs,
    required this.maxFingers,
    required this.intervalMs,
    required this.showFeedback,
    required this.suggestNext,
    required this.minSuggestionStroke,
    required this.excludedSites,
    required this.bindings,
  });

  GestureSettings.withDefaults({
    bool? enabled,
    bool? active,
    int? strokeSize,
    int? timeoutMs,
    int? maxFingers,
    int? intervalMs,
    bool? showFeedback,
    bool? suggestNext,
    int? minSuggestionStroke,
    List<String>? excludedSites,
    Map<String, GestureAction>? bindings,
  }) : enabled = enabled ?? false,
       active = active ?? true,
       strokeSize = strokeSize ?? defaultGestureStrokeSize,
       timeoutMs = timeoutMs ?? defaultGestureTimeoutMs,
       maxFingers = maxFingers ?? defaultGestureMaxFingers,
       intervalMs = intervalMs ?? defaultGestureIntervalMs,
       showFeedback = showFeedback ?? true,
       suggestNext = suggestNext ?? true,
       minSuggestionStroke =
           minSuggestionStroke ?? defaultGestureMinSuggestionStroke,
       excludedSites = excludedSites ?? const [],
       bindings = bindings ?? defaultGestureBindings;

  /// Whether the recognizer should actually run.
  bool get effectiveEnabled => enabled && active;

  factory GestureSettings.fromJson(Map<String, dynamic> json) =>
      _$GestureSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$GestureSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    enabled,
    active,
    strokeSize,
    timeoutMs,
    maxFingers,
    intervalMs,
    showFeedback,
    suggestNext,
    minSuggestionStroke,
    excludedSites,
    bindings,
  ];
}

/// Normalises a user-entered site into a bare lowercase host, e.g.
/// `https://News.example.com/foo` → `news.example.com`. Accepts either a full
/// URL or a bare host, and validates the result with the same rules the address
/// bar uses ([isValidHostCandidate]). Returns null for input without a valid
/// host.
String? normalizeGestureSiteHost(String input) {
  final trimmed = input.trim().toLowerCase();
  if (trimmed.isEmpty) return null;

  final candidate = trimmed.contains('://') ? trimmed : 'https://$trimmed';
  final host = Uri.tryParse(candidate)?.host;
  if (host == null || host.isEmpty) return null;

  return isValidHostCandidate(host) ? host : null;
}

/// Whether [url] is covered by any entry in [excludedSites]. An entry matches
/// the URL's host exactly or as a parent domain (so `example.com` also covers
/// `m.example.com`).
bool isGestureSiteExcluded(Uri url, List<String> excludedSites) {
  final host = url.host.toLowerCase();
  if (host.isEmpty) return false;

  for (final entry in excludedSites) {
    final pattern = entry.toLowerCase();
    if (pattern.isEmpty) continue;
    if (host == pattern || host.endsWith('.$pattern')) return true;
  }
  return false;
}
