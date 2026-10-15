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
import 'package:simple_intent_receiver/simple_intent_receiver.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/data/models/received_intent_parameter.dart';
import 'package:weblibre/features/app_widget/domain/services/home_widget.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
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
/// instead. On a cold start [StartupLaunchCover] holds one from earlier still,
/// before the router mounts, covering the stretch before the launch reaches the
/// consumer.
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

/// What a raised cover holds. Exists exactly as long as the cover is up.
final class _RaisedCover {
  _RaisedCover({
    required this.awaited,
    required IntentLaunchClaim claim,
    required void Function() onTimeout,
  }) : _claim = claim..claim(),
       _timeout = Timer(StartupLaunchCover._maxCover, onTimeout);

  /// By identity: pigeon's `Intent` compares by value, and an equal link that
  /// arrived later is not the one being waited for.
  final Set<Intent> awaited;
  final IntentLaunchClaim _claim;
  final Timer _timeout;

  void end() {
    _timeout.cancel();
    _claim.release();
  }
}

/// Keeps the browser behind the startup spinner while a cold start is still
/// opening the launch the app was started for.
///
/// The router mounts as soon as initialization finishes, and the restored
/// session has no selection yet, so the home surface painted for a quarter of a
/// second before the launch's tab replaced it (#612).
///
/// Raised by startup, before the router mounts, from the receiver's backlog.
/// While up it holds an [IntentLaunchClaim]: the consumer takes its own only
/// once the launch has crossed the gatekeeper and reached the browser view, and
/// a startup home target that ran in between found no claim, no selection, and
/// latched home over the launch anyway.
///
/// Lowered by whichever comes first:
/// - a tab is selected — normally the launch's own;
/// - the sharing pipeline let go of every awaited launch without opening it;
/// - the consumer gave up, or is showing a route rather than a tab ([lower]);
/// - [_maxCover], so a launch lost on the way never strands the spinner.
@Riverpod(keepAlive: true)
class StartupLaunchCover extends _$StartupLaunchCover {
  /// Past the consumer's 10s wait for the engine, and short of
  /// [IntentLaunchClaim]'s own bound, so the claim held here is released by
  /// this rather than expiring underneath it.
  static const _maxCover = Duration(seconds: 12);

  _RaisedCover? _cover;
  var _startupHandled = false;

  @override
  bool build() {
    ref.listen(selectedTabProvider, (_, tabId) {
      if (tabId != null) lower();
    });

    final unopened = ref
        .watch(unopenedSharingIntentsProvider)
        .stream
        .listen(_onUnopened);

    ref.onDispose(() {
      unawaited(unopened.cancel());
      // Only the timer: no provider may be modified from a disposal, and the
      // claim goes with this container and settles itself.
      _cover?._timeout.cancel();
    });

    return false;
  }

  /// Raises the cover for [launches], the openable part of the startup
  /// backlog. Does nothing when there are none, and nothing on any call after
  /// the first: only the launch the app was started with is hidden this way.
  void raiseFor(Iterable<Intent> launches) {
    if (_startupHandled) return;
    _startupHandled = true;

    final awaited = Set<Intent>.identity()..addAll(launches);
    if (awaited.isEmpty) return;

    _cover = _RaisedCover(
      awaited: awaited,
      claim: ref.read(intentLaunchClaimProvider.notifier),
      onTimeout: lower,
    );
    state = true;
  }

  void lower() {
    final cover = _cover;
    if (cover == null) return;

    _cover = null;
    cover.end();
    state = false;
  }

  void _onUnopened(Intent intent) {
    final cover = _cover;
    if (cover == null || !cover.awaited.remove(intent)) return;
    if (cover.awaited.isEmpty) lower();
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
