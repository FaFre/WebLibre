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
import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';

class TrackingDetailsDialog extends HookWidget {
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

  List<bool> _initialSelection() {
    // Once a clean has actually been applied, mirror it so the checkboxes
    // describe the state the user is looking at. Before that — including on a
    // redirect wrapper, where none of the parameters are literally present —
    // fall back to recommending removal.
    final progress = urlCleanerProgress(currentUrl, result);
    if (progress.removed.isNotEmpty) {
      return result.removedParams
          .map((item) => progress.removed.contains(item))
          .toList();
    }

    return result.removedParams
        .map(
          (item) =>
              !allowReferralMarketing ||
              item.type != UrlCleanerMatchType.referralRule,
        )
        .toList();
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
    final items = result.removedParams;
    final selected = useState(_initialSelection());

    // Always rebuild from the URL the parameters were matched against —
    // subtracting from [currentUrl] could only ever remove more, so a
    // deselected parameter that a previous clean already stripped would have
    // no way back.
    var previewUrl = result.paramBaseUrl;
    for (var i = 0; i < items.length; i++) {
      if (selected.value[i]) {
        previewUrl = removeUrlCleanerMatch(previewUrl, items[i]);
      }
    }

    final canApply = onApplySelectedRemovals != null;
    final selectedCount = selected.value
        .where((isSelected) => isSelected)
        .length;
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
                child: FadingScroll(
                  fadingSize: 25,
                  builder: (context, controller) {
                    return ListView.separated(
                      controller: controller,
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          Divider(height: 1, color: colorScheme.outlineVariant),
                      itemBuilder: (context, index) {
                        final item = items[index];
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
                                if (item.type ==
                                    UrlCleanerMatchType.referralRule)
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
                          value: selected.value[index],
                          onChanged: canApply
                              ? (checked) {
                                  selected.value = [...selected.value]
                                    ..[index] = checked ?? false;
                                }
                              : null,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  '$selectedCount of ${items.length} selected for removal',
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
                  previewUrl,
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
                        onApplySelectedRemovals!(previewUrl);
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
