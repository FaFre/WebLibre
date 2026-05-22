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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/providers.dart';

part 'singbox_proxy_profiles.g.dart';

@Riverpod(keepAlive: true)
class SingboxProxyProfilesRepository extends _$SingboxProxyProfilesRepository {
  Future<List<ProxyProfile>> fetchProfiles() {
    return ref.read(userDatabaseProvider).proxyProfileDao.fetchAll();
  }

  Future<ProxyProfile?> findProfile(String id) {
    return ref.read(userDatabaseProvider).proxyProfileDao.findById(id);
  }

  Future<ProxyProfile> createProfile({
    required String name,
    required SingboxProxyProfileType type,
    required String configJson,
    String? secretJson,
    String? dnsOverrideJson,
  }) async {
    final now = DateTime.now();
    final profile = ProxyProfile(
      id: uuid.v4(),
      name: name,
      type: type,
      configJson: configJson,
      dnsOverrideJson: dnsOverrideJson,
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(userDatabaseProvider).proxyProfileDao.upsert(profile);
    await ref
        .read(singboxProxyCredentialsRepositoryProvider.notifier)
        .writeSecretJson(profile.id, secretJson);
    return profile;
  }

  /// Updates an existing profile, bumping `updatedAt` only when the persisted
  /// row actually changed. Pass [secretJson] (possibly null) to replace the
  /// stored secret; pass [updateSecret] = false to leave secrets untouched.
  Future<void> updateProfile(ProxyProfile profile, {String? secretJson}) async {
    final dao = ref.read(userDatabaseProvider).proxyProfileDao;
    final existing = await dao.findById(profile.id);

    final contentChanged =
        existing == null ||
        existing.name != profile.name ||
        existing.type != profile.type ||
        existing.configJson != profile.configJson ||
        existing.dnsOverrideJson != profile.dnsOverrideJson;

    if (contentChanged) {
      await dao.upsert(
        ProxyProfile(
          id: profile.id,
          name: profile.name,
          type: profile.type,
          configJson: profile.configJson,
          dnsOverrideJson: profile.dnsOverrideJson,
          createdAt: existing?.createdAt ?? profile.createdAt,
          updatedAt: DateTime.now(),
        ),
      );
    }

    if (secretJson != null) {
      await ref
          .read(singboxProxyCredentialsRepositoryProvider.notifier)
          .writeSecretJson(profile.id, secretJson);
    }
  }

  Future<void> deleteProfile(String profileId) async {
    await ref.read(userDatabaseProvider).proxyProfileDao.deleteById(profileId);
    await ref
        .read(singboxProxyCredentialsRepositoryProvider.notifier)
        .deleteSecretJson(profileId);
  }

  @override
  Stream<List<ProxyProfile>> build() {
    return ref.watch(userDatabaseProvider).proxyProfileDao.watch().watch();
  }
}
