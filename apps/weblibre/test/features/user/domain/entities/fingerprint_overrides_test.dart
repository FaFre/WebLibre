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
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/rfp_target.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';

/// Gecko 159's release Android defaults
/// (`toolkit/components/resistfingerprinting/RFPTargetsDefault.inc`; the
/// WebGL vendor and renderer defaults there are Nightly-only).
const _geckoAndroidDefaults = {
  'CanvasRandomization',
  'EfficientCanvasRandomization',
  'FontVisibilityLangPack',
  'JSMathFdlibm',
  'ScreenAvailToResolution',
  'NavigatorHWConcurrencyTiered',
  'MaxTouchPointsCollapse',
  'IMEStyle',
};

/// What every release before Gecko 159 stored for the two presets. Frozen
/// copies: the point is that these exact strings keep being recognised.
const _legacyDefaults =
    '-AllTargets,+CanvasRandomization,+EfficientCanvasRandomization,'
    '+FontVisibilityLangPack,+JSMathFdlibm,+ScreenAvailToResolution,'
    '+NavigatorHWConcurrencyTiered,+MaxTouchPointsCollapse';
const _legacyHardenedDefaults =
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

Future<List<RFPTarget>> _loadTargets() async {
  final json =
      jsonDecode(
            await rootBundle.loadString('assets/preferences/rfp_targets.json'),
          )
          as List<dynamic>;
  return json
      .map((e) => RFPTarget.fromJson(e as Map<String, dynamic>))
      .toList();
}

Set<String> _enabledTargets(FingerprintOverrides overrides) => {
  for (final entry in overrides.targets.entries)
    if (entry.value) entry.key,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('presets', () {
    test("defaults are Gecko's Android defaults without the efficient "
        'canvas mode', () {
      final defaults = FingerprintOverrides.defaults();

      // Update together with RFPTargetsDefault.inc when Gecko adds a default.
      expect(
        _enabledTargets(defaults),
        _geckoAndroidDefaults.difference({'EfficientCanvasRandomization'}),
      );
      expect(defaults.allTargets, isFalse);
    });

    test('no preset turns on the efficient canvas mode', () {
      // With it on, getImageData and WebGL readbacks are not noised.
      for (final preset in [
        FingerprintOverrides.defaults(),
        FingerprintOverrides.hardenedDefaults(),
      ]) {
        expect(preset.targets['EfficientCanvasRandomization'], isNot(isTrue));
        expect(preset.targets['CanvasRandomization'], isTrue);
      }
    });

    test('every preset target is in the catalogue', () async {
      final names = (await _loadTargets()).map((t) => t.name).toSet();

      for (final preset in [
        FingerprintOverrides.defaults(),
        FingerprintOverrides.hardenedDefaults(),
      ]) {
        expect(names, containsAll(preset.targets.keys));
        expect(
          FingerprintOverrides.parse(preset.toString(), names).isSuccess,
          isTrue,
        );
      }
    });
  });

  group('catalogue', () {
    test('names and ids are unique', () async {
      final targets = await _loadTargets();

      expect(targets.map((t) => t.name).toSet(), hasLength(targets.length));
      expect(targets.map((t) => t.id).toSet(), hasLength(targets.length));
    });

    test('lists no target Gecko removed', () async {
      final names = (await _loadTargets()).map((t) => t.name).toSet();

      expect(names.intersection(FingerprintOverrides.retiredTargets), isEmpty);
    });
  });

  group('upgradeStored', () {
    test("turns the legacy presets into today's", () {
      expect(
        FingerprintOverrides.upgradeStored(_legacyDefaults),
        FingerprintOverrides.defaults().toString(),
      );
      expect(
        FingerprintOverrides.upgradeStored(_legacyHardenedDefaults),
        FingerprintOverrides.hardenedDefaults().toString(),
      );
    });

    test('leaves current presets and custom lists alone', () {
      for (final stored in [
        FingerprintOverrides.defaults().toString(),
        FingerprintOverrides.hardenedDefaults().toString(),
        '+WebGLRenderInfo',
        '-AllTargets,+CanvasRandomization,+EfficientCanvasRandomization',
        '',
      ]) {
        expect(FingerprintOverrides.upgradeStored(stored), stored);
      }
    });

    test('drops retired targets from a custom list and keeps the rest', () {
      expect(
        FingerprintOverrides.upgradeStored(
          '-AllTargets,+TouchEvents,+PointerId,-JSLocale',
        ),
        '-AllTargets,+TouchEvents,-JSLocale',
      );
      expect(
        FingerprintOverrides.upgradeStored('+AllTargets,-PointerId'),
        '+AllTargets',
      );
    });

    test('upgraded strings parse against the catalogue', () async {
      final names = (await _loadTargets()).map((t) => t.name).toSet();

      for (final stored in [
        _legacyDefaults,
        _legacyHardenedDefaults,
        '-AllTargets,+TouchEvents,+PointerId',
      ]) {
        expect(
          FingerprintOverrides.parse(
            FingerprintOverrides.upgradeStored(stored),
            names,
          ).isSuccess,
          isTrue,
          reason: stored,
        );
      }
    });

    test('engine settings load a legacy hardened preset as the preset', () {
      // The onboarding tiles and EngineSettings.effective recognise the
      // hardened preset by string equality.
      expect(
        EngineSettings.withDefaults(
          fingerprintingProtectionOverrides: _legacyHardenedDefaults,
        ).fingerprintingProtectionOverrides,
        FingerprintOverrides.hardenedDefaults().toString(),
      );
    });
  });
}
