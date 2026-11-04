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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/onboarding/domain/entities/setup_goal.dart';
import 'package:weblibre/features/onboarding/domain/providers/setup_follow_ups.dart';
import 'package:weblibre/features/onboarding/presentation/hooks/use_setup_follow_ups.dart';

/// Pending from the start, as after the onboarding commit. A goal that opens
/// nothing, so the test needs no router.
class _Pending extends PendingGoalSetups {
  @override
  List<SetupGoal> build() => const [SetupGoal.keepAccountsApart];
}

/// The connection setup asked for in the onboarding.
class _PendingConnections extends PendingGoalSetups {
  @override
  List<SetupGoal> build() => const [SetupGoal.setUpConnections];
}

class _FollowUps extends HookConsumerWidget {
  const _FollowUps();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useSetupFollowUps(context, ref);
    return const SizedBox();
  }
}

void main() {
  // The browser screen's first build runs the hook: clearing the pending
  // goals there is a provider write during build, which Riverpod rejects.
  testWidgets('takes pending goals after the first frame, not in build', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [pendingGoalSetupsProvider.overrideWith(_Pending.new)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: _FollowUps()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(container.read(pendingGoalSetupsProvider), isEmpty);
  });

  testWidgets('a requested connection setup opens once, after the commit', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        pendingGoalSetupsProvider.overrideWith(_PendingConnections.new),
      ],
    );
    addTearDown(container.dispose);

    var opened = 0;
    GoRouter router() => GoRouter(
      routes: [
        GoRoute(path: '/', builder: (_, _) => const _FollowUps()),
        GoRoute(
          path: const SingboxProxyProfilesRoute().location,
          builder: (_, _) {
            opened++;
            return const Text('connections');
          },
        ),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('connections'), findsOne);
    expect(opened, 1);
    expect(container.read(pendingGoalSetupsProvider), isEmpty);

    // The browser screen built again (a later start, a new router): nothing
    // is pending any more, so nothing opens again.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(key: UniqueKey(), routerConfig: router()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('connections'), findsNothing);
    expect(opened, 1);
  });
}
