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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/account/data/models/subscription_status.dart';
import 'package:weblibre/features/account/domain/repositories/subscription_repository.dart';
import 'package:weblibre/features/account/presentation/widgets/subscription_card.dart';

void main() {
  testWidgets('refreshes subscription status when the app resumes', (
    tester,
  ) async {
    final repository = _FakeSubscriptionRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          subscriptionRepositoryProvider.overrideWith(() => repository),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SubscriptionCard(
              subscriptionAsync: AsyncData(SubscriptionStatus.inactive),
            ),
          ),
        ),
      ),
    );

    expect(repository.refreshCount, 0);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(repository.refreshCount, 1);
  });

  testWidgets(
    'lifecycle refresh still fires when card is in the error branch',
    (tester) async {
      final repository = _FakeSubscriptionRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider.overrideWith(() => repository),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SubscriptionCard(
                subscriptionAsync: AsyncError(
                  Exception('offline'),
                  StackTrace.current,
                ),
              ),
            ),
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(repository.refreshCount(), 1);
    },
  );
}

class _FakeSubscriptionRepository extends SubscriptionRepository {
  int _refreshCount = 0;

  int refreshCount() => _refreshCount;

  @override
  Future<SubscriptionStatus> build() async => SubscriptionStatus.inactive;

  @override
  Future<void> refresh() async {
    _refreshCount++;
  }
}
