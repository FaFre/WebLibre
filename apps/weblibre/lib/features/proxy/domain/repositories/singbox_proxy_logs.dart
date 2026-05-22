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

/// Snapshot of buffered log entries. Most-recent-last (chronological).
@Riverpod(keepAlive: true)
class SingboxProxyLogs extends _$SingboxProxyLogs {
  final _buffer = Queue<ProxyLogMessage>();

  StreamSubscription<SingboxProxyLogMessage>? _singboxSubscription;
  StreamSubscription<TorLogMessage>? _torSubscription;

  void _append(ProxyLogMessage message) {
    _buffer.add(message);

    while (_buffer.length > _ringBufferCapacity) {
      _buffer.removeFirst();
    }

    state = List.unmodifiable(_buffer);
  }

  void clear() {
    _buffer.clear();
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
      unawaited(_singboxSubscription?.cancel());
      unawaited(_torSubscription?.cancel());
    });

    return List.unmodifiable(_buffer);
  }
}
