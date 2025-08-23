/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';

part 'engine_settings.g.dart';

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class EngineSettings extends GeckoEngineSettings with FastEquatable {
  @override
  bool get javascriptEnabled => super.javascriptEnabled!;
  @override
  TrackingProtectionPolicy get trackingProtectionPolicy =>
      super.trackingProtectionPolicy!;
  @override
  HttpsOnlyMode get httpsOnlyMode => super.httpsOnlyMode!;
  @override
  ColorScheme get preferredColorScheme => super.preferredColorScheme!;
  @override
  bool get globalPrivacyControlEnabled => super.globalPrivacyControlEnabled!;
  @override
  CookieBannerHandlingMode get cookieBannerHandlingMode =>
      super.cookieBannerHandlingMode!;
  @override
  CookieBannerHandlingMode get cookieBannerHandlingModePrivateBrowsing =>
      super.cookieBannerHandlingModePrivateBrowsing!;
  @override
  bool get cookieBannerHandlingGlobalRules =>
      super.cookieBannerHandlingGlobalRules!;
  @override
  bool get cookieBannerHandlingGlobalRulesSubFrames =>
      super.cookieBannerHandlingGlobalRulesSubFrames!;
  @override
  WebContentIsolationStrategy get webContentIsolationStrategy =>
      super.webContentIsolationStrategy!;

  final QueryParameterStripping queryParameterStripping;

  final BounceTrackingProtectionMode bounceTrackingProtectionMode;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ContentBlocking get contentBlocking => ContentBlocking(
    queryParameterStripping: queryParameterStripping,
    queryParameterStrippingAllowList: '',
    queryParameterStrippingStripList:
        '__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid srsltid ss_email_id twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid',
    bounceTrackingProtectionMode: bounceTrackingProtectionMode,
  );

  EngineSettings({
    required super.javascriptEnabled,
    required super.trackingProtectionPolicy,
    required super.httpsOnlyMode,
    required super.globalPrivacyControlEnabled,
    required super.preferredColorScheme,
    required super.cookieBannerHandlingMode,
    required super.cookieBannerHandlingModePrivateBrowsing,
    required super.cookieBannerHandlingGlobalRules,
    required super.cookieBannerHandlingGlobalRulesSubFrames,
    required super.webContentIsolationStrategy,
    required super.userAgent,
    required this.queryParameterStripping,
    required this.bounceTrackingProtectionMode,
  });

  EngineSettings.withDefaults({
    bool? javascriptEnabled,
    TrackingProtectionPolicy? trackingProtectionPolicy,
    HttpsOnlyMode? httpsOnlyMode,
    bool? globalPrivacyControlEnabled,
    ColorScheme? preferredColorScheme,
    CookieBannerHandlingMode? cookieBannerHandlingMode,
    CookieBannerHandlingMode? cookieBannerHandlingModePrivateBrowsing,
    bool? cookieBannerHandlingGlobalRules,
    bool? cookieBannerHandlingGlobalRulesSubFrames,
    WebContentIsolationStrategy? webContentIsolationStrategy,
    QueryParameterStripping? queryParameterStripping,
    BounceTrackingProtectionMode? bounceTrackingProtectionMode,
    super.userAgent,
  }) : queryParameterStripping =
           queryParameterStripping ?? QueryParameterStripping.disabled,
       bounceTrackingProtectionMode =
           bounceTrackingProtectionMode ??
           BounceTrackingProtectionMode.disabled,
       super(
         javascriptEnabled: javascriptEnabled ?? true,
         trackingProtectionPolicy:
             trackingProtectionPolicy ?? TrackingProtectionPolicy.strict,
         httpsOnlyMode: httpsOnlyMode ?? HttpsOnlyMode.enabled,
         globalPrivacyControlEnabled: globalPrivacyControlEnabled ?? true,
         preferredColorScheme: preferredColorScheme ?? ColorScheme.system,
         cookieBannerHandlingMode:
             cookieBannerHandlingMode ?? CookieBannerHandlingMode.rejectAll,
         cookieBannerHandlingModePrivateBrowsing:
             cookieBannerHandlingModePrivateBrowsing ??
             CookieBannerHandlingMode.rejectAll,
         cookieBannerHandlingGlobalRules:
             cookieBannerHandlingGlobalRules ?? true,
         cookieBannerHandlingGlobalRulesSubFrames:
             cookieBannerHandlingGlobalRulesSubFrames ?? true,
         webContentIsolationStrategy:
             webContentIsolationStrategy ??
             WebContentIsolationStrategy.isolateHighValue,
       );

  factory EngineSettings.fromJson(Map<String, dynamic> json) =>
      _$EngineSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EngineSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    super.javascriptEnabled,
    super.trackingProtectionPolicy,
    super.httpsOnlyMode,
    super.globalPrivacyControlEnabled,
    super.preferredColorScheme,
    super.cookieBannerHandlingMode,
    super.cookieBannerHandlingModePrivateBrowsing,
    super.cookieBannerHandlingGlobalRules,
    super.cookieBannerHandlingGlobalRulesSubFrames,
    super.webContentIsolationStrategy,
    super.userAgent,
    queryParameterStripping,
    bounceTrackingProtectionMode,
  ];
}
