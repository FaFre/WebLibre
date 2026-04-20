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
import 'package:weblibre/features/share_intent/domain/entities/intent_container_mode.dart';
import 'package:weblibre/utils/input_classification.dart';

sealed class SharedContent with FastEquatable {
  final String? contextId;
  final IntentContainerMode containerMode;

  SharedContent({
    this.contextId,
    this.containerMode = IntentContainerMode.useSelected,
  });

  factory SharedContent.parse(
    String content, {
    String? contextId,
    IntentContainerMode containerMode = IntentContainerMode.useSelected,
  }) {
    if (parseSharedIntentUrl(content) case final Uri uri) {
      return SharedUrl(uri, contextId: contextId, containerMode: containerMode);
    } else {
      return SharedText(
        content,
        contextId: contextId,
        containerMode: containerMode,
      );
    }
  }

  @override
  List<Object?> get hashParameters => [contextId, containerMode];
}

final class SharedUrl extends SharedContent {
  final Uri url;

  SharedUrl(this.url, {super.contextId, super.containerMode});

  @override
  String toString() => url.toString();

  @override
  List<Object?> get hashParameters => [url, ...super.hashParameters];
}

final class SharedText extends SharedContent {
  final String text;

  SharedText(this.text, {super.contextId, super.containerMode});

  @override
  String toString() => text;

  @override
  List<Object?> get hashParameters => [text, ...super.hashParameters];
}
