/*
 * Copyright (c) 2024-2025 Fabian Freund.
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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/utils/clipboard.dart';

/// Creates a floating snackbar.
/// The margin is controlled by the scaffold's snackBarTheme for proper
/// positioning above bottom app bars of varying heights.
SnackBar _createFloatingSnackBar({
  required Widget content,
  Color? backgroundColor,
  SnackBarAction? action,
  Duration duration = const Duration(seconds: 4),
  bool persist = false,
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

void showErrorMessage(BuildContext context, String message) {
  final snackBar = _createFloatingSnackBar(
    content: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
    backgroundColor: Theme.of(context).colorScheme.onError,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showInfoMessage(BuildContext context, String message) {
  final snackBar = _createFloatingSnackBar(content: Text(message));

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showTabBackButtonMessage(
  BuildContext context,
  int tabCount,
  Duration duration,
) {
  final snackbar = _createFloatingSnackBar(
    content: (tabCount > 1)
        ? const Text('Navigate BACK again to close current tab')
        : const Text('Navigate BACK again to exit app'),
    duration: duration,
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
}) {
  final message = switch (tabName.whenNotEmpty) {
    String() => "New tab '$tabName' opened in background",
    null => 'New tab opened in background',
  };

  final snackBar = _createFloatingSnackBar(
    content: Text(message),
    action: onShow.mapNotNull(
      (onPressed) => SnackBarAction(label: 'Show', onPressed: onPressed),
    ),
    duration: duration,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showSuggestNewTabMessage(
  BuildContext context, {
  required void Function(String? searchText) onAdd,
  Duration duration = const Duration(seconds: 2),
}) async {
  final clipboardUrl = await tryGetUriFromClipboard();

  if (clipboardUrl != null) {
    final snackBar = _createFloatingSnackBar(
      content: const Text('Want to open link from clipboard?'),
      action: SnackBarAction(
        label: 'Open',
        onPressed: () {
          onAdd(clipboardUrl.toString());
        },
      ),
      duration: duration,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }
}

void showTabSwitchMessage(
  BuildContext context, {
  String? tabName,
  void Function()? onSwitch,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  final message = switch (tabName.whenNotEmpty) {
    String() => "New tab '$tabName' opened",
    null => 'New tab opened',
  };

  final snackBar = _createFloatingSnackBar(
    content: Text(message),
    action: onSwitch.mapNotNull(
      (onPressed) => SnackBarAction(label: 'Switch', onPressed: onPressed),
    ),
    duration: duration,
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
          showErrorMessage(context, 'Could not launch URL ($url)');
        }
      }
    } catch (e, s) {
      logger.e('Failed to launch URL: $url', error: e, stackTrace: s);
      if (context.mounted) {
        showErrorMessage(context, 'Could not launch URL ($url)');
      }
    }
  } else {
    if (context.mounted) {
      showErrorMessage(context, 'Can not handle "${url.scheme}"');
    }
  }
}

void showTabUndoClose(
  BuildContext context,
  VoidCallback onUndo, {
  int count = 1,
  Duration duration = const Duration(seconds: 2),
}) {
  ScaffoldMessenger.of(context).clearSnackBars();

  final snackBar = _createFloatingSnackBar(
    content: (count > 1)
        ? Text('$count Tabs closed')
        : const Text('Tab closed'),
    action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    duration: duration,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
