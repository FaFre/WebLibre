import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/features/bangs/domain/providers/bangs.dart';
import 'package:lensai/features/geckoview/domain/providers/tab_session.dart';
import 'package:lensai/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:lensai/presentation/hooks/listenable_callback.dart';
import 'package:lensai/presentation/widgets/auto_suggest_text_field.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

class AddressWithSuggestionsField extends HookConsumerWidget {
  const AddressWithSuggestionsField({
    super.key,
    required this.url,
    required this.incognitoEnabled,
  });

  final Uri url;
  final bool incognitoEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressTextController = useTextEditingController(
      text: url.toString(),
    );
    final addressTextFocusNode = useFocusNode();

    final suggestion = useState<String?>(null);

    useListenableCallback(addressTextController, () async {
      if (addressTextController.text.isNotEmpty) {
        final result = await ref
            .read(engineSuggestionsProvider.notifier)
            .getAutocompleteSuggestion(addressTextController.text);

        suggestion.value = result;
      }
    });

    return AutoSuggestTextField(
      controller: addressTextController,
      focusNode: addressTextFocusNode,
      suggestion: suggestion.value,
      enableIMEPersonalizedLearning: !incognitoEnabled,
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(
        label: Text('Address'),
        floatingLabelBehavior: FloatingLabelBehavior.always,
      ),
      onTap: () {
        if (!addressTextFocusNode.hasFocus) {
          // Select all text when the field is tapped
          addressTextController.selection = TextSelection(
            baseOffset: 0,
            extentOffset: addressTextController.text.length,
          );
        }
      },
      onSubmitted: (value) async {
        if (value.isNotEmpty) {
          var newUrl = uri_parser.tryParseUrl(value, eagerParsing: true);

          if (newUrl == null) {
            final defaultSearchBang = await ref.read(
              defaultSearchBangDataProvider.future,
            );

            newUrl = defaultSearchBang?.getUrl(value);
          }

          if (newUrl != null) {
            await ref
                .read(tabSessionProvider(tabId: null).notifier)
                .loadUrl(url: newUrl);

            if (context.mounted) {
              context.pop();
            }
          }
        }
      },
    );
  }
}
