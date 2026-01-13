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
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:speech_to_text_dialog/speech_to_text_dialog.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

class SpeechToTextButton extends HookWidget {
  final Function(String text) onTextReceived;

  const SpeechToTextButton({required this.onTextReceived, super.key});

  @override
  Widget build(BuildContext context) {
    final speechDialog = useMemoized(() => SpeechToTextDialog());
    final subscription = useRef<StreamSubscription<String>?>(null);

    useEffect(() {
      return () {
        subscription.value?.cancel().ignore();
        speechDialog.dispose();
      };
    }, [speechDialog]);

    Future<void> showSpeechDialog() async {
      // Cancel any existing subscription
      await subscription.value?.cancel();

      // Listen for the next text result
      subscription.value = speechDialog.textStream.take(1).listen((text) {
        if (text.isNotEmpty) {
          onTextReceived(text);
        }
      });

      // Show the dialog
      final isServiceAvailable = await speechDialog.showDialog(
        locale: PlatformDispatcher.instance.locale.toLanguageTag(),
      );

      if (!isServiceAvailable) {
        if (context.mounted) {
          ui_helper.showErrorMessage(context, 'Service is not available');
        }
        await subscription.value?.cancel();
      }
    }

    return IconButton(onPressed: showSpeechDialog, icon: const Icon(Icons.mic));
  }
}
