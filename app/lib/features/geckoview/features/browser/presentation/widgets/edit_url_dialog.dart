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
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/features/geckoview/features/search/presentation/widgets/clipboard_fill.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/auto_suggest_text_field.dart';
import 'package:weblibre/utils/form_validators.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

class EditUrlDialog extends HookConsumerWidget {
  final Uri initialUrl;

  const EditUrlDialog({required this.initialUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final addressTextController = useTextEditingController(
      text: initialUrl.toString(),
    );

    return AlertDialog(
      title: const Text('Edit Address'),
      content: HookBuilder(
        builder: (context) {
          final addressTextFocusNode = useFocusNode();

          final suggestion = useState<String?>(null);
          final lastText = useRef<String>(addressTextController.text);

          useListenableCallback(addressTextController, () async {
            if (addressTextController.text.isNotEmpty) {
              if (suggestion.value.isNotEmpty &&
                  lastText.value.length > 1 &&
                  addressTextController.text ==
                      lastText.value.substring(0, lastText.value.length - 1)) {
                suggestion.value = null;
                addressTextController.text = lastText.value;
              } else if (addressTextController.text != lastText.value) {
                final result = await ref
                    .read(engineSuggestionsProvider.notifier)
                    .getAutocompleteSuggestion(addressTextController.text);

                suggestion.value = result;
              }
            }

            lastText.value = addressTextController.text;
          });

          return Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AutoSuggestTextField(
                  controller: addressTextController,
                  focusNode: addressTextFocusNode,
                  suggestion: suggestion.value,
                  // enableIMEPersonalizedLearning: !incognitoEnabled,
                  maxLines: null,
                  keyboardType: TextInputType.url,
                  decoration: const InputDecoration(hintText: 'Enter URL'),
                  onTap: () {
                    if (!addressTextFocusNode.hasFocus) {
                      // Select all text when the field is tapped
                      addressTextController.selection = TextSelection(
                        baseOffset: 0,
                        extentOffset: addressTextController.text.length,
                      );
                    }
                  },
                  validator: (value) {
                    return validateUrl(value, requireAuthority: false);
                  },
                ),
                ClipboardFillLink(controller: addressTextController),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() ?? false) {
              Navigator.of(context).pop(
                uri_parser.tryParseUrl(
                  addressTextController.text,
                  eagerParsing: true,
                ),
              );
            }
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
