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
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/data/database/converters/color.dart';
import 'package:weblibre/data/database/converters/icon_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

part 'container_data.g.dart';

@CopyWith()
@JsonSerializable(constructor: 'withDefaults')
class ContainerMetadata with FastEquatable {
  @IconDataJsonConverter()
  final IconData? iconData;

  final String? contextualIdentity;

  @JsonKey(
    fromJson: _proxyConnectionIdFromJson,
    toJson: _proxyConnectionIdToJson,
  )
  final ProxyConnectionId? proxyConnectionId;

  @JsonKey(defaultValue: false)
  final bool clearDataOnExit;

  // Read by the `tab_to_history_on_*` SQL triggers via
  // `json_extract(metadata, '$.excludeFromIndex')`. Keep this key name in
  // sync with the trigger gate in definitions.drift.
  @JsonKey(defaultValue: false)
  final bool excludeFromIndex;

  // When true, this container's browsing history is not recorded at all: the
  // native WebLibreHistoryDelegate skips the Mozilla Places write for its
  // visits (hard exclude / "incognito container"), and no visit→container
  // relation row is written. Gates history recording independently of
  // `excludeFromIndex` (which only gates the local FTS search index).
  //
  // Invariant: requires a Gecko contextId — without one the native delegate
  // can't distinguish the container's visits to skip them. Enforced by
  // [sanitized] on write and normalized on read below.
  @JsonKey(defaultValue: false)
  final bool excludeFromHistory;

  @JsonKey(defaultValue: false)
  final bool bypassGlobalProxy;

  // When true, ContainerData.color is used directly as primaryContainer
  // instead of being fed through ColorScheme.fromSeed. Lets power users pick
  // any color (including dark/black) at the cost of M3 harmonization.
  @JsonKey(defaultValue: false)
  final bool useCustomColor;

  final List<Uri>? assignedSites;

  ContainerMetadata({
    required this.iconData,
    required this.contextualIdentity,
    required this.proxyConnectionId,
    required this.clearDataOnExit,
    required this.excludeFromIndex,
    required this.excludeFromHistory,
    required this.bypassGlobalProxy,
    required this.useCustomColor,
    required this.assignedSites,
  });

  ContainerMetadata.withDefaults({
    IconData? iconData,
    String? contextualIdentity,
    ProxyConnectionId? proxyConnectionId,
    bool? clearDataOnExit,
    bool? excludeFromIndex,
    bool? excludeFromHistory,
    bool? bypassGlobalProxy,
    bool? useCustomColor,
    List<Uri>? assignedSites,
  }) : this(
         iconData: iconData,
         contextualIdentity: contextualIdentity,
         proxyConnectionId: proxyConnectionId,
         clearDataOnExit: clearDataOnExit ?? false,
         excludeFromIndex: excludeFromIndex ?? false,
         // Invariant: exclude-from-history requires a Gecko contextId (cookie
         // isolation). Without one there is no way to hard-exclude the
         // container from Places — the native delegate can't tell its visits
         // apart. This is the deserialization path, so a legacy/foreign record
         // with the bad combination is normalized on read; writers re-apply it
         // via [sanitized].
         excludeFromHistory:
             (excludeFromHistory ?? false) && contextualIdentity != null,
         bypassGlobalProxy: bypassGlobalProxy ?? false,
         useCustomColor: useCustomColor ?? false,
         assignedSites: assignedSites,
       );

  /// Enforce the [excludeFromHistory] invariant before persistence: it can only
  /// be true for a cookie-isolated (contextId-bearing) container, since the
  /// native delegate needs the contextId to hard-exclude visits from Places.
  /// The primary constructor can't normalize (copy_with_extension_gen requires
  /// params to map 1:1 to fields), so writers route through this.
  ContainerMetadata sanitized() {
    if (excludeFromHistory && contextualIdentity == null) {
      return copyWith(excludeFromHistory: false);
    }
    return this;
  }

  bool get usesTorProxy => proxyConnectionId is TorProxyConnectionId;

  factory ContainerMetadata.fromJson(Map<String, dynamic> json) =>
      _$ContainerMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerMetadataToJson(this);

  @override
  List<Object?> get hashParameters => [
    iconData,
    contextualIdentity,
    proxyConnectionId,
    clearDataOnExit,
    excludeFromIndex,
    excludeFromHistory,
    bypassGlobalProxy,
    useCustomColor,
    assignedSites,
  ];
}

@JsonSerializable()
@CopyWith()
class ContainerData with FastEquatable {
  final String id;
  final String? name;
  @ColorJsonConverter()
  final Color color;

  final String orderKey;

  @JsonKey(defaultValue: false)
  final bool isPinned;

  final ContainerMetadata metadata;

  ContainerData({
    required this.id,
    this.name,
    required this.color,
    required this.orderKey,
    this.isPinned = false,
    ContainerMetadata? metadata,
  }) : metadata = metadata ?? ContainerMetadata.withDefaults();

  factory ContainerData.fromJson(Map<String, dynamic> json) =>
      _$ContainerDataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerDataToJson(this);

  @override
  List<Object?> get hashParameters => [
    id,
    name,
    color,
    orderKey,
    isPinned,
    metadata,
  ];
}

@JsonSerializable()
class ContainerDataWithCount extends ContainerData {
  final int? tabCount;

  ContainerDataWithCount({
    required super.id,
    super.name,
    required super.color,
    required super.orderKey,
    super.isPinned,
    super.metadata,
    required this.tabCount,
  });

  factory ContainerDataWithCount.fromJson(Map<String, dynamic> json) =>
      _$ContainerDataWithCountFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ContainerDataWithCountToJson(this);

  @override
  List<Object?> get hashParameters => [...super.hashParameters, tabCount];
}

ProxyConnectionId? _proxyConnectionIdFromJson(String? json) =>
    ProxyConnectionId.decode(json);

String? _proxyConnectionIdToJson(ProxyConnectionId? object) => object?.encode();
