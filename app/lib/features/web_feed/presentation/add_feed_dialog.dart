import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lensai/core/routing/routes.dart';
import 'package:lensai/features/web_feed/domain/providers/add_dialog_blocking.dart';
import 'package:lensai/utils/form_validators.dart';
import 'package:lensai/utils/uri_parser.dart' as uri_parser;

class AddFeedDialog extends HookConsumerWidget {
  final Uri? initialUri;

  const AddFeedDialog({super.key, required this.initialUri});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());

    final textController = useTextEditingController(
      text: initialUri?.toString(),
    );

    return AlertDialog(
      title: const Text('Add Feed'),
      // contentPadding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 16.0),
      content: Form(
        key: formKey,
        child: TextFormField(
          decoration: const InputDecoration(
            label: Text('URL'),
            hintText: 'https://example.com/feed',
            floatingLabelBehavior: FloatingLabelBehavior.always,
          ),
          controller: textController,
          keyboardType: TextInputType.url,
          validator: (value) {
            return validateUrl(value, onlyHttpProtocol: true);
          },
        ),
      ),
      actions: [
        if (initialUri != null)
          TextButton(
            onPressed: () {
              ref
                  .read(addFeedDialogBlockingProvider.notifier)
                  .ignore(initialUri!);
              context.pop();
            },
            child: const Text('Ignore'),
          ),
        TextButton(
          onPressed: () {
            context.pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState?.validate() == true) {
              FeedCreateRoute(
                feedId: uri_parser.tryParseUrl(textController.text)!,
              ).pushReplacement(context);
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
