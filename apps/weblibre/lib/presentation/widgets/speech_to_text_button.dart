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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text_dialog/speech_to_text_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Shows the system's speech recognition dialog and returns what was said, or
/// null when nothing was. A missing speech service is reported on [context].
///
/// The plugin hands its results to a single handler for the whole app, which
/// every [SpeechToTextDialog] replaces on creation and clears on dispose. So
/// each dictation registers its own just for its answer: a long-lived one per
/// button lost every result as soon as another button was built or disposed.
///
/// Only one dictation runs at a time. A request made while one is open (a
/// second tap before the recognizer covers the app) returns null at once:
/// its own recognizer would take the handler from the first, which would then
/// wait forever, and its dispose would drop the result still to come.
Future<String?> dictateText(BuildContext context) async {
  if (_isDictating) return null;
  _isDictating = true;

  final speechDialog = SpeechToTextDialog();
  final result = Completer<String>();
  final subscription = speechDialog.textStream.take(1).listen(result.complete);

  try {
    final isServiceAvailable = await speechDialog.showDialog(
      locale: PlatformDispatcher.instance.locale.toLanguageTag(),
    );

    if (!isServiceAvailable) {
      if (context.mounted) {
        ui_helper.showErrorMessage(
          context,
          AppLocalizations.of(context).speechToTextButton_serviceNotAvailable,
        );
      }
      return null;
    }

    // Empty when the user cancelled or nothing was recognized.
    final text = await result.future;
    return text.isEmpty ? null : text;
  } finally {
    await subscription.cancel();
    speechDialog.dispose();
    _isDictating = false;
  }
}

bool _isDictating = false;

class SpeechToTextButton extends StatelessWidget {
  final Function(String text) onTextReceived;

  const SpeechToTextButton({required this.onTextReceived, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final text = await dictateText(context);
        // Callers write the text into controllers that go with the button.
        if (text != null && context.mounted) onTextReceived(text);
      },
      icon: const Icon(Icons.mic),
    );
  }
}
