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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/design/app_colors.dart';

part 'defaults.g.dart';

@Riverpod(keepAlive: true)
Color lightSeedColorFallback(Ref ref) => AppColors.light.seedColor;

@Riverpod(keepAlive: true)
Color darkSeedColorFallback(Ref ref) => AppColors.dark.seedColor;

@Riverpod(keepAlive: true)
Uri docsUri(Ref ref) => Uri.parse('https://docs.weblibre.eu/');
