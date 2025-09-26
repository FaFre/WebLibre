import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

typedef DeleteDecision = ({bool delete, bool remember});

Future<DeleteDecision?> showDeleteFileDialog(
  BuildContext context,
  String filePath, {
  bool multiFileMode = false,
}) {
  return showDialog<DeleteDecision>(
    context: context,
    builder: (context) {
      final fileName = p.basename(filePath);

      return HookBuilder(
        builder: (context) {
          final remember = useState(false);

          return AlertDialog(
            title: const Text('Delete Downloaded File?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      const TextSpan(text: 'Would you like to delete '),
                      TextSpan(
                        text: fileName,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const TextSpan(text: ' from your device?'),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (multiFileMode) ...[
                  const SizedBox(height: 16),
                  CheckboxListTile.adaptive(
                    value: remember.value,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (value) {
                      remember.value = value!;
                    },
                    title: const Text('Remember my choice for remaining files'),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.pop<DeleteDecision>((
                    delete: false,
                    remember: remember.value,
                  ));
                },
                child: const Text('Keep File'),
              ),
              FilledButton(
                onPressed: () {
                  context.pop<DeleteDecision>((
                    delete: true,
                    remember: remember.value,
                  ));
                },
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Theme.of(context).colorScheme.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
    },
  );
}
