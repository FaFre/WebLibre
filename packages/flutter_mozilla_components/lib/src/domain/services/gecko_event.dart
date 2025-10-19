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

class GeckoEventService extends GeckoStateEvents {
  // Stream controllers
  final _viewStateSubject = BehaviorSubject.seeded(false);
  final _engineStateSubject = BehaviorSubject.seeded(false);
  final _tabListSubject = BehaviorSubject<List<String>>();
  final _selectedTabSubject = BehaviorSubject<String?>();

  final _tabContentSubject = ReplaySubject<TabContentState>();
  final _historySubject = ReplaySubject<HistoryEvent>();
  final _securityInfoSubject = ReplaySubject<SecurityInfoEvent>();
  final _readerableSubject = ReplaySubject<ReaderableEvent>();

  final _iconChangeSubject = PublishSubject<IconChangeEvent>();
  final _iconUpdateSubject = PublishSubject<IconUpdateEvent>();
  final _thumbnailSubject = PublishSubject<ThumbnailEvent>();
  final _findResultsSubject = PublishSubject<FindResultsEvent>();
  final _longPressSubject = PublishSubject<LongPressEvent>();
  final _scrollEventSubject = PublishSubject<ScrollEvent>();
  final _prefUpdateSubject = PublishSubject<GeckoPref>();

  final _tabAddedSubject = PublishSubject<String>();

  // Event streams
  ValueStream<bool> get viewReadyStateEvents => _viewStateSubject.stream;
  ValueStream<bool> get engineReadyStateEvents => _engineStateSubject.stream;
  ValueStream<List<String>> get tabListEvents => _tabListSubject.stream;
  ValueStream<String?> get selectedTabEvents => _selectedTabSubject.stream;

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
  Stream<ScrollEvent> get scrollEvent => _scrollEventSubject.stream;
  Stream<GeckoPref> get prefUpdateEvent => _prefUpdateSubject.stream;

  Stream<String> get tabAddedStream => _tabAddedSubject.stream;

  @override
  void onViewReadyStateChange(int timestamp, bool state) {
    _viewStateSubject.addWhenMoreRecent(timestamp, null, state);
  }

  @override
  void onEngineReadyStateChange(int timestamp, bool state) {
    _engineStateSubject.addWhenMoreRecent(timestamp, null, state);
  }

  // Overridden methods
  @override
  void onTabListChange(int timestamp, List<String?> tabIds) {
    _tabListSubject.addWhenMoreRecent(
      timestamp,
      null,
      tabIds.nonNulls.toList(),
    );
  }

  @override
  void onSelectedTabChange(int timestamp, String? id) {
    _selectedTabSubject.addWhenMoreRecent(timestamp, id, id);
  }

  @override
  void onTabContentStateChange(int timestamp, TabContentState state) {
    _tabContentSubject.addWhenMoreRecent(timestamp, state.id, state);
  }

  @override
  void onHistoryStateChange(int timestamp, String id, HistoryState state) {
    _historySubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      history: state,
    ));
  }

  @override
  void onReaderableStateChange(
    int timestamp,
    String id,
    ReaderableState state,
  ) {
    _readerableSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      readerable: state,
    ));
  }

  @override
  void onSecurityInfoStateChange(
    int timestamp,
    String id,
    SecurityInfoState state,
  ) {
    _securityInfoSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      securityInfo: state,
    ));
  }

  @override
  void onIconChange(int timestamp, String id, Uint8List? bytes) {
    _iconChangeSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      bytes: bytes,
    ));
  }

  @override
  void onIconUpdate(int timestamp, String url, Uint8List bytes) {
    _iconUpdateSubject.addWhenMoreRecent(timestamp, url, (
      url: url,
      bytes: bytes,
    ));
  }

  @override
  void onThumbnailChange(int timestamp, String id, Uint8List? bytes) {
    _thumbnailSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      bytes: bytes,
    ));
  }

  @override
  void onFindResults(int timestamp, String id, List<FindResultState?> results) {
    _findResultsSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      results: results.nonNulls.toList(),
    ));
  }

  @override
  void onLongPress(int timestamp, String id, HitResult hitResult) {
    _longPressSubject.addWhenMoreRecent(timestamp, id, (
      tabId: id,
      hitResult: hitResult,
    ));
  }

  @override
  void onTabAdded(int timestamp, String tabId) {
    _tabAddedSubject.addWhenMoreRecent(timestamp, null, tabId);
  }

  @override
  void onScrollChange(int timestamp, String tabId, int scrollY) {
    _scrollEventSubject.addWhenMoreRecent(timestamp, tabId, (
      tabId: tabId,
      scrollY: scrollY,
    ));
  }

  @override
  void onPreferenceChange(int timestamp, GeckoPref value) {
    _prefUpdateSubject.addWhenMoreRecent(timestamp, value.name, value);
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

  void dispose() {
    unawaited(_viewStateSubject.close());
    unawaited(_engineStateSubject.close());
    unawaited(_tabListSubject.close());
    unawaited(_selectedTabSubject.close());
    unawaited(_tabContentSubject.close());
    unawaited(_historySubject.close());
    unawaited(_readerableSubject.close());
    unawaited(_securityInfoSubject.close());
    unawaited(_iconChangeSubject.close());
    unawaited(_iconUpdateSubject.close());
    unawaited(_thumbnailSubject.close());
    unawaited(_findResultsSubject.close());
    unawaited(_longPressSubject.close());
    unawaited(_scrollEventSubject.close());
    unawaited(_tabAddedSubject.close());
    unawaited(_prefUpdateSubject.close());
  }
}
