// ignore_for_file: deprecated_member_use

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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:weblibre/core/logger.dart';
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

Color _levelBackgroundColor(Level level, BuildContext context) {
  return switch (level) {
    Level.trace => Colors.grey.withValues(alpha: 0.1),
    Level.debug => Colors.blue.withValues(alpha: 0.05),
    Level.info => Colors.cyan.withValues(alpha: 0.05),
    Level.warning => Colors.orange.withValues(alpha: 0.1),
    Level.error => Colors.red.withValues(alpha: 0.1),
    Level.fatal => Colors.purple.withValues(alpha: 0.1),
    Level.all => Colors.grey.withValues(alpha: 0.1),
    Level.verbose => Colors.teal.withValues(alpha: 0.05),
    Level.wtf => Colors.brown.withValues(alpha: 0.1),
    Level.nothing => Colors.grey.withValues(alpha: 0.05),
    Level.off => Colors.grey.withValues(alpha: 0.05),
  };
}

class ErrorLogsScreen extends HookWidget {
  const ErrorLogsScreen({super.key});

  String _logsText() {
    final logs = loggerMemory.buffer;
    return logs.map((e) => e.lines.join('\n')).join('\n\n');
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _logsText()));
    if (context.mounted) {
      showInfoMessage(context, 'Logs copied');
    }
  }

  @override
  Widget build(BuildContext context) {
    final minLogLevel = useState(Level.all);
    final allLogs = useMemoized(() => loggerMemory.buffer.toList());

    final sortedLogs = useMemoized(
      () => allLogs.reversed
          .where((e) => e.level.value >= minLogLevel.value.value)
          .toList(),
      [allLogs, minLogLevel.value],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Logs'),
        actions: [
          MenuAnchor(
            builder: (context, controller, childAnchor) {
              return TextButton.icon(
                onPressed: controller.open,
                icon: const Icon(Icons.filter_list),
                label: Text(minLogLevel.value.name.toUpperCase()),
              );
            },
            menuChildren: [
              const Divider(height: 0),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.trace),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.debug),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.info),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.warning),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.error),
              _buildLevelFilterMenuItem(context, minLogLevel, Level.fatal),
            ],
          ),
          IconButton(
            onPressed: () => _copyToClipboard(context),
            icon: const Icon(Icons.copy),
            tooltip: 'Copy logs',
          ),
        ],
      ),
      body: SafeArea(
        child: sortedLogs.isEmpty
            ? const Center(child: Text('No logs available'))
            : ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: sortedLogs.length,
                itemBuilder: (context, index) {
                  final logEntry = sortedLogs[index];
                  return _LogEntryTile(event: logEntry);
                },
              ),
      ),
    );
  }

  Widget _buildLevelFilterMenuItem(
    BuildContext context,
    ValueNotifier<Level> minLogLevel,
    Level level,
  ) {
    final isSelected = level.value == minLogLevel.value.value;
    final levelColor = _levelColor(level);

    return CheckboxMenuButton(
      trailingIcon: Icon(_levelIcon(level), color: levelColor),
      value: isSelected,
      onChanged: (value) {
        if (value == true) {
          minLogLevel.value = level;
        }
      },
      child: Text(level.name.toUpperCase()),
    );
  }
}

class _LogEntryTile extends StatelessWidget {
  const _LogEntryTile({required this.event});

  final OutputEvent event;

  @override
  Widget build(BuildContext context) {
    final logEvent = event.origin;

    final level = logEvent.level;
    final message = logEvent.message?.toString() ?? '';
    final error = logEvent.error?.toString();
    final stackTrace = logEvent.stackTrace?.toString();
    final time = logEvent.time;

    final iconData = _levelIcon(level);
    final iconColor = _levelColor(level);
    final backgroundColor = _levelBackgroundColor(level, context);

    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: InkWell(
        onTap: () async {
          await showDialog(
            context: context,
            builder: (context) => _LogDetailsDialog(
              level: level,
              message: message,
              error: error,
              stackTrace: stackTrace,
              time: time,
            ),
          );
        },
        child: ListTile(
          leading: Icon(iconData, color: iconColor, size: 24),
          title: Text(
            message,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.robotoMono(fontSize: 12),
          ),
          subtitle: _buildTime(time, context),
        ),
      ),
    );
  }

  Widget? _buildTime(DateTime? time, BuildContext context) {
    if (time == null) return null;

    return Text(
      timeago.format(time),
      style: TextStyle(
        fontSize: 10,
        fontStyle: FontStyle.italic,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _LogDetailsDialog extends StatelessWidget {
  const _LogDetailsDialog({
    required this.level,
    required this.message,
    this.error,
    this.stackTrace,
    required this.time,
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
