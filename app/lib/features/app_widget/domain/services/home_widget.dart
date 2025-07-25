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
import 'package:home_widget/home_widget.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';

part 'home_widget.g.dart';

@Riverpod(keepAlive: true)
FutureOr<bool> widgetPinnable(Ref ref) async {
  return await HomeWidget.isRequestPinWidgetSupported() ?? false;
}

@Riverpod()
Raw<Stream<ReceivedIntentParameter>> appWidgetLaunchStream(Ref ref) {
  // ignore: discarded_futures is used as stream
  final initialStream = HomeWidget.initiallyLaunchedFromHomeWidget().asStream();

  return ConcatStream([
    initialStream,
    HomeWidget.widgetClicked,
  ]).whereNotNull().map((uri) => ReceivedIntentParameter(null, uri.host));
}
