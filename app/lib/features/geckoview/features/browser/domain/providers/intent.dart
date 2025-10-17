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
import 'dart:async';

import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'intent.g.dart';

final _contentParserTransformer =
    StreamTransformer<ReceivedIntentParameter, SharedContent>.fromHandlers(
      handleData: (parameter, sink) {
        final parsed = parameter.content.mapNotNull(
          (content) => SharedContent.parse(content),
        );

        if (parsed != null) {
          sink.add(parsed);
        } else if (parameter.tool == 'search') {
          sink.add(SharedText(SearchRoute.emptySearchText));
        }
      },
    );

@Riverpod()
class EngineBoundIntentStream extends _$EngineBoundIntentStream {
  @override
  Stream<SharedContent> build() {
    final engineReady = ref.watch(engineReadyStateProvider);
    if (!engineReady) {
      return const Stream.empty();
    }

    final sharingItentStream = ref.watch(sharingIntentStreamProvider);
    final appWidgetLaunchStream = ref.watch(appWidgetLaunchStreamProvider);

    return MergeStream([
      sharingItentStream.transform(_contentParserTransformer),
      appWidgetLaunchStream.transform(_contentParserTransformer),
    ]);
  }

  @override
  bool updateShouldNotify(
    AsyncValue<SharedContent> previous,
    AsyncValue<SharedContent> next,
  ) {
    // Always notify if e.g. same link opened consecutive that are elseiwese filtered on == comaprison
    return true;
  }
}
