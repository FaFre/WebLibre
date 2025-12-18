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
import 'package:uuid/uuid_value.dart';
import 'package:weblibre/core/uuid.dart';

part 'profile.g.dart';

@JsonSerializable()
@CopyWith()
class Profile with FastEquatable {
  @CopyWithField(immutable: true)
  final String id;
  final String name;

  late final uuidValue = UuidValue.fromString(id);

  static String getNewProfileId() => uuid.v7();

  Profile({required this.id, required this.name});

  factory Profile.create({required String name}) {
    return Profile(id: getNewProfileId(), name: name);
  }

  @override
  List<Object?> get hashParameters => [id, name];

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}
