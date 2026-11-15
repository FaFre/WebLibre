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
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:weblibre/features/app_update/data/github/update_endpoints.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/services/update_backend.dart';
import 'package:weblibre/features/proxy/domain/services/app_routing_policy.dart';

/// Fixed, carrying no version or device detail (7.2).
const updaterUserAgent = 'WebLibre-Updater';

/// Every updater request goes through here (plan 7.2): HTTPS only, the
/// compiled hosts only, redirects followed by hand and validated before they
/// are requested, no cookies, no `Authorization`, no `Referer`.
///
/// [client] is the routed client. There is no direct fallback anywhere in
/// this feature: a blocked route is `routingUnavailable`.
class AllowlistedFetcher {
  AllowlistedFetcher({
    required this.client,
    this.awaitRouting,
    this.endpoints = UpdateEndpoints.production,
    this.limits = const FetchLimits(),
  });

  final http.Client client;

  /// Waits until app routing is decided (7.1 step 1), before every request.
  /// Decides nothing about the route: [client] still refuses a blocked one.
  /// Bounded on its own (30 s); a cancel ends the wait at once.
  final Future<void> Function()? awaitRouting;
  final UpdateEndpoints endpoints;
  final FetchLimits limits;

  /// The whole exchange, redirects and body included, ends within
  /// [FetchLimits.catalogueTimeout] of routing being settled: a server that
  /// trickles bytes can't hold the check (and the coordinator's one
  /// operation slot) open. Each wait is cut to the time left, and the body
  /// read stops when it runs out, whether or not the client honors the abort.
  Future<List<int>> fetchCatalogue(
    String packageId, {
    CancelToken? cancel,
  }) async {
    final url = endpoints.catalogueUrl(packageId);
    _checkAllowed(url, endpoints.isCatalogueUrl);
    await _routingSettled(cancel);

    final deadline = _Deadline(limits.catalogueTimeout);
    final response = await _send(
      url,
      redirectAllowed: endpoints.isCatalogueUrl,
      cancel: cancel,
      timeout: limits.catalogueTimeout,
      deadline: deadline,
    );
    if (response.statusCode != 200) {
      await discardBody(response);
      throw UpdateFailure(
        UpdateFailureKind.network,
        'catalogue HTTP ${response.statusCode}',
      );
    }
    try {
      return await _readCatalogueBody(response, deadline, cancel);
    } on UpdateFailure {
      rethrow;
    } catch (e) {
      throw mapError(e, cancel);
    }
  }

  /// Ends with the body, a failure, a cancel or the deadline, whichever is
  /// first. Any error ends the fold, which cancels the subscription and so
  /// closes the connection.
  Future<List<int>> _readCatalogueBody(
    http.StreamedResponse response,
    _Deadline deadline,
    CancelToken? cancel,
  ) async {
    final stop = Rx.merge<Never>([
      TimerStream<void>(null, deadline.remaining).map(
        (_) => throw TimeoutException('catalogue deadline', deadline.limit),
      ),
      if (cancel != null)
        cancel.whenCancelled.asStream().map(
          (_) => throw const OperationCancelled(),
        ),
    ]);
    final body = await response.stream.takeUntil(stop).fold(
      BytesBuilder(copy: false),
      (bytes, chunk) {
        bytes.add(chunk);
        if (bytes.length > limits.catalogueBytes) {
          throw UpdateFailure(
            UpdateFailureKind.metadataInvalid,
            'catalogue too large',
          );
        }
        return bytes;
      },
    );
    return body.takeBytes();
  }

  /// Opens an artifact download. The caller reads the stream; the response's
  /// [http.BaseResponse.request] is the final, validated URL.
  Future<http.StreamedResponse> openArtifact(
    Uri url, {
    int? rangeStart,
    required CancelToken cancel,
  }) async {
    _checkAllowed(url, endpoints.isArtifactUrl);
    await _routingSettled(cancel);
    return await _send(
      url,
      redirectAllowed: endpoints.isArtifactRedirect,
      cancel: cancel,
      timeout: limits.connectTimeout,
      headers: {
        if (rangeStart != null && rangeStart > 0) 'range': 'bytes=$rangeStart-',
      },
    );
  }

  static void _checkAllowed(Uri url, bool Function(Uri) allowed) {
    if (!allowed(url)) {
      throw UpdateFailure(
        UpdateFailureKind.metadataInvalid,
        'url outside the allowlist',
      );
    }
  }

  /// [awaitRouting], ended early by a cancel: Cancel frees the operation
  /// slot at once, not when routing settles. A routing failure that arrives
  /// after the cancel is dropped.
  Future<void> _routingSettled(CancelToken? cancel) async {
    final routing = awaitRouting?.call();
    if (routing == null) return;
    await (cancel == null ? routing : cancel.orCancelled(routing));
  }

  /// [timeout] bounds each hop's wait for a response; [deadline], when
  /// given, all of them together.
  Future<http.StreamedResponse> _send(
    Uri url, {
    required bool Function(Uri) redirectAllowed,
    required CancelToken? cancel,
    required Duration timeout,
    _Deadline? deadline,
    Map<String, String> headers = const {},
  }) async {
    var current = url;
    for (var hop = 0; hop <= limits.maxRedirects; hop++) {
      if (cancel?.isCancelled ?? false) throw const OperationCancelled();
      final wait = deadline == null || deadline.remaining > timeout
          ? timeout
          : deadline.remaining;
      if (wait <= Duration.zero) {
        throw UpdateFailure(UpdateFailureKind.network, 'catalogue deadline');
      }

      // Cancelling or giving up on the response both abort the request, so a
      // late response never holds its connection open unread.
      final abort = Completer<void>();
      void abortRequest() {
        if (!abort.isCompleted) abort.complete();
      }

      unawaited(cancel?.whenCancelled.then((_) => abortRequest()));
      final request =
          http.AbortableRequest('GET', current, abortTrigger: abort.future)
            ..followRedirects = false
            ..persistentConnection = true
            ..headers.addAll({
              'user-agent': updaterUserAgent,
              'accept-encoding': 'identity',
              ...headers,
            });

      final pending = client.send(request);
      final http.StreamedResponse response;
      try {
        response = await pending.timeout(
          wait,
          onTimeout: () {
            abortRequest();
            // Should a response still arrive, its body is dropped.
            unawaited(pending.then<void>(discardBody, onError: (Object _) {}));
            throw TimeoutException('no response', wait);
          },
        );
      } catch (e) {
        throw mapError(e, cancel);
      }

      // Set by the client: dart:io's rule for a GET (301, 302, 303, 307, 308).
      if (!response.isRedirect) return response;

      await discardBody(response);
      final location = response.headers['location'];
      final next = location == null ? null : current.resolve(location);
      if (next == null || !redirectAllowed(next)) {
        throw UpdateFailure(
          UpdateFailureKind.network,
          'redirect outside the allowlist',
        );
      }
      current = next;
    }
    throw UpdateFailure(UpdateFailureKind.network, 'too many redirects');
  }

  /// For callers that read a response stream themselves, too.
  static Object mapError(Object error, CancelToken? cancel) {
    if (cancel?.isCancelled ?? false) return const OperationCancelled();
    if (error is UpdateFailure || error is OperationCancelled) return error;
    if (error is AppRoutingBlockedException) {
      return UpdateFailure(UpdateFailureKind.routingUnavailable, error.reason);
    }
    if (error is http.RequestAbortedException) {
      return const OperationCancelled();
    }
    // Timeouts, sockets, TLS, HTTP and client errors alike.
    return UpdateFailure(UpdateFailureKind.network, error.toString());
  }

  /// Drops a body nobody reads. Cancelled rather than drained: a server that
  /// sends headers and then stalls would hold a drain past every timeout.
  /// Cancelling closes the connection instead of returning it to the pool.
  static Future<void> discardBody(http.StreamedResponse response) async {
    try {
      await response.stream
          .listen(null, cancelOnError: true)
          .cancel()
          .timeout(const Duration(seconds: 1));
    } catch (_) {}
  }
}

/// A time budget on the monotonic clock, for one whole exchange.
class _Deadline {
  _Deadline(this.limit) : _clock = Stopwatch()..start();

  final Duration limit;
  final Stopwatch _clock;

  Duration get remaining => limit - _clock.elapsed;
}
