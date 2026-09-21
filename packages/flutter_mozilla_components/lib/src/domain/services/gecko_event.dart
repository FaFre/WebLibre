/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_mozilla_components/src/extensions/subject.dart';
import 'package:flutter_mozilla_components/src/pigeons/gecko.g.dart';
import 'package:rxdart/rxdart.dart';

// Typedefs for record types
typedef HistoryEvent = ({String tabId, HistoryState history});
typedef ReaderableEvent = ({String tabId, ReaderableState readerable});
typedef SecurityInfoEvent = ({String tabId, SecurityInfoState securityInfo});
typedef IconChangeEvent = ({String tabId, Uint8List? bytes});
typedef IconUpdateEvent = ({String url, Uint8List bytes});
typedef ThumbnailEvent = ({String tabId, Uint8List? bytes});
typedef FindResultsEvent = ({String tabId, List<FindResultState> results});
typedef LongPressEvent = ({String tabId, HitResult hitResult});
typedef ScrollEvent = ({String tabId, int scrollY});
typedef ManifestUpdateEvent = ({String tabId, PwaManifest? manifest});
typedef TabTranslationEvent = ({String tabId, TabTranslationStateData state});
typedef TranslationEngineEvent = TranslationEngineStateData;
typedef DownloadStoppedEvent = DownloadState;

class GeckoEventService extends GeckoStateEvents {
  // Stream controllers
  final _viewStateSubject = BehaviorSubject.seeded(false);
  final _engineStateSubject = BehaviorSubject.seeded(false);
  final _tabListSubject = BehaviorSubject<List<String>>();
  final _selectedTabSubject = BehaviorSubject<String?>();
  final _restoreCompleteSubject = BehaviorSubject.seeded(false);

  final _tabContentSubject = ReplaySubject<TabContentState>();
  final _historySubject = ReplaySubject<HistoryEvent>();
  final _securityInfoSubject = ReplaySubject<SecurityInfoEvent>();
  final _readerableSubject = ReplaySubject<ReaderableEvent>();

  final _iconChangeSubject = PublishSubject<IconChangeEvent>();
  final _iconUpdateSubject = PublishSubject<IconUpdateEvent>();
  final _thumbnailSubject = PublishSubject<ThumbnailEvent>();
  final _findResultsSubject = PublishSubject<FindResultsEvent>();
  final _longPressSubject = PublishSubject<LongPressEvent>();
  // final _scrollEventSubject = PublishSubject<ScrollEvent>();
  final _prefUpdateSubject = PublishSubject<GeckoPref>();
  final _siteAssignementSubject = PublishSubject<ContainerSiteAssignment>();

  /// Proxy load errors that fired before anything was listening, newest per tab.
  ///
  /// A cold start is when these are most likely — the proxy extension blocks
  /// every request until routing is installed — and it is also the one moment
  /// where the browser screen has not subscribed yet, so a plain
  /// [PublishSubject] drops exactly the errors the recovery exists to handle.
  /// Only held until the first subscriber arrives: after that a dropped event
  /// means nobody is displaying tabs, and an error resurfacing later would
  /// reload a page that has long since loaded fine.
  final _bufferedProxyLoadErrors = <String?, (int, ProxyLoadError)>{};
  var _proxyLoadErrorsObserved = false;

  late final _proxyLoadErrorSubject = PublishSubject<ProxyLoadError>(
    onListen: _flushProxyLoadErrors,
  );

  final _tabAddedSubject = PublishSubject<String>();
  final _mlProgressSubject = PublishSubject<MlProgressData>();
  final _downloadStoppedSubject = PublishSubject<DownloadStoppedEvent>();
  final _manifestUpdateSubject = PublishSubject<ManifestUpdateEvent>();
  final _translationEngineSubject = BehaviorSubject<TranslationEngineEvent>();
  final _tabTranslationSubject = ReplaySubject<TabTranslationEvent>();

  // Event streams
  ValueStream<bool> get viewReadyStateEvents => _viewStateSubject.stream;
  ValueStream<bool> get engineReadyStateEvents => _engineStateSubject.stream;
  ValueStream<List<String>> get tabListEvents => _tabListSubject.stream;
  ValueStream<String?> get selectedTabEvents => _selectedTabSubject.stream;
  ValueStream<bool> get restoreCompleteEvents => _restoreCompleteSubject.stream;

  Stream<TabContentState> get tabContentEvents => _tabContentSubject.stream;
  Stream<HistoryEvent> get historyEvents => _historySubject.stream;
  Stream<ReaderableEvent> get readerableEvents => _readerableSubject.stream;
  Stream<SecurityInfoEvent> get securityInfoEvents =>
      _securityInfoSubject.stream;
  Stream<IconChangeEvent> get iconChangeEvents => _iconChangeSubject.stream;
  Stream<IconUpdateEvent> get iconUpdateEvents => _iconUpdateSubject.stream;
  Stream<ThumbnailEvent> get thumbnailEvents => _thumbnailSubject.stream;
  Stream<FindResultsEvent> get findResultsEvent => _findResultsSubject.stream;
  Stream<LongPressEvent> get longPressEvent => _longPressSubject.stream;
  // Stream<ScrollEvent> get scrollEvent => _scrollEventSubject.stream;
  Stream<GeckoPref> get prefUpdateEvent => _prefUpdateSubject.stream;
  Stream<ContainerSiteAssignment> get siteAssignementEvent =>
      _siteAssignementSubject.stream;
  Stream<ProxyLoadError> get proxyLoadErrorEvents =>
      _proxyLoadErrorSubject.stream;

  Stream<String> get tabAddedStream => _tabAddedSubject.stream;
  Stream<MlProgressData> get mlProgressEvents => _mlProgressSubject.stream;
  Stream<DownloadStoppedEvent> get downloadStoppedEvents =>
      _downloadStoppedSubject.stream;
  Stream<ManifestUpdateEvent> get manifestUpdateEvents =>
      _manifestUpdateSubject.stream;
  ValueStream<TranslationEngineEvent> get translationEngineEvents =>
      _translationEngineSubject.stream;
  Stream<TabTranslationEvent> get tabTranslationEvents =>
      _tabTranslationSubject.stream;

  @override
  Future<void> onViewReadyStateChange(int sequence, bool state) async {
    _viewStateSubject.addWhenMoreRecent(sequence, null, state);
  }

  @override
  Future<void> onEngineReadyStateChange(int sequence, bool state) async {
    _engineStateSubject.addWhenMoreRecent(sequence, null, state);
  }

  // Overridden methods
  @override
  Future<void> onTabListChange(int sequence, List<String?> tabIds) async {
    _tabListSubject.addWhenMoreRecent(sequence, null, tabIds.nonNulls.toList());
  }

  @override
  Future<void> onSelectedTabChange(int sequence, String? id) async {
    _selectedTabSubject.addWhenMoreRecent(sequence, id, id);
  }

  @override
  Future<void> onRestoreCompleteChange(
    int sequence,
    bool restoreComplete,
  ) async {
    _restoreCompleteSubject.addWhenMoreRecent(sequence, null, restoreComplete);
  }

  @override
  Future<void> onTabContentStateChange(
    int sequence,
    TabContentState state,
  ) async {
    _tabContentSubject.addWhenMoreRecent(sequence, state.id, state);
  }

  @override
  Future<void> onHistoryStateChange(
    int sequence,
    String id,
    HistoryState state,
  ) async {
    _historySubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      history: state,
    ));
  }

  @override
  Future<void> onReaderableStateChange(
    int sequence,
    String id,
    ReaderableState state,
  ) async {
    _readerableSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      readerable: state,
    ));
  }

  @override
  Future<void> onSecurityInfoStateChange(
    int sequence,
    String id,
    SecurityInfoState state,
  ) async {
    _securityInfoSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      securityInfo: state,
    ));
  }

  @override
  Future<void> onIconChange(int sequence, String id, Uint8List? bytes) async {
    _iconChangeSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      bytes: bytes,
    ));
  }

  @override
  Future<void> onIconUpdate(int sequence, String url, Uint8List bytes) async {
    _iconUpdateSubject.addWhenMoreRecent(sequence, url, (
      url: url,
      bytes: bytes,
    ));
  }

  @override
  Future<void> onThumbnailChange(
    int sequence,
    String id,
    Uint8List? bytes,
  ) async {
    _thumbnailSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      bytes: bytes,
    ));
  }

  @override
  Future<void> onFindResults(
    int sequence,
    String id,
    List<FindResultState?> results,
  ) async {
    _findResultsSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      results: results.nonNulls.toList(),
    ));
  }

  @override
  Future<void> onLongPress(int sequence, String id, HitResult hitResult) async {
    _longPressSubject.addWhenMoreRecent(sequence, id, (
      tabId: id,
      hitResult: hitResult,
    ));
  }

  @override
  Future<void> onTabAdded(int sequence, String tabId) async {
    _tabAddedSubject.addWhenMoreRecent(sequence, null, tabId);
  }

  // @override
  // void onScrollChange(int sequence, String tabId, int scrollY) {
  //   _scrollEventSubject.addWhenMoreRecent(sequence, tabId, (
  //     tabId: tabId,
  //     scrollY: scrollY,
  //   ));
  // }

  @override
  Future<void> onPreferenceChange(int sequence, GeckoPref value) async {
    _prefUpdateSubject.addWhenMoreRecent(sequence, value.name, value);
  }

  @override
  Future<void> onContainerSiteAssignment(
    int sequence,
    ContainerSiteAssignment details,
  ) async {
    _siteAssignementSubject.addWhenMoreRecent(
      sequence,
      details.requestId,
      details,
    );
  }

  @override
  Future<void> onProxyLoadError(int sequence, ProxyLoadError details) async {
    if (!_proxyLoadErrorsObserved) {
      // Same ordering rule the subject itself applies: these arrive over a
      // platform channel that does not promise delivery order, which is what
      // the sequence exists for. Overwriting blindly would let a late-delivered
      // older error be the one replayed.
      final buffered = _bufferedProxyLoadErrors[details.tabId];
      if (buffered != null && buffered.$1 >= sequence) return;

      _bufferedProxyLoadErrors[details.tabId] = (sequence, details);
      return;
    }

    _proxyLoadErrorSubject.addWhenMoreRecent(sequence, details.tabId, details);
  }

  /// Hands the first subscriber whatever it missed.
  ///
  /// Replayed through [SubjectAddRecent.addWhenMoreRecent] like any other event,
  /// so a buffered error a newer one has already superseded stays dropped. The
  /// delivery itself is deferred: this runs from inside `listen()`, before the
  /// subscription it belongs to exists.
  void _flushProxyLoadErrors() {
    _proxyLoadErrorsObserved = true;
    if (_bufferedProxyLoadErrors.isEmpty) return;

    final buffered = _bufferedProxyLoadErrors.values.toList();
    _bufferedProxyLoadErrors.clear();

    scheduleMicrotask(() {
      for (final (sequence, details) in buffered) {
        if (_proxyLoadErrorSubject.isClosed) return;
        _proxyLoadErrorSubject.addWhenMoreRecent(
          sequence,
          details.tabId,
          details,
        );
      }
    });
  }

  @override
  Future<void> onMlProgress(int sequence, MlProgressData progress) async {
    _mlProgressSubject.addWhenMoreRecent(sequence, null, progress);
  }

  @override
  Future<void> onDownloadStopped(int sequence, DownloadState state) async {
    _downloadStoppedSubject.addWhenMoreRecent(sequence, state.id, state);
  }

  @override
  Future<void> onManifestUpdate(
    int sequence,
    String tabId,
    PwaManifest? manifest,
  ) async {
    _manifestUpdateSubject.addWhenMoreRecent(sequence, tabId, (
      tabId: tabId,
      manifest: manifest,
    ));
  }

  @override
  Future<void> onTranslationEngineStateChange(
    int sequence,
    TranslationEngineStateData state,
  ) async {
    _translationEngineSubject.addWhenMoreRecent(sequence, null, state);
  }

  @override
  Future<void> onTabTranslationStateChange(
    int sequence,
    TabTranslationStateData state,
  ) async {
    _tabTranslationSubject.addWhenMoreRecent(sequence, state.tabId, (
      tabId: state.tabId,
      state: state,
    ));
  }

  GeckoEventService.setUp({
    BinaryMessenger? binaryMessenger,
    String messageChannelSuffix = '',
  }) {
    GeckoStateEvents.setUp(
      this,
      binaryMessenger: binaryMessenger,
      messageChannelSuffix: messageChannelSuffix,
    );
  }

  Future<void> dispose() async {
    await _viewStateSubject.close();
    await _engineStateSubject.close();
    await _tabListSubject.close();
    await _selectedTabSubject.close();
    await _tabContentSubject.close();
    await _historySubject.close();
    await _readerableSubject.close();
    await _securityInfoSubject.close();
    await _iconChangeSubject.close();
    await _iconUpdateSubject.close();
    await _thumbnailSubject.close();
    await _findResultsSubject.close();
    await _longPressSubject.close();
    // await _scrollEventSubject.close();
    await _tabAddedSubject.close();
    await _prefUpdateSubject.close();
    await _siteAssignementSubject.close();
    await _proxyLoadErrorSubject.close();
    await _mlProgressSubject.close();
    await _downloadStoppedSubject.close();
    await _manifestUpdateSubject.close();
    await _translationEngineSubject.close();
    await _tabTranslationSubject.close();
  }
}
