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
import 'package:weblibre/features/app_update/data/providers.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/domain/services/update_coordinator.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// The browser's side of the updater: starts it (the browser exists only
/// after a profile is committed), tells it when the app returns to the
/// foreground, and shows the one-off snackbars: the once-per-version
/// announcement (8.4), "Updated to X" after a self-update (8.5) and
/// "Download/Installation cancelled".
class AppUpdateBrowserListener extends HookConsumerWidget {
  const AppUpdateBrowserListener({super.key, required this.child});

  final Widget child;

  static const _duration = Duration(seconds: 6);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(
      appUpdateControllerProvider.select((s) => s?.pendingAnnouncement),
    );
    final updatedTo = ref.watch(
      appUpdateControllerProvider.select((s) => s?.updatedTo),
    );
    final coordinator = ref.watch(
      appUpdateCoordinatorProvider.select((v) => v.value),
    );

    useOnAppLifecycleStateChange((previous, current) {
      if (current == AppLifecycleState.resumed) {
        unawaited(ref.read(appUpdateControllerProvider.notifier).onResume());
      }
    });

    // Subscribed directly, not through a provider: a provider drops a
    // notice equal to the previous one, and cancelling twice must show twice.
    useOnStreamChange(
      coordinator?.notices,
      onData: (notice) {
        if (!context.mounted) return;
        final l10n = AppLocalizations.of(context);
        _show(context, switch (notice) {
          UpdateNotice.downloadCancelled => l10n.appUpdate_downloadCancelled,
          UpdateNotice.installationCancelled =>
            l10n.appUpdate_installationCancelled,
        });
      },
    );

    useEffect(() {
      if (pending == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _announce(context, pending);
        unawaited(
          ref
              .read(appUpdateControllerProvider.notifier)
              .acknowledgeAnnouncement(),
        );
      });
      return null;
    }, [pending]);

    useEffect(() {
      if (updatedTo == null) return null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        _show(
          context,
          AppLocalizations.of(context).appUpdate_updatedTo(updatedTo),
        );
        ref
            .read(appUpdateControllerProvider.notifier)
            .acknowledgeUpdatedNotice();
      });
      return null;
    }, [updatedTo]);

    return child;
  }

  static void _announce(BuildContext context, UpdateAssessment assessment) {
    final l10n = AppLocalizations.of(context);
    final version = assessment.appVersion;
    showInfoMessage(
      context,
      version == null
          ? l10n.appUpdate_announcementUnknownVersion
          : l10n.appUpdate_announcement(version),
      action: SnackBarAction(
        label: l10n.appUpdate_announcementView,
        onPressed: () => const AppUpdateSettingsRoute().push(context),
      ),
      duration: _duration,
    );
  }

  static void _show(BuildContext context, String text) =>
      showInfoMessage(context, text, duration: _duration);
}
