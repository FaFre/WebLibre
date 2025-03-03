import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:lensai/utils/form_validators.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

class EditUrlDialog extends HookWidget {
  final Uri initialUrl;

  const EditUrlDialog({required this.initialUrl});

  @override
  Widget build(BuildContext context) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final urlController = useTextEditingController(text: initialUrl.toString());

    return AlertDialog(
      title: const Text('Edit Address'),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: urlController,
          maxLines: null,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'Enter URL'),
          validator: (value) {
            return validateUrl(value, requireAuthority: false);
          },
        ),
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
                uri_parser.tryParseUrl(urlController.text, eagerParsing: true),
              );
            }
          },
          child: const Text('Edit'),
        ),
      ],
    );
  }
}
