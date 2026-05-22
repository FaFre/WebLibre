import 'package:flutter/material.dart';

class WebSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final Future<void> Function(String query) onSubmitted;
  final VoidCallback onClear;

  const WebSearchField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 60,
      padding: const EdgeInsets.only(left: 20, right: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.search,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search the web...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                isDense: true,
              ),
              onSubmitted: enabled ? onSubmitted : null,
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Clear',
                onPressed: enabled ? onClear : null,
                icon: Icon(Icons.close, color: colorScheme.onSurfaceVariant),
              );
            },
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: enabled ? () => onSubmitted(controller.text) : null,
            style: FilledButton.styleFrom(
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
