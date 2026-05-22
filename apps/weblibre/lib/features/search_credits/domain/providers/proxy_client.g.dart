// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Resolved Tor SOCKS5 port for search traffic, or `null` when search should
/// route directly. Returns non-null only when the user has enabled the
/// "route search through Tor" toggle AND Tor is currently running with a
/// known SOCKS port.

@ProviderFor(searchProxyPort)
final searchProxyPortProvider = SearchProxyPortProvider._();

/// Resolved Tor SOCKS5 port for search traffic, or `null` when search should
/// route directly. Returns non-null only when the user has enabled the
/// "route search through Tor" toggle AND Tor is currently running with a
/// known SOCKS port.

final class SearchProxyPortProvider
    extends $FunctionalProvider<int?, int?, int?>
    with $Provider<int?> {
  /// Resolved Tor SOCKS5 port for search traffic, or `null` when search should
  /// route directly. Returns non-null only when the user has enabled the
  /// "route search through Tor" toggle AND Tor is currently running with a
  /// known SOCKS port.
  SearchProxyPortProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProxyPortProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProxyPortHash();

  @$internal
  @override
  $ProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int? create(Ref ref) {
    return searchProxyPort(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int?>(value),
    );
  }
}

String _$searchProxyPortHash() => r'1ca1d6f08f9eeabf2f70ce2e27b71242e0808dc0';

/// HttpClient used by both WebSocket (via `IOWebSocketChannel.customClient`)
/// and HTTP-based search clients. SOCKS5-routed when Tor toggle is on, plain
/// otherwise. Rebuilt when the proxy port changes.

@ProviderFor(searchHttpClient)
final searchHttpClientProvider = SearchHttpClientProvider._();

/// HttpClient used by both WebSocket (via `IOWebSocketChannel.customClient`)
/// and HTTP-based search clients. SOCKS5-routed when Tor toggle is on, plain
/// otherwise. Rebuilt when the proxy port changes.

final class SearchHttpClientProvider
    extends $FunctionalProvider<HttpClient, HttpClient, HttpClient>
    with $Provider<HttpClient> {
  /// HttpClient used by both WebSocket (via `IOWebSocketChannel.customClient`)
  /// and HTTP-based search clients. SOCKS5-routed when Tor toggle is on, plain
  /// otherwise. Rebuilt when the proxy port changes.
  SearchHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchHttpClientHash();

  @$internal
  @override
  $ProviderElement<HttpClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HttpClient create(Ref ref) {
    return searchHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HttpClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HttpClient>(value),
    );
  }
}

String _$searchHttpClientHash() => r'b3aa4b658e99fb580031ac412fabfbeece5fe830';

/// `package:http` Client wrapping [searchHttpClientProvider]. Use for the
/// non-WebSocket parts of the search flow (token issuance, one-shot capture,
/// capture artifact downloads).

@ProviderFor(searchProxyHttpClient)
final searchProxyHttpClientProvider = SearchProxyHttpClientProvider._();

/// `package:http` Client wrapping [searchHttpClientProvider]. Use for the
/// non-WebSocket parts of the search flow (token issuance, one-shot capture,
/// capture artifact downloads).

final class SearchProxyHttpClientProvider
    extends $FunctionalProvider<http.Client, http.Client, http.Client>
    with $Provider<http.Client> {
  /// `package:http` Client wrapping [searchHttpClientProvider]. Use for the
  /// non-WebSocket parts of the search flow (token issuance, one-shot capture,
  /// capture artifact downloads).
  SearchProxyHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchProxyHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchProxyHttpClientHash();

  @$internal
  @override
  $ProviderElement<http.Client> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  http.Client create(Ref ref) {
    return searchProxyHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(http.Client value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<http.Client>(value),
    );
  }
}

String _$searchProxyHttpClientHash() =>
    r'08acee399abc5c6960a82365219af6b5a44ba5bd';
