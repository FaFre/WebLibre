part of 'routes.dart';

@TypedGoRoute<SettingsRoute>(
  name: 'SettingsRoute',
  path: '/settings',
  routes: [
    TypedGoRoute<GeneralSettingsRoute>(
      name: 'GeneralSettingsRoute',
      path: 'general',
    ),
    TypedGoRoute<BangSettingsRoute>(name: 'BangSettingsRoute', path: 'bang'),
    TypedGoRoute<WebEngineSettingsRoute>(
      name: 'WebEngineSettingsRoute',
      path: 'web_engine',
      routes: [
        TypedGoRoute<WebEngineHardeningRoute>(
          name: 'WebEngineHardeningRoute',
          path: 'hardening',
          routes: [
            TypedGoRoute<WebEngineHardeningGroupRoute>(
              name: 'WebEngineHardeningGroupRoute',
              path: 'group/:group',
            ),
          ],
        ),
      ],
    ),
  ],
)
class SettingsRoute extends GoRouteData with _$SettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}

class GeneralSettingsRoute extends GoRouteData with _$GeneralSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const GeneralSettingsScreen();
  }
}

class BangSettingsRoute extends GoRouteData with _$BangSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const BangSettingsScreen();
  }
}

class WebEngineSettingsRoute extends GoRouteData with _$WebEngineSettingsRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineSettingsScreen();
  }
}

class WebEngineHardeningRoute extends GoRouteData
    with _$WebEngineHardeningRoute {
  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WebEngineHardeningScreen();
  }
}

class WebEngineHardeningGroupRoute extends GoRouteData
    with _$WebEngineHardeningGroupRoute {
  final String group;

  const WebEngineHardeningGroupRoute({required this.group});

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return WebEngineHardeningGroupScreen(groupName: group);
  }
}
