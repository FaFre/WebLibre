/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:weblibre/features/gestures/data/models/gesture_action.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_action_picker.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_stroke_view.dart';

typedef GestureBindingResult = ({GestureStroke stroke, GestureAction action});

/// Opens the gesture binding editor as a full-screen page.
///
/// Returns the configured stroke + action, or null if dismissed. Editing an
/// existing binding is supported by passing [initialStroke]/[initialAction].
///
/// [existingBindings] is the current stroke-key → action map, used to warn
/// before a new stroke would overwrite an already-assigned one.
Future<GestureBindingResult?> showGestureBindingEditor(
  BuildContext context, {
  GestureStroke? initialStroke,
  GestureAction? initialAction,
  Map<String, GestureAction> existingBindings = const {},
  int maxFingers = 1,
}) {
  return Navigator.of(context).push<GestureBindingResult>(
    MaterialPageRoute<GestureBindingResult>(
      builder: (context) => _GestureBindingEditor(
        initialStroke: initialStroke,
        initialAction: initialAction,
        existingBindings: existingBindings,
        maxFingers: maxFingers,
      ),
    ),
  );
}

class _GestureBindingEditor extends HookWidget {
  final GestureStroke? initialStroke;
  final GestureAction? initialAction;
  final Map<String, GestureAction> existingBindings;
  final int maxFingers;

  const _GestureBindingEditor({
    required this.initialStroke,
    required this.initialAction,
    required this.existingBindings,
    required this.maxFingers,
  });

  @override
  Widget build(BuildContext context) {
    final action = useState(initialAction ?? GestureAction.values.first);
    final startPosition = useState(
      initialStroke?.startPosition ?? GestureStartPosition.anywhere,
    );
    final fingers = useState(initialStroke?.fingers ?? 1);
    final arrows = useState<List<GestureArrow>>(
      initialStroke?.arrows ?? const [],
    );

    // Allow at least 3 fingers in the picker so multi-finger gestures can be
    // configured; the native recognizer is told to match whatever is bound.
    final fingerLimit = maxFingers < 3 ? 3 : maxFingers;

    final stroke = GestureStroke(
      startPosition: startPosition.value,
      fingers: fingers.value,
      arrows: arrows.value,
    );

    // A collision is an existing binding under the same stroke key that is not
    // the one currently being edited (editing a binding in place is fine).
    final collisionAction = stroke.isValid && stroke.key != initialStroke?.key
        ? existingBindings[stroke.key]
        : null;

    Future<void> save() async {
      if (!stroke.isValid) return;

      if (collisionAction != null) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.warning_amber),
            title: const Text('Replace existing gesture?'),
            content: Text(
              'This stroke is already assigned to "${collisionAction.title}". '
              'Saving will replace that binding.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Replace'),
              ),
            ],
          ),
        );
        if (confirmed != true) return;
      }

      if (context.mounted) {
        Navigator.of(context).pop((stroke: stroke, action: action.value));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(initialStroke == null ? 'Create gesture' : 'Edit gesture'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Target action — opens the grouped action picker sheet.
                  Card.filled(
                    margin: EdgeInsets.zero,
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    clipBehavior: Clip.antiAlias,
                    child: ListTile(
                      leading: Icon(action.value.icon),
                      title: const Text('Target action'),
                      subtitle: Text(action.value.title),
                      trailing: const Icon(Icons.unfold_more),
                      onTap: () async {
                        final picked = await showGestureActionPicker(
                          context,
                          selected: action.value,
                        );
                        if (picked != null) action.value = picked;
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Start position',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final value in GestureStartPosition.values)
                        ChoiceChip(
                          avatar: Icon(value.icon),
                          showCheckmark: false,
                          label: Text(value.label),
                          selected: startPosition.value == value,
                          onSelected: (selected) {
                            if (selected) startPosition.value = value;
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Fingers'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: fingers.value > 1
                              ? () => fingers.value = fingers.value - 1
                              : null,
                        ),
                        Text('${fingers.value}'),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: fingers.value < fingerLimit
                              ? () => fingers.value = fingers.value + 1
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Stroke pattern',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Visualizer canvas mirroring the live stroke as it is built.
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: arrows.value.isEmpty
                        ? Text(
                            'Draw a stroke pattern below',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          )
                        : GestureStrokeView(stroke: stroke),
                  ),
                  const SizedBox(height: 16),

                  // Direction pad laid out like a compass (← ↑ ↓ →).
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final arrow in const [
                        GestureArrow.left,
                        GestureArrow.up,
                        GestureArrow.down,
                        GestureArrow.right,
                      ])
                        _DirectionButton(
                          arrow: arrow,
                          // The recognizer collapses consecutive identical directions
                          // into a single stroke, so a duplicate of the last arrow
                          // could never be matched. Disable it to keep the builder in
                          // sync with what native recognition can produce.
                          onPressed: arrows.value.lastOrNull == arrow
                              ? null
                              : () => arrows.value = [...arrows.value, arrow],
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: arrows.value.isEmpty
                          ? null
                          : () => arrows.value = arrows.value.sublist(
                              0,
                              arrows.value.length - 1,
                            ),
                      icon: const Icon(Icons.backspace_outlined),
                      label: const Text('Undo last'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (collisionAction != null) ...[
                    _CollisionWarning(action: collisionAction),
                    const SizedBox(height: 12),
                  ],
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: stroke.isValid ? save : null,
                    child: Text(
                      collisionAction != null
                          ? 'Replace gesture'
                          : 'Save gesture',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Inline warning shown in the editor's save bar when the current stroke would
/// overwrite another binding.
class _CollisionWarning extends StatelessWidget {
  final GestureAction action;

  const _CollisionWarning({required this.action});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            size: 20,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Already assigned to "${action.title}". Saving replaces it.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A circular tonal button for one swipe direction in the editor's D-pad.
class _DirectionButton extends StatelessWidget {
  final GestureArrow arrow;
  final VoidCallback? onPressed;

  const _DirectionButton({required this.arrow, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(20),
      ),
      onPressed: onPressed,
      child: Icon(arrow.icon),
    );
  }
}
