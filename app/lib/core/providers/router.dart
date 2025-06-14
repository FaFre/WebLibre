import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';

part 'router.g.dart';

@Riverpod(keepAlive: true)
Future<GoRouter> router(Ref ref) async {
  String? initialLocation;

  final onboardingMandatory = await ref
      .read(onboardingRepositoryProvider.notifier)
      .isOutdated();

  if (onboardingMandatory) {
    final current = await ref
        .read(onboardingRepositoryProvider.notifier)
        .getCurrentRevision();

    final route = OnboardingRoute(
      currentRevision: current ?? -1,
      targetRevision: OnboardingRepository.targetRevision,
    );

    initialLocation = route.location;
  }

  return GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
    initialLocation: initialLocation,
  );
}
