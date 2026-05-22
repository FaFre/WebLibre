// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_connection_options.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(proxyConnectionOptions)
final proxyConnectionOptionsProvider = ProxyConnectionOptionsProvider._();

final class ProxyConnectionOptionsProvider
    extends
        $FunctionalProvider<
          List<ProxyConnectionOption>,
          List<ProxyConnectionOption>,
          List<ProxyConnectionOption>
        >
    with $Provider<List<ProxyConnectionOption>> {
  ProxyConnectionOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyConnectionOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyConnectionOptionsHash();

  @$internal
  @override
  $ProviderElement<List<ProxyConnectionOption>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ProxyConnectionOption> create(Ref ref) {
    return proxyConnectionOptions(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ProxyConnectionOption> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ProxyConnectionOption>>(value),
    );
  }
}

String _$proxyConnectionOptionsHash() =>
    r'7832968f74acd98189110cf926208e694a20d55a';
