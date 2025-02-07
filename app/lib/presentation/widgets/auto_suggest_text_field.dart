import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lensai/extensions/nullable.dart';

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
  final ValueChanged<String>? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final FocusNode? focusNode;
  final Color? cursorColor;
  final Color? suggestionHighlightColor;
  final bool? enableIMEPersonalizedLearning;
  final TapRegionCallback? onTapOutside;

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
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.focusNode,
    this.cursorColor,
    this.suggestionHighlightColor,
    this.enableIMEPersonalizedLearning = true,
    this.onTapOutside,
  });

  bool _suggestionHasMatch() =>
      suggestion != null &&
      controller.text.isNotEmpty &&
      suggestion!.startsWith(controller.text);

  @override
  Widget build(BuildContext context) {
    final baseDecoration = decoration ?? const InputDecoration();

    return Stack(
      children: [
        if (suggestion != null)
          AbsorbPointer(
            child: TextField(
              decoration: baseDecoration.copyWith(
                floatingLabelBehavior: FloatingLabelBehavior.never,
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

                    return RichText(
                      text: TextSpan(
                        text: text,
                        style: (style ?? Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(color: Colors.transparent),
                        children: <TextSpan>[
                          TextSpan(
                            text: suggestion!.substring(text.length),
                            style: TextStyle(
                              height: 1.2,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              backgroundColor: suggestionHighlightColor ??
                                  Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.40),
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
        TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: baseDecoration.copyWith(
            label: baseDecoration.label ?? const Text(''),
            floatingLabelBehavior: baseDecoration.floatingLabelBehavior ??
                FloatingLabelBehavior.never,
          ),
          style: style,
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
          onSubmitted: onSubmitted.mapNotNull(
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
        ),
      ],
    );
  }
}
