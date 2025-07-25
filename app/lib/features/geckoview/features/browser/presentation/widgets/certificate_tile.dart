/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
