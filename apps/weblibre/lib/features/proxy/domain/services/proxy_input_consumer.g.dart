// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_input_consumer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProxyInputConsumer)
final proxyInputConsumerProvider = ProxyInputConsumerProvider._();

final class ProxyInputConsumerProvider
    extends $NotifierProvider<ProxyInputConsumer, void> {
  ProxyInputConsumerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proxyInputConsumerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proxyInputConsumerHash();

  @$internal
  @override
  ProxyInputConsumer create() => ProxyInputConsumer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$proxyInputConsumerHash() =>
    r'fed529f253a9bdf72d0b1c23a298765b681d07b8';

abstract class _$ProxyInputConsumer extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
