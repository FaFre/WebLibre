import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nullability/nullability.dart';
import 'package:weblibre/features/bangs/domain/providers/bangs.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_session.dart';
import 'package:weblibre/features/geckoview/features/search/domain/providers/engine_suggestions.dart';
import 'package:weblibre/presentation/hooks/listenable_callback.dart';
import 'package:weblibre/presentation/widgets/auto_suggest_text_field.dart';
import 'package:weblibre/utils/uri_parser.dart' as uri_parser;

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

            newUrl = defaultSearchBang?.getTemplateUrl(value);
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
