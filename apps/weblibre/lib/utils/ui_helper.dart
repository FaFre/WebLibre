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
import 'package:nullability/nullability.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/clipboard.dart';

/// Creates a floating snackbar.
/// The margin is controlled by the scaffold's snackBarTheme for proper
/// positioning above bottom app bars of varying heights.
SnackBar _createFloatingSnackBar({
  required Widget content,
  Color? backgroundColor,
  SnackBarAction? action,
  required Duration duration,
  required bool persist,
}) {
  return SnackBar(
    content: content,
    backgroundColor: backgroundColor,
    action: action,
    duration: duration,
    persist: persist,
    behavior: SnackBarBehavior.floating,
  );
}

/// Maximum number of lines an error/info snackbar will render before
/// truncating with an ellipsis. Long error messages (e.g. raw exception
/// dumps) would otherwise overflow the floating snackbar layout.
const int _kSnackBarMaxLines = 4;

/// Maximum number of characters of a raw error string included in a
/// snackbar before it is truncated. Keeps stack-trace-like blobs from
/// dominating the screen while still leaving the full error available
/// in the log output.
const int _kSnackBarErrorMaxChars = 240;

String _truncateForSnackBar(String message) {
  if (message.length <= _kSnackBarErrorMaxChars) return message;
  return '${message.substring(0, _kSnackBarErrorMaxChars).trimRight()}…';
}

void showErrorMessage(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  bool persist = false,
}) {
  final snackBar = _createFloatingSnackBar(
    content: Text(
      _truncateForSnackBar(message),
      maxLines: _kSnackBarMaxLines,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
    backgroundColor: Theme.of(context).colorScheme.onError,
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showInfoMessage(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 4),
  bool persist = false,
  SnackBarAction? action,
}) {
  final snackBar = _createFloatingSnackBar(
    content: Text(
      _truncateForSnackBar(message),
      maxLines: _kSnackBarMaxLines,
      overflow: TextOverflow.ellipsis,
    ),
    action: action,
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showFindInPageSuggestion(
  BuildContext context, {
  required String query,
  required VoidCallback onFind,
  Duration duration = const Duration(seconds: 5),
  bool persist = false,
}) {
  final l10n = AppLocalizations.of(context);

  final snackBar = _createFloatingSnackBar(
    content: Text(
      l10n.uiHelper_findInPageSuggestion(_truncateForSnackBar(query)),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    ),
    action: SnackBarAction(label: l10n.uiHelper_actionFind, onPressed: onFind),
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showOpenedTabsFromAnotherDeviceMessage(
  BuildContext context,
  int openedTabs, {
  Duration duration = const Duration(seconds: 4),
  bool persist = false,
}) {
  if (openedTabs <= 0) {
    return;
  }

  final message = AppLocalizations.of(
    context,
  ).uiHelper_openedTabsFromAnotherDevice(openedTabs);

  showInfoMessage(context, message, duration: duration, persist: persist);
}

void showTabBackButtonMessage(
  BuildContext context,
  bool closesTab,
  Duration duration, {
  bool persist = false,
}) {
  final l10n = AppLocalizations.of(context);

  final snackbar = _createFloatingSnackBar(
    content: Text(
      closesTab
          ? l10n.uiHelper_navigateBackToCloseTab
          : l10n.uiHelper_navigateBackToExitApp,
    ),
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(snackbar);
}

void showTabOpenedMessage(
  BuildContext context, {
  String? tabName,
  void Function()? onShow,
  Duration duration = const Duration(seconds: 3),
  bool persist = false,
}) {
  final l10n = AppLocalizations.of(context);

  final message = switch (tabName.whenNotEmpty) {
    String() => l10n.uiHelper_newTabOpenedInBackgroundNamed(tabName!),
    null => l10n.uiHelper_newTabOpenedInBackground,
  };

  final snackBar = _createFloatingSnackBar(
    content: Text(message),
    action: onShow.mapNotNull(
      (onPressed) =>
          SnackBarAction(label: l10n.uiHelper_actionShow, onPressed: onPressed),
    ),
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showSuggestNewTabMessage(
  BuildContext context, {
  required void Function(String? searchText) onAdd,
  Duration duration = const Duration(seconds: 3),
  bool persist = false,
}) async {
  final clipboardUrl = await tryGetUriFromClipboard();

  if (clipboardUrl != null) {
    if (!context.mounted) return;
    final l10n = AppLocalizations.of(context);

    final snackBar = _createFloatingSnackBar(
      content: Text(l10n.uiHelper_wantToOpenLinkFromClipboard),
      action: SnackBarAction(
        label: l10n.common_open,
        onPressed: () {
          onAdd(clipboardUrl.toString());
        },
      ),
      duration: duration,
      persist: persist,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void showTabSwitchMessage(
  BuildContext context, {
  String? tabName,
  void Function()? onSwitch,
  Duration duration = const Duration(seconds: 3),
  bool persist = false,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  final l10n = AppLocalizations.of(context);

  final message = switch (tabName.whenNotEmpty) {
    String() => l10n.uiHelper_newTabOpenedNamed(tabName!),
    null => l10n.uiHelper_newTabOpened,
  };

  final snackBar = _createFloatingSnackBar(
    content: Text(message),
    action: onSwitch.mapNotNull(
      (onPressed) => SnackBarAction(
        label: l10n.uiHelper_actionSwitch,
        onPressed: onPressed,
      ),
    ),
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> launchUrlFeedback(
  BuildContext context,
  Uri url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  if (await canLaunchUrl(url)) {
    try {
      if (!await launchUrl(url, mode: mode)) {
        if (context.mounted) {
          showErrorMessage(
            context,
            AppLocalizations.of(context).uiHelper_couldNotLaunchUrl('$url'),
          );
        }
      }
    } catch (e, s) {
      logger.e('Failed to launch URL: $url', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(
          context,
          AppLocalizations.of(context).uiHelper_couldNotLaunchUrl('$url'),
        );
      }
    }
  } else {
    if (context.mounted) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).uiHelper_canNotHandleScheme(url.scheme),
      );
    }
  }
}

void showTabUndoClose(
  BuildContext context,
  VoidCallback onUndo, {
  int count = 1,
  Duration duration = const Duration(seconds: 3),
  bool persist = false,
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  final l10n = AppLocalizations.of(context);

  final snackBar = _createFloatingSnackBar(
    content: Text(l10n.uiHelper_tabsClosedCount(count)),
    action: SnackBarAction(label: l10n.common_undo, onPressed: onUndo),
    duration: duration,
    persist: persist,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// Shows a confirmation dialog before closing isolated tabs whose data
/// will be permanently cleared. Returns `true` if the user confirms.
Future<bool> confirmIsolatedTabClose(
  BuildContext context, {
  int groupCount = 1,
}) async {
  final l10n = AppLocalizations.of(context);
  final message = l10n.uiHelper_closeIsolatedTabsConfirm(groupCount);

  final result = await showDialog<bool>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: (context) => AlertDialog(
      title: Text(l10n.uiHelper_closeIsolatedTabsTitle),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.common_close),
        ),
      ],
    ),
  );

  return result ?? false;
}
