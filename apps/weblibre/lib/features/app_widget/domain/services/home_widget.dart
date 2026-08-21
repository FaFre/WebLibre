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
import 'package:home_widget/home_widget.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'home_widget.g.dart';

@Riverpod(keepAlive: true)
Future<bool> widgetPinnable(Ref ref) async {
  return await HomeWidget.isRequestPinWidgetSupported() ?? false;
}

/// The action the search-bar widget sends, defined by the `home_widget` plugin.
const homeWidgetLaunchAction = 'es.antonborri.home_widget.action.LAUNCH';

/// A widget launch the broker held, in the shape the widget stream already reads.
///
/// Returns null for anything that is not a widget launch.
ReceivedIntentParameter? widgetLaunchFrom(Intent intent) {
  if (intent.action != homeWidgetLaunchAction) return null;

  final data = intent.data;
  if (data == null) return null;

  final uri = Uri.tryParse(data);
  if (uri == null || uri.host.isEmpty) return null;

  return ReceivedIntentParameter(null, uri.host);
}

/// Every widget launch, whoever delivered it.
///
/// ## Who delivers a widget launch
///
/// The `home_widget` plugin reads the launch intent itself, so §7.1's question is
/// real: broker, plugin, or both with deduplication. The answer here is
/// **whichever one has it, and never both** — which holds by construction rather
/// than by filtering:
///
/// - **Cold start.** `MainActivity.onCreate` does not queue, so the launch intent
///   is untouched and `initiallyLaunchedFromHomeWidget()` reads it as always.
/// - **Warm, profile committed.** The broker declines the intent, `super` runs,
///   and the plugin's `widgetClicked` fires.
/// - **Warm, nothing committed** — the picker, maintenance, restart teardown.
///   The broker takes the intent and `MainActivity` returns without `super`, so
///   the plugin never sees it and cannot double-deliver. Before this, the plugin
///   sent it to a Dart side with no listeners and the tap did nothing at all.
///
/// The two paths are mutually exclusive on the *same* condition the broker uses
/// to take an intent, so a deduplication step would have nothing to deduplicate.
/// The merge below is a union of disjoint sources, not a race.
///
/// Subscribed as soon as it is built, and buffered, unlike the plugin's own
/// streams: a launch the broker replays is delivered once, at startup, while the
/// widget that reads this only exists once the browser has mounted. See
/// [bufferedIntentStream].
@Riverpod(keepAlive: true)
Raw<Stream<ReceivedIntentParameter>> appWidgetLaunchStream(Ref ref) {
  final initialStream = HomeWidget.initiallyLaunchedFromHomeWidget().asStream();

  final brokered = ref
      .watch(allIntentsProvider)
      .map(widgetLaunchFrom)
      .whereNotNull();

  return bufferedIntentStream(
    ref,
    MergeStream([
      ConcatStream([
        initialStream,
        HomeWidget.widgetClicked,
      ]).whereNotNull().map((uri) => ReceivedIntentParameter(null, uri.host)),
      brokered,
    ]),
  );
}
