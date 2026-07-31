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
import 'dart:collection';

import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'singbox_proxy_logs.g.dart';

/// Cap to keep memory bounded. ~2KB per line × 2000 = ~4MB worst-case, which
/// is well within budget for a debugging surface.
const int _ringBufferCapacity = 2000;

/// Lower bound between two published snapshots. A chatty proxy can emit lines
/// far faster than the screen can render them, and every publication copies the
/// whole ring buffer, so coalescing bursts is free in terms of what the user
/// actually sees.
const _publishInterval = Duration(milliseconds: 100);

/// Snapshot of buffered log entries. Most-recent-last (chronological).
///
/// This notifier is `keepAlive` and subscribed from app start (see
/// `main.dart`) so startup messages are retained even before any UI mounts.
/// Appending and *publishing* are therefore deliberately decoupled: lines
/// always land in [_buffer], but a new immutable snapshot is only produced
/// while the log screen is on screen ([setLivePublishing]) and at most once
/// per [_publishInterval].
@Riverpod(keepAlive: true)
class SingboxProxyLogs extends _$SingboxProxyLogs {
  final _buffer = Queue<ProxyLogMessage>();

  StreamSubscription<SingboxProxyLogMessage>? _singboxSubscription;
  StreamSubscription<TorLogMessage>? _torSubscription;

  Timer? _publishTimer;
  bool _livePublishing = false;

  /// Buffer contents materialized on demand, regardless of publication state.
  /// Lets a freshly mounted screen paint the backlog without waiting for the
  /// first throttled snapshot.
  List<ProxyLogMessage> get snapshot => List.unmodifiable(_buffer);

  /// Enables/disables snapshot publication. Called by the log screen as it
  /// mounts and unmounts; flushes on both edges so the state left behind is
  /// always complete.
  void setLivePublishing(bool enabled) {
    if (_livePublishing == enabled) {
      return;
    }

    _livePublishing = enabled;
    _publishTimer?.cancel();
    _publishTimer = null;
    _publish();
  }

  void _append(ProxyLogMessage message) {
    _buffer.add(message);

    while (_buffer.length > _ringBufferCapacity) {
      _buffer.removeFirst();
    }

    if (!_livePublishing || (_publishTimer?.isActive ?? false)) {
      return;
    }

    _publishTimer = Timer(_publishInterval, _publish);
  }

  void _publish() {
    _publishTimer = null;

    if (!ref.mounted) {
      return;
    }

    state = snapshot;
  }

  void clear() {
    _buffer.clear();
    _publishTimer?.cancel();
    _publishTimer = null;
    state = const [];
  }

  @override
  List<ProxyLogMessage> build() {
    final client = ref.watch(singboxProxyClientProvider);
    final torLogs = torLogStream(ref);

    _singboxSubscription = client.logStream.listen(
      (message) => _append(ProxyLogMessage.fromSingbox(message)),
    );
    _torSubscription = torLogs.listen(
      (message) => _append(ProxyLogMessage.fromTor(message)),
    );

    ref.onDispose(() {
      _publishTimer?.cancel();
      unawaited(_singboxSubscription?.cancel());
      unawaited(_torSubscription?.cancel());
    });

    return snapshot;
  }
}
