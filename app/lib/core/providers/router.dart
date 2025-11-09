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
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/providers/app_state.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> router(Ref ref) async {
  ref.watch(appStateKeyProvider); //Rebuild router on key changes

  final onboardingRepository = ref.read(onboardingRepositoryProvider.notifier);

  String? initialLocation;

  final onboardingMandatory = await onboardingRepository.isOutdated();

  if (onboardingMandatory) {
    final current = await onboardingRepository.getCurrentRevision();

    final route = OnboardingRoute(
      currentRevision: current ?? -1,
      targetRevision: OnboardingRepository.targetRevision,
    );

    initialLocation = route.location;
  }

  return GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: initialLocation ?? BrowserRoute().location,
  );
}
