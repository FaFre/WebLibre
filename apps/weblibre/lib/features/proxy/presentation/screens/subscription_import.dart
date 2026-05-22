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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/services/subscription_importer.dart';
import 'package:weblibre/presentation/widgets/button_spinner.dart';
import 'package:weblibre/utils/ui_helper.dart';

class SubscriptionImportScreen extends HookConsumerWidget {
  const SubscriptionImportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlController = useTextEditingController();
    final hasUrl = useListenableSelector(
      urlController,
      () => urlController.text.trim().isNotEmpty,
    );
    final fetching = useState(false);
    final result = useState<SubscriptionImportResult?>(null);
    final selection = useState(<int>{});
    final fetchError = useState<String?>(null);
    final isImporting = useState(false);

    Future<void> fetch() async {
      final raw = urlController.text.trim();
      if (raw.isEmpty) return;
      final uri = Uri.tryParse(raw);
      if (uri == null || !uri.hasScheme) {
        fetchError.value = 'Enter a full https:// subscription URL.';
        return;
      }

      fetching.value = true;
      fetchError.value = null;
      try {
        final outcome = await fetchSubscription(uri);
        result.value = outcome;
        selection.value = {
          for (final (index, entry) in outcome.entries.indexed)
            if (entry is SubscriptionEntrySuccess) index,
        };
      } catch (error, stackTrace) {
        logger.e(
          'Failed to fetch subscription from $uri',
          error: error,
          stackTrace: stackTrace,
        );
        fetchError.value = error.toString();
        result.value = null;
      } finally {
        if (context.mounted) fetching.value = false;
      }
    }

    Future<void> importSelected() async {
      final outcome = result.value;
      if (outcome == null) return;
      isImporting.value = true;
      var imported = 0;
      try {
        final notifier = ref.read(
          singboxProxyProfilesRepositoryProvider.notifier,
        );
        for (final (index, entry) in outcome.entries.indexed) {
          if (!selection.value.contains(index)) continue;
          if (entry is! SubscriptionEntrySuccess) continue;

          final parsed = entry.imported;
          final spec = singboxProxyFormSpecs[parsed.type];
          if (spec == null) continue;
          await notifier.createProfile(
            name: parsed.name ?? 'Imported ${imported + 1}',
            type: parsed.type,
            configJson: spec.toConfigJson(parsed.values),
            secretJson: spec.toSecretJson(parsed.values),
          );
          imported++;
        }
      } finally {
        if (context.mounted) isImporting.value = false;
      }

      if (context.mounted) {
        showInfoMessage(context, 'Imported $imported profile(s)');
        Navigator.of(context).pop();
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Import Subscription')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: urlController,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(
              labelText: 'Subscription URL',
              hintText: 'https://example.com/sub',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supports the v2rayN-style format: a base64-encoded list of '
            'ss://, vless://, vmess://, trojan://, hysteria2://, tuic:// '
            'and similar URIs. Routing rules from the subscription are '
            'ignored — only proxy nodes are imported.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: !hasUrl || fetching.value ? null : fetch,
            icon: fetching.value
                ? const ButtonSpinner()
                : const Icon(Icons.cloud_download_outlined),
            label: const Text('Fetch'),
          ),
          if (fetchError.value != null) ...[
            const SizedBox(height: 12),
            Text(
              fetchError.value!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (result.value != null) ...[
            const SizedBox(height: 24),
            _ResultsSection(
              result: result.value!,
              selectedIndices: selection.value,
              isImporting: isImporting.value,
              onSelectionChanged: (next) => selection.value = next,
              onImport: importSelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultsSection extends StatelessWidget {
  final SubscriptionImportResult result;
  final Set<int> selectedIndices;
  final bool isImporting;
  final ValueChanged<Set<int>> onSelectionChanged;
  final Future<void> Function() onImport;

  const _ResultsSection({
    required this.result,
    required this.selectedIndices,
    required this.isImporting,
    required this.onSelectionChanged,
    required this.onImport,
  });

  @override
  Widget build(BuildContext context) {
    final successCount = result.successes.length;
    final failureCount = result.failures.length;

    void selectAll() {
      onSelectionChanged({
        for (final (index, entry) in result.entries.indexed)
          if (entry is SubscriptionEntrySuccess) index,
      });
    }

    void toggle(int index, bool selected) {
      final next = {...selectedIndices};
      if (selected) {
        next.add(index);
      } else {
        next.remove(index);
      }
      onSelectionChanged(next);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$successCount usable node(s)'
                '${failureCount > 0 ? ', $failureCount failed' : ''}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            TextButton(
              onPressed: successCount == 0 ? null : selectAll,
              child: const Text('Select all'),
            ),
            TextButton(
              onPressed: () => onSelectionChanged(const {}),
              child: const Text('Clear'),
            ),
          ],
        ),
        const Divider(),
        for (final (index, entry) in result.entries.indexed)
          _EntryTile(
            entry: entry,
            selected: selectedIndices.contains(index),
            onChanged: entry is SubscriptionEntrySuccess
                ? (checked) => toggle(index, checked ?? false)
                : null,
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: isImporting || selectedIndices.isEmpty ? null : onImport,
          icon: isImporting
              ? const ButtonSpinner()
              : const Icon(Icons.download_done),
          label: Text('Import ${selectedIndices.length} profile(s)'),
        ),
      ],
    );
  }
}

class _EntryTile extends StatelessWidget {
  final SubscriptionImportEntry entry;
  final bool selected;
  final ValueChanged<bool?>? onChanged;

  const _EntryTile({
    required this.entry,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return switch (entry) {
      SubscriptionEntrySuccess(:final imported) => CheckboxListTile(
        value: selected,
        onChanged: onChanged,
        title: Text(imported.name ?? entry.rawLine),
        subtitle: Text(
          imported.type.name,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        dense: true,
      ),
      SubscriptionEntryFailure(:final error) => ListTile(
        leading: Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
        ),
        title: Text(
          entry.rawLine,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          error is FormatException ? error.message : error.toString(),
        ),
        dense: true,
      ),
    };
  }
}
