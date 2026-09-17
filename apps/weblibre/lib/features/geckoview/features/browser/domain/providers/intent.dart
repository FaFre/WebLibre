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

import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/share_intent/domain/entities/shared_content.dart';
import 'package:weblibre/features/share_intent/domain/services/sharing_intent.dart';

part 'intent.g.dart';

final _contentParserTransformer =
    StreamTransformer<ReceivedIntentParameter, SharedContent>.fromHandlers(
      handleData: (parameter, sink) {
        final parsed = parameter.content.mapNotNull(
          (content) => SharedContent.parse(
            content,
            contextId: parameter.contextId,
            containerMode: parameter.containerMode,
          ),
        );

        if (parsed != null) {
          sink.add(parsed);
        } else if (parameter.tool == 'search') {
          sink.add(SharedText(SearchRoute.emptySearchText));
        }
      },
    );

/// Whether an external launch is on its way to a tab.
///
/// Held from the moment the launch is delivered — synchronously, before the
/// engine-readiness wait — until its tab exists, so that startup logic which
/// would otherwise conclude the browser has nothing to show waits for it
/// instead.
///
/// The two are far apart on a cold start. Opening the launch means waiting for
/// the engine, resolving a container and writing the tab DB, while
/// `HomeTargetController` gives a restored selection ~300ms before it decides
/// the session is empty and latches the home surface (or resumes some other
/// tab) over whatever the launch opens next. The launch then loaded behind the
/// home screen, looking like it had been dropped (#623). "Ask" never showed it,
/// because the dialog defers the tab to a tap that lands long after startup has
/// settled.
@Riverpod(keepAlive: true)
class IntentLaunchClaim extends _$IntentLaunchClaim {
  /// Bounds a claim whose holder never releases it. Generous, because the
  /// holder's own wait for the engine already runs to 10s and expiring early
  /// would reintroduce the race it exists to close; the cost of being late is
  /// only that a target which opens or resumes a tab does so later, against a
  /// home surface that is already on screen.
  static const _maxHold = Duration(seconds: 15);

  var _outstanding = 0;
  Timer? _expiry;
  final _settled = <Completer<void>>[];

  /// Takes a claim. Every call must be matched by a [release], including on the
  /// failure paths — hence the `finally` at the call site.
  void claim() {
    _outstanding++;
    _expiry?.cancel();
    _expiry = Timer(_maxHold, _settle);

    if (ref.mounted) {
      state = true;
    }
  }

  void release() {
    if (_outstanding == 0) {
      return;
    }

    _outstanding--;

    if (_outstanding == 0) {
      _settle();
    }
  }

  /// Completes once nothing is outstanding, immediately if nothing is.
  ///
  /// Never throws and never waits forever: an expired claim settles the same way
  /// a released one does.
  Future<void> waitUntilSettled() {
    if (!state) {
      return Future.value();
    }

    final completer = Completer<void>();
    _settled.add(completer);

    return completer.future;
  }

  void _settle() {
    _outstanding = 0;
    _expiry?.cancel();
    _expiry = null;

    if (ref.mounted) {
      state = false;
    }

    for (final completer in _settled) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }
    _settled.clear();
  }

  @override
  bool build() {
    // Waiters outlive nothing: a container torn down mid-launch must not leave
    // a startup sequence parked on a future that can no longer complete.
    ref.onDispose(_settle);

    return false;
  }
}

@Riverpod()
class EngineBoundIntentStream extends _$EngineBoundIntentStream {
  @override
  Stream<SharedContent> build() {
    final sharingItentStream = ref.watch(sharingIntentStreamProvider);
    final appWidgetLaunchStream = ref.watch(appWidgetLaunchStreamProvider);

    // Create a broadcast stream controller to buffer events
    final controller = StreamController<SharedContent>.broadcast();

    final subscription =
        MergeStream([
          sharingItentStream.transform(_contentParserTransformer),
          appWidgetLaunchStream.transform(_contentParserTransformer),
        ]).listen(
          controller.add,
          onError: (Object error, StackTrace stackTrace) {
            logger.e(
              'Intent stream error',
              error: error,
              stackTrace: stackTrace,
            );
            controller.addError(error, stackTrace);
          },
          onDone: controller.close,
        );

    ref.onDispose(() async {
      await subscription.cancel();
      await controller.close();
    });

    return controller.stream;
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
