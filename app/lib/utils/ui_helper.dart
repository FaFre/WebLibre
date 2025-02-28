import 'package:flutter/material.dart';
import 'package:lensai/extensions/nullable.dart';
import 'package:url_launcher/url_launcher.dart';

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

void showTabBackButtonMessage(BuildContext context, int tabCount) {
  final snackbar = SnackBar(
    content:
        (tabCount > 1)
            ? const Text('Please click BACK again to close current tab')
            : const Text('Please click BACK again to exit app'),
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
