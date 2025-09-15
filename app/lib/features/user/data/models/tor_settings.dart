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
import 'package:json_annotation/json_annotation.dart';

part 'tor_settings.g.dart';

enum TorConnectionConfig { auto, direct, obfs4, snowflake }

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class TorSettings with FastEquatable {
  final bool proxyPrivateTabsTor;
  final TorConnectionConfig config;
  final bool requireBridge;
  final bool fetchRemoteBridges;

  TorSettings({
    required this.proxyPrivateTabsTor,
    required this.config,
    required this.requireBridge,
    required this.fetchRemoteBridges,
  });

  TorSettings.withDefaults({
    bool? proxyPrivateTabsTor,
    TorConnectionConfig? config,
    bool? requireBridge,
    bool? fetchRemoteBridges,
  }) : proxyPrivateTabsTor = proxyPrivateTabsTor ?? false,
       config = config ?? TorConnectionConfig.auto,
       requireBridge = requireBridge ?? false,
       fetchRemoteBridges = fetchRemoteBridges ?? true;

  factory TorSettings.fromJson(Map<String, dynamic> json) =>
      _$TorSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$TorSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [
    proxyPrivateTabsTor,
    config,
    requireBridge,
    fetchRemoteBridges,
  ];
}
