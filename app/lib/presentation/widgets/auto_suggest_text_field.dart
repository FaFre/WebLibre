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
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/extensions/string.dart';
import 'package:weblibre/utils/text_field_line_count.dart';

class AutoSuggestTextField extends HookWidget {
  final TextEditingController controller;
  final String? suggestion;
  final TextStyle? style;
  final TextStyle? labelStyle;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final bool autofocus;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onEditingComplete;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final Color? suggestionHighlightColor;
  final bool? enableIMEPersonalizedLearning;
  final TapRegionCallback? onTapOutside;
  final VoidCallback? onTap;
  final bool autocorrect;
  final GlobalKey? textFieldKey;

  const AutoSuggestTextField({
    super.key,
    required this.controller,
    this.suggestion,
    this.style,
    this.labelStyle,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofocus = false,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.onChanged,
    this.onEditingComplete,
    this.validator,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.focusNode,
    this.cursorColor,
    this.suggestionHighlightColor,
    this.enableIMEPersonalizedLearning = true,
    this.onTapOutside,
    this.onTap,
    this.autocorrect = false,
    this.textFieldKey,
  });

  bool _suggestionHasMatch() =>
      suggestion != null &&
      controller.text.isNotEmpty &&
      suggestion!.startsWithIgnoreCase(controller.text);

  @override
  Widget build(BuildContext context) {
    final textFieldKey =
        this.textFieldKey ?? useMemoized<GlobalKey>(() => GlobalKey());

    final effectiveStyle = style ?? Theme.of(context).textTheme.bodyLarge!;

    final showSuggestion = useListenableSelector(controller, () {
      if (maxLines != 1) {
        final lines = getTextFieldLineCount(
          textFieldKey,
          controller.text,
          effectiveStyle,
        );
        final suggestionLines = suggestion.mapNotNull(
          (suggestion) =>
              getTextFieldLineCount(textFieldKey, suggestion, effectiveStyle),
        );

        return lines == 1 && suggestionLines == 1;
      }

      return true;
    });

    final baseDecoration = decoration ?? const InputDecoration();

    return Stack(
      children: [
        if (showSuggestion && suggestion != null)
          AbsorbPointer(
            child: TextField(
              minLines: minLines,
              maxLines: maxLines,
              maxLength: maxLength,
              decoration: baseDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                border: InputBorder.none,
                suffixIcon: baseDecoration.suffixIcon.mapNotNull(
                  (_) => const SizedBox.square(dimension: 48),
                ),
                prefixIcon: baseDecoration.prefixIcon.mapNotNull(
                  (_) => const SizedBox.square(dimension: 48),
                ),
                label: HookBuilder(
                  builder: (context) {
                    final text = useListenableSelector(
                      controller,
                      () => controller.text,
                    );

                    useEffect(() {
                      TextSelection? lastSelection;

                      void handleSelectionChange() {
                        if (lastSelection != controller.selection) {
                          lastSelection = controller.selection;
                          if (lastSelection!.start != lastSelection!.end) {
                            if (_suggestionHasMatch()) {
                              controller.value = controller.value.copyWith(
                                text: suggestion,
                                selection: lastSelection!.expandTo(
                                  TextPosition(offset: suggestion!.length),
                                ),
                              );
                            }
                          }
                        }
                      }

                      controller.addListener(handleSelectionChange);
                      return () =>
                          controller.removeListener(handleSelectionChange);
                    });

                    if (!_suggestionHasMatch()) {
                      return const SizedBox.shrink();
                    }

                    //TODO: maybe change to Text.rich
                    return RichText(
                      maxLines: maxLines,
                      text: TextSpan(
                        text: text,
                        style: effectiveStyle.copyWith(
                          color: Colors.transparent,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text: suggestion!.substring(text.length),
                            style: effectiveStyle.copyWith(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              backgroundColor:
                                  suggestionHighlightColor ??
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.40),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                alignLabelWithHint: true,
              ),
            ),
          ),
        TextFormField(
          key: textFieldKey,
          controller: controller,
          focusNode: focusNode,
          decoration: baseDecoration.copyWith(
            label: baseDecoration.label ?? const Text(''),
            floatingLabelBehavior:
                baseDecoration.floatingLabelBehavior ??
                FloatingLabelBehavior.never,
          ),
          style: effectiveStyle,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          textCapitalization: textCapitalization,
          autofocus: autofocus,
          obscureText: obscureText,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          validator: validator,
          autocorrect: autocorrect,
          onFieldSubmitted: onSubmitted.mapNotNull(
            (onSubmitted) => (value) {
              if (_suggestionHasMatch()) {
                onSubmitted(suggestion!);
              } else {
                onSubmitted(value);
              }
            },
          ),
          inputFormatters: inputFormatters,
          enabled: enabled,
          cursorColor: cursorColor,
          enableIMEPersonalizedLearning: enableIMEPersonalizedLearning ?? true,
          onTapOutside: onTapOutside,
          onTap: onTap,
        ),
      ],
    );
  }
}
