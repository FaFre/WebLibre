import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';

part 'proxy_settings_replication.g.dart';

@Riverpod(keepAlive: true)
class ProxySettingsReplication extends _$ProxySettingsReplication {
  final _service = GeckoContainerProxyService();

  @override
  void build() {
    ref.listen(
      fireImmediately: true,
      torProxyServiceProvider.select((data) => data.valueOrNull),
      (previous, next) async {
        if (next != null) {
          await _service.setProxyPort(next);
        }
      },
    );

    ref.listen(
      fireImmediately: true,
      containersWithCountProvider.select(
        (value) => EquatableValue(
          value.valueOrNull
              ?.where((container) => container.metadata.useProxy)
              .map((container) => container.metadata.contextualIdentity)
              .nonNulls
              .toList(),
        ),
      ),
      (previous, next) async {
        if (next.value != null) {
          for (final contextId in next.value!) {
            await _service.addContainerProxy(contextId);
          }
        }
      },
    );
  }
}
