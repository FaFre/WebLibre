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

class FingerprintOverrides with FastEquatable {
  static final pattern = RegExp('([+-])([a-zA-Z_][a-zA-Z0-9_]{1,64})');

  final bool? allTargets;
  final Map<String, bool> targets;

  FingerprintOverrides(this.allTargets, this.targets);

  //Monitor https://searchfox.org/firefox-main/source/toolkit/components/resistfingerprinting/RFPTargetsDefault.inc
  FingerprintOverrides.defaults()
    : this(false, {
        'CanvasRandomization': true,
        'EfficientCanvasRandomization': true,
        'FontVisibilityLangPack': true,
        'JSMathFdlibm': true,
        'ScreenAvailToResolution': true,
        'NavigatorHWConcurrencyTiered': true,
        'MaxTouchPointsCollapse': true,
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
        'PointerId': true,
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
      });

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
          const ErrorMessage(source: 'FpParser', message: 'Invalid Override'),
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
