import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/data/models/bang_data.dart';
import 'package:lensai/features/bangs/presentation/widgets/bang_icon.dart';
import 'package:lensai/features/user/domain/repositories/settings.dart';
import 'package:lensai/presentation/widgets/speech_to_text_button.dart';

class SearchField extends HookConsumerWidget {
  final TextEditingController textEditingController;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;

  final BangData? activeBang;
  final bool showBangIcon;

  const SearchField({
    super.key,
    required this.textEditingController,
    required this.onFieldSubmitted,
    required this.activeBang,
    this.focusNode,
    this.showBangIcon = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incognitoEnabled = ref.watch(
      settingsRepositoryProvider.select(
        (value) => value.incognitoMode,
      ),
    );

    final hasText = useListenableSelector(
      textEditingController,
      () => textEditingController.text.isNotEmpty,
    );

    return TextFormField(
      controller: textEditingController,
      enableIMEPersonalizedLearning: !incognitoEnabled,
      focusNode: focusNode,
      decoration: InputDecoration(
        border: InputBorder.none,
        prefixIcon: (showBangIcon && activeBang != null)
            ? Padding(
                padding: const EdgeInsetsDirectional.all(12.0),
                child: BangIcon(activeBang!, iconSize: 24.0),
              )
            : null,
        label: const Text('Search'),
        hintText: 'Ask anything...',
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
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
