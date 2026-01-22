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
import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/user/domain/entities/fingerprint_overrides.dart';

part 'engine_settings.g.dart';

enum BuiltInDohProviders {
  quad9('Quad9', 'https://dns.quad9.net/dns-query'),
  mullvad('Mullvad', 'https://dns.mullvad.net/dns-query'),
  adguard('AdGuard', 'https://dns.adguard-dns.com/dns-query'),
  ffmuc('Freifunk München', 'https://doh.ffmuc.net/dns-query');

  final String name;
  final String url;

  static bool isBuiltin(String url) =>
      BuiltInDohProviders.values.any((provider) => provider.url == url);

  const BuiltInDohProviders(this.name, this.url);
}

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
  @override
  bool get enterpriseRootsEnabled => super.enterpriseRootsEnabled!;

  @override
  List<String> get locales => super.locales!;

  // Custom Tracking Protection overrides
  @override
  bool get blockCookies => super.blockCookies!;
  @override
  CustomCookiePolicy get customCookiePolicy => super.customCookiePolicy!;
  @override
  bool get blockTrackingContent => super.blockTrackingContent!;
  @override
  TrackingScope get trackingContentScope => super.trackingContentScope!;
  @override
  bool get blockCryptominers => super.blockCryptominers!;
  @override
  bool get blockFingerprinters => super.blockFingerprinters!;
  @override
  bool get blockRedirectTrackers => super.blockRedirectTrackers!;
  @override
  bool get blockSuspectedFingerprinters => super.blockSuspectedFingerprinters!;
  @override
  TrackingScope get suspectedFingerprintersScope =>
      super.suspectedFingerprintersScope!;
  @override
  bool get allowListBaseline => super.allowListBaseline!;
  @override
  bool get allowListConvenience => super.allowListConvenience!;

  final QueryParameterStripping queryParameterStripping;

  final BounceTrackingProtectionMode bounceTrackingProtectionMode;

  @JsonKey(fromJson: _addonCollectionFromJson, toJson: _addonCollectionToJson)
  final AddonCollection? addonCollection;

  final DohSettingsMode dohSettingsMode;
  final String dohProviderUrl;
  final String dohDefaultProviderUrl;
  final List<String> dohExceptionsList;

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  DohSettings get dohSettings => DohSettings(
    dohSettingsMode: dohSettingsMode,
    dohProviderUrl: dohProviderUrl,
    dohDefaultProviderUrl: dohDefaultProviderUrl,
    dohExceptionsList: dohExceptionsList,
  );

  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  ContentBlocking get contentBlocking => ContentBlocking(
    queryParameterStripping: queryParameterStripping,
    queryParameterStrippingAllowList: '',
    queryParameterStrippingStripList:
        '__hsfp __hssc __hstc __s _bhlid _branch_match_id _branch_referrer _gl _hsenc _kx _openstat at_recipient_id at_recipient_list bbeml bsft_clkid bsft_uid dclid et_rid fb_action_ids fb_comment_id fbclid gbraid gclid guce_referrer guce_referrer_sig hsCtaTracking igshid irclickid mc_eid mkt_tok ml_subscriber ml_subscriber_hash msclkid mtm_cid oft_c oft_ck oft_d oft_id oft_ids oft_k oft_lk oft_sk oly_anon_id oly_enc_id pk_cid rb_clickid s_cid sc_customer sc_eh sc_uid srsltid ss_email_id twclid unicorn_click_id vero_conv vero_id vgo_ee wbraid wickedid yclid ymclid ysclid',
    bounceTrackingProtectionMode: bounceTrackingProtectionMode,
  );

  final bool enablePdfJs;

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
    required super.enterpriseRootsEnabled,
    required this.queryParameterStripping,
    required this.bounceTrackingProtectionMode,
    required this.addonCollection,
    required this.dohSettingsMode,
    required this.dohProviderUrl,
    required this.dohDefaultProviderUrl,
    required this.dohExceptionsList,
    required super.fingerprintingProtectionOverrides,
    required this.enablePdfJs,
    required super.locales,
    required super.blockCookies,
    required super.customCookiePolicy,
    required super.blockTrackingContent,
    required super.trackingContentScope,
    required super.blockCryptominers,
    required super.blockFingerprinters,
    required super.blockRedirectTrackers,
    required super.blockSuspectedFingerprinters,
    required super.suspectedFingerprintersScope,
    required super.allowListBaseline,
    required super.allowListConvenience,
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
    bool? enterpriseRootsEnabled,
    this.addonCollection,
    DohSettingsMode? dohSettingsMode,
    String? dohProviderUrl,
    String? dohDefaultProviderUrl,
    List<String>? dohExceptionsList,
    String? fingerprintingProtectionOverrides,
    bool? enablePdfJs,
    List<String>? locales,
    bool? blockCookies,
    CustomCookiePolicy? customCookiePolicy,
    bool? blockTrackingContent,
    TrackingScope? trackingContentScope,
    bool? blockCryptominers,
    bool? blockFingerprinters,
    bool? blockRedirectTrackers,
    bool? blockSuspectedFingerprinters,
    TrackingScope? suspectedFingerprintersScope,
    bool? allowListBaseline,
    bool? allowListConvenience,
  }) : queryParameterStripping =
           queryParameterStripping ?? QueryParameterStripping.disabled,
       bounceTrackingProtectionMode =
           bounceTrackingProtectionMode ??
           BounceTrackingProtectionMode.disabled,
       dohSettingsMode = dohSettingsMode ?? DohSettingsMode.increased,
       dohProviderUrl = dohProviderUrl ?? BuiltInDohProviders.quad9.url,
       dohDefaultProviderUrl =
           dohDefaultProviderUrl ?? BuiltInDohProviders.quad9.url,
       dohExceptionsList = dohExceptionsList ?? [],
       enablePdfJs = enablePdfJs ?? true,
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
         enterpriseRootsEnabled: enterpriseRootsEnabled ?? false,
         fingerprintingProtectionOverrides:
             fingerprintingProtectionOverrides ??
             FingerprintOverrides.defaults().toString(),
         locales:
             locales ??
             WidgetsBinding.instance.platformDispatcher.locales
                 .map((x) => x.toLanguageTag())
                 .toList(),
         blockCookies: blockCookies ?? true,
         customCookiePolicy:
             customCookiePolicy ?? CustomCookiePolicy.totalProtection,
         blockTrackingContent: blockTrackingContent ?? true,
         trackingContentScope: trackingContentScope ?? TrackingScope.all,
         blockCryptominers: blockCryptominers ?? true,
         blockFingerprinters: blockFingerprinters ?? true,
         blockRedirectTrackers: blockRedirectTrackers ?? true,
         blockSuspectedFingerprinters: blockSuspectedFingerprinters ?? true,
         suspectedFingerprintersScope:
             suspectedFingerprintersScope ?? TrackingScope.all,
         allowListBaseline: allowListBaseline ?? true,
         allowListConvenience: allowListConvenience ?? false,
       );

  static AddonCollection? _addonCollectionFromJson(String? json) =>
      json.mapNotNull(
        (collection) => AddonCollection.decode(jsonDecode(collection) as List),
      );

  static String? _addonCollectionToJson(AddonCollection? collection) =>
      collection.mapNotNull((collection) => jsonEncode(collection.encode()));

  factory EngineSettings.fromJson(Map<String, dynamic> json) =>
      _$EngineSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$EngineSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    javascriptEnabled,
    trackingProtectionPolicy,
    httpsOnlyMode,
    globalPrivacyControlEnabled,
    preferredColorScheme,
    cookieBannerHandlingMode,
    cookieBannerHandlingModePrivateBrowsing,
    cookieBannerHandlingGlobalRules,
    cookieBannerHandlingGlobalRulesSubFrames,
    webContentIsolationStrategy,
    userAgent,
    enterpriseRootsEnabled,
    queryParameterStripping,
    bounceTrackingProtectionMode,
    addonCollection,
    dohSettingsMode,
    dohProviderUrl,
    dohDefaultProviderUrl,
    dohExceptionsList,
    fingerprintingProtectionOverrides,
    enablePdfJs,
    locales,
    blockCookies,
    customCookiePolicy,
    blockTrackingContent,
    trackingContentScope,
    blockCryptominers,
    blockFingerprinters,
    blockRedirectTrackers,
    blockSuspectedFingerprinters,
    suspectedFingerprintersScope,
    allowListBaseline,
    allowListConvenience,
  ];
}
