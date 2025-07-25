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
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class BangIcon extends ConsumerWidget {
  final String trigger;
  final double iconSize;

  const BangIcon({super.key, required this.trigger, this.iconSize = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bang = ref.watch(
      bangDataProvider(trigger).select((value) => value.valueOrNull),
    );

    return UrlIcon([
      if (bang != null) bang.getTemplateUrl(''),
    ], iconSize: iconSize);
  }
}
