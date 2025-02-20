import 'package:flutter/material.dart';
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

Future<void> launchUrlFeedback(
  BuildContext context,
  Uri url, {
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  if (!await launchUrl(url, mode: mode)) {
    if (context.mounted) {
      showErrorMessage(context, 'Could not launch URL ($url)');
    }
  }
}

void showTabBackButtonMessage(BuildContext context, int tabCount) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content:
            (tabCount > 1)
                ? const Text('Please click BACK again to close current tab')
                : const Text('Please click BACK again to exit app'),
      ),
    );
}
