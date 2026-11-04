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
import 'package:weblibre/features/settings/domain/hidden_settings.dart';
import 'package:weblibre/features/settings/presentation/utils/hidden_settings_l10n.dart';
import 'package:weblibre/features/user/domain/presentation/dialogs/quit_browser_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/exit_app.dart';

/// Asks before hiding [featureLabel] stops [settings] from applying: they
/// are changed from their defaults, and the defaults apply while it is
/// hidden. With [setUpKeepsWorking] it also says that what the user set up
/// keeps working, rather than a snackbar on top of the dialog afterwards.
/// Returns whether to hide it.
Future<bool> confirmHidingChangedSettings(
  BuildContext context, {
  required String featureLabel,
  required List<HiddenSetting> settings,
  bool setUpKeepsWorking = false,
}) async {
  final l10n = AppLocalizations.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      // A long list, landscape or large text can outgrow the window.
      scrollable: true,
      icon: const Icon(Icons.visibility_off_outlined),
      title: Text(l10n.visibilitySwitch_hideWarningTitle(featureLabel)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.visibilitySwitch_hideWarningContent(1)),
          const SizedBox(height: 8),
          HiddenSettingsList(settings: settings),
          if (setUpKeepsWorking) ...[
            const SizedBox(height: 8),
            Text(l10n.settings_featureControlKeepsWorking),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.visibilitySwitch_hideWarningConfirm),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}

/// Offers the restart the settings rows offer for these settings when one of
/// [settings], which stopped or started applying, is read only when the
/// engine starts ([HiddenSetting.appliesOnRestart]). [container] is the
/// caller's `ref.container`.
Future<void> offerRestartForStartupSettings(
  BuildContext context,
  ProviderContainer container,
  Iterable<HiddenSetting> settings,
) async {
  if (!settings.any((setting) => setting.appliesOnRestart)) return;
  final quit = await showQuitBrowserDialog(context);
  if (quit == true && context.mounted) {
    await exitApp(container);
  }
}

/// [settings] by their own titles, one per line. The ones the engine reads
/// only at start ([HiddenSetting.appliesOnRestart]) say so: hiding or
/// showing their feature changes nothing before a restart.
class HiddenSettingsList extends StatelessWidget {
  const HiddenSettingsList({super.key, required this.settings});

  final List<HiddenSetting> settings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final setting in settings)
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            leading: const Icon(Icons.settings_backup_restore),
            title: Text(setting.label(context)),
            subtitle: setting.appliesOnRestart
                ? Text(l10n.visibilitySwitch_takesEffectAfterRestart)
                : null,
          ),
      ],
    );
  }
}
