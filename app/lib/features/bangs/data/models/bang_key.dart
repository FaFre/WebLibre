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
import 'package:json_annotation/json_annotation.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';

class BangKey {
  final String trigger;
  final BangGroup group;

  const BangKey({required this.group, required this.trigger});

  @override
  String toString() {
    return '${group.name}::$trigger';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BangKey &&
          runtimeType == other.runtimeType &&
          trigger == other.trigger &&
          group == other.group;

  @override
  int get hashCode => Object.hash(trigger, group);

  static BangKey? tryFromString(String key) {
    try {
      final [group, trigger] = key.split('::');
      return BangKey(
        group: BangGroup.values.firstWhere((g) => g.name == group),
        trigger: trigger,
      );
    } catch (e, s) {
      logger.w('Failed to parse BangKey from string: "$key"', error: e, stackTrace: s);
      return null;
    }
  }
}

class BangKeyConverter implements JsonConverter<BangKey?, String?> {
  const BangKeyConverter();

  @override
  BangKey? fromJson(String? json) {
    return json.mapNotNull((json) => BangKey.tryFromString(json));
  }

  @override
  String? toJson(BangKey? object) {
    return object?.toString();
  }
}
