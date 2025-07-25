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
import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/data/database/converters/icon_data.dart';

part 'container_data.g.dart';

@CopyWith()
@JsonSerializable()
class ContainerAuthSettings with FastEquatable {
  final bool authenticationRequired;
  final bool lockOnAppBackground;
  final Duration? lockTimeout;

  ContainerAuthSettings({
    required this.authenticationRequired,
    required this.lockOnAppBackground,
    required this.lockTimeout,
  });

  ContainerAuthSettings.withDefaults({
    bool? authenticationRequired,
    bool? lockOnAppBackground,
    Duration? lockTimeout,
  }) : this(
         authenticationRequired: authenticationRequired ?? false,
         lockOnAppBackground: lockOnAppBackground ?? false,
         lockTimeout: lockTimeout,
       );

  factory ContainerAuthSettings.fromJson(Map<String, dynamic> json) =>
      _$ContainerAuthSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerAuthSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    authenticationRequired,
    lockOnAppBackground,
    lockTimeout,
  ];
}

@CopyWith()
@JsonSerializable(constructor: 'withDefaults')
class ContainerMetadata with FastEquatable {
  @IconDataJsonConverter()
  final IconData? iconData;
  final String? contextualIdentity;
  final ContainerAuthSettings authSettings;

  @JsonKey(defaultValue: false)
  final bool useProxy;

  ContainerMetadata({
    required this.iconData,
    required this.contextualIdentity,
    required this.authSettings,
    required this.useProxy,
  });

  ContainerMetadata.withDefaults({
    IconData? iconData,
    String? contextualIdentity,
    ContainerAuthSettings? authSettings,
    bool? useProxy,
  }) : this(
         iconData: iconData,
         contextualIdentity: contextualIdentity,
         authSettings: authSettings ?? ContainerAuthSettings.withDefaults(),
         useProxy: useProxy ?? false,
       );

  factory ContainerMetadata.fromJson(Map<String, dynamic> json) =>
      _$ContainerMetadataFromJson(json);

  Map<String, dynamic> toJson() => _$ContainerMetadataToJson(this);

  @override
  List<Object?> get hashParameters => [
    iconData,
    contextualIdentity,
    authSettings,
    useProxy,
  ];
}

@CopyWith()
class ContainerData with FastEquatable {
  final String id;
  final String? name;
  final Color color;
  final ContainerMetadata metadata;

  ContainerData({
    required this.id,
    this.name,
    required this.color,
    ContainerMetadata? metadata,
  }) : metadata = metadata ?? ContainerMetadata.withDefaults();

  @override
  List<Object?> get hashParameters => [id, name, color, metadata];
}

class ContainerDataWithCount extends ContainerData {
  final int? tabCount;

  ContainerDataWithCount({
    required super.id,
    super.name,
    required super.color,
    super.metadata,
    required this.tabCount,
  });

  @override
  List<Object?> get hashParameters => [...super.hashParameters, tabCount];
}
