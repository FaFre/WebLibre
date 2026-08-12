// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routed_http_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The client for app-originated requests that belong to no particular tab —
/// add-on metadata, proxy subscriptions, catalog downloads, account handoff.
///
/// Anything that bypasses this and builds its own `HttpClient`/`http.Client`
/// is, by construction, traffic that ignores the user's proxy settings.
///
/// Requests that describe what the user is browsing belong on
/// [selectedTabRoutedHttpClient] instead.

@ProviderFor(routedHttpClient)
final routedHttpClientProvider = RoutedHttpClientProvider._();

/// The client for app-originated requests that belong to no particular tab —
/// add-on metadata, proxy subscriptions, catalog downloads, account handoff.
///
/// Anything that bypasses this and builds its own `HttpClient`/`http.Client`
/// is, by construction, traffic that ignores the user's proxy settings.
///
/// Requests that describe what the user is browsing belong on
/// [selectedTabRoutedHttpClient] instead.

final class RoutedHttpClientProvider
    extends
        $FunctionalProvider<
          Raw<http.Client>,
          Raw<http.Client>,
          Raw<http.Client>
        >
    with $Provider<Raw<http.Client>> {
  /// The client for app-originated requests that belong to no particular tab —
  /// add-on metadata, proxy subscriptions, catalog downloads, account handoff.
  ///
  /// Anything that bypasses this and builds its own `HttpClient`/`http.Client`
  /// is, by construction, traffic that ignores the user's proxy settings.
  ///
  /// Requests that describe what the user is browsing belong on
  /// [selectedTabRoutedHttpClient] instead.
  RoutedHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routedHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routedHttpClientHash();

  @$internal
  @override
  $ProviderElement<Raw<http.Client>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Raw<http.Client> create(Ref ref) {
    return routedHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<http.Client> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<http.Client>>(value),
    );
  }
}

String _$routedHttpClientHash() => r'a080e4e09bbd5be98d7a6e117492551abe4e8319';

/// Resolves routing for a request made on behalf of the selected tab.
///
/// Search suggestions, favicon lookups and link expansions disclose what the
/// user is typing, looking at and about to open, which is exactly what the
/// tab's own proxy is there to hide. Sending them over the general container's
/// route would leak them past the proxy of whatever container the user is
/// actually browsing in.
///
/// A provider handing back a function, for two reasons: the context has to be
/// resolved per request so switching tabs takes effect on the next one, and
/// consumers that are otherwise engine-free — the favicon service, its tests —
/// get a seam they can substitute instead of standing up the tab and engine
/// graph behind the selected tab.

@ProviderFor(selectedTabRoutingPolicy)
final selectedTabRoutingPolicyProvider = SelectedTabRoutingPolicyProvider._();

/// Resolves routing for a request made on behalf of the selected tab.
///
/// Search suggestions, favicon lookups and link expansions disclose what the
/// user is typing, looking at and about to open, which is exactly what the
/// tab's own proxy is there to hide. Sending them over the general container's
/// route would leak them past the proxy of whatever container the user is
/// actually browsing in.
///
/// A provider handing back a function, for two reasons: the context has to be
/// resolved per request so switching tabs takes effect on the next one, and
/// consumers that are otherwise engine-free — the favicon service, its tests —
/// get a seam they can substitute instead of standing up the tab and engine
/// graph behind the selected tab.

final class SelectedTabRoutingPolicyProvider
    extends
        $FunctionalProvider<
          Raw<Future<AppRoutingPolicy> Function()>,
          Raw<Future<AppRoutingPolicy> Function()>,
          Raw<Future<AppRoutingPolicy> Function()>
        >
    with $Provider<Raw<Future<AppRoutingPolicy> Function()>> {
  /// Resolves routing for a request made on behalf of the selected tab.
  ///
  /// Search suggestions, favicon lookups and link expansions disclose what the
  /// user is typing, looking at and about to open, which is exactly what the
  /// tab's own proxy is there to hide. Sending them over the general container's
  /// route would leak them past the proxy of whatever container the user is
  /// actually browsing in.
  ///
  /// A provider handing back a function, for two reasons: the context has to be
  /// resolved per request so switching tabs takes effect on the next one, and
  /// consumers that are otherwise engine-free — the favicon service, its tests —
  /// get a seam they can substitute instead of standing up the tab and engine
  /// graph behind the selected tab.
  SelectedTabRoutingPolicyProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabRoutingPolicyProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabRoutingPolicyHash();

  @$internal
  @override
  $ProviderElement<Raw<Future<AppRoutingPolicy> Function()>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Future<AppRoutingPolicy> Function()> create(Ref ref) {
    return selectedTabRoutingPolicy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Future<AppRoutingPolicy> Function()> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Raw<Future<AppRoutingPolicy> Function()>>(value),
    );
  }
}

String _$selectedTabRoutingPolicyHash() =>
    r'adf37266f1c77d80dcb52edafb6e15cd401ace1d';

/// The client for app-originated requests made on behalf of the selected tab.
///
/// See [selectedTabRoutingPolicy] for why these do not follow the general
/// container. [RoutedHttpClient] swaps its delegate when the resolved policy
/// changes, so a tab switch costs a new delegate rather than a stale route.

@ProviderFor(selectedTabRoutedHttpClient)
final selectedTabRoutedHttpClientProvider =
    SelectedTabRoutedHttpClientProvider._();

/// The client for app-originated requests made on behalf of the selected tab.
///
/// See [selectedTabRoutingPolicy] for why these do not follow the general
/// container. [RoutedHttpClient] swaps its delegate when the resolved policy
/// changes, so a tab switch costs a new delegate rather than a stale route.

final class SelectedTabRoutedHttpClientProvider
    extends
        $FunctionalProvider<
          Raw<http.Client>,
          Raw<http.Client>,
          Raw<http.Client>
        >
    with $Provider<Raw<http.Client>> {
  /// The client for app-originated requests made on behalf of the selected tab.
  ///
  /// See [selectedTabRoutingPolicy] for why these do not follow the general
  /// container. [RoutedHttpClient] swaps its delegate when the resolved policy
  /// changes, so a tab switch costs a new delegate rather than a stale route.
  SelectedTabRoutedHttpClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabRoutedHttpClientProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabRoutedHttpClientHash();

  @$internal
  @override
  $ProviderElement<Raw<http.Client>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Raw<http.Client> create(Ref ref) {
    return selectedTabRoutedHttpClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<http.Client> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<http.Client>>(value),
    );
  }
}

String _$selectedTabRoutedHttpClientHash() =>
    r'72e199d492c667597ea65eb7e3dacd351928c82c';
