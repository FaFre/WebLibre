import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:lensai/features/user/domain/providers.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/auto_suggest_text_field.dart';
import 'package:lensai/presentation/widgets/bang_icon.dart';
import 'package:lensai/presentation/widgets/speech_to_text_button.dart';

class SearchField extends HookConsumerWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final bool autofocus;
  final void Function(String)? onSubmitted;
  final bool showSuggestions;

  final BangData? activeBang;
  final bool showBangIcon;

  const SearchField({
    super.key,
    required this.textEditingController,
    required this.onSubmitted,
    required this.activeBang,
    required this.showSuggestions,
    this.focusNode,
    this.showBangIcon = true,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(incognitoModeEnabledProvider);

    final hasText = useListenableSelector(
      textEditingController,
      () => textEditingController.text.isNotEmpty,
    );

    final suggestion = useState<String?>(null);

    if (showSuggestions) {
      useListenableCallback(
        textEditingController,
        () async {
          if (textEditingController.text.isNotEmpty) {
            final result = await ref
                .read(engineSuggestionsProvider.notifier)
                .getAutocompleteSuggestion(textEditingController.text);

            suggestion.value = result;
          }
        },
      );
    }

    return AutoSuggestTextField(
      controller: textEditingController,
      suggestion: suggestion.value,
      enableIMEPersonalizedLearning: !incognitoEnabled,
      focusNode: focusNode,
      autofocus: autofocus,
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: (showBangIcon && activeBang != null)
            ? Padding(
                padding: const EdgeInsetsDirectional.all(12.0),
                child: UrlIcon(activeBang!.getUrl(''), iconSize: 24.0),
              )
            : null,
        label: const Text('Search'),
        // hintText: 'Ask anything...',
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: hasText
            ? IconButton(
                onPressed: () {
                  textEditingController.clear();
                },
                icon: const Icon(Icons.clear),
              )
            : SpeechToTextButton(
                onTextReceived: (data) {
                  textEditingController.text = data.toString();
                },
              ),
      ),
      onTapOutside: (focusNode != null)
          ? (event) {
              focusNode!.unfocus();
            }
          : null,
      onSubmitted: onSubmitted,
    );
  }
}
