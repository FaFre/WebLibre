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
import 'dart:ui';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/split_view/presentation/utils/frozen_placeholder_labels.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_freeze_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

ContainerFreezeView _view(
  ContextFreezePhase phase, {
  EngineEnforcement enforcement = EngineEnforcement.enforced,
  LifecycleOperationState operation = LifecycleOperationState.idle,
  int skipped = 0,
  bool recovered = false,
}) => ContainerFreezeView(
  phase: phase,
  enforcement: enforcement,
  operation: operation,
  recovered: recovered,
  undeliveredPushCount: skipped,
);

void main() {
  final l10n = lookupAppLocalizations(const Locale('en'));

  group('state wording (3.3)', () {
    test('follows the phase and what the engine acknowledged', () {
      expect(_view(ContextFreezePhase.frozen).stateLabel(l10n), 'Frozen');
      expect(
        _view(ContextFreezePhase.failed).stateLabel(l10n),
        l10n.browser_freezeIncompleteBlocked,
      );
      expect(
        _view(
          ContextFreezePhase.failed,
          enforcement: EngineEnforcement.uncertain,
        ).stateLabel(l10n),
        l10n.browser_freezeIncompleteUncertain,
      );
      expect(
        _view(ContextFreezePhase.resuming).stateLabel(l10n),
        l10n.browser_resumeIncompleteBlocked,
      );
      expect(
        _view(
          ContextFreezePhase.resuming,
          enforcement: EngineEnforcement.lifted,
        ).stateLabel(l10n),
        l10n.browser_resumeIncompleteLifted,
      );
    });

    test('a running operation shows itself, with the teardown progress', () {
      final freezing = _view(
        ContextFreezePhase.freezing,
        operation: LifecycleOperationState.freezing,
      );
      expect(freezing.stateLabel(l10n), 'Freezing…');
      expect(
        freezing.stateLabel(l10n, progress: FreezeProgress(done: 2, total: 5)),
        'Freezing… 2 of 5',
      );
      expect(
        _view(
          ContextFreezePhase.resuming,
          operation: LifecycleOperationState.resuming,
        ).stateLabel(l10n),
        'Resuming…',
      );
    });

    test('a deletion under way is not shown as frozen', () {
      for (final phase in [
        ContextFreezePhase.deletionPending,
        ContextFreezePhase.releasing,
        ContextFreezePhase.orphaned,
      ]) {
        expect(_view(phase).stateLabel(l10n), isNull, reason: phase.name);
        expect(_view(phase).showsFrozen, isFalse, reason: phase.name);
      }
    });
  });

  group('short state for the containers list chip', () {
    test('one or two words for every state, never the full sentence', () {
      expect(_view(ContextFreezePhase.frozen).shortStateLabel(l10n), 'Frozen');
      expect(
        _view(ContextFreezePhase.frozen, recovered: true).shortStateLabel(l10n),
        'Frozen',
      );
      expect(
        _view(ContextFreezePhase.failed).shortStateLabel(l10n),
        'Freeze incomplete',
      );
      expect(
        _view(
          ContextFreezePhase.resuming,
          enforcement: EngineEnforcement.lifted,
        ).shortStateLabel(l10n),
        'Resume incomplete',
      );
      expect(
        _view(
          ContextFreezePhase.freezing,
          operation: LifecycleOperationState.freezing,
        ).shortStateLabel(l10n),
        'Freezing…',
      );
      expect(
        _view(
          ContextFreezePhase.frozen,
          operation: LifecycleOperationState.resuming,
        ).shortStateLabel(l10n),
        'Resuming…',
      );
      expect(
        _view(ContextFreezePhase.unrestricted).shortStateLabel(l10n),
        isNull,
      );
    });
  });

  group('frozen to be safe (5.6)', () {
    test('says why WebLibre froze the container itself', () {
      final view = _view(
        ContextFreezePhase.frozen,
        recovered: true,
        skipped: 1,
      );

      expect(view.stateLabel(l10n), l10n.browser_containerFrozenToBeSafeLabel);
      expect(frozenPlaceholderLabels(l10n, {'work': view}, {'work': 'Work'}), [
        FrozenPlaceholderLabel(
          ownerId: 'work',
          title: 'Work was frozen to be safe',
          detail:
              '${l10n.splitView_frozenToBeSafeDetail}\n'
              '${l10n.splitView_frozenSkippedMessages(1)}',
        ),
      ]);
    });

    test('a Resume of it that runs shows the Resume instead', () {
      final view = _view(
        ContextFreezePhase.frozen,
        recovered: true,
        operation: LifecycleOperationState.resuming,
      );

      expect(
        frozenPlaceholderLabels(l10n, {'work': view}, {'work': 'Work'}).single,
        FrozenPlaceholderLabel(
          ownerId: 'work',
          title: 'Resuming Work…',
          detail: null,
        ),
      );
    });
  });

  group('placeholder labels', () {
    test("name the container, say how far it got, and count skipped "
        'messages', () {
      final labels = frozenPlaceholderLabels(
        l10n,
        {
          'work': _view(ContextFreezePhase.frozen, skipped: 3),
          'home': _view(
            ContextFreezePhase.frozen,
            operation: LifecycleOperationState.freezing,
          ),
          'old': _view(ContextFreezePhase.failed),
          'gone': _view(ContextFreezePhase.releasing),
          'unknown': _view(ContextFreezePhase.frozen),
        },
        {'work': 'Work', 'home': 'Home', 'old': 'Old', 'gone': 'Gone'},
      );

      expect(labels, [
        FrozenPlaceholderLabel(
          ownerId: 'work',
          title: 'Work is frozen',
          detail: l10n.splitView_frozenSkippedMessages(3),
        ),
        FrozenPlaceholderLabel(
          ownerId: 'home',
          title: 'Freezing Home…',
          detail: null,
        ),
        FrozenPlaceholderLabel(
          ownerId: 'old',
          title: 'Freezing Old did not finish',
          detail: null,
        ),
        FrozenPlaceholderLabel(
          ownerId: 'unknown',
          title: 'This container is frozen',
          detail: null,
        ),
      ]);
    });
  });
}
