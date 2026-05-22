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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_logs.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SingboxProxyLogsScreen extends HookConsumerWidget {
  const SingboxProxyLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(singboxProxyLogsProvider);
    final filter = useState<String?>(null);
    final autoScroll = useState(true);
    final scrollController = useScrollController();

    // Stick to the bottom when new lines arrive — unless the user scrolled up.
    // We coalesce scroll-to-bottom across rapid bursts via a pending flag so a
    // chatty proxy can't fight the user trying to scroll up.
    final pendingAutoScroll = useRef(false);
    useEffect(() {
      if (!autoScroll.value) return null;
      if (pendingAutoScroll.value) return null;
      pendingAutoScroll.value = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        pendingAutoScroll.value = false;
        if (!autoScroll.value) return;
        if (scrollController.hasClients) {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      });
      return null;
    }, [logs.length, autoScroll.value]);

    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final atBottom =
            scrollController.position.pixels >=
            scrollController.position.maxScrollExtent - 24;
        if (autoScroll.value != atBottom) {
          autoScroll.value = atBottom;
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    final filtered = filter.value == null
        ? logs
        : logs.where((m) => m.level.toLowerCase() == filter.value).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Logs'),
        actions: [
          PopupMenuButton<String?>(
            tooltip: 'Filter by level',
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => filter.value = value,
            itemBuilder: (context) => const [
              PopupMenuItem<String?>(child: Text('All levels')),
              PopupMenuItem(value: 'error', child: Text('Error')),
              PopupMenuItem(value: 'warn', child: Text('Warning')),
              PopupMenuItem(value: 'info', child: Text('Info')),
              PopupMenuItem(value: 'debug', child: Text('Debug')),
              PopupMenuItem(value: 'trace', child: Text('Trace')),
            ],
          ),
          IconButton(
            tooltip: 'Copy all',
            icon: const Icon(Icons.copy_all),
            onPressed: filtered.isEmpty
                ? null
                : () async {
                    await Clipboard.setData(
                      ClipboardData(text: _formatLogs(filtered)),
                    );
                    if (context.mounted) {
                      showInfoMessage(context, 'Copied to clipboard');
                    }
                  },
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: filtered.isEmpty
                ? null
                : () => SharePlus.instance.share(
                    ShareParams(
                      text: _formatLogs(filtered),
                      subject: 'proxy logs',
                    ),
                  ),
          ),
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.delete_outline),
            onPressed: logs.isEmpty
                ? null
                : () => ref.read(singboxProxyLogsProvider.notifier).clear(),
          ),
        ],
      ),
      body: filtered.isEmpty
          ? _EmptyLogs(hasFilter: filter.value != null)
          : ListView.builder(
              controller: scrollController,
              itemCount: filtered.length,
              itemBuilder: (context, index) =>
                  _LogLine(message: filtered[index]),
            ),
    );
  }
}

class _LogLine extends StatelessWidget {
  final ProxyLogMessage message;

  const _LogLine({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (message.level.toLowerCase()) {
      'error' || 'fatal' => scheme.error,
      'warn' || 'warning' => scheme.tertiary,
      _ => scheme.onSurface,
    };
    final time = DateFormat(
      'HH:mm:ss',
    ).format(DateTime.fromMillisecondsSinceEpoch(message.timestamp));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: SelectableText.rich(
        TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontFamily: 'monospace',
            color: color,
          ),
          children: [
            TextSpan(
              text: '$time ',
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
            TextSpan(
              text: '[${_sourceLabel(message.source)}] ',
              style: TextStyle(color: scheme.primary),
            ),
            TextSpan(
              text: '[${message.level}] ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            if (message.profileId != null)
              TextSpan(
                text: '${message.profileId} ',
                style: TextStyle(color: scheme.primary),
              ),
            TextSpan(text: message.message),
          ],
        ),
      ),
    );
  }
}

class _EmptyLogs extends StatelessWidget {
  final bool hasFilter;

  const _EmptyLogs({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          hasFilter
              ? 'No log lines match the current filter.'
              : 'No log lines yet. Start a proxy or Tor to see output here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

String _formatLogs(List<ProxyLogMessage> messages) {
  final buffer = StringBuffer();
  for (final m in messages) {
    final time = DateTime.fromMillisecondsSinceEpoch(
      m.timestamp,
    ).toIso8601String();
    buffer.writeln(
      '$time [${_sourceLabel(m.source)}] [${m.level}]${m.profileId == null ? '' : ' (${m.profileId})'} ${m.message}',
    );
  }
  return buffer.toString();
}

String _sourceLabel(ProxyLogSource source) {
  return switch (source) {
    ProxyLogSource.singBox => 'sing-box',
    ProxyLogSource.tor => 'tor',
  };
}
