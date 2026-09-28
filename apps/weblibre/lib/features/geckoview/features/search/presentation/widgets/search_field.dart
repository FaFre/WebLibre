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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/search_source_policy.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/hooks/on_listenable_change_selector.dart';
import 'package:weblibre/presentation/widgets/auto_suggest_text_field.dart';
import 'package:weblibre/presentation/widgets/qr_scanner_button.dart';
import 'package:weblibre/presentation/widgets/speech_to_text_button.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class SearchField extends HookConsumerWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final Widget? label;
  final bool autofocus;
  final void Function(String)? onSubmitted;
  final bool showSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool unfocusOnTapOutside;
  final GlobalKey? textFieldKey;
  final Widget? hint;
  final bool privateMode;

  final BangData? activeBang;
  final bool showBangIcon;

  /// Whether [activeBang] was explicitly chosen for this search — a provider
  /// chip or an inline `!bang` — rather than being the standing default.
  ///
  /// Picking a provider states the intent to *search*, so the inline URL
  /// completion is no longer what submitting should mean. The suggestion stays
  /// on screen and can still be taken by tapping it; it just no longer wins by
  /// default when the user hits enter.
  final bool explicitBangSelected;

  /// Overrides the clear (`x`) button behaviour. When null, the button just
  /// clears the text. When provided, the callback decides what to do (e.g.
  /// restore a previous value first, then clear on the next press).
  final VoidCallback? onClearPressed;

  const SearchField({
    super.key,
    required this.textEditingController,
    required this.onSubmitted,
    required this.activeBang,
    required this.showSuggestions,
    required this.label,
    this.focusNode,
    this.maxLines = 1,
    this.minLines = 1,
    this.unfocusOnTapOutside = true,
    this.showBangIcon = true,
    this.explicitBangSelected = false,
    this.autofocus = false,
    this.textFieldKey,
    this.hint,
    this.onClearPressed,
    this.privateMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final acceptSuggestionOnSubmit = ref.watch(
      generalSettingsWithDefaultsProvider.select(
        (s) => s.acceptSuggestionOnSubmit,
      ),
    );

    final hasText = useListenableSelector(
      textEditingController,
      () => textEditingController.text.isNotEmpty,
    );

    final safeFocusNode = focusNode ?? useFocusNode();

    // The latest completion, with whether saved history was allowed to supply
    // it. Kept even when it can no longer be shown, so nothing has to be
    // cleared in reaction to a policy change.
    final completion = useState<({String text, bool usedHistory})?>(null);
    final lastText = useRef<String>(textEditingController.text);

    // A completion that may have come from saved history is hidden whenever
    // history is off limits. The check is made here, at build time, rather
    // than when the lookup finishes: switching to a private tab must hide one
    // already on screen, and one still in flight that lands after the switch.
    final savedHistoryAllowed = ref.watch(
      searchSourcePolicyProvider(
        privateMode: privateMode,
      ).select((policy) => policy.savedHistory),
    );
    final suggestion = switch (completion.value) {
      (:final text, :final usedHistory)
          when !usedHistory || savedHistoryAllowed =>
        text,
      _ => null,
    };

    if (showSuggestions) {
      useOnListenableChangeSelector(
        textEditingController,
        () => textEditingController.text,
        () async {
          final text = textEditingController.text;
          if (text.isEmpty) {
            completion.value = null;
          } else {
            final isDeleting = text.length < lastText.value.length;

            if (isDeleting) {
              completion.value = null;
            } else {
              final includeHistory = ref
                  .read(searchSourcePolicyProvider(privateMode: privateMode))
                  .savedHistory;

              final result = await ref
                  .read(engineSuggestionsProvider.notifier)
                  .getAutocompleteSuggestion(
                    text,
                    includeHistory: includeHistory,
                  );

              // Lookups finish out of order; one for text the user has since
              // typed past must not replace the newer completion.
              if (context.mounted && textEditingController.text == text) {
                completion.value = result == null
                    ? null
                    : (text: result, usedHistory: includeHistory);
              }
            }
          }

          lastText.value = text;
        },
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: AutoSuggestTextField(
        controller: textEditingController,
        suggestion: suggestion,
        acceptSuggestionOnSubmit:
            acceptSuggestionOnSubmit && !explicitBangSelected,
        enableSuggestions: true,
        autocorrect: false,
        enableIMEPersonalizedLearning: !privateMode,
        focusNode: safeFocusNode,
        maxLines: maxLines,
        textFieldKey: textFieldKey,
        keyboardType: TextInputType.webSearch,
        textInputAction: (maxLines == null || maxLines! > 1)
            ? TextInputAction.done
            : TextInputAction.send,
        minLines: minLines,
        autofocus: autofocus,
        onSuggestionDismiss: () {
          completion.value = null;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsetsDirectional.fromSTEB(12, 12, 0, 12),
          prefixIcon: (showBangIcon && activeBang != null)
              ? Padding(
                  padding: const EdgeInsetsDirectional.all(12.0),
                  child: UrlIcon([activeBang!.getDefaultUrl()], iconSize: 24.0),
                )
              : null,
          label: label,
          hint: hint,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIconConstraints: const BoxConstraints(minHeight: 48),
          suffixIcon: hasText
              ? Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: IconButton(
                    onPressed: () {
                      if (onClearPressed != null) {
                        onClearPressed!();
                      } else {
                        textEditingController.clear();
                      }
                    },
                    icon: const Icon(Icons.clear),
                  ),
                )
              : Padding(
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      QrScannerButton(
                        onScanResult: (scanResult) {
                          if (scanResult?.code != null) {
                            textEditingController.text = scanResult!.code!;
                          }
                        },
                      ),
                      SpeechToTextButton(
                        onTextReceived: (data) {
                          textEditingController.text = data;
                        },
                      ),
                    ],
                  ),
                ),
        ),
        onTapOutside: unfocusOnTapOutside
            ? (event) {
                safeFocusNode.unfocus();
              }
            : null,
        onSubmitted: onSubmitted,
        onTap: () {
          if (suggestion != null) {
            unawaited(HapticFeedback.lightImpact());

            textEditingController.text = suggestion;
            textEditingController.selection = TextSelection.collapsed(
              offset: suggestion.length,
            );

            completion.value = null;
          }
        },
      ),
    );
  }
}
