import 'package:json_annotation/json_annotation.dart';

part 'moat.g.dart';

enum TransportType {
  obfs4('obfs4'),
  snowflake('snowflake'),
  meek('meek'),
  meekAzure('meek-azure'),
  webtunnel('webtunnel');

  const TransportType(this.value);
  final String value;

  @override
  String toString() => value;

  static TransportType? fromString(String value) {
    for (final transport in TransportType.values) {
      if (transport.value == value) return transport;
    }
    return null;
  }
}

@JsonSerializable()
class SettingsRequest {
  final String? country;
  @JsonKey(toJson: _transportsToJson, fromJson: _transportsFromJson)
  final List<TransportType> transports;

  const SettingsRequest({
    this.country,
    this.transports = const [
      TransportType.obfs4,
      TransportType.snowflake,
      TransportType.webtunnel,
    ],
  });

  static List<String> _transportsToJson(List<TransportType> transports) =>
      transports.map((t) => t.value).toList();

  static List<TransportType> _transportsFromJson(List<dynamic> json) => json
      .cast<String>()
      .map((s) => TransportType.fromString(s))
      .where((t) => t != null)
      .cast<TransportType>()
      .toList();

  factory SettingsRequest.fromJson(Map<String, dynamic> json) =>
      _$SettingsRequestFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsRequestToJson(this);
}

@JsonSerializable()
class SettingsResponse {
  final List<Setting>? settings;
  final String? country;
  final List<MoatError>? errors;

  const SettingsResponse({this.settings, this.country, this.errors});

  factory SettingsResponse.fromJson(Map<String, dynamic> json) =>
      _$SettingsResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsResponseToJson(this);
}

@JsonSerializable()
class Setting {
  @JsonKey(name: 'bridges')
  final Bridge bridge;

  const Setting({required this.bridge});

  factory Setting.fromJson(Map<String, dynamic> json) =>
      _$SettingFromJson(json);

  Map<String, dynamic> toJson() => _$SettingToJson(this);
}

@JsonSerializable()
class Bridge {
  @JsonKey(toJson: _transportToJson, fromJson: _transportFromJson)
  final TransportType type;
  final String source;
  @JsonKey(name: 'bridge_strings')
  final List<String>? bridges;

  const Bridge({required this.type, required this.source, this.bridges});

  static String _transportToJson(TransportType transport) => transport.value;

  static TransportType _transportFromJson(dynamic json) =>
      TransportType.fromString(json as String)!;

  factory Bridge.fromJson(Map<String, dynamic> json) => _$BridgeFromJson(json);

  Map<String, dynamic> toJson() => _$BridgeToJson(this);
}

@JsonSerializable()
class MoatError implements Exception {
  final String? id;
  final String? type;
  final String? version;
  final int? code;
  final String? status;
  final String? detail;

  const MoatError({
    this.id,
    this.type,
    this.version,
    this.code,
    this.status,
    this.detail,
  });

  factory MoatError.fromJson(Map<String, dynamic> json) =>
      _$MoatErrorFromJson(json);

  Map<String, dynamic> toJson() => _$MoatErrorToJson(this);

  @override
  String toString() {
    if (detail != null && detail!.isNotEmpty) {
      return detail!;
    }
    return '$code $status';
  }
}

@JsonSerializable()
class BuiltInBridges {
  final List<String> meek;

  @JsonKey(name: 'meek-azure')
  final List<String> meekAzure;

  final List<String> obfs4;
  final List<String> snowflake;

  const BuiltInBridges({
    required this.meek,
    required this.meekAzure,
    required this.obfs4,
    required this.snowflake,
  });

  factory BuiltInBridges.fromJson(Map<String, dynamic> json) =>
      _$BuiltInBridgesFromJson(json);

  Map<String, dynamic> toJson() => _$BuiltInBridgesToJson(this);
}
