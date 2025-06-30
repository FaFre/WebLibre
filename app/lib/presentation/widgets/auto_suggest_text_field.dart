import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:nullability/nullability.dart';

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
  });

  bool _suggestionHasMatch() =>
      suggestion != null &&
      controller.text.isNotEmpty &&
      suggestion!.startsWith(controller.text);

  static int _getLineCountUsingBoxes(
    String text,
    TextStyle style,
    double maxWidth,
  ) {
    final textSpan = TextSpan(text: text, style: style);

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: maxWidth);

    // Select all text
    final selection = TextSelection(baseOffset: 0, extentOffset: text.length);

    // Each box represents one line
    final lines = textPainter.getBoxesForSelection(selection);
    return lines.length;
  }

  @override
  Widget build(BuildContext context) {
    final textFieldKey = useMemoized(() => GlobalKey());

    final showSuggestion = useListenableSelector(controller, () {
      if (maxLines != 1) {
        final box = textFieldKey.currentContext?.findRenderObject();
        if (box case final RenderBox box) {
          final width = box.size.width;

          final lines = _getLineCountUsingBoxes(
            controller.text,
            style ?? Theme.of(context).textTheme.bodyLarge!,
            width,
          );

          final suggestionLines = suggestion.mapNotNull(
            (suggestion) => _getLineCountUsingBoxes(
              suggestion,
              style ?? Theme.of(context).textTheme.bodyLarge!,
              width,
            ),
          );

          return lines == 1 && suggestionLines == 1;
        }
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
                      maxLines: maxLines,
                      text: TextSpan(
                        text: text,
                        style: (style ?? Theme.of(context).textTheme.bodyLarge)
                            ?.copyWith(color: Colors.transparent),
                        children: <TextSpan>[
                          TextSpan(
                            text: suggestion!.substring(text.length),
                            style: TextStyle(
                              height: 1.2,
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
          validator: validator,
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
