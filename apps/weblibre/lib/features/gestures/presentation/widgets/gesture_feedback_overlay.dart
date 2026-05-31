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
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/gestures/data/models/gesture_action.dart';
import 'package:weblibre/features/gestures/data/models/gesture_settings.dart';
import 'package:weblibre/features/gestures/data/models/gesture_stroke.dart';
import 'package:weblibre/features/gestures/domain/repositories/gesture_settings.dart';
import 'package:weblibre/features/gestures/domain/services/gesture_control.dart';
import 'package:weblibre/features/gestures/presentation/widgets/gesture_stroke_view.dart';

/// One candidate completion shown in the overlay.
typedef _Suggestion = ({
  GestureStroke stroke,
  GestureAction action,
  bool exact,
});

/// Translucent overlay shown near the top of the page while a gesture stroke is
/// being drawn. Mirrors the reference add-on's live toast: it renders the
/// in-progress stroke and the action it currently matches, and (once enough
/// strokes are drawn) the other gestures the user could complete from here.
///
/// Purely informational — it never intercepts touch input.
class GestureFeedbackOverlay extends HookConsumerWidget {
  const GestureFeedbackOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gestureSettingsWithDefaultsProvider);
    final partialKey = settings.showFeedback
        ? ref.watch(gestureProgressProvider).asData?.value
        : null;

    final suggestions = partialKey == null
        ? const <_Suggestion>[]
        : _resolveSuggestions(settings, GestureStroke.fromKey(partialKey));

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: suggestions.isEmpty
            ? const SizedBox.shrink()
            : Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _SuggestionCard(suggestions: suggestions),
                ),
              ),
      ),
    );
  }

  /// Bindings reachable from the in-progress [current] stroke.
  ///
  /// A binding is reachable when it uses the same finger count, a compatible
  /// start position (its own, or anywhere), and its arrow sequence begins with
  /// what has been drawn so far. Until [GestureSettings.minSuggestionStroke]
  /// strokes are drawn (or suggestions are disabled), only the exact current
  /// match is shown.
  List<_Suggestion> _resolveSuggestions(
    GestureSettings settings,
    GestureStroke current,
  ) {
    if (current.arrows.isEmpty) return const [];

    final suggestAll =
        settings.suggestNext &&
        current.arrows.length >= settings.minSuggestionStroke;

    final result = <_Suggestion>[];
    for (final MapEntry(key: key, value: action) in settings.bindings.entries) {
      final stroke = GestureStroke.fromKey(key);
      if (stroke.fingers != current.fingers) continue;
      if (stroke.startPosition != GestureStartPosition.anywhere &&
          stroke.startPosition != current.startPosition) {
        continue;
      }
      if (!_arrowsStartWith(stroke.arrows, current.arrows)) continue;

      final exact = stroke.arrows.length == current.arrows.length;
      if (!suggestAll && !exact) continue;

      result.add((stroke: stroke, action: action, exact: exact));
    }

    result.sort((a, b) {
      if (a.exact != b.exact) return a.exact ? -1 : 1;
      return a.stroke.arrows.length.compareTo(b.stroke.arrows.length);
    });
    return result;
  }

  bool _arrowsStartWith(List<GestureArrow> full, List<GestureArrow> prefix) {
    if (prefix.length > full.length) return false;
    for (var i = 0; i < prefix.length; i++) {
      if (full[i] != prefix[i]) return false;
    }
    return true;
  }
}

class _SuggestionCard extends StatelessWidget {
  final List<_Suggestion> suggestions;

  const _SuggestionCard({required this.suggestions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.inverseSurface.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(16),
      elevation: 6,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final suggestion in suggestions)
                Opacity(
                  opacity: suggestion.exact ? 1 : 0.6,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Icon(
                          suggestion.action.icon,
                          size: 18,
                          color: theme.colorScheme.onInverseSurface,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            suggestion.action.title,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onInverseSurface,
                              fontWeight: suggestion.exact
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureStrokeView(
                          stroke: suggestion.stroke,
                          color: theme.colorScheme.onInverseSurface,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
