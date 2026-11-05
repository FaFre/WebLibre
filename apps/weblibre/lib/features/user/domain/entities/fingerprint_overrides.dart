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
import 'package:exceptions/exceptions.dart';
import 'package:fast_equatable/fast_equatable.dart';

/// Why a stored override string could not be parsed, carried in
/// [ErrorMessage.details] so the settings screen can say it in the UI
/// language ([ErrorMessage.message] stays English, for logs).
enum FingerprintOverrideParseFailure { invalidOverride, unknownTarget }

class FingerprintOverrides with FastEquatable {
  static final pattern = RegExp('([+-])([a-zA-Z_][a-zA-Z0-9_]{1,64})');

  final bool? allTargets;
  final Map<String, bool> targets;

  FingerprintOverrides(this.allTargets, this.targets);

  /// Gecko's release Android defaults
  /// (`toolkit/components/resistfingerprinting/RFPTargetsDefault.inc`), with
  /// one deliberate difference: no `EfficientCanvasRandomization`.
  ///
  /// When that target is on, Gecko picks its cheaper extraction mode
  /// (`dom/canvas/CanvasUtils.cpp`), and only `toDataURL`/`toBlob` honour it: `getImageData`, WebGL `readPixels`/`getBufferSubData`,
  /// ImageBitmap and OffscreenCanvas all check for the full `Randomize` mode
  /// and return unnoised pixels. Without it, `CanvasRandomization` noises every
  /// readback.
  ///
  /// The list is explicit (it starts with `-AllTargets`) because the editor
  /// can only show a target as on when it is listed. A test pins it to the
  /// Gecko default set, so update both when Gecko adds a default.
  FingerprintOverrides.defaults()
    : this(false, {
        'CanvasRandomization': true,
        'FontVisibilityLangPack': true,
        'JSMathFdlibm': true,
        'ScreenAvailToResolution': true,
        'NavigatorHWConcurrencyTiered': true,
        'MaxTouchPointsCollapse': true,
        'IMEStyle': true,
      });

  FingerprintOverrides.hardenedDefaults()
    : this(false, {
        'TouchEvents': true,
        'PointerEvents': true,
        'KeyboardEvents': true,
        'ScreenOrientation': true,
        'SpeechSynthesis': true,
        'CSSPrefersReducedMotion': true,
        'CSSPrefersContrast': true,
        'CanvasRandomization': true,
        'CanvasExtractionFromThirdPartiesIsBlocked': true,
        'JSLocale': true,
        'NavigatorAppVersion': true,
        'NavigatorBuildID': true,
        'NavigatorHWConcurrency': true,
        'NavigatorOscpu': true,
        'NavigatorPlatform': true,
        'NavigatorUserAgent': true,
        'PdfjsSpoof': true,
        'StreamVideoFacingMode': true,
        'JSDateTimeUTC': true,
        'JSMathFdlibm': true,
        'Gamepad': true,
        'HttpUserAgent': true,
        'WindowOuterSize': true,
        'WindowScreenXY': true,
        'WindowInnerScreenXY': true,
        'ScreenPixelDepth': true,
        'ScreenRect': true,
        'ScreenAvailRect': true,
        'VideoElementMozFrames': true,
        'VideoElementMozFrameDelay': true,
        'VideoElementPlaybackQuality': true,
        'ReduceTimerPrecision': true,
        'WidgetEvents': true,
        'MediaDevices': true,
        'MediaCapabilities': true,
        'AudioSampleRate': true,
        'NetworkConnection': true,
        'WindowDevicePixelRatio': true,
        'MouseEventScreenPoint': true,
        'FontVisibilityBaseSystem': true,
        'FontVisibilityLangPack': true,
        'DeviceSensors': true,
        'RoundWindowSize': true,
        'UseStandinsForNativeColors': true,
        'AudioContext': true,
        'MediaError': true,
        'DOMStyleOsxFontSmoothing': true,
        'CSSDeviceSize': true,
        'CSSColorInfo': true,
        'CSSResolution': true,
        'CSSPrefersReducedTransparency': true,
        'CSSInvertedColors': true,
        'CSSVideoDynamicRange': true,
        'CSSPointerCapabilities': true,
        'WebGLRenderCapability': true,
        'WebGLRenderInfo': true,
        'SiteSpecificZoom': true,
        'FontVisibilityRestrictGenerics': true,
        'WebVTT': true,
        'WebGPULimits': true,
        'WebGPUIsFallbackAdapter': true,
        'WebGPUSubgroupSizes': true,
        'JSLocalePrompt': true,
        'ScreenAvailToResolution': true,
        'UseHardcodedFontSubstitutes': true,
        'DiskStorageLimit': true,
        'WebCodecs': true,
        'MaxTouchPoints': true,
        'MaxTouchPointsCollapse': true,
        'NavigatorHWConcurrencyTiered': true,
        'IMEStyle': true,
      });

  /// Targets Gecko has removed. A stored string that still names one would
  /// fail [parse] as a whole, so [upgradeStored] drops them.
  ///
  /// `PointerId` (id 20) is gone since Gecko 159; the id now belongs to
  /// `PdfjsSpoof`.
  static const retiredTargets = {'PointerId'};

  /// [defaults] and [hardenedDefaults] as every release before Gecko 159
  /// stored them. They never changed between those releases.
  static const _legacyDefaults =
      '-AllTargets,+CanvasRandomization,+EfficientCanvasRandomization,'
      '+FontVisibilityLangPack,+JSMathFdlibm,+ScreenAvailToResolution,'
      '+NavigatorHWConcurrencyTiered,+MaxTouchPointsCollapse';
  static const _legacyHardenedDefaults =
      '-AllTargets,+TouchEvents,+PointerEvents,+KeyboardEvents,'
      '+ScreenOrientation,+SpeechSynthesis,+CSSPrefersReducedMotion,'
      '+CSSPrefersContrast,+CanvasRandomization,'
      '+CanvasExtractionFromThirdPartiesIsBlocked,+JSLocale,'
      '+NavigatorAppVersion,+NavigatorBuildID,+NavigatorHWConcurrency,'
      '+NavigatorOscpu,+NavigatorPlatform,+NavigatorUserAgent,+PointerId,'
      '+StreamVideoFacingMode,+JSDateTimeUTC,+JSMathFdlibm,+Gamepad,'
      '+HttpUserAgent,+WindowOuterSize,+WindowScreenXY,+WindowInnerScreenXY,'
      '+ScreenPixelDepth,+ScreenRect,+ScreenAvailRect,+VideoElementMozFrames,'
      '+VideoElementMozFrameDelay,+VideoElementPlaybackQuality,'
      '+ReduceTimerPrecision,+WidgetEvents,+MediaDevices,+MediaCapabilities,'
      '+AudioSampleRate,+NetworkConnection,+WindowDevicePixelRatio,'
      '+MouseEventScreenPoint,+FontVisibilityBaseSystem,'
      '+FontVisibilityLangPack,+DeviceSensors,+RoundWindowSize,'
      '+UseStandinsForNativeColors,+AudioContext,+MediaError,'
      '+DOMStyleOsxFontSmoothing,+CSSDeviceSize,+CSSColorInfo,+CSSResolution,'
      '+CSSPrefersReducedTransparency,+CSSInvertedColors,'
      '+CSSVideoDynamicRange,+CSSPointerCapabilities,+WebGLRenderCapability,'
      '+WebGLRenderInfo,+SiteSpecificZoom,+FontVisibilityRestrictGenerics,'
      '+WebVTT,+WebGPULimits,+WebGPUIsFallbackAdapter,+WebGPUSubgroupSizes,'
      '+JSLocalePrompt,+ScreenAvailToResolution,+UseHardcodedFontSubstitutes,'
      '+DiskStorageLimit,+WebCodecs,+MaxTouchPoints,+MaxTouchPointsCollapse,'
      '+NavigatorHWConcurrencyTiered';

  /// Brings a stored override string up to date. Idempotent, so it runs on
  /// every load.
  ///
  /// A string that is exactly an earlier preset becomes today's preset: the
  /// presets are recognised by string equality (the onboarding tiles,
  /// `EngineSettings.effective`), so a stale copy would stop counting as one.
  /// Anything else is the user's own list and keeps every choice in it; only
  /// targets Gecko no longer has are dropped.
  static String upgradeStored(String stored) {
    if (stored == _legacyDefaults) {
      return FingerprintOverrides.defaults().toString();
    }
    if (stored == _legacyHardenedDefaults) {
      return FingerprintOverrides.hardenedDefaults().toString();
    }

    if (!retiredTargets.any(stored.contains)) {
      return stored;
    }

    return stored
        .split(',')
        .where((word) {
          final match = pattern.firstMatch(word.trim());
          return match == null || !retiredTargets.contains(match.group(2));
        })
        .join(',');
  }

  static Result<FingerprintOverrides> parse(
    String input,
    Set<String> availableTargets,
  ) {
    final cleaned = input.replaceAll(RegExp(r'\s'), '');
    if (cleaned.isEmpty) return Result.success(FingerprintOverrides(null, {}));

    bool? allTargets;
    final targets = <String, bool>{};

    for (final word in cleaned.split(',')) {
      final match = pattern.firstMatch(word);
      if (match == null) {
        return Result.failure(
          const ErrorMessage(
            source: 'FpParser',
            message: 'Invalid Override',
            details: FingerprintOverrideParseFailure.invalidOverride,
          ),
        );
      }

      final enabled = match.group(1) != '-';
      final name = match.group(2)!;

      if (name == 'AllTargets') {
        allTargets = enabled;
        continue;
      }

      if (!availableTargets.contains(name)) {
        return Result.failure(
          const ErrorMessage(
            source: 'FpParser',
            message: 'Invalid target name',
            details: FingerprintOverrideParseFailure.unknownTarget,
          ),
        );
      }

      targets[name] = enabled;
    }

    return Result.success(FingerprintOverrides(allTargets, targets));
  }

  @override
  String toString() {
    final sb = StringBuffer();

    if (allTargets != null) {
      sb.write('${allTargets! ? '+' : '-'}AllTargets');
      if (targets.isNotEmpty) {
        sb.write(',');
      }
    }

    sb.write(
      targets.entries.map((e) => (e.value ? '+' : '-') + e.key).join(','),
    );

    return sb.toString();
  }

  FingerprintOverrides copyWithAllTargetsEnabled(bool value) {
    return FingerprintOverrides(
      value,
      Map.fromEntries(targets.entries.where((e) => e.value != value)),
    );
  }

  FingerprintOverrides copyWithTarget(String name, bool value) {
    if (value && allTargets == true) {
      return this;
    }

    return FingerprintOverrides(allTargets, {...targets, name: value});
  }

  @override
  List<Object?> get hashParameters => [allTargets, targets];
}
