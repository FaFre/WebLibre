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
import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/providers/profile_auth.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> router(Ref ref) async {
  ref.watch(appStateKeyProvider); //Rebuild router on key changes

  final onboardingRepository = ref.read(onboardingRepositoryProvider.notifier);
  unawaited(ref.read(profileAuthStateProvider.notifier).bootstrapFromProfile());

  /// Where the app belongs once it is unlocked: onboarding when it is owed,
  /// otherwise the browser.
  ///
  /// Resolved once, here, rather than re-derived inside `redirect`: the redirect
  /// runs on every navigation and cannot await a database read, and the answer
  /// only changes when onboarding completes — which invalidates this provider and
  /// rebuilds the whole router.
  String? onboardingLocation;

  final onboardingMandatory = await onboardingRepository.isOutdated();

  if (onboardingMandatory) {
    final current = await onboardingRepository.getCurrentRevision();

    final route = OnboardingRoute(
      currentRevision: current ?? -1,
      targetRevision: OnboardingRepository.targetRevision,
    );

    onboardingLocation = route.location;
  }

  final profileAuthRefreshListenable = ref.watch(profileAuthProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    // Always the lock: `bootstrapFromProfile` unlocks immediately for a profile
    // that has no lock, and the redirect below then forwards to wherever the app
    // belongs. Starting *at* onboarding instead is what let a locked profile be
    // walked through onboarding without ever unlocking.
    initialLocation: const LockRoute().location,
    refreshListenable: profileAuthRefreshListenable,
    redirect: (context, state) {
      final authenticated = ref.read(profileAuthStateProvider);
      final currentTopRouteName = state.topRoute?.name;
      final isOnLockRoute = currentTopRouteName == LockRoute.name;
      final isOnOnboarding = currentTopRouteName == OnboardingRoute.name;

      // The lock comes first, onboarding included. Onboarding used to be exempt,
      // and it is not a harmless screen to hand out: it writes the profile's
      // search engine, DNS, toolbar and permission settings, installs add-ons,
      // and can restore a backup over the profile. It is also owed by *every*
      // existing profile after a `targetRevision` bump, so the exemption fired on
      // ordinary updates rather than only on first run.
      if (!authenticated && !isOnLockRoute) {
        return const LockRoute().location;
      }

      // Unlocked, so onboarding is reachable — and is where an unlocked profile
      // that still owes it belongs.
      if (authenticated && isOnLockRoute) {
        return onboardingLocation ?? const BrowserRoute().location;
      }

      if (isOnOnboarding) return null;

      return null;
    },
  );
}

@Riverpod(keepAlive: true)
class CurrentTopRoute extends _$CurrentTopRoute {
  @override
  RouteBase? build() {
    final router = ref.watch(routerProvider).value;
    if (router == null) return null;

    GoRoute? getCurrentRoute() {
      final config = router.routerDelegate.currentConfiguration;

      if (config.isEmpty) {
        return null;
      }

      final match = config.last;
      return match.route;
    }

    void update() {
      unawaited(
        Future(() {
          state = getCurrentRoute();
        }),
      );
    }

    router.routerDelegate.addListener(update);
    ref.onDispose(() => router.routerDelegate.removeListener(update));

    return getCurrentRoute();
  }
}
