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

// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:weblibre/utils/ui_helper.dart';

IconData _levelIcon(Level level) {
  return switch (level) {
    Level.trace => Icons.blur_circular,
    Level.debug => Icons.bug_report,
    Level.info => Icons.info,
    Level.warning => Icons.warning,
    Level.error => Icons.error,
    Level.fatal => Icons.dangerous,
    Level.all => Icons.notes,
    Level.verbose => Icons.chat_bubble_outline,
    Level.wtf => Icons.question_mark,
    Level.nothing => Icons.close,
    Level.off => Icons.offline_bolt,
  };
}

Color _levelColor(Level level) {
  return switch (level) {
    Level.trace => Colors.grey,
    Level.debug => Colors.blue,
    Level.info => Colors.cyan,
    Level.warning => Colors.orange,
    Level.error => Colors.red,
    Level.fatal => Colors.purple,
    Level.all => Colors.grey,
    Level.verbose => Colors.teal,
    Level.wtf => Colors.brown,
    Level.nothing => Colors.grey,
    Level.off => Colors.grey,
  };
}

class LogDetailsDialog extends StatelessWidget {
  const LogDetailsDialog({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    required this.time,
    super.key,
  });

  final Level level;
  final String message;
  final String? error;
  final String? stackTrace;
  final DateTime time;

  String _formatTime(DateTime time) {
    return DateFormat('HH:mm:ss.SSS').format(time);
  }

  Future<void> _copyEntryToClipboard(BuildContext context) async {
    final text = StringBuffer();

    text.writeln(
      '[${_formatTime(time)}] ${level.name.toUpperCase()}: $message',
    );
    if (error != null) {
      text.writeln('Error: $error');
    }
    if (stackTrace != null) {
      text.writeln('Stack Trace:');
      text.writeln(stackTrace);
    }

    await Clipboard.setData(ClipboardData(text: text.toString()));

    if (context.mounted) {
      showInfoMessage(context, 'Entry copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(_levelIcon(level), color: _levelColor(level)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(level.name.toUpperCase()),
              Text(
                _formatTime(time),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (message.isNotEmpty) ...[
                Text(
                  'Message:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  message,
                  style: GoogleFonts.robotoMono(fontSize: 12),
                ),
                const SizedBox(height: 16),
              ],
              if (error != null) ...[
                Text(
                  'Error:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _levelColor(level),
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  error!,
                  style: GoogleFonts.robotoMono(fontSize: 11),
                ),
                const SizedBox(height: 16),
              ],
              if (stackTrace != null) ...[
                Text(
                  'Stack Trace:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  stackTrace!,
                  style: GoogleFonts.robotoMono(fontSize: 9),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        TextButton.icon(
          onPressed: () => _copyEntryToClipboard(context),
          icon: const Icon(Icons.copy),
          label: const Text('Copy'),
        ),
      ],
    );
  }
}

Future<void> showLogDetailsDialog(
  BuildContext context, {
  required Level level,
  required String message,
  String? error,
  String? stackTrace,
  required DateTime time,
}) {
  return showDialog(
    context: context,
    builder: (context) => LogDetailsDialog(
      level: level,
      message: message,
      error: error,
      stackTrace: stackTrace,
      time: time,
    ),
  );
}
