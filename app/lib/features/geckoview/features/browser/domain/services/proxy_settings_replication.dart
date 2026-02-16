/*
 * Copyright (c) 2024-2026 Fabian Freund.
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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:nullability/nullability.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/tor/domain/repositories/tor_proxy.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';

part 'proxy_settings_replication.g.dart';

@Riverpod(keepAlive: true)
class ProxySettingsReplication extends _$ProxySettingsReplication {
  @override
  void build() {
    ref.listen(
      fireImmediately: true,
      torProxyServiceProvider.select((data) => data.value),
      (previous, next) async {
        await ref
            .read(torProxyRepositoryProvider.notifier)
            .setProxyPort(next?.socksPort ?? -1);
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to torProxyServiceProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      watchContainersWithCountProvider.select(
        (value) => EquatableValue(value.value),
      ),
      (previous, next) async {
        if (next.value != null) {
          for (final container in next.value!) {
            if (container.metadata.contextualIdentity.isNotEmpty) {
              if (container.metadata.useProxy) {
                await ref
                    .read(torProxyRepositoryProvider.notifier)
                    .addContainerProxy(container.metadata.contextualIdentity!);
              } else {
                await ref
                    .read(torProxyRepositoryProvider.notifier)
                    .removeContainerProxy(
                      container.metadata.contextualIdentity!,
                    );
              }
            }
          }
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to containersWithCountProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      torSettingsWithDefaultsProvider.select(
        (value) => value.proxyPrivateTabsTor,
      ),
      (previous, next) async {
        if (next) {
          await ref
              .read(torProxyRepositoryProvider.notifier)
              .addContainerProxy('private');
        } else {
          await ref
              .read(torProxyRepositoryProvider.notifier)
              .removeContainerProxy('private');
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(
      fireImmediately: true,
      torSettingsWithDefaultsProvider.select(
        (value) => value.proxyRegularTabsMode,
      ),
      (previous, next) async {
        switch (next) {
          case TorRegularTabProxyMode.container:
            await ref
                .read(torProxyRepositoryProvider.notifier)
                .removeContainerProxy('general');
          case TorRegularTabProxyMode.all:
            await ref
                .read(torProxyRepositoryProvider.notifier)
                .addContainerProxy('general');
        }
      },
      onError: (error, stackTrace) {
        logger.e(
          'Error listening to generalSettingsRepositoryProvider',
          error: error,
          stackTrace: stackTrace,
        );
      },
    );

    ref.listen(watchAllAssignedSitesProvider, (previous, next) async {
      if (next.hasValue) {
        await ref
            .read(torProxyRepositoryProvider.notifier)
            .setSiteAssignments(next.requireValue);
      }
    });
  }
}
