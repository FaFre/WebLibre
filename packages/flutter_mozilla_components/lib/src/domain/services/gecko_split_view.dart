/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

/// A divider release reported by native.
class SplitRatioCommit {
  final int sequence;
  final String epoch;
  final String pairId;
  final SplitAxis axis;
  final double ratio;

  const SplitRatioCommit({
    required this.sequence,
    required this.epoch,
    required this.pairId,
    required this.axis,
    required this.ratio,
  });
}

/// A tap on the divider grip (or its accessibility action).
class SplitHandleTap {
  final int sequence;
  final String epoch;
  final String pairId;

  const SplitHandleTap({
    required this.sequence,
    required this.epoch,
    required this.pairId,
  });
}

/// The divider released at the edge: [keptTabId]'s pane is shown alone.
class SplitDividerCollapse {
  final int sequence;
  final String epoch;
  final String pairId;
  final String keptTabId;

  const SplitDividerCollapse({
    required this.sequence,
    required this.epoch,
    required this.pairId,
    required this.keptTabId,
  });
}

/// A pane that was touched or got input focus, whose tab native selected.
class SplitPaneActivation {
  final int sequence;
  final String epoch;
  final String tabId;

  const SplitPaneActivation({
    required this.sequence,
    required this.epoch,
    required this.tabId,
  });
}

/// The native split view host: pushes state down and reports interactions
/// with the native chrome (divider, panes) back up.
class GeckoSplitViewService extends GeckoSplitViewEvents {
  final GeckoSplitViewApi _api;

  final _ratioCommits = PublishSubject<SplitRatioCommit>();
  final _dividerCollapses = PublishSubject<SplitDividerCollapse>();
  final _handleTaps = PublishSubject<SplitHandleTap>();
  final _paneActivations = PublishSubject<SplitPaneActivation>();

  Stream<SplitRatioCommit> get ratioCommits => _ratioCommits.stream;
  Stream<SplitDividerCollapse> get dividerCollapses => _dividerCollapses.stream;
  Stream<SplitHandleTap> get handleTaps => _handleTaps.stream;
  Stream<SplitPaneActivation> get paneActivations => _paneActivations.stream;

  GeckoSplitViewService({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) : _api = GeckoSplitViewApi(
         binaryMessenger: binaryMessenger,
         messageChannelSuffix: messageChannelSuffix,
       );

  /// The service each event channel (by suffix) is registered to: a
  /// service disposed after another took its channel over must not
  /// unregister that one.
  static final _registered = <String, GeckoSplitViewService>{};

  ({BinaryMessenger? binaryMessenger, String messageChannelSuffix})?
  _registration;

  /// Registers this service for native events, until [dispose].
  void setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoSplitViewEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
    _registered[messageChannelSuffix] = this;
    _registration = (
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  /// Completes once native applied [state] and laid the panes out for it.
  Future<void> setSplitState(SplitViewState state) => _api.setSplitState(state);

  @override
  Future<void> onRatioCommitted(
    int sequence,
    String epoch,
    String pairId,
    SplitAxis axis,
    double ratio,
  ) async {
    if (_ratioCommits.isClosed) return;
    _ratioCommits.add(
      SplitRatioCommit(
        sequence: sequence,
        epoch: epoch,
        pairId: pairId,
        axis: axis,
        ratio: ratio,
      ),
    );
  }

  @override
  Future<void> onDividerCollapsed(
    int sequence,
    String epoch,
    String pairId,
    String keptTabId,
  ) async {
    if (_dividerCollapses.isClosed) return;
    _dividerCollapses.add(
      SplitDividerCollapse(
        sequence: sequence,
        epoch: epoch,
        pairId: pairId,
        keptTabId: keptTabId,
      ),
    );
  }

  @override
  Future<void> onHandleTapped(int sequence, String epoch, String pairId) async {
    if (_handleTaps.isClosed) return;
    _handleTaps.add(
      SplitHandleTap(sequence: sequence, epoch: epoch, pairId: pairId),
    );
  }

  @override
  Future<void> onPaneActivated(int sequence, String epoch, String tabId) async {
    if (_paneActivations.isClosed) return;
    _paneActivations.add(
      SplitPaneActivation(sequence: sequence, epoch: epoch, tabId: tabId),
    );
  }

  /// Stops native events from reaching this service, then closes its
  /// streams. Events still on their way are dropped.
  Future<void> dispose() async {
    final registration = _registration;
    _registration = null;
    if (registration != null &&
        identical(_registered[registration.messageChannelSuffix], this)) {
      _registered.remove(registration.messageChannelSuffix);
      GeckoSplitViewEvents.setUp(
        null,
        binaryMessenger: registration.binaryMessenger,
        messageChannelSuffix: registration.messageChannelSuffix,
      );
    }
    await _ratioCommits.close();
    await _dividerCollapses.close();
    await _handleTaps.close();
    await _paneActivations.close();
  }
}
