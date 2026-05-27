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

  @JsonKey(defaultValue: false)
  final bool bypassGlobalProxy;

  final List<Uri>? assignedSites;

  ContainerMetadata({
    required this.iconData,
    required this.contextualIdentity,
    required this.proxyConnectionId,
    required this.clearDataOnExit,
    required this.excludeFromIndex,
    required this.bypassGlobalProxy,
    required this.assignedSites,
  });

  ContainerMetadata.withDefaults({
    IconData? iconData,
    String? contextualIdentity,
    ProxyConnectionId? proxyConnectionId,
    bool? clearDataOnExit,
    bool? excludeFromIndex,
    bool? bypassGlobalProxy,
    List<Uri>? assignedSites,
  }) : this(
         iconData: iconData,
         contextualIdentity: contextualIdentity,
         proxyConnectionId: proxyConnectionId,
         clearDataOnExit: clearDataOnExit ?? false,
         excludeFromIndex: excludeFromIndex ?? false,
         bypassGlobalProxy: bypassGlobalProxy ?? false,
         assignedSites: assignedSites,
       );

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
    bypassGlobalProxy,
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
