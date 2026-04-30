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
import 'package:json_annotation/json_annotation.dart';

part 'ublock_asset.g.dart';

enum UBlockAssetGroup {
  @JsonValue('default')
  $default,
  @JsonValue('ads')
  ads,
  @JsonValue('privacy')
  privacy,
  @JsonValue('malware')
  malware,
  @JsonValue('annoyances')
  annoyances,
  @JsonValue('multipurpose')
  multipurpose,
  @JsonValue('regions')
  regions;

  String get label => switch (this) {
    $default => 'Default',
    ads => 'Ads',
    privacy => 'Privacy',
    malware => 'Malware',
    annoyances => 'Annoyances',
    multipurpose => 'Multipurpose',
    regions => 'Regions',
  };

  static const displayOrder = UBlockAssetGroup.values;
}

enum UBlockAssetSubGroup {
  @JsonValue('cookies')
  cookies,
  @JsonValue('social')
  social;

  String get label => switch (this) {
    cookies => 'Cookie Notices',
    social => 'Social Widgets',
  };
}

List<String> _contentUrlFromJson(dynamic value) {
  if (value is List) return value.cast<String>();
  if (value is String) return [value];
  return [];
}

dynamic _contentUrlToJson(List<String> value) {
  if (value.length == 1) return value.first;
  return value;
}

@JsonSerializable()
class UBlockAssetEntry {
  final String content;

  @JsonKey(includeIfNull: false)
  final UBlockAssetGroup? group;

  @JsonKey(includeIfNull: false)
  final UBlockAssetSubGroup? group2;

  @JsonKey(includeIfNull: false)
  final String? parent;

  @JsonKey(includeIfNull: false)
  final String? title;

  @JsonKey(
    includeIfNull: false,
    fromJson: _contentUrlFromJson,
    toJson: _contentUrlToJson,
  )
  final List<String> contentURL;

  @JsonKey(includeIfNull: false)
  final List<String>? cdnURLs;

  @JsonKey(includeIfNull: false)
  final List<String>? patchURLs;

  @JsonKey(includeIfNull: false)
  final String? supportURL;

  @JsonKey(includeIfNull: false)
  final String? instructionURL;

  @JsonKey(includeIfNull: false)
  final String? tags;

  @JsonKey(includeIfNull: false)
  final String? lang;

  @JsonKey(includeIfNull: false)
  final String? ua;

  @JsonKey(includeIfNull: false, defaultValue: false)
  final bool off;

  @JsonKey(includeIfNull: false, defaultValue: false)
  final bool preferred;

  @JsonKey(includeIfNull: false)
  final int? updateAfter;

  const UBlockAssetEntry({
    required this.content,
    this.group,
    this.group2,
    this.parent,
    this.title,
    this.contentURL = const [],
    this.cdnURLs,
    this.patchURLs,
    this.supportURL,
    this.instructionURL,
    this.tags,
    this.lang,
    this.ua,
    this.off = false,
    this.preferred = false,
    this.updateAfter,
  });

  bool get isFilterList => content == 'filters';

  bool get isDefaultEnabled => !off;

  UBlockAssetGroup get effectiveGroup =>
      group2?.toGroup() ?? group ?? UBlockAssetGroup.ads;

  factory UBlockAssetEntry.fromJson(Map<String, dynamic> json) =>
      _$UBlockAssetEntryFromJson(json);

  Map<String, dynamic> toJson() => _$UBlockAssetEntryToJson(this);
}

extension on UBlockAssetSubGroup {
  UBlockAssetGroup toGroup() => switch (this) {
    UBlockAssetSubGroup.cookies => UBlockAssetGroup.annoyances,
    UBlockAssetSubGroup.social => UBlockAssetGroup.annoyances,
  };
}

class UBlockAssetsRegistry {
  final Map<String, UBlockAssetEntry> _entries;

  UBlockAssetsRegistry(this._entries);

  Map<String, UBlockAssetEntry> get filterEntries =>
      Map.fromEntries(_entries.entries.where((e) => e.value.isFilterList));

  List<String> get defaultEnabledTokens => _entries.entries
      .where((e) => e.value.isFilterList && e.value.isDefaultEnabled)
      .map((e) => e.key)
      .toList();

  UBlockAssetEntry? operator [](String key) => _entries[key];

  Map<UBlockAssetGroup, Map<String?, List<String>>> buildGroupedParentTree() {
    final result = <UBlockAssetGroup, Map<String?, List<String>>>{};

    for (final group in UBlockAssetGroup.displayOrder) {
      final groupEntries = <String?, List<String>>{};
      final processedKeys = <String>{};

      final groupSubGroups = UBlockAssetSubGroup.values
          .where((sg) => sg.toGroup() == group)
          .toList();

      for (final subGroup in groupSubGroups) {
        for (final entry in _entries.entries.where(
          (e) => e.value.isFilterList && e.value.group2 == subGroup,
        )) {
          final parentKey = entry.value.parent;
          groupEntries.putIfAbsent(parentKey, () => []).add(entry.key);
          processedKeys.add(entry.key);
        }
      }

      for (final entry in _entries.entries.where(
        (e) =>
            e.value.isFilterList &&
            e.value.group == group &&
            e.value.group2 == null &&
            !processedKeys.contains(e.key),
      )) {
        final parentKey = entry.value.parent;
        groupEntries.putIfAbsent(parentKey, () => []).add(entry.key);
      }

      if (groupEntries.isNotEmpty) {
        result[group] = groupEntries;
      }
    }

    return result;
  }

  List<String> tokensMatchingLocales(Iterable<String> languageCodes) {
    final primaryCodes = languageCodes.map((code) {
      final parts = code.split('-');
      return parts.first.toLowerCase();
    }).toSet();

    return _entries.entries
        .where((e) {
          if (!e.value.isFilterList || !e.value.off) return false;
          final lang = e.value.lang;
          if (lang == null) return false;
          final entryLangs = lang
              .split(RegExp(r'\s+'))
              .map((l) => l.toLowerCase())
              .toSet();
          return primaryCodes.intersection(entryLangs).isNotEmpty;
        })
        .map((e) => e.key)
        .toList();
  }

  int enabledCountInGroup(UBlockAssetGroup group, Set<String> enabledTokens) {
    var count = 0;
    for (final entry in _entries.entries) {
      if (!entry.value.isFilterList) continue;
      if (entry.value.effectiveGroup != group) continue;
      if (enabledTokens.contains(entry.key)) count++;
    }
    return count;
  }

  int totalCountInGroup(UBlockAssetGroup group) {
    var count = 0;
    for (final entry in _entries.entries) {
      if (!entry.value.isFilterList) continue;
      if (entry.value.effectiveGroup != group) continue;
      count++;
    }
    return count;
  }

  static UBlockAssetsRegistry fromJson(Map<String, dynamic> json) {
    final entries = <String, UBlockAssetEntry>{};
    for (final entry in json.entries) {
      if (entry.value is Map<String, dynamic>) {
        entries[entry.key] = UBlockAssetEntry.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }
    return UBlockAssetsRegistry(entries);
  }
}
