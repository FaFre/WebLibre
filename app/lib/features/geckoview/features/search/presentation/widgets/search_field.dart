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
import 'package:weblibre/features/user/domain/providers.dart';
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

  final BangData? activeBang;
  final bool showBangIcon;

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
    this.autofocus = false,
    this.textFieldKey,
    this.hint,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(incognitoModeEnabledProvider);

    final hasText = useListenableSelector(
      textEditingController,
      () => textEditingController.text.isNotEmpty,
    );

    final safeFocusNode = focusNode ?? useFocusNode();

    final suggestion = useState<String?>(null);
    final lastText = useRef<String>(textEditingController.text);

    if (showSuggestions) {
      useOnListenableChangeSelector(
        textEditingController,
        () => textEditingController.text,
        () async {
          final text = textEditingController.text;
          if (text.isEmpty) {
            suggestion.value = null;
          } else {
            final isDeleting = text.length < lastText.value.length;

            if (isDeleting) {
              suggestion.value = null;
            } else {
              await ref
                  .read(engineSuggestionsProvider.notifier)
                  .getAutocompleteSuggestion(text)
                  .then((result) {
                    suggestion.value = result;
                  });
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
        suggestion: suggestion.value,
        enableIMEPersonalizedLearning: !incognitoEnabled,
        focusNode: safeFocusNode,
        maxLines: maxLines,
        textFieldKey: textFieldKey,
        textInputAction: (maxLines == null || maxLines! > 1)
            ? TextInputAction.done
            : null,
        minLines: minLines,
        autofocus: autofocus,
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
                      textEditingController.clear();
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
          if (suggestion.value != null) {
            unawaited(HapticFeedback.lightImpact());

            textEditingController.text = suggestion.value!;
            textEditingController.selection = TextSelection.collapsed(
              offset: suggestion.value!.length,
            );

            suggestion.value = null;
          }
        },
      ),
    );
  }
}
