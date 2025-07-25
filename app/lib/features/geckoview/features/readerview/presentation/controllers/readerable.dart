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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/readerview/domain/providers/readerable.dart';

part 'readerable.g.dart';

@Riverpod(keepAlive: true)
class ReaderableScreenController extends _$ReaderableScreenController {
  late GeckoReaderableService _service;

  Future<void> toggleReaderView(bool enable) async {
    state = const AsyncValue.loading();

    final eventChange = ref.read(eventServiceProvider).readerableEvents.first;
    final toggle = _service.toggleReaderView(enable);

    state = await AsyncValue.guard(() => Future.wait([toggle, eventChange]));
  }

  @override
  Future<void> build() {
    _service = ref.watch(readerableServiceProvider);

    return Future.value();
  }
}
