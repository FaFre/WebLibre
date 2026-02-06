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
import 'package:pigeon/pigeon.dart';

/// Pigeon API for speech recognition dialog.
///
/// This API provides type-safe communication between Flutter and Android
/// for showing the Google speech recognition dialog.
@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/pigeons/speech_to_text.g.dart',
    dartOptions: DartOptions(),
    kotlinOut:
        'android/src/main/kotlin/eu/weblibre/speech_to_text_dialog/pigeons/SpeechToText.g.kt',
    kotlinOptions: KotlinOptions(
      package: 'eu.weblibre.speech_to_text_dialog.pigeons',
    ),
    dartPackageName: 'speech_to_text_dialog',
  ),
)
/// Host API - methods called from Flutter to native Android.
@HostApi()
abstract class SpeechToTextApi {
  /// Show the speech recognition dialog.
  ///
  /// Returns [true] if the dialog was shown successfully.
  /// Returns [false] if the speech recognition service is not available.
  ///
  /// The [locale] parameter specifies the language locale for recognition
  /// (e.g., 'en-US', 'de-DE'). If null, uses the device default.
  bool showDialog({String? locale});
}

/// Flutter API - callbacks from native Android to Flutter.
@FlutterApi()
abstract class SpeechToTextEvents {
  /// Called when speech recognition completes with the recognized text.
  ///
  /// [text] contains the recognized speech text. May be empty if
  /// recognition failed or was cancelled.
  void onTextReceived(String text);
}
