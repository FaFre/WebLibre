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
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/services/local_authentication.dart';

part 'profile_auth.g.dart';

String profileAccessAuthKey(String profileId) => 'profile_access::$profileId';

@Riverpod(keepAlive: true)
class ProfileAuthState extends _$ProfileAuthState {
  bool _bootstrapped = false;

  Future<void> bootstrapFromProfile() async {
    if (_bootstrapped) return;

    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return;

    _bootstrapped = true;

    if (!profile.authSettings.authenticationRequired) {
      _unlock();
    }
  }

  Future<bool> authenticate() async {
    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted) return false;

    if (!profile.authSettings.authenticationRequired) {
      _unlock();
      return true;
    }

    final result = await ref
        .read(localAuthenticationServiceProvider.notifier)
        .authenticate(
          authKey: profileAccessAuthKey(profile.id),
          localizedReason: 'Unlock profile',
          settings: profile.authSettings,
          useAuthCache: true,
        );

    if (!ref.mounted) return false;

    state = result;
    return result;
  }

  Future<void> revalidateAfterResume() async {
    if (!state) return;

    final profile = await ref.read(selectedProfileProvider.future);
    if (!ref.mounted || !profile.authSettings.authenticationRequired) return;

    final cached = ref
        .read(localAuthenticationServiceProvider.notifier)
        .isCached(profileAccessAuthKey(profile.id));

    if (!cached && ref.mounted) {
      _lock();
    }
  }

  void _lock() {
    state = false;
  }

  void _unlock() {
    state = true;
  }

  @override
  bool build() {
    return false;
  }
}

@Riverpod(keepAlive: true)
Raw<ProfileAuthNotifier> profileAuthNotifier(Ref ref) {
  final notifier = ProfileAuthNotifier();

  ref.listen<bool>(profileAuthStateProvider, (_, _) {
    notifier.notify();
  });

  ref.onDispose(notifier.dispose);

  return notifier;
}

class ProfileAuthNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
