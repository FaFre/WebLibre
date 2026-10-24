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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';

const _showDialogChannel =
    'dev.flutter.pigeon.speech_to_text_dialog.SpeechToTextApi.showDialog';
const _resultChannel =
    'dev.flutter.pigeon.speech_to_text_dialog.SpeechToTextEvents.onTextReceived';

// The plugin's codec only adds its own types to the standard one, and these
// messages carry none.
const _codec = StandardMessageCodec();

/// Stands in for the native side: counts the recognizers opened and answers
/// whether the speech service is there.
class _FakeRecognizer {
  final WidgetTester tester;
  bool serviceAvailable = true;
  int opened = 0;

  _FakeRecognizer(this.tester) {
    tester.binding.defaultBinaryMessenger.setMockMessageHandler(
      _showDialogChannel,
      (message) async {
        opened++;
        return _codec.encodeMessage(<Object?>[serviceAvailable]);
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMessageHandler(
        _showDialogChannel,
        null,
      ),
    );
  }

  /// Sends what the open recognizer heard; empty when it was cancelled.
  Future<void> answer(String text) async {
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      _resultChannel,
      _codec.encodeMessage(<Object?>[text]),
      (_) {},
    );
    await _settle(tester);
  }
}

/// Runs a dictation to its end. Cancelling a finished subscription returns a
/// future from the root zone, which resumes only on a real turn of the event
/// loop, so pumping the fake clock alone leaves the dictation hanging there.
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(Duration.zero));
  await tester.pump();
}

/// What a dictation returned, once it has.
class _Outcome {
  bool isDone = false;
  String? text;
}

_Outcome _track(Future<String?> dictation) {
  final outcome = _Outcome();
  unawaited(
    dictation.then((text) {
      outcome
        ..text = text
        ..isDone = true;
    }),
  );
  return outcome;
}

Future<BuildContext> _pumpApp(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) {
            captured = context;
            return const SizedBox.shrink();
          },
        ),
      ),
    ),
  );
  return captured;
}

void main() {
  testWidgets('a second request while one is open opens no recognizer', (
    tester,
  ) async {
    final recognizer = _FakeRecognizer(tester);
    final context = await _pumpApp(tester);

    final first = _track(dictateText(context));
    final second = _track(dictateText(context));
    await tester.pump();

    expect(recognizer.opened, 1);
    expect(second.isDone, isTrue);
    expect(second.text, isNull);

    await recognizer.answer('hello');

    expect(first.isDone, isTrue);
    expect(first.text, 'hello');
  });

  testWidgets('a dictation can start again once the last one answered', (
    tester,
  ) async {
    final recognizer = _FakeRecognizer(tester);
    final context = await _pumpApp(tester);

    final cancelled = _track(dictateText(context));
    await tester.pump();
    await recognizer.answer('');

    expect(cancelled.isDone, isTrue);
    expect(cancelled.text, isNull);

    final next = _track(dictateText(context));
    await tester.pump();
    await recognizer.answer('again');

    expect(recognizer.opened, 2);
    expect(next.text, 'again');
  });

  testWidgets('a missing speech service ends the dictation', (tester) async {
    final recognizer = _FakeRecognizer(tester)..serviceAvailable = false;
    final context = await _pumpApp(tester);

    final unavailable = _track(dictateText(context));
    await _settle(tester);

    expect(unavailable.isDone, isTrue);
    expect(unavailable.text, isNull);
    expect(find.text('Speech recognition is not available'), findsOne);

    recognizer.serviceAvailable = true;
    final next = _track(dictateText(context));
    await tester.pump();
    await recognizer.answer('found');

    expect(recognizer.opened, 2);
    expect(next.text, 'found');

    // Lets the error message time out.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
