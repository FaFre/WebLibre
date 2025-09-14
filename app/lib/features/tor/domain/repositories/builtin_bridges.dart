import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/tor/data/services/builtin_bridges.dart';

part 'builtin_bridges.g.dart';

@Riverpod()
class BuiltinBridgesRepository extends _$BuiltinBridgesRepository {
  Future<void> updateIfNecessary() async {
    final lastUpdate = await ref
        .read(builtinBridgesServiceProvider.notifier)
        .lastUpdate();

    if (lastUpdate == null ||
        DateTime.now().difference(lastUpdate) > const Duration(days: 2)) {
      BuiltInBridges? remoteBridges;
      try {
        remoteBridges = await service.getBuiltinBridges();
      } catch (e, s) {
        logger.e('Failed fetching builtin bridges', error: e, stackTrace: s);
      }

      if (remoteBridges != null) {
        await ref
            .read(builtinBridgesServiceProvider.notifier)
            .updateStoredBuiltinBridges(remoteBridges);
      }
    }
  }

  Future<BuiltInBridges> getBridges({bool tryUpdate = true}) async {
    if (tryUpdate) {
      await updateIfNecessary();
    }

    final storedBridges = await ref
        .read(builtinBridgesServiceProvider.notifier)
        .getStoredBuiltinBridges();

    return storedBridges ??
        await ref
            .read(builtinBridgesServiceProvider.notifier)
            .getBundledBuiltinBridges();
  }

  @override
  void build(MoatService service) {}
}
