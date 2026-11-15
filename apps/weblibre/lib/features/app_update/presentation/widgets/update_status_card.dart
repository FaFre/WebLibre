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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/providers/format.dart';
import 'package:weblibre/features/app_update/domain/entities/distribution_policy.dart';
import 'package:weblibre/features/app_update/domain/entities/release_metadata.dart';
import 'package:weblibre/features/app_update/domain/entities/update_failure.dart';
import 'package:weblibre/features/app_update/domain/entities/update_state.dart';
import 'package:weblibre/features/app_update/domain/providers.dart';
import 'package:weblibre/features/app_update/presentation/utils/update_state_l10n.dart';
import 'package:weblibre/features/app_update/presentation/widgets/update_actions.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/units_l10n.dart';

/// The status card of the Updates screen (8.1): one row of the state table.
class UpdateStatusCard extends HookConsumerWidget {
  const UpdateStatusCard({
    super.key,
    required this.state,
    required this.policy,
    required this.lastSuccess,
  });

  final UpdateState state;
  final DistributionPolicy policy;
  final DateTime? lastSuccess;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(appUpdateControllerProvider.notifier);
    final assessment = state.assessment;

    final details = <Widget>[];
    void line(String text, {TextStyle? style}) => details.add(
      Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(text, style: style ?? theme.textTheme.bodyMedium),
      ),
    );

    switch (state) {
      case UpdateUpToDate() || UpdateIdle():
        if (lastSuccess case final time?) {
          line(lastCheckedText(context, ref, time));
        }
      case UpdateAvailable(:final partialBytes):
        final artifact = assessment?.artifact;
        if (artifact != null) {
          line(
            l10n.appUpdate_downloadSize(
              formatByteSize(l10n, artifact.byteLength),
            ),
          );
        }
        if (partialBytes > 0) {
          line(
            l10n.appUpdate_partialDownloaded(
              formatByteSize(l10n, partialBytes),
            ),
          );
        }
      case UpdateDownloading(:final received, :final total, :final progress):
        details.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(value: progress),
          ),
        );
        if (total != null) {
          line(
            l10n.appUpdate_downloadProgress(
              formatByteSize(l10n, received),
              formatByteSize(l10n, total),
            ),
          );
        }
      case UpdateChecking() || UpdateVerifying():
        details.add(
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: LinearProgressIndicator(),
          ),
        );
      default:
        break;
    }

    if (assessment != null && state is! UpdateFailed) {
      switch (assessment.securityClassification) {
        case SecurityClassification.critical:
          line(
            l10n.appUpdate_securityCritical,
            style: TextStyle(color: theme.colorScheme.error),
          );
        case SecurityClassification.fixesIncluded:
          line(l10n.appUpdate_securityFixes);
        case SecurityClassification.unknown:
          break;
      }
      if (assessment.advisories.unresolved.isNotEmpty) {
        line(l10n.appUpdate_securityLaterVersion);
      }
    }

    final actions = _actions(context, ref, controller, l10n);
    final highlighted = switch (state) {
      UpdateAvailable() ||
      UpdateReadyToInstall() ||
      UpdateAwaitingPermission() ||
      UpdateAwaitingUserAction() => true,
      _ => false,
    };

    return Card(
      color: state is UpdateFailed
          ? theme.colorScheme.errorContainer
          : highlighted
          ? theme.colorScheme.secondaryContainer
          : null,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _icon,
                  color: highlighted ? theme.colorScheme.primary : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.headline(context),
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            ...details,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.end,
                children: actions,
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData get _icon => switch (state) {
    UpdateUpToDate() => Icons.check_circle_outline,
    UpdateFailed() => Icons.error_outline,
    UpdateAvailable() || UpdateReadyToInstall() => Icons.system_update,
    UpdateDownloading() || UpdateVerifying() => Icons.downloading,
    _ => Icons.update,
  };

  List<Widget> _actions(
    BuildContext context,
    WidgetRef ref,
    AppUpdateController controller,
    AppLocalizations l10n,
  ) {
    Widget primary(String label, Future<void> Function() onPressed) =>
        FilledButton(onPressed: onPressed, child: Text(label));
    Widget secondary(String label, Future<void> Function() onPressed) =>
        TextButton(onPressed: onPressed, child: Text(label));

    final checkNow = secondary(
      l10n.appUpdate_actionCheckNow,
      controller.checkNow,
    );
    final assessment = state.assessment;

    return switch (state) {
      UpdateIdle() || UpdateUpToDate() => [checkNow],
      UpdateChecking() || UpdateVerifying() => const [],
      UpdateAvailable(:final partialBytes) => [
        primary(
          partialBytes > 0
              ? l10n.appUpdate_actionContinueDownload
              : l10n.appUpdate_actionDownload,
          () => controller.download(assessment!.targetId),
        ),
      ],
      UpdateDownloading() => [
        if (policy is GithubUpdates)
          secondary(l10n.common_cancel, controller.cancel),
      ],
      UpdateReadyToInstall() => [
        primary(
          policy is PlayUpdates
              ? l10n.appUpdate_actionRestart
              : l10n.appUpdate_actionInstall,
          () => confirmAndInstall(context, ref, assessment!.targetId),
        ),
      ],
      UpdateAwaitingPermission() => [
        primary(
          l10n.appUpdate_actionAllow,
          () => requestInstallPermission(context, ref),
        ),
      ],
      UpdateAwaitingUserAction() => [
        secondary(l10n.common_cancel, controller.cancel),
        primary(l10n.appUpdate_actionContinue, controller.continueInstallation),
      ],
      UpdateInstalling(:final foundAfterRestart) => [
        if (foundAfterRestart)
          secondary(l10n.appUpdate_actionCancelInstallation, controller.cancel),
      ],
      final UpdateFailed failed => [
        // The session beneath the failure still waits, and still holds the
        // install slot: it can be given up from here.
        if (failed.underlying is UpdateAwaitingUserAction)
          secondary(l10n.common_cancel, controller.cancel),
        // Only a backend that keeps trust state reports it damaged.
        if (failed.kind == UpdateFailureKind.stateCorrupt)
          primary(
            l10n.appUpdate_actionResetTrust,
            controller.resetTrustAndCheck,
          )
        else if (failed.retryable)
          primary(
            l10n.common_retry,
            () => _retry(context, ref, controller, failed),
          )
        else if (failed.underlying is UpdateAwaitingUserAction)
          primary(
            l10n.appUpdate_actionContinue,
            controller.continueInstallation,
          )
        // No check starts while a session holds the install slot: Android's
        // outcome moves the state on by itself.
        else if (failed.underlying is! UpdateInstalling)
          checkNow,
      ],
    };
  }

  /// Retry repeats the operation that failed, from the state it left. A
  /// failed check is checked again even when an update is waiting beneath it;
  /// an installation whose file is gone needs the download first.
  Future<void> _retry(
    BuildContext context,
    WidgetRef ref,
    AppUpdateController controller,
    UpdateFailed failed,
  ) async {
    switch ((failed.operation, failed.underlying)) {
      case (
        UpdateOperation.download || UpdateOperation.install,
        UpdateAvailable(:final assessment),
      ):
        await controller.download(assessment.targetId);
      case (UpdateOperation.install, UpdateReadyToInstall(:final assessment)):
        await confirmAndInstall(context, ref, assessment.targetId);
      case (UpdateOperation.install, UpdateAwaitingUserAction()):
        await controller.continueInstallation();
      case (
        UpdateOperation.cancelInstallation,
        UpdateAwaitingUserAction() || UpdateInstalling(),
      ):
        await controller.cancel();
      default:
        await controller.checkNow();
    }
  }
}

/// "Last checked …" for the last successful check at [time].
String lastCheckedText(BuildContext context, WidgetRef ref, DateTime time) =>
    AppLocalizations.of(context).appUpdate_lastChecked(
      ref.read(formatProvider.notifier).fullDateTime(time.toLocal()),
    );
