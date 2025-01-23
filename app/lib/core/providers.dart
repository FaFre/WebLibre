import 'package:go_router/go_router.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    debugLogDiagnostics: true,
    routes: $appRoutes,
  );
}
