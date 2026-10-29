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
import 'package:flutter/rendering.dart';
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
  final VoidCallback? onSuggestionDismiss;

  /// Called when a tap lands on the shown suggestion's completion — the part
  /// past the typed text.
  ///
  /// Where the tap lands decides, as in Firefox's inline autocomplete: a tap
  /// inside the typed text places the cursor there and dismisses the
  /// suggestion ([onSuggestionDismiss]), and a tap at the end of the typed
  /// text, where the cursor already sits, leaves the suggestion as it is. Only
  /// a tap on the completion itself says "take this".
  final VoidCallback? onSuggestionAccept;
  final bool enableSuggestions;
  final bool autocorrect;
  final GlobalKey? textFieldKey;

  /// Whether pressing the keyboard submit/enter button should automatically
  /// accept and complete an inline search suggestion. Defaults to false.
  final bool acceptSuggestionOnSubmit;

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
    this.onSuggestionDismiss,
    this.onSuggestionAccept,
    this.enableSuggestions = true,
    this.autocorrect = false,
    this.textFieldKey,
    this.acceptSuggestionOnSubmit = true,
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

    final hasSuggestionNotifier = useValueNotifier(false);

    useEffect(() {
      hasSuggestionNotifier.value = _suggestionHasMatch();
      return null;
    }, [suggestion, controller.text]);

    final dismissFormatter = useMemoized(
      () => _SuggestionDismissFormatter(
        hasSuggestionNotifier: hasSuggestionNotifier,
        onSuggestionDismiss: onSuggestionDismiss,
      ),
    );

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

    // A tap callback carries no position, so the pointer-down that started it
    // is kept to find out where it landed.
    final lastPointerDown = useRef<Offset?>(null);

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

                    if (!_suggestionHasMatch()) {
                      return const SizedBox.shrink();
                    }

                    return Text.rich(
                      maxLines: maxLines,
                      TextSpan(
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
        Listener(
          onPointerDown: (event) => lastPointerDown.value = event.position,
          child: TextFormField(
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
            enableSuggestions: enableSuggestions,
            autocorrect: autocorrect,
            onFieldSubmitted: onSubmitted.mapNotNull(
              (onSubmitted) => (value) {
                if (acceptSuggestionOnSubmit && _suggestionHasMatch()) {
                  onSubmitted(suggestion!);
                } else {
                  onSubmitted(value);
                }
              },
            ),
            inputFormatters: [dismissFormatter, ...?inputFormatters],
            enabled: enabled,
            cursorColor: cursorColor,
            enableIMEPersonalizedLearning:
                enableIMEPersonalizedLearning ?? true,
            onTapOutside: onTapOutside,
            onTap: () {
              final position = lastPointerDown.value;
              if (position != null && showSuggestion && _suggestionHasMatch()) {
                switch (_classifySuggestionTap(
                  textFieldKey,
                  position,
                  controller.text.length,
                )) {
                  case _SuggestionTap.completion:
                    onSuggestionAccept?.call();
                  case _SuggestionTap.typedText:
                    onSuggestionDismiss?.call();
                  case _SuggestionTap.end:
                    break;
                }
              }
              onTap?.call();
            },
          ),
        ),
      ],
    );
  }
}

enum _SuggestionTap { typedText, end, completion }

/// How far past the end of the typed text a tap still counts as a tap *at* the
/// end — placing the cursor where it already is — rather than on the
/// completion. A fingertip is not that precise.
const _suggestionEndSlop = kMinInteractiveDimension / 4;

/// Where a tap at [globalPosition] landed relative to the typed text of
/// [textLength] characters, in the field under [textFieldKey].
///
/// The completion is drawn as a continuation of the typed text, so anything
/// past the caret at its end, in the text's own direction, is on the
/// completion.
_SuggestionTap _classifySuggestionTap(
  GlobalKey textFieldKey,
  Offset globalPosition,
  int textLength,
) {
  final root = textFieldKey.currentContext?.findRenderObject();
  final editable = root == null ? null : _findRenderEditable(root);
  if (editable == null || !editable.hasSize) return _SuggestionTap.end;

  if (editable.getPositionForPoint(globalPosition).offset < textLength) {
    return _SuggestionTap.typedText;
  }

  final local = editable.globalToLocal(globalPosition);
  final start = editable.getLocalRectForCaret(const TextPosition(offset: 0));
  final end = editable.getLocalRectForCaret(TextPosition(offset: textLength));
  final pastEnd = end.left >= start.left
      ? local.dx - end.left
      : end.left - local.dx;

  return pastEnd > _suggestionEndSlop
      ? _SuggestionTap.completion
      : _SuggestionTap.end;
}

RenderEditable? _findRenderEditable(RenderObject node) {
  if (node is RenderEditable) return node;
  RenderEditable? found;
  node.visitChildren((child) {
    found ??= _findRenderEditable(child);
  });
  return found;
}

class _SuggestionDismissFormatter extends TextInputFormatter {
  final ValueNotifier<bool> hasSuggestionNotifier;
  final VoidCallback? onSuggestionDismiss;

  _SuggestionDismissFormatter({
    required this.hasSuggestionNotifier,
    this.onSuggestionDismiss,
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (hasSuggestionNotifier.value &&
        newValue.text.length < oldValue.text.length &&
        oldValue.selection.isCollapsed &&
        oldValue.selection.baseOffset == oldValue.text.length) {
      onSuggestionDismiss?.call();
      return oldValue;
    }
    return newValue;
  }
}
