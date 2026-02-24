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
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';

class TrackingDetailsDialog extends StatefulWidget {
  final String currentUrl;
  final UrlCleanerResult result;
  final bool allowReferralMarketing;
  final ValueChanged<String>? onApplySelectedRemovals;

  const TrackingDetailsDialog({
    super.key,
    required this.currentUrl,
    required this.result,
    required this.allowReferralMarketing,
    this.onApplySelectedRemovals,
  });

  @override
  State<TrackingDetailsDialog> createState() => _TrackingDetailsDialogState();
}

class _TrackingDetailsDialogState extends State<TrackingDetailsDialog> {
  late final List<RemovedParam> _items;
  late final List<bool> _selected;

  @override
  void initState() {
    super.initState();
    _items = widget.result.removedParams;
    _selected = _items.map(_isInitiallySelected).toList();
  }

  bool _isInitiallySelected(RemovedParam item) {
    if (!widget.allowReferralMarketing) return true;
    return item.type != UrlCleanerMatchType.referralRule;
  }

  String get _previewUrl {
    var url = widget.currentUrl;
    for (var i = 0; i < _items.length; i++) {
      if (_selected[i]) {
        url = removeUrlCleanerMatch(url, _items[i]);
      }
    }
    return url;
  }

  ({String key, String? value}) _splitMatch(String match) {
    final separatorIndex = match.indexOf('=');
    if (separatorIndex <= 0 || separatorIndex >= match.length - 1) {
      return (key: match, value: null);
    }
    return (
      key: match.substring(0, separatorIndex),
      value: match.substring(separatorIndex + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canApply = widget.onApplySelectedRemovals != null;
    final selectedCount = _selected.where((isSelected) => isSelected).length;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final subtitleColor = textTheme.bodySmall?.color;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Remove Tracking Parameters', style: textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'Select parameters to strip from this URL.',
                style: textTheme.bodyMedium?.copyWith(color: subtitleColor),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _items.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: colorScheme.outlineVariant),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    final display = _splitMatch(item.match);

                    return CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: colorScheme.primary,
                      checkColor: colorScheme.onPrimary,
                      title: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                display.key,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (item.type == UrlCleanerMatchType.referralRule)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'Referral marketing',
                                  style: TextStyle(
                                    color: colorScheme.onTertiaryContainer,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      subtitle: display.value == null
                          ? null
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                display.value!,
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                      value: _selected[index],
                      onChanged: canApply
                          ? (checked) {
                              setState(() {
                                _selected[index] = checked ?? false;
                              });
                            }
                          : null,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '$selectedCount of ${_items.length} selected for removal',
                  style: textTheme.bodySmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              Text(
                'Cleaned URL:',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: SelectableText(
                  _previewUrl,
                  style: textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(canApply ? 'Cancel' : 'Close'),
                  ),
                  if (canApply) ...[
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onApplySelectedRemovals!(_previewUrl);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                      child: const Text('Apply Changes'),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
