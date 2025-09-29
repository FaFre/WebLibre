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
import 'package:weblibre/features/bangs/data/models/bang.dart';
import 'package:weblibre/features/bangs/data/models/bang_group.dart';
import 'package:weblibre/features/bangs/data/models/bang_key.dart';
import 'package:weblibre/features/geckoview/domain/entities/browser_icon.dart';

part 'bang_data.g.dart';

@CopyWith()
class BangData extends Bang {
  final int frequency;
  final DateTime? lastUsed;

  final BrowserIcon? icon;

  @override
  BangGroup get group => super.group!;

  BangData({
    required super.websiteName,
    required super.domain,
    required super.trigger,
    required super.urlTemplate,
    super.category,
    super.subCategory,
    super.format,
    int? frequency,
    this.lastUsed,
    this.icon,
  }) : frequency = frequency ?? 0;

  BangKey toKey() => BangKey(group: group, trigger: trigger);

  @override
  List<Object?> get hashParameters => [
    ...super.hashParameters,
    frequency,
    lastUsed,
    icon,
  ];
}
