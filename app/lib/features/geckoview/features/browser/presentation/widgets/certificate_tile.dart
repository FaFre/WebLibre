import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';

class CertificateTile extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabState = ref.watch(selectedTabStateProvider);

    if (tabState == null) {
      return const SizedBox.shrink();
    }

    final icon = useMemoized(() {
      if (tabState.url.isScheme('http')) {
        return ListTile(
          leading: Icon(
            MdiIcons.lockOff,
            color: Theme.of(context).colorScheme.error,
          ),
          title: Text(
            'Connection is not secure',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        );
      } else if (!tabState.securityInfoState.secure) {
        return ListTile(
          leading: Icon(
            MdiIcons.lockAlert,
            color: Theme.of(context).colorScheme.errorContainer,
          ),
          title: Text(
            'Connection is not secure',
            style: TextStyle(
              color: Theme.of(context).colorScheme.errorContainer,
            ),
          ),
        );
      } else if (!tabState.isLoading) {
        return ListTile(
          leading: const Icon(MdiIcons.lock),
          title: const Text('Connection is secure'),
          subtitle: Text('Verified By: ${tabState.securityInfoState.issuer}'),
        );
      } else {
        return Skeletonizer(
          child: ListTile(
            leading: const Skeleton.keep(child: Icon(MdiIcons.timerSand)),
            title: Text(BoneMock.title),
          ),
        );
      }
    }, [tabState]);

    return icon;
  }
}
