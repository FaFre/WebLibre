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
import 'package:weblibre/core/design/display_features.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// What a [RememberablePromptDialog] was answered with.
typedef RememberablePromptResult<T extends Enum> = ({T answer, bool remember});

/// A button that answers a [RememberablePromptDialog].
class PromptAnswerAction<T extends Enum> {
  final T answer;
  final String label;

  /// Whether this is the dialog's primary action, drawn filled.
  final bool primary;

  const PromptAnswerAction({
    required this.answer,
    required this.label,
    this.primary = false,
  });
}

/// An [AlertDialog] with a "Don't ask again" checkbox, for the prompts in
/// [RememberedPrompt]. Show it through [askUnlessRemembered], which skips it
/// once an answer is remembered.
///
/// Pops a [RememberablePromptResult] for an answer button, and null for Cancel
/// or a dismissal — neither is ever remembered, so ticking the box and then
/// backing out stores nothing.
///
/// With [offerRemember] false the checkbox is left out, for a question that
/// sometimes cannot be remembered; show it with [showRememberablePromptDialog]
/// then.
class RememberablePromptDialog<T extends Enum> extends HookWidget {
  final Widget? icon;
  final Widget title;
  final Widget content;
  final List<PromptAnswerAction<T>> answers;

  /// Whether a Cancel button comes first. A question that has no "not now",
  /// like keeping or discarding a tab, leaves it out.
  final bool cancellable;

  /// Whether the "Don't ask again" checkbox is shown. Without it, every answer
  /// pops with `remember` false.
  final bool offerRemember;

  const RememberablePromptDialog({
    required this.title,
    required this.content,
    required this.answers,
    this.icon,
    this.cancellable = true,
    this.offerRemember = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final dontAskAgain = useState(false);

    return AlertDialog(
      icon: icon,
      title: title,
      scrollable: true,
      content: offerRemember
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 8),
                CheckboxListTile.adaptive(
                  value: dontAskAgain.value,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(l10n.rememberedPrompt_dontAskAgain),
                  subtitle: Text(l10n.rememberedPrompt_dontAskAgainHint),
                  onChanged: (value) => dontAskAgain.value = value ?? false,
                ),
              ],
            )
          : content,
      actions: [
        if (cancellable)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.common_cancel),
          ),
        for (final action in answers)
          if (action.primary)
            TextButton(
              onPressed: () => _answer(context, action.answer, dontAskAgain),
              child: Text(action.label),
            )
          else
            TextButton(
              onPressed: () => _answer(context, action.answer, dontAskAgain),
              child: Text(action.label),
            ),
      ],
    );
  }

  void _answer(BuildContext context, T answer, ValueNotifier<bool> remember) {
    Navigator.of(context).pop<RememberablePromptResult<T>>((
      answer: answer,
      remember: remember.value,
    ));
  }
}

/// Shows the [RememberablePromptDialog] that [builder] returns, without
/// looking at or storing a remembered answer. [askUnlessRemembered] is the
/// usual way in; this is for asking a prompt that is not remembered this time.
Future<RememberablePromptResult<T>?> showRememberablePromptDialog<
  T extends Enum
>(BuildContext context, {required WidgetBuilder builder}) {
  return showDialog<RememberablePromptResult<T>>(
    context: context,
    anchorPoint: preferredAnchorPoint(MediaQuery.of(context)),
    builder: builder,
  );
}

/// Answers [prompt] with what was remembered for it, or asks with the
/// [RememberablePromptDialog] that [builder] returns and remembers the answer
/// when "Don't ask again" was ticked. [read] is the caller's `ref.read`; it is
/// only used before the dialog opens.
///
/// [T] is the prompt's answer type, one of [RememberedPrompt.answers]. Returns
/// null when the dialog was cancelled or dismissed.
Future<T?> askUnlessRemembered<T extends Enum>(
  BuildContext context,
  ProviderRead read,
  RememberedPrompt prompt, {
  required WidgetBuilder builder,
}) async {
  final remembered = read(
    generalSettingsWithDefaultsProvider,
  ).rememberedAnswer<T>(prompt);
  if (remembered != null) return remembered;

  // Taken before the dialog opens: callers are often short-lived (menu
  // items, tab tiles, chips) and gone by the time it closes, and their
  // `ref.read` throws then. The repository is keepAlive and already built by
  // the read above, so holding it costs nothing.
  final repository = read(generalSettingsRepositoryProvider.notifier);

  final result = await showRememberablePromptDialog<T>(
    context,
    builder: builder,
  );
  if (result == null) return null;

  if (result.remember) {
    try {
      await repository.setRememberedAnswer(prompt, result.answer);
    } catch (error, stackTrace) {
      // The answer still stands for this time; it is only asked again.
      logger.e(
        'Failed to remember the answer to ${prompt.name}',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  return result.answer;
}

/// [askUnlessRemembered] for a yes/no confirmation: Cancel, and a primary
/// [confirmLabel] button. Returns whether to go ahead.
Future<bool> confirmUnlessRemembered(
  BuildContext context,
  ProviderRead read,
  RememberedPrompt prompt, {
  required String title,
  required String content,
  required String confirmLabel,
  Widget? icon,
}) async {
  final answer = await askUnlessRemembered<PromptConfirmation>(
    context,
    read,
    prompt,
    builder: (context) => RememberablePromptDialog<PromptConfirmation>(
      icon: icon,
      title: Text(title),
      content: Text(content),
      answers: [
        PromptAnswerAction(
          answer: PromptConfirmation.confirmed,
          label: confirmLabel,
          primary: true,
        ),
      ],
    ),
  );

  return answer == PromptConfirmation.confirmed;
}
