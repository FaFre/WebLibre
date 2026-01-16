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
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/site_permissions_provider.dart';

/// Section widget for clearing site data
class ClearSiteDataSection extends HookConsumerWidget {
  final Uri url;

  const ClearSiteDataSection({
    required this.url,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = useState(false);
    final isClearing = useState(false);
    final selectedTypes = ref.watch(selectedClearDataTypesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: const Text('Clear Site Data'),
          subtitle: Text(
            isExpanded.value
                ? 'Select data types to clear'
                : 'Cookies, cache, and site data',
          ),
          trailing: Icon(
            isExpanded.value ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () => isExpanded.value = !isExpanded.value,
        ),
        if (isExpanded.value) ...[
          _DataTypeCheckbox(
            label: 'Cookies',
            subtitle: 'Login tokens, preferences, tracking data',
            type: ClearDataType.cookies,
            isSelected: selectedTypes.contains(ClearDataType.cookies),
            onChanged: (selected) {
              ref.read(selectedClearDataTypesProvider.notifier).toggle(ClearDataType.cookies);
            },
          ),
          _DataTypeCheckbox(
            label: 'Cached Files',
            subtitle: 'Images, scripts, stylesheets',
            type: ClearDataType.allCaches,
            isSelected: selectedTypes.contains(ClearDataType.allCaches),
            onChanged: (selected) {
              ref.read(selectedClearDataTypesProvider.notifier).toggle(ClearDataType.allCaches);
            },
          ),
          _DataTypeCheckbox(
            label: 'Site Data',
            subtitle: 'Offline storage, databases, local files',
            type: ClearDataType.allSiteData,
            isSelected: selectedTypes.contains(ClearDataType.allSiteData),
            onChanged: (selected) {
              ref.read(selectedClearDataTypesProvider.notifier).toggle(ClearDataType.allSiteData);
            },
          ),
          _DataTypeCheckbox(
            label: 'Auth Sessions',
            subtitle: 'Saved logins, active sessions',
            type: ClearDataType.authSessions,
            isSelected: selectedTypes.contains(ClearDataType.authSessions),
            onChanged: (selected) {
              ref.read(selectedClearDataTypesProvider.notifier).toggle(ClearDataType.authSessions);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isClearing.value || selectedTypes.isEmpty
                    ? null
                    : () => _showConfirmationAndClear(context, ref, isClearing),
                icon: isClearing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete),
                label: Text(isClearing.value ? 'Clearing...' : 'Clear Now'),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showConfirmationAndClear(
    BuildContext context,
    WidgetRef ref,
    ValueNotifier<bool> isClearing,
  ) async {
    final selectedTypes = ref.read(selectedClearDataTypesProvider);
    if (selectedTypes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one data type')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning),
        title: const Text('Clear Site Data'),
        content: Text(
          'This will clear ${_formatTypes(selectedTypes)} for ${url.host}.\n\n'
          'You may need to log in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      isClearing.value = true;
      try {
        await _clearData(ref, selectedTypes);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Site data cleared')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to clear site data: $e')),
          );
        }
      } finally {
        isClearing.value = false;
      }
    }
  }

  String _formatTypes(Set<ClearDataType> types) {
    final labels = types.map((t) {
      switch (t) {
        case ClearDataType.cookies:
          return 'cookies';
        case ClearDataType.allCaches:
          return 'cached files';
        case ClearDataType.allSiteData:
          return 'site data';
        case ClearDataType.authSessions:
          return 'auth sessions';
      }
    }).toList();

    if (labels.length == 1) return labels.first;
    if (labels.length == 2) return '${labels[0]} and ${labels[1]}';
    return '${labels.sublist(0, labels.length - 1).join(', ')}, and ${labels.last}';
  }

  Future<void> _clearData(WidgetRef ref, Set<ClearDataType> selectedTypes) async {
    final host = url.host;

    // Get base domain using PSL API (falls back to host on error)
    final pslApi = GeckoPublicSuffixListApi();
    final baseDomain = await pslApi.getPublicSuffixPlusOne(host);

    // Clear data via API
    final clearApi = GeckoDeleteBrowsingDataController();
    await clearApi.clearDataForHost(baseDomain, selectedTypes.toList());

    // Reload tab
    await ref.read(selectedTabSessionProvider).reload();
  }
}

class _DataTypeCheckbox extends StatelessWidget {
  final String label;
  final String subtitle;
  final ClearDataType type;
  final bool isSelected;
  final ValueChanged<bool> onChanged;

  const _DataTypeCheckbox({
    required this.label,
    required this.subtitle,
    required this.type,
    required this.isSelected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      subtitle: Text(subtitle),
      value: isSelected,
      onChanged: (value) => onChanged(value ?? false),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
