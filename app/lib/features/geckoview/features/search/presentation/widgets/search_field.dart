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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/bangs/data/models/bang_data.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/user/domain/providers.dart';
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
  final VoidCallback? onTap;
  final bool unfocusOnTapOutside;
  final GlobalKey? textFieldKey;

  final BangData? activeBang;
  final bool showBangIcon;

  const SearchField({
    super.key,
    required this.textEditingController,
    required this.onSubmitted,
    required this.activeBang,
    required this.showSuggestions,
    this.label,
    this.focusNode,
    this.maxLines = 1,
    this.minLines = 1,
    this.onTap,
    this.unfocusOnTapOutside = true,
    this.showBangIcon = true,
    this.autofocus = false,
    this.textFieldKey,
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
      useOnListenableChange(textEditingController, () async {
        if (textEditingController.text.isNotEmpty) {
          if (suggestion.value.isNotEmpty &&
              lastText.value.length > 1 &&
              textEditingController.text ==
                  lastText.value.substring(0, lastText.value.length - 1)) {
            suggestion.value = null;
            textEditingController.text = lastText.value;
          } else if (textEditingController.text != lastText.value) {
            final result = await ref
                .read(engineSuggestionsProvider.notifier)
                .getAutocompleteSuggestion(textEditingController.text);

            suggestion.value = result;
          }
        }

        lastText.value = textEditingController.text;
      });
    }

    return AutoSuggestTextField(
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
        prefixIcon: (showBangIcon && activeBang != null)
            ? Padding(
                padding: const EdgeInsetsDirectional.all(12.0),
                child: UrlIcon([activeBang!.getDefaultUrl()], iconSize: 24.0),
              )
            : null,
        label: label ?? const Text('Search'),
        // hintText: 'Ask anything...',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: hasText
            ? IconButton(
                onPressed: () {
                  textEditingController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : Row(
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
      onTapOutside: unfocusOnTapOutside
          ? (event) {
              safeFocusNode.unfocus();
            }
          : null,
      onSubmitted: onSubmitted,
      onTap: onTap,
    );
  }
}
