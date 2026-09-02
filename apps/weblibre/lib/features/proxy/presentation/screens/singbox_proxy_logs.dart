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
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/features/proxy/data/models/proxy_log_message.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_logs.dart';
import 'package:weblibre/features/proxy/presentation/widgets/proxy_log_level_sheet.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Built once. Constructing a [DateFormat] parses its pattern, and doing that
/// per line per frame is most of what a log line costs to paint.
final _lineTimeFormat = DateFormat('HH:mm:ss');

/// How far from the newest line the list has to be scrolled before the viewer
/// is offered a way back to it.
const _jumpToLatestThreshold = 240.0;

/// Reads the proxy runtimes' shared log, and sets how much they write to it.
///
/// The verbosity control lives here rather than in Settings on purpose: it is
/// the log's own setting, only ever changed *because* of what this screen does
/// or does not show, and a level raised for a diagnosis is a level to put back
/// from the same place. Settings links here instead of duplicating it.
class SingboxProxyLogsScreen extends HookConsumerWidget {
  const SingboxProxyLogsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final minimumSeverity = useState<ProxyLogSeverity?>(null);

    // Only whether there is *anything* to act on, so a chatty proxy publishing
    // a snapshot every 100ms rebuilds the list and nothing else. The list
    // watches the feed itself; see [_ProxyLogList].
    final hasLogs = ref.watch(
      proxyLogFeedProvider.select((logs) => logs.isNotEmpty),
    );

    List<ProxyLogMessage> currentLines() =>
        _filter(ref.read(proxyLogFeedProvider), minimumSeverity.value);

    Future<void> copyAll() async {
      final lines = currentLines();
      if (lines.isEmpty) {
        showInfoMessage(context, 'No log lines match the current filter');
        return;
      }

      await Clipboard.setData(ClipboardData(text: _formatLogs(lines)));
      if (context.mounted) {
        showInfoMessage(context, 'Copied ${lines.length} lines to clipboard');
      }
    }

    Future<void> share() async {
      final lines = currentLines();
      if (lines.isEmpty) {
        showInfoMessage(context, 'No log lines match the current filter');
        return;
      }

      await SharePlus.instance.share(
        ShareParams(text: _formatLogs(lines), subject: 'proxy logs'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proxy Logs'),
        actions: [
          IconButton(
            tooltip: 'Copy all',
            icon: const Icon(Icons.copy_all),
            onPressed: hasLogs ? copyAll : null,
          ),
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: hasLogs ? share : null,
          ),
          IconButton(
            tooltip: 'Clear log',
            icon: const Icon(Icons.delete_outline),
            onPressed: hasLogs
                ? () => ref.read(singboxProxyLogsProvider.notifier).clear()
                : null,
          ),
        ],
      ),
      // The controls are in the body rather than the app bar's `bottom`, which
      // wants a height declared up front. Both rows are text at whatever scale
      // the user reads at, and a declared height is one they can overflow.
      body: Column(
        children: [
          const _RecordingLevelBanner(),
          _SeverityFilterBar(
            minimumSeverity: minimumSeverity.value,
            onChanged: (value) => minimumSeverity.value = value,
          ),
          const Divider(height: 1),
          Expanded(
            child: _ProxyLogList(minimumSeverity: minimumSeverity.value),
          ),
        ],
      ),
    );
  }
}

/// What the runtimes are currently recording, and the way to change it.
///
/// Shown rather than tucked into a menu because it is the answer to the first
/// question this screen provokes — "why is there nothing here?" — and because a
/// verbose level left on costs the user browsing speed for as long as they do
/// not notice it.
class _RecordingLevelBanner extends ConsumerWidget {
  const _RecordingLevelBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final logLevel = ref
        .watch(proxyDiagnosticsSettingsWithDefaultsProvider)
        .logLevel;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 0),
      child: Row(
        children: [
          Icon(
            logLevel.isVerbose
                ? Icons.warning_amber_outlined
                : Icons.tune_outlined,
            size: 20,
            color: logLevel.isVerbose
                ? theme.colorScheme.error
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              logLevel.isVerbose
                  ? 'Recording ${logLevel.label.toLowerCase()} — this slows browsing'
                  : 'Recording ${logLevel.label.toLowerCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: logLevel.isVerbose
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () => showProxyLogLevelSheet(context),
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }
}

/// Which lines the viewer keeps, as a visible row rather than a menu behind an
/// icon.
///
/// The choice is a *minimum* severity: "Warnings" keeps errors too. Filtering
/// on one level exactly, which is what the icon menu did, hid the error that
/// followed the warning the user went looking for.
class _SeverityFilterBar extends StatelessWidget {
  final ProxyLogSeverity? minimumSeverity;
  final ValueChanged<ProxyLogSeverity?> onChanged;

  const _SeverityFilterBar({
    required this.minimumSeverity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        spacing: 8,
        children: [
          _SeverityChip(
            label: 'All',
            semanticsLabel: 'Show all levels',
            selected: minimumSeverity == null,
            onSelected: () => onChanged(null),
          ),
          for (final severity in ProxyLogSeverity.values.reversed)
            _SeverityChip(
              label: severity.filterLabel,
              semanticsLabel: severity == ProxyLogSeverity.error
                  ? 'Show errors only'
                  : 'Show ${severity.filterLabel.toLowerCase()} and above',
              selected: minimumSeverity == severity,
              onSelected: () => onChanged(severity),
            ),
        ],
      ),
    );
  }
}

class _SeverityChip extends StatelessWidget {
  final String label;
  final String semanticsLabel;
  final bool selected;
  final VoidCallback onSelected;

  const _SeverityChip({
    required this.label,
    required this.semanticsLabel,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      tooltip: semanticsLabel,
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

/// The lines themselves, newest at the bottom.
///
/// Built `reverse: true` — index 0 is the newest line, at the bottom of the
/// viewport — which is what makes the log follow itself. A forward list has to
/// be scrolled to `maxScrollExtent` after every publication to stay at the end,
/// and that jump both fights a user who has scrolled up and lands short
/// whenever the extent is not final yet. Reversed, the newest line simply *is*
/// the anchor, and a user who scrolls back sees the older lines hold still
/// while new ones arrive out of sight below.
class _ProxyLogList extends HookConsumerWidget {
  final ProxyLogSeverity? minimumSeverity;

  const _ProxyLogList({required this.minimumSeverity});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(proxyLogFeedProvider);
    final scrollController = useScrollController();

    // Only rescans when a new snapshot or a new filter arrives — never when the
    // scroll position changes, which is what it does most.
    final filtered = useMemoized(() => _filter(logs, minimumSeverity), [
      logs,
      minimumSeverity,
    ]);

    final isAwayFromLatest = useState(false);
    useEffect(() {
      void onScroll() {
        if (!scrollController.hasClients) return;
        final away = scrollController.position.pixels > _jumpToLatestThreshold;
        if (isAwayFromLatest.value != away) {
          isAwayFromLatest.value = away;
        }
      }

      scrollController.addListener(onScroll);
      return () => scrollController.removeListener(onScroll);
    }, [scrollController]);

    if (filtered.isEmpty) {
      return _EmptyLogs(hasFilter: minimumSeverity != null);
    }

    return Stack(
      children: [
        // One selection region for the whole list rather than a selectable
        // widget per line: the per-line version built gesture recognizers, a
        // focus node and selection controls for every one of up to 2000
        // entries, and still could not select across two of them.
        SelectionArea(
          child: ListView.builder(
            controller: scrollController,
            reverse: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) =>
                _LogLine(message: filtered[filtered.length - 1 - index]),
          ),
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: IgnorePointer(
            ignoring: !isAwayFromLatest.value,
            child: AnimatedSlide(
              offset: isAwayFromLatest.value ? Offset.zero : const Offset(0, 2),
              duration: const Duration(milliseconds: 150),
              child: AnimatedOpacity(
                opacity: isAwayFromLatest.value ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: FloatingActionButton.extended(
                  heroTag: 'proxy-logs-jump-to-latest',
                  onPressed: () => scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                  ),
                  icon: const Icon(Icons.arrow_downward),
                  label: const Text('Latest'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _LogLine extends StatelessWidget {
  final ProxyLogMessage message;

  const _LogLine({required this.message});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = switch (message.severity) {
      ProxyLogSeverity.error => scheme.error,
      ProxyLogSeverity.warn => scheme.tertiary,
      _ => scheme.onSurface,
    };
    final time = _lineTimeFormat.format(
      DateTime.fromMillisecondsSinceEpoch(message.timestamp),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Text.rich(
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
              text: '[${message.source.label}] ',
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
        // Colour carries the severity for anyone who can see it; this is how
        // the rest of it is carried. Read as a sentence rather than as the
        // bracketed prefixes, which a screen reader spells out one by one.
        semanticsLabel:
            '$time, ${message.source.label}, ${message.level}'
            '${message.profileId == null ? '' : ', ${message.profileId}'}. '
            '${message.message}',
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
              ? 'No log lines at this level. Lower the filter, or raise what '
                    'the proxy records.'
              : 'No log lines yet. Start a proxy or $torBrand to see output here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

List<ProxyLogMessage> _filter(
  List<ProxyLogMessage> logs,
  ProxyLogSeverity? minimumSeverity,
) {
  if (minimumSeverity == null) return logs;

  return logs
      .where((message) => message.severity.isAtLeast(minimumSeverity))
      .toList();
}

String _formatLogs(List<ProxyLogMessage> messages) {
  final buffer = StringBuffer();
  for (final m in messages) {
    final time = DateTime.fromMillisecondsSinceEpoch(
      m.timestamp,
    ).toIso8601String();
    buffer.writeln(
      '$time [${m.source.label}] [${m.level}]${m.profileId == null ? '' : ' (${m.profileId})'} ${m.message}',
    );
  }
  return buffer.toString();
}
