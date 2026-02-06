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
import 'package:flutter/services.dart' show BinaryMessenger;
import 'src/pigeons/speech_to_text.g.dart';

/// Speech recognition dialog using Android's RecognizerIntent.
///
/// This class provides a Flutter interface to Android's speech recognition
/// dialog, allowing users to dictate text that is then returned to the app.
///
/// Example usage:
/// ```dart
/// final speechDialog = SpeechToTextDialog();
///
/// // Listen for results
/// final subscription = speechDialog.textStream.listen((text) {
///   print('Recognized: $text');
/// });
///
/// // Show the dialog
/// final success = await speechDialog.showDialog(locale: 'en-US');
///
/// // Clean up when done
/// await subscription.cancel();
/// speechDialog.dispose();
/// ```
class SpeechToTextDialog implements SpeechToTextEvents {
  /// Creates a new [SpeechToTextDialog] instance.
  ///
  /// Optionally provide a custom [api] for testing or dependency injection.
  /// If [binaryMessenger] is provided, it will be used for Pigeon communication.
  SpeechToTextDialog({SpeechToTextApi? api, BinaryMessenger? binaryMessenger})
    : _api = api ?? SpeechToTextApi(binaryMessenger: binaryMessenger),
      _binaryMessenger = binaryMessenger {
    // Set up the event handler
    SpeechToTextEvents.setUp(this, binaryMessenger: binaryMessenger);
  }

  final SpeechToTextApi _api;
  final BinaryMessenger? _binaryMessenger;
  final _textStreamController = StreamController<String>.broadcast();
  bool _disposed = false;

  /// Stream of recognized speech text.
  ///
  /// This stream emits the recognized text when the user completes
  /// speech input. An empty string may be emitted if recognition failed
  /// or the user cancelled.
  Stream<String> get textStream => _textStreamController.stream;

  /// Show the speech recognition dialog.
  ///
  /// Returns [true] if the dialog was shown successfully.
  /// Returns [false] if the speech recognition service is not available.
  ///
  /// The [locale] parameter specifies the language locale for recognition
  /// (e.g., 'en-US', 'de-DE', 'es-ES'). If null, uses the device default locale.
  ///
  /// Example:
  /// ```dart
  /// final success = await speechDialog.showDialog(locale: 'en-US');
  /// if (!success) {
  ///   print('Speech recognition not available');
  /// }
  /// ```
  Future<bool> showDialog({String? locale}) async {
    return _api.showDialog(locale: locale);
  }

  @override
  void onTextReceived(String text) {
    if (!_disposed) {
      _textStreamController.add(text);
    }
  }

  /// Release resources used by this instance.
  ///
  /// Call this when the speech dialog is no longer needed to avoid memory leaks.
  /// After calling [dispose], this instance cannot be used again.
  void dispose() {
    if (!_disposed) {
      _disposed = true;
      SpeechToTextEvents.setUp(null, binaryMessenger: _binaryMessenger);
      _textStreamController.close();
    }
  }
}
