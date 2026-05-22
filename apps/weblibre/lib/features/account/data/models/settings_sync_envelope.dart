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
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';

part 'settings_sync_envelope.g.dart';

@JsonSerializable()
class SettingsSyncPayload {
  final GeneralSettings? general;
  final EngineSettings? engine;
  final TorSettings? tor;

  SettingsSyncPayload({this.general, this.engine, this.tor});

  factory SettingsSyncPayload.fromJson(Map<String, dynamic> json) =>
      _$SettingsSyncPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsSyncPayloadToJson(this);
}

@JsonSerializable()
class SettingsSyncEnvelope {
  @JsonKey(name: 'schema_version')
  final int schemaVersion;

  @JsonKey(name: 'exported_at')
  final String exportedAt;

  final SettingsSyncPayload payload;

  SettingsSyncEnvelope({
    required this.schemaVersion,
    required this.exportedAt,
    required this.payload,
  });

  factory SettingsSyncEnvelope.fromJson(Map<String, dynamic> json) =>
      _$SettingsSyncEnvelopeFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsSyncEnvelopeToJson(this);
}
