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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/geckoview/domain/providers.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_state.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

enum _TranslatePhase { idle, submitting, processing }

Future<void> showTranslationBottomSheet(
  BuildContext context, {
  required String selectedTabId,
}) {
  unawaited(
    GeckoTabService().syncEvents(onTranslationStateChange: true).catchError((
      Object e,
      StackTrace s,
    ) {
      logger.w(
        'Failed to refresh translation state before opening sheet',
        error: e,
        stackTrace: s,
      );
    }),
  );

  return showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => TranslationBottomSheet(selectedTabId: selectedTabId),
  );
}

class TranslationBottomSheet extends HookConsumerWidget {
  final String selectedTabId;

  const TranslationBottomSheet({super.key, required this.selectedTabId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final tabState = ref.watch(tabStateProvider(selectedTabId));
    final translationState = tabState?.translationState;
    final engineState = ref.watch(translationEngineStateProvider);

    final fromLanguages = engineState?.fromLanguages?.nonNulls.toList() ?? [];
    final toLanguages = engineState?.toLanguages?.nonNulls.toList() ?? [];
    final suggestedFrom =
        translationState?.detectedLanguageCode ??
        translationState?.requestedFromLanguage;
    final suggestedTo =
        translationState?.userPreferredLanguageCode ??
        translationState?.requestedToLanguage;

    final selectedFrom = useState<String?>(suggestedFrom);
    final selectedTo = useState<String?>(suggestedTo);

    useEffect(() {
      if (selectedFrom.value == null && suggestedFrom != null) {
        selectedFrom.value = suggestedFrom;
      }
      if (selectedTo.value == null && suggestedTo != null) {
        selectedTo.value = suggestedTo;
      }
      return null;
    }, [suggestedFrom, suggestedTo]);

    final isTranslated = translationState?.isTranslated ?? false;
    final isProcessing = translationState?.isTranslateProcessing ?? false;
    final hasError = translationState?.hasError ?? false;
    final errorName = translationState?.translationErrorName;
    final translatePhase = useState(_TranslatePhase.idle);

    final effectiveProcessing =
        isProcessing || translatePhase.value != _TranslatePhase.idle;

    useEffect(() {
      switch (translatePhase.value) {
        case _TranslatePhase.idle:
          return null;
        case _TranslatePhase.submitting:
          if (isProcessing) {
            translatePhase.value = _TranslatePhase.processing;
          } else if (hasError) {
            translatePhase.value = _TranslatePhase.idle;
          }
          return null;
        case _TranslatePhase.processing:
          if (!isProcessing && (isTranslated || hasError)) {
            translatePhase.value = _TranslatePhase.idle;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.pop(context);
            });
          }
          // Otherwise stay in processing — transient stop during retranslate.
          return null;
      }
    }, [isProcessing, isTranslated, hasError, translatePhase.value]);

    final canTranslate =
        selectedFrom.value != null &&
        selectedTo.value != null &&
        selectedFrom.value != selectedTo.value &&
        !effectiveProcessing;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.translate, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Translate Page',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (effectiveProcessing)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // From language dropdown
            _LanguageDropdown(
              label: 'From',
              languages: fromLanguages,
              selectedCode: selectedFrom.value,
              onChanged: effectiveProcessing
                  ? null
                  : (code) => selectedFrom.value = code,
            ),
            const SizedBox(height: 12),

            // To language dropdown
            _LanguageDropdown(
              label: 'To',
              languages: toLanguages,
              selectedCode: selectedTo.value,
              onChanged: effectiveProcessing
                  ? null
                  : (code) => selectedTo.value = code,
            ),
            const SizedBox(height: 16),

            // Error display
            if (hasError && errorName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Translation error: $errorName',
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ),

            // Action buttons
            Row(
              children: [
                if (isTranslated)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: effectiveProcessing
                          ? null
                          : () async {
                              try {
                                await ref
                                    .read(
                                      tabSessionProvider(
                                        tabId: selectedTabId,
                                      ).notifier,
                                    )
                                    .translateRestore();
                              } catch (e) {
                                if (context.mounted) {
                                  ui_helper.showErrorMessage(
                                    context,
                                    'Failed to restore page',
                                  );
                                }
                              }
                              if (context.mounted) Navigator.pop(context);
                            },
                      child: const Text('Show Original'),
                    ),
                  ),
                if (isTranslated) const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canTranslate
                        ? () async {
                            translatePhase.value = _TranslatePhase.submitting;
                            try {
                              await ref
                                  .read(
                                    tabSessionProvider(
                                      tabId: selectedTabId,
                                    ).notifier,
                                  )
                                  .translate(
                                    fromLanguage: selectedFrom.value!,
                                    toLanguage: selectedTo.value!,
                                  );
                            } catch (e) {
                              translatePhase.value = _TranslatePhase.idle;
                              if (context.mounted) {
                                ui_helper.showErrorMessage(
                                  context,
                                  'Failed to translate page',
                                );
                              }
                            }
                          }
                        : null,
                    child: Text(isTranslated ? 'Retranslate' : 'Translate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageDropdown extends StatelessWidget {
  final String label;
  final List<TranslationLanguage> languages;
  final String? selectedCode;
  final ValueChanged<String?>? onChanged;

  const _LanguageDropdown({
    required this.label,
    required this.languages,
    required this.selectedCode,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure selectedCode exists in the list, otherwise use null
    final effectiveSelection = languages.any((l) => l.code == selectedCode)
        ? selectedCode
        : null;

    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      initialValue: effectiveSelection,
      isExpanded: true,
      items: languages
          .map(
            (lang) => DropdownMenuItem(
              value: lang.code,
              child: Text(lang.localizedDisplayName),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}
