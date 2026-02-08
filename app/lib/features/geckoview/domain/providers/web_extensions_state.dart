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
import 'dart:async';
import 'dart:ui';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/domain/entities/equatable_image.dart';
import 'package:weblibre/features/geckoview/domain/entities/states/web_extension.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/utils/image_helper.dart';
import 'package:weblibre/utils/lru_cache.dart';

part 'web_extensions_state.g.dart';

@Riverpod(keepAlive: true)
class WebExtensionsState extends _$WebExtensionsState {
  late final LRUCache<String, EquatableImage> _imageCache;

  WebExtensionsState()
    : _imageCache = LRUCache(50, onEvict: (image) => image.dispose());

  void _onExtensionUpdate(ExtensionDataEvent event) {
    final ExtensionDataEvent(:extensionId, :data) = event;

    if (data != null) {
      final cachedIcon = _imageCache.get(extensionId);
      if (cachedIcon != null && cachedIcon.value == null) {
        _imageCache.remove(extensionId);
      }

      final current =
          state[extensionId] ??
          WebExtensionState(
            extensionId: extensionId,
            icon: _imageCache.get(extensionId),
            enabled: false,
          );

      state = {...state}
        ..[extensionId] = current.copyWith(
          title: data.title,
          enabled: data.enabled ?? current.enabled,
          badgeText: data.badgeText,
          badgeTextColor: data.badgeTextColor.mapNotNull(
            (color) => Color(color),
          ),
          badgeBackgroundColor: data.badgeBackgroundColor.mapNotNull(
            (color) => Color(color),
          ),
        );
    } else {
      if (state.containsKey(extensionId)) {
        state = {...state}..remove(extensionId);
        // remove() triggers onEvict which handles disposal
        _imageCache.remove(extensionId);
      }
    }
  }

  Future<void> _onIconChange(ExtensionIconEvent event) async {
    final ExtensionIconEvent(:extensionId, :bytes) = event;

    final image = await tryDecodeImage(bytes);

    if (image != null) {
      // set() will evict the old entry via onEvict callback, which handles disposal
      _imageCache.set(extensionId, image);

      if (state.containsKey(extensionId)) {
        state = {...state}
          ..[extensionId] = state[extensionId]!.copyWith.icon(image);
      }
    }
  }

  @override
  Map<String, WebExtensionState> build(WebExtensionActionType actionType) {
    final addonService = ref.watch(addonServiceProvider);

    final subscriptions = switch (actionType) {
      WebExtensionActionType.browser => [
        addonService.browserExtensionStream.listen(
          (event) {
            _onExtensionUpdate(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in browser extension stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
        addonService.browserIconStream.listen(
          (event) async {
            await _onIconChange(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in browser icon stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
      ],
      WebExtensionActionType.page => [
        addonService.pageExtensionStream.listen(
          (event) {
            _onExtensionUpdate(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in page extension stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
        addonService.pageIconStream.listen(
          (event) async {
            await _onIconChange(event);
          },
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Error in page icon stream',
              error: error,
              stackTrace: stackTrace,
            );
          },
        ),
      ],
    };

    ref.onDispose(() async {
      // Dispose all cached images
      _imageCache.clear();

      // Cancel all stream subscriptions
      for (final sub in subscriptions) {
        await sub.cancel();
      }
    });

    return {};
  }
}
