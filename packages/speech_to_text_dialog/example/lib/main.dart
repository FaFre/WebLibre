import 'package:flutter/material.dart';
import 'dart:async';

import 'package:speech_to_text_dialog/speech_to_text_dialog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _speechToTextDialog = SpeechToTextDialog();
  StreamSubscription<String>? _textSubscription;
  String _recognizedText = 'Tap the button to start speaking...';
  String _selectedLocale = 'en-US';

  final List<String> _locales = [
    'en-US',
    'de-DE',
    'es-ES',
    'fr-FR',
    'it-IT',
    'pt-BR',
    'ru-RU',
    'zh-CN',
    'ja-JP',
    'ko-KR',
  ];

  @override
  void initState() {
    super.initState();
    // Listen for recognized text
    _textSubscription = _speechToTextDialog.textStream.listen((text) {
      setState(() {
        if (text.isEmpty) {
          _recognizedText = 'No speech detected or cancelled';
        } else {
          _recognizedText = text;
        }
      });
    });
  }

  @override
  void dispose() {
    _textSubscription?.cancel();
    _speechToTextDialog.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    setState(() {
      _recognizedText = 'Listening...';
    });

    final success = await _speechToTextDialog.showDialog(
      locale: _selectedLocale,
    );

    if (!success) {
      setState(() {
        _recognizedText = 'Speech recognition not available';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Speech to Text Dialog'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mic, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              Text(
                _recognizedText,
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              DropdownButton<String>(
                value: _selectedLocale,
                hint: const Text('Select Language'),
                items: _locales.map((String locale) {
                  return DropdownMenuItem<String>(
                    value: locale,
                    child: Text(locale),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedLocale = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _startListening,
                icon: const Icon(Icons.mic),
                label: const Text('Start Speech Recognition'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
