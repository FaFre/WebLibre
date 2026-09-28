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
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/controllers/bottom_sheet.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/dialogs/clear_site_data_dialog.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart';

/// Section widget for clearing site data
class ClearSiteDataSection extends HookConsumerWidget {
  final Uri url;
  final ValueChanged<bool>? onExpandedChanged;

  const ClearSiteDataSection({
    required this.url,
    this.onExpandedChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isExpanded = useState(false);
    final isClearing = useState(false);
    final closeTabAfterClear = useState(false);
    final selectedTypes = useState<Set<ClearDataType>>({
      ClearDataType.allSiteData,
      ClearDataType.authSessions,
    });

    void toggleType(ClearDataType type) {
      final newTypes = Set<ClearDataType>.from(selectedTypes.value);
      if (newTypes.contains(type)) {
        newTypes.remove(type);
      } else {
        newTypes.add(type);

        if (type == ClearDataType.allSiteData) {
          newTypes.removeAll([
            ClearDataType.onlyCaches,
            ClearDataType.onlyCookies,
          ]);
        }
      }
      selectedTypes.value = newTypes;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.delete_sweep),
          title: Text(l10n.browser_clearSiteDataTitle),
          subtitle: Text(
            isExpanded.value
                ? l10n.browser_selectDataTypesToClear
                : l10n.browser_cookiesCacheAndSiteData,
          ),
          trailing: Icon(
            isExpanded.value ? Icons.expand_less : Icons.expand_more,
          ),
          onTap: () {
            final newValue = !isExpanded.value;
            isExpanded.value = newValue;
            onExpandedChanged?.call(newValue);
          },
        ),
        if (isExpanded.value) ...[
          _DataTypeCheckbox(
            label: l10n.browser_dataTypeAuthSessions,
            subtitle: l10n.browser_dataTypeAuthSessionsSubtitle,
            type: ClearDataType.authSessions,
            isSelected: selectedTypes.value.contains(
              ClearDataType.authSessions,
            ),
            onChanged: (selected) => toggleType(ClearDataType.authSessions),
          ),
          _DataTypeCheckbox(
            label: l10n.browser_dataTypeSiteData,
            subtitle: l10n.browser_dataTypeSiteDataSubtitle,
            type: ClearDataType.allSiteData,
            isSelected: selectedTypes.value.contains(ClearDataType.allSiteData),
            onChanged: (selected) => toggleType(ClearDataType.allSiteData),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _DataTypeCheckbox(
              label: l10n.browser_dataTypeCookies,
              subtitle: l10n.browser_dataTypeCookiesSubtitle,
              type: ClearDataType.onlyCookies,
              isSelected:
                  selectedTypes.value.contains(ClearDataType.allSiteData) ||
                  selectedTypes.value.contains(ClearDataType.onlyCookies),
              onChanged: selectedTypes.value.contains(ClearDataType.allSiteData)
                  ? null
                  : (selected) => toggleType(ClearDataType.onlyCookies),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: _DataTypeCheckbox(
              label: l10n.browser_dataTypeCachedFiles,
              subtitle: l10n.browser_dataTypeCachedFilesSubtitle,
              type: ClearDataType.onlyCaches,
              isSelected:
                  selectedTypes.value.contains(ClearDataType.allSiteData) ||
                  selectedTypes.value.contains(ClearDataType.onlyCaches),
              onChanged: selectedTypes.value.contains(ClearDataType.allSiteData)
                  ? null
                  : (selected) => toggleType(ClearDataType.onlyCaches),
            ),
          ),
          CheckboxListTile(
            title: Text(l10n.browser_closeTabAfterClearing),
            subtitle: Text(l10n.browser_closeTabAfterClearingSubtitle),
            value: closeTabAfterClear.value,
            onChanged: isClearing.value
                ? null
                : (value) => closeTabAfterClear.value = value ?? false,
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isClearing.value || selectedTypes.value.isEmpty
                    ? null
                    : () => _showConfirmationAndClear(
                        context,
                        ref,
                        isClearing,
                        selectedTypes.value,
                        closeTabAfterClear.value,
                      ),
                icon: isClearing.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.delete),
                label: Text(
                  isClearing.value
                      ? l10n.browser_clearingEllipsis
                      : l10n.browser_clearNow,
                ),
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
    Set<ClearDataType> selectedTypes,
    bool closeTabAfterClear,
  ) async {
    if (selectedTypes.isEmpty) {
      showErrorMessage(
        context,
        AppLocalizations.of(context).browser_selectAtLeastOneDataType,
      );
      return;
    }

    final confirmed = await showClearSiteDataDialog(
      context,
      host: url.host,
      formattedTypes: _formatTypes(AppLocalizations.of(context), selectedTypes),
    );

    if (confirmed == true && context.mounted) {
      isClearing.value = true;
      try {
        await _clearData(ref, selectedTypes, closeTabAfterClear);
        if (context.mounted) {
          showInfoMessage(
            context,
            AppLocalizations.of(context).browser_siteDataCleared,
          );
          ref.read(bottomSheetControllerProvider.notifier).requestDismiss();
        }
      } catch (e, s) {
        logger.e('Failed to clear site data', error: e, stackTrace: s);
        if (context.mounted) {
          showErrorMessage(
            context,
            AppLocalizations.of(
              context,
            ).browser_failedToClearSiteData(e.toString()),
          );
        }
      } finally {
        isClearing.value = false;
      }
    }
  }

  /// One bulleted line per selected type, in checkbox order, using the
  /// checkbox labels — a list rather than a joined phrase, so no language has
  /// to fit a translated "and" around them.
  String _formatTypes(AppLocalizations l10n, Set<ClearDataType> types) {
    return [
      if (types.contains(ClearDataType.authSessions))
        l10n.browser_dataTypeAuthSessions,
      if (types.contains(ClearDataType.allSiteData))
        l10n.browser_dataTypeSiteData,
      if (types.contains(ClearDataType.onlyCookies))
        l10n.browser_dataTypeCookies,
      if (types.contains(ClearDataType.onlyCaches))
        l10n.browser_dataTypeCachedFiles,
    ].map((label) => '• $label').join('\n');
  }

  Future<void> _clearData(
    WidgetRef ref,
    Set<ClearDataType> selectedTypes,
    bool closeTabAfterClear,
  ) async {
    final host = url.host;

    // Get base domain using PSL API (falls back to host on error)
    final pslApi = GeckoPublicSuffixListApi();
    final baseDomain = await pslApi.getPublicSuffixPlusOne(host);

    // Clear data via API
    final clearApi = GeckoDeleteBrowsingDataController();
    await clearApi.clearDataForHost(baseDomain, selectedTypes.toList());

    if (closeTabAfterClear) {
      // Close the tab instead of reloading it into the just-cleared state
      final tabId = ref.read(selectedTabProvider);
      if (tabId != null) {
        await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
      }
    } else {
      // Reload tab
      await ref.read(selectedTabSessionProvider).reload();
    }
  }
}

class _DataTypeCheckbox extends StatelessWidget {
  final String label;
  final String subtitle;
  final ClearDataType type;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

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
      onChanged: onChanged.mapNotNull(
        (onChanged) =>
            (value) => onChanged(value ?? false),
      ),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
