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
 */
import 'package:fast_equatable/fast_equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_autostart.dart';
import 'package:weblibre/features/proxy/domain/services/proxy_demand.dart';
import 'package:weblibre/features/tor/domain/extensions/tor_status_x.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'proxy_start_expectation.g.dart';

/// Which proxy connections still owe the routing snapshot an endpoint.
///
/// The extension blocks any context routed through a proxy it has no endpoint
/// for. That is the correct answer for a backend that is not running, and the
/// wrong one for a backend that is thirty milliseconds from publishing its
/// port — the first deserves an error page and a "start it?" prompt, the second
/// deserves a moment's patience. Nothing downstream of the app can tell them
/// apart, so the app says which it is.
///
/// Answered per connection rather than per backend. A blanket "sing-box is
/// starting" holds a container routed through a profile nobody is starting for
/// the extension's whole budget just because some other profile is coming up,
/// which is precisely the error page this exists to avoid — only later, and
/// after ninety seconds of nothing.
class ProxyStartExpectation with FastEquatable {
  /// True while the app has not yet settled *which* connections it starts by
  /// itself — at launch, or on behalf of a Custom Tab or PWA waiting for one.
  ///
  /// Routing is published as soon as its inputs resolve, which is well before
  /// startup gets round to autostarting anything (`main.dart` runs the
  /// autostart service near the end of its sequence, deliberately unawaited).
  /// A snapshot pushed in that window would otherwise claim every endpoint-less
  /// relation is a settled block, and requests waiting for the routing to
  /// arrive would be released straight into an error page.
  ///
  /// Ends when the autostart *configuration* is read, not when the starts it
  /// asks for finish — those are named in [startingProxyIds] from that moment
  /// on, so a connection nothing intends to start stops being covered while the
  /// ones that are still are.
  final bool unresolved;

  /// The encoded ids a start is in flight for, or is about to be.
  ///
  /// Assembled from both halves of the question, because neither alone spans
  /// the whole window: autostart knows what it is going to bring up before it
  /// calls anything, and the backends know what is coming up once it has —
  /// including for starts autostart never asked for, which is every one the
  /// user triggers by hand.
  final Set<String> startingProxyIds;

  ProxyStartExpectation({
    required this.unresolved,
    required this.startingProxyIds,
  });

  /// Nothing is coming: every endpoint-less relation is a settled block.
  ///
  /// A single shared instance rather than a `const` constructor, which
  /// [FastEquatable]'s cached hash rules out. Nothing here is mutable, so one
  /// instance stands in for all of them exactly as a canonicalized const would.
  static final ProxyStartExpectation none = ProxyStartExpectation(
    unresolved: false,
    startingProxyIds: const {},
  );

  /// Whether an endpoint for [encodedProxyId] is still expected to appear.
  ///
  /// An id that decodes to no known connection is answered "no": it names a
  /// backend nothing here can start, so waiting for it could only postpone the
  /// same block. Checked ahead of [unresolved] for that reason — a retired
  /// backend is not made startable by startup not having finished.
  bool covers(String encodedProxyId) {
    if (ProxyConnectionId.decode(encodedProxyId) == null) return false;
    if (unresolved) return true;

    return startingProxyIds.contains(encodedProxyId);
  }

  // By value, so the provider below stops the snapshot recomputing on every
  // Tor bootstrap progress tick — the status stream reports far more often than
  // the answer here changes.
  @override
  List<Object?> get hashParameters => [unresolved, startingProxyIds];
}

/// The live [ProxyStartExpectation], assembled from what each backend reports.
///
/// Watched by [containerRoutingSnapshot], so a start that settles — succeeds,
/// fails, or is abandoned — recomputes the snapshot and pushes it. That push is
/// what ends the extension's wait: without it a request held for a start would
/// sit out the whole budget before failing.
@Riverpod(keepAlive: true)
ProxyStartExpectation proxyStartExpectation(Ref ref) {
  final autostartPending = ref.watch(proxyAutostartServiceProvider);
  final demandPending = ref.watch(proxyDemandServiceProvider);
  final torStatus = ref.watch(torProxyServiceProvider);
  final singboxStarting = ref.watch(singboxProxyStartingConnectionsProvider);

  return ProxyStartExpectation(
    // Both halves have to have answered. A launch waiting for a proxy is a
    // decision to start it that this process has already taken and not yet
    // acted on, and publishing it as a settled block in that window releases
    // the very requests the launch is waiting on into an error page.
    unresolved: autostartPending == null || demandPending == null,
    startingProxyIds: {
      // What startup has decided to bring up but may not have called yet.
      ...?autostartPending,
      // The same, for a launch that asked for one.
      ...?demandPending,
      // `isBusy` also covers the provider's own loading state, which is what a
      // start that has been asked for but not yet reported looks like.
      if (torStatus.isBusy) const TorProxyConnectionId().encode(),
      // Already encoded: the runtime identifies profiles by connection id.
      ...singboxStarting,
    },
  );
}
