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
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/providers/split_view_inputs.dart';
import 'package:weblibre/features/geckoview/features/split_view/domain/services/split_presentation.dart';

part 'split_view_native_sync.g.dart';

/// The native split view host, registered for its events once.
@Riverpod(keepAlive: true)
GeckoSplitViewService splitViewService(Ref ref) {
  final service = GeckoSplitViewService()..setUp();
  ref.onDispose(service.dispose);
  return service;
}

/// Keeps native's split mirror equal to the Dart state.
///
/// Watches the pair, the content size, the keyboard, the members' identity
/// colors, the theme and the labels, and pushes a [SplitViewState] whenever the
/// value changes (by value; never per frame). Pushes are serialized and the
/// latest value wins.
///
/// Ordering across restarts: every instance picks its own epoch, and its
/// revisions count from one within it. Native accepts any new epoch, so a
/// restarted Dart half takes over with its first push.
@Riverpod(keepAlive: true)
class SplitViewNativeSync extends _$SplitViewNativeSync {
  final String _epoch = const Uuid().v4();
  int _revision = 0;

  /// The value last queued, with revision 0, to compare by value.
  SplitViewState? _queued;

  Future<void> _chain = Future.value();

  String get epoch => _epoch;

  @override
  SplitViewState build() {
    final pair = ref.watch(splitPairShownProvider);
    // Only a pair is laid out by these: without one, a resize or the keyboard
    // changes nothing native needs.
    final content = pair == null
        ? null
        : ref.watch(browserContentGeometryProvider);
    final hinge = pair == null ? null : ref.watch(browserContentHingeProvider);
    final keyboardVisible =
        pair != null &&
        ref.watch(
          splitKeyboardVisibleProvider.select((value) => value.value ?? false),
        );
    final chrome = ref.watch(splitViewChromeControllerProvider);
    // The members' identities are held open only while they are in the pair:
    // a tab that leaves it is no longer watched, and its identity disposes.
    final firstIdentity = pair == null
        ? null
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        : ref.watch(splitTabIdentityProvider(pair.firstTabId));
    final secondIdentity = pair == null
        ? null
        // ignore: riverpod_lint/only_use_keep_alive_inside_keep_alive
        : ref.watch(splitTabIdentityProvider(pair.secondTabId));

    // A Flutter view that attached again (a restarted Dart half, a recreated
    // activity) gets the current state even when nothing changed here.
    ref.listen(engineReadyStateProvider, (previous, next) {
      final current = stateOrNull;
      if (next && previous != true && current != null) {
        _queued = null;
        _schedule(current);
      }
    });

    final next = _compose(
      pair: pair,
      content: content,
      hinge: hinge,
      keyboardVisible: keyboardVisible,
      chrome: chrome,
      firstIdentity: firstIdentity,
      secondIdentity: secondIdentity,
    );
    _schedule(next);
    return next;
  }

  SplitViewState _compose({
    required SplitPair? pair,
    required Size? content,
    required Rect? hinge,
    required bool keyboardVisible,
    required SplitViewChrome? chrome,
    required SplitTabIdentity? firstIdentity,
    required SplitTabIdentity? secondIdentity,
  }) {
    SplitPairState? pairState;
    if (pair != null) {
      final presentation = resolveSplitPresentation(
        pair: pair,
        content: content,
        keyboardVisible: keyboardVisible,
        hinge: hinge,
      );
      Color accentOf(SplitTabIdentity? identity) => chrome == null
          ? const Color(0x00000000)
          : (identity ?? ModeSplitTabIdentity(null)).accent(chrome);

      pairState = SplitPairState(
        pairId: pair.pairId,
        firstTabId: pair.firstTabId,
        secondTabId: pair.secondTabId,
        mode: switch (presentation.mode) {
          SplitMode.sideBySide => SplitPaneMode.sideBySide,
          SplitMode.stacked => SplitPaneMode.stacked,
          SplitMode.focusedOnly => SplitPaneMode.focusedOnly,
        },
        ratio: presentation.ratio,
        dividerDp: presentation.dividerDp,
        draggable: presentation.draggable,
        firstAccentArgb: accentOf(firstIdentity).toARGB32(),
        secondAccentArgb: accentOf(secondIdentity).toARGB32(),
      );
    }

    // Native re-checks the resolved mode against this at its own size, so it
    // has to be the floor the resolver used for this pair's preference.
    final minPane = splitShowMinPane(
      pair?.layout ?? SplitLayoutPreference.automatic,
    );

    return SplitViewState(
      epoch: _epoch,
      revision: 0,
      pair: pairState,
      minPaneWidthDp: minPane.width,
      minPaneHeightDp: minPane.height,
      dragMinPaneWidthDp: SplitMetrics.dragMinPaneWidthDp,
      dragMinPaneHeightDp: SplitMetrics.dragMinPaneHeightDp,
      dividerColorArgb: chrome?.divider.toARGB32() ?? 0,
      gripColorArgb: chrome?.grip.toARGB32() ?? 0,
      dragPreviewColorArgb: chrome?.dragPreview.toARGB32() ?? 0,
      placeholderColorArgb: chrome?.placeholder.toARGB32() ?? 0xFFFFFFFF,
      onPlaceholderColorArgb: chrome?.onPlaceholder.toARGB32() ?? 0xFF000000,
      labels: SplitViewLabels(
        dividerDescription: chrome?.dividerDescription ?? '',
        dividerOptionsAction: chrome?.dividerOptionsAction ?? '',
        // Empty until the host reports its localized labels; native has the
        // one fallback for that moment.
        crashedTitle: chrome?.crashedTitle ?? '',
        crashedReload: chrome?.crashedReload ?? '',
      ),
    );
  }

  void _schedule(SplitViewState next) {
    if (next == _queued) return;
    _queued = next;
    _chain = _chain.then((_) => _push(next));
  }

  Future<void> _push(SplitViewState value) async {
    // A newer value is queued behind this one; it supersedes it.
    if (!identical(value, _queued)) return;

    final revision = ++_revision;
    final outgoing = SplitViewState(
      epoch: value.epoch,
      revision: revision,
      pair: value.pair,
      minPaneWidthDp: value.minPaneWidthDp,
      minPaneHeightDp: value.minPaneHeightDp,
      dragMinPaneWidthDp: value.dragMinPaneWidthDp,
      dragMinPaneHeightDp: value.dragMinPaneHeightDp,
      dividerColorArgb: value.dividerColorArgb,
      gripColorArgb: value.gripColorArgb,
      dragPreviewColorArgb: value.dragPreviewColorArgb,
      placeholderColorArgb: value.placeholderColorArgb,
      onPlaceholderColorArgb: value.onPlaceholderColorArgb,
      labels: value.labels,
    );

    try {
      await ref.read(splitViewServiceProvider).setSplitState(outgoing);
    } catch (error, stackTrace) {
      // Native is not up yet (no engine): the engine-ready push catches up.
      // Otherwise the next [flush] pushes it again.
      logger.w(
        'Split view state not delivered',
        error: error,
        stackTrace: stackTrace,
      );
      if (identical(value, _queued)) {
        _queued = null;
      }
    }
  }

  /// Completes once the push carrying the current state has completed: the
  /// barrier [SplitViewController.pair] waits on before anything selects.
  ///
  /// Returns whether native has the current state. A state whose push failed
  /// earlier is pushed again first, so a transient failure does not stick
  /// until some unrelated dependency changes.
  Future<bool> flush() async {
    final current = stateOrNull;
    if (_queued == null && current != null) {
      _schedule(current);
    }
    // Pushes queued while waiting are part of the current state too.
    while (true) {
      final chain = _chain;
      await chain;
      if (identical(chain, _chain)) break;
    }
    return _queued != null;
  }
}

/// Brings the sync up to date with a change made just now and waits until
/// native has it. Reading the sync rebuilds it if a dependency changed.
/// Returns false when native did not take it.
///
/// Takes the container, not a `Ref`: the controller that calls this is a
/// dependency of the sync, and reading the sync through the controller's own
/// `ref` is a dependency cycle (Riverpod throws `CircularDependencyError`).
/// A container read adds no dependency.
Future<bool> flushSplitViewState(ProviderContainer container) {
  container.read(splitViewNativeSyncProvider);
  return container.read(splitViewNativeSyncProvider.notifier).flush();
}
