import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:lensai/data/models/equatable_iterable.dart';
import 'package:lensai/features/geckoview/features/tabs/domain/providers.dart';
import 'package:lensai/features/tor/domain/services/tor_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'proxy_settings_replucation.g.dart';

@Riverpod(keepAlive: true)
class ProxySettingsReplucation extends _$ProxySettingsReplucation {
  final _service = GeckoContainerProxyService();

  @override
  void build() {
    ref.listen(
      torProxyServiceProvider.select((data) => data.valueOrNull),
      (previous, next) async {
        if (next != null) {
          await _service.setProxyPort(next);
        }
      },
    );

    ref.listen(
      containersWithCountProvider.select(
        (value) => EquatableCollection(
          value.valueOrNull
              ?.where((container) => container.metadata.useProxy)
              .map((container) => container.metadata.contextualIdentity)
              .nonNulls
              .toList(),
          immutable: true,
        ),
      ),
      (previous, next) async {
        if (next.collection != null) {
          for (final contextId in next.collection!) {
            await _service.addContainerProxy(contextId);
          }
        }
      },
    );
  }
}
