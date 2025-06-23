import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

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
        (value) => EquatableValue(value.valueOrNull),
      ),
      (previous, next) async {
        if (next.value != null) {
          for (final container in next.value!) {
            if (container.metadata.contextualIdentity.isNotEmpty) {
              if (container.metadata.useProxy) {
                await _service.addContainerProxy(
                  container.metadata.contextualIdentity!,
                );
              } else {
                await _service.removeContainerProxy(
                  container.metadata.contextualIdentity!,
                );
              }
            }
          }
        }
      },
    );

    ref.listen(
      fireImmediately: true,
      generalSettingsRepositoryProvider.select(
        (value) => value.proxyPrivateTabsTor,
      ),
      (previous, next) async {
        if (next) {
          await _service.addContainerProxy('private');
        } else {
          await _service.removeContainerProxy('private');
        }
      },
    );
  }
}
