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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/frozen_to_be_safe_dialog.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/utils/container_freeze_actions.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/entities/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/repositories/container.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/services/container_freeze.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_data_l10n.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/utils/container_freeze_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Shows what the start-time reconciliation of frozen containers found (5.5,
/// 5.6): containers frozen to be safe after a damaged record, restoring that
/// did not finish, and deletions that did not finish. Also what came of
/// actions without a screen of their own: a placeholder's Resume that did not
/// finish, a page its container refused, a navigation or an undo close that
/// could not run. Each is shown once, also when it was found before this
/// screen first built.
void useContainerFreezeNotices(BuildContext context, WidgetRef ref) {
  void show() {
    if (!context.mounted) return;
    final notices = ref.read(containerFreezeNoticesProvider.notifier).take();
    for (final notice in notices) {
      unawaited(_show(context, ref, notice));
    }
  }

  ref.listen(containerFreezeNoticesProvider, (previous, next) {
    // Taking the notices changes the provider: after it has notified, and
    // without waiting for a frame that an idle screen does not schedule.
    if (next.isNotEmpty) scheduleMicrotask(show);
  });

  // Found before this screen built: the listener above came too late.
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) => show());
    return null;
  }, const []);
}

Future<void> _show(
  BuildContext context,
  WidgetRef ref,
  ContainerFreezeNotice notice,
) async {
  final l10n = AppLocalizations.of(context);
  switch (notice) {
    case ContainersFrozenToBeSafe(:final count):
      final showContainers = await showFrozenToBeSafeDialog(
        context,
        count: count,
      );
      if (showContainers && context.mounted) {
        await const ContainerListRoute().push(context);
      }
    case FreezeRecoveryFailed():
      ui_helper.showErrorMessage(
        context,
        l10n.browser_freezeRecoveryFailed,
        duration: const Duration(seconds: 10),
        action: SnackBarAction(
          label: l10n.common_retry,
          onPressed: () => unawaited(
            ref.read(containerFreezeServiceProvider.notifier).retryRecovery(),
          ),
        ),
      );
    case ResumeNotFinished(:final outcome):
      showResumeOutcome(context, outcome);
    case PageNotOpened(:final refusal):
      ui_helper.showInfoMessage(context, refusal.describe(l10n));
    case NavigationWaitsForRecovery():
      ui_helper.showInfoMessage(context, l10n.browser_freezeRecoveryPending);
    case NavigationWaitsForRouting():
      ui_helper.showInfoMessage(context, l10n.browser_wakeTabRoutingNotReady);
    case UndoWaitsForSiteDataDeletion():
      ui_helper.showInfoMessage(context, l10n.browser_undoWaitsForSiteData);
    case ContainerDeletionNotFinished(:final containerIds):
      final repository = ref.read(containerRepositoryProvider.notifier);
      for (final containerId in containerIds) {
        final container = await repository.getContainerData(containerId);
        if (container == null || !context.mounted) continue;
        ui_helper.showErrorMessage(
          context,
          l10n.browser_containerDeletionNotFinished(
            container.displayName(l10n),
          ),
        );
      }
  }
}
