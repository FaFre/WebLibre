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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/unshorten_result.dart';

part 'unshorten_response_data.g.dart';

@JsonSerializable()
class UnshortenResponseData with FastEquatable {
  @JsonKey(defaultValue: false)
  final bool success;
  final String? error;

  @JsonKey(name: 'unshortened_url')
  final String? unshortenedUrl;

  @JsonKey(name: 'resolved_url')
  final String? resolvedUrl;

  @JsonKey(name: 'remaining_calls', fromJson: _toInt)
  final int? remainingCalls;

  @JsonKey(name: 'usage_count', fromJson: _toInt)
  final int? usageCount;

  UnshortenResponseData({
    required this.success,
    this.error,
    this.unshortenedUrl,
    this.resolvedUrl,
    this.remainingCalls,
    this.usageCount,
  });

  String? get finalUrl => unshortenedUrl ?? resolvedUrl;

  factory UnshortenResponseData.fromJson(Map<String, dynamic> json) =>
      _$UnshortenResponseDataFromJson(json);

  Map<String, dynamic> toJson() => _$UnshortenResponseDataToJson(this);

  factory UnshortenResponseData.fromAuthenticatedJson(
    Map<String, dynamic> json,
  ) {
    final data = UnshortenResponseData.fromJson(json);
    final error = data.error;
    if (error != null && error.isNotEmpty) {
      return UnshortenResponseData(success: false, error: error);
    }

    return UnshortenResponseData(
      success: true,
      unshortenedUrl: data.unshortenedUrl,
      resolvedUrl: data.resolvedUrl,
      remainingCalls: data.remainingCalls,
      usageCount: data.usageCount,
    );
  }

  factory UnshortenResponseData.fromUnauthenticatedJson(
    Map<String, dynamic> json,
  ) {
    final data = UnshortenResponseData.fromJson(json);
    final success = data.success;
    if (!success) {
      return UnshortenResponseData(
        success: false,
        error: data.error ?? 'Unknown error',
        remainingCalls: data.remainingCalls,
        usageCount: data.usageCount,
      );
    }

    return UnshortenResponseData(
      success: true,
      unshortenedUrl: data.unshortenedUrl,
      resolvedUrl: data.resolvedUrl,
      remainingCalls: data.remainingCalls,
      usageCount: data.usageCount,
    );
  }

  UnshortenResult toDomain() {
    return UnshortenResult(
      success: success,
      error: error,
      finalUrl: finalUrl,
      remainingCalls: remainingCalls,
      usageCount: usageCount,
    );
  }

  @override
  List<Object?> get hashParameters => [
    success,
    error,
    unshortenedUrl,
    resolvedUrl,
    remainingCalls,
    usageCount,
  ];
}

int? _toInt(Object? value) {
  return switch (value) {
    final int value => value,
    final num value => value.toInt(),
    _ => null,
  };
}
