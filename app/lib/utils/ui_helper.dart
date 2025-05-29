import 'package:flutter/material.dart';
import 'package:nullability/nullability.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/utils/clipboard.dart';

void showErrorMessage(BuildContext context, String message) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
    backgroundColor: Theme.of(context).colorScheme.onError,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

void showTabBackButtonMessage(
  BuildContext context,
  int tabCount,
  Duration duration,
) {
  final snackbar = SnackBar(
    content:
        (tabCount > 1)
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
}) {
  final message = switch (tabName.whenNotEmpty) {
    String() => "New tab '$tabName' opened in background",
    null => 'New tab opened in background',
  };

  final snackBar = SnackBar(
    content: Text(message),
    action: onShow.mapNotNull(
      (onPressed) => SnackBarAction(label: 'Show', onPressed: onPressed),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> showSuggestNewTabMessage(
  BuildContext context, {
  required void Function(String? searchText) onAdd,
  Duration duration = const Duration(seconds: 2),
}) async {
  final clipboardUrl = await tryGetUriFromClipboard();

  final snackBar =
      (clipboardUrl != null)
          ? SnackBar(
            content: const Text('Want to open link from clipboard?'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                onAdd(clipboardUrl.toString());
              },
            ),
            duration: duration,
          )
          : SnackBar(
            content: const Text('Want to open a new tab?'),
            action: SnackBarAction(
              label: 'New Tab',
              onPressed: () {
                onAdd(null);
              },
            ),
            duration: duration,
          );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

void showTabSwitchMessage(
  BuildContext context, {
  String? tabName,
  void Function()? onSwitch,
}) {
  final message = switch (tabName.whenNotEmpty) {
    String() => "New tab '$tabName' opened",
    null => 'New tab opened',
  };

  final snackBar = SnackBar(
    content: Text(message),
    action: onSwitch.mapNotNull(
      (onPressed) => SnackBarAction(label: 'Switch', onPressed: onPressed),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

Future<void> launchUrlFeedback(
  BuildContext context,
  Uri url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  if (await canLaunchUrl(url)) {
    if (!await launchUrl(url, mode: mode)) {
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
