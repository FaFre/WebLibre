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
import 'package:weblibre/features/user/data/models/ublock_asset.dart';

part 'ublock_filter_list_settings.g.dart';

const kUBlockMaxExternalUrls = 32;

const kUBlockHardeningStockTokens = <String>[
  'adguard-mobile',
  'adguard-mobile-app-banners',
  'adguard-spyware-url',
  'fanboy-cookiemonster',
  'fanboy-social',
  'ublock-annoyances',
];

final kUBlockHardeningExternalLists = <UBlockExternalList>[
  UBlockExternalList(
    url:
        'https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt',
    description: 'Legitimate URL Shortener Tool (DandelionSprout)',
  ),
];

@CopyWith()
@JsonSerializable(includeIfNull: true)
class UBlockExternalList with FastEquatable {
  final String url;

  @JsonKey(includeIfNull: false)
  final String? description;

  UBlockExternalList({required this.url, this.description});

  factory UBlockExternalList.fromJson(Map<String, dynamic> json) =>
      _$UBlockExternalListFromJson(json);

  Map<String, dynamic> toJson() => _$UBlockExternalListToJson(this);

  @override
  List<Object?> get hashParameters => [url, description];
}

@CopyWith()
@JsonSerializable(includeIfNull: true)
class UBlockFilterListSettings with FastEquatable {
  static const String _userFiltersToken = 'user-filters';

  final bool enabled;

  final List<String> enabledStockListTokens;

  final List<String> autoEnabledStockListTokens;

  final bool autoSelectRegionalLists;

  final List<UBlockExternalList> externalFilterLists;

  UBlockFilterListSettings({
    this.enabled = false,
    this.enabledStockListTokens = const [],
    this.autoEnabledStockListTokens = const [],
    this.autoSelectRegionalLists = false,
    this.externalFilterLists = const [],
  });

  factory UBlockFilterListSettings.managedDefaults(UBlockAssetsRegistry registry) {
    return UBlockFilterListSettings(
      enabled: true,
      enabledStockListTokens: registry.defaultEnabledTokens,
    );
  }

  factory UBlockFilterListSettings.optimizedDefaults(
    UBlockAssetsRegistry registry,
  ) {
    final defaultTokens = registry.defaultEnabledTokens;

    final stockTokens = [...defaultTokens];
    for (final token in kUBlockHardeningStockTokens) {
      if (!stockTokens.contains(token)) {
        stockTokens.add(token);
      }
    }

    final externals = <UBlockExternalList>[];
    final seenUrls = <String>{};
    for (final entry in kUBlockHardeningExternalLists) {
      if (seenUrls.add(entry.url) &&
          externals.length < kUBlockMaxExternalUrls) {
        externals.add(entry);
      }
    }

    return UBlockFilterListSettings(
      enabled: true,
      enabledStockListTokens: stockTokens,
      externalFilterLists: externals,
    );
  }

  factory UBlockFilterListSettings.fromJson(Map<String, dynamic> json) =>
      _$UBlockFilterListSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$UBlockFilterListSettingsToJson(this);

  List<String> resolveFinalList() {
    if (!enabled) {
      return const [];
    }

    final result = <String>[];
    final seen = <String>{_userFiltersToken};

    result.add(_userFiltersToken);

    for (final token in enabledStockListTokens) {
      if (seen.add(token)) {
        result.add(token);
      }
    }

    for (final token in autoEnabledStockListTokens) {
      if (seen.add(token)) {
        result.add(token);
      }
    }

    for (final entry in externalFilterLists) {
      final url = entry.url.trim();
      if (url.isEmpty) continue;
      final parsed = Uri.tryParse(url);
      if (parsed == null) continue;
      if (parsed.scheme != 'http' && parsed.scheme != 'https') continue;
      if (!parsed.hasAuthority) continue;
      if (seen.add(url)) {
        result.add(url);
      }
    }

    return result;
  }

  bool isTokenEnabled(String token) =>
      enabledStockListTokens.contains(token) ||
      autoEnabledStockListTokens.contains(token);

  @override
  List<Object?> get hashParameters => [
    enabled,
    enabledStockListTokens,
    autoEnabledStockListTokens,
    autoSelectRegionalLists,
    externalFilterLists,
  ];
}
