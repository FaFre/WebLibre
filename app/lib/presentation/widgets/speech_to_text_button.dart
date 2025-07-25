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
import 'package:speech_to_text_google_dialog/speech_to_text_google_dialog.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SpeechToTextButton extends StatelessWidget {
  final Function(dynamic data) onTextReceived;

  const SpeechToTextButton({required this.onTextReceived, super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () async {
        final isServiceAvailable = await SpeechToTextGoogleDialog.getInstance()
            .showGoogleDialog(
              onTextReceived: onTextReceived,
              // locale: "en-US",
            );

        if (!isServiceAvailable) {
          if (context.mounted) {
            ui_helper.showErrorMessage(context, 'Service is not available');
          }
        }
      },
      icon: const Icon(Icons.mic),
    );
  }
}
