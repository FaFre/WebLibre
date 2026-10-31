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

/// The answer to a yes/no confirmation.
///
/// There is only the one value because it is the only one that is remembered:
/// cancelling means "not now", never "never", so "Don't ask again" has nothing
/// to store for it.
enum PromptConfirmation { confirmed }

/// The answer to "Keep tab?", asked when back leaves a tab that has no earlier
/// page — for a tab another app opened, or one opened from the search screen.
enum KeepTabAnswer { keep, discard }

/// A prompt that can be answered once and for all with "Don't ask again".
///
/// Each carries the answers it can remember, so a stored answer that does not
/// belong to its prompt is never handed out. Adding a prompt takes a value
/// here, its labels in `remembered_prompt_l10n.dart` and a row in the
/// confirmations settings.
///
/// Values are persisted by name: renaming one forgets what was remembered.
enum RememberedPrompt {
  keepExternalTab(KeepTabAnswer.values),
  closeIsolatedTabs(PromptConfirmation.values),
  closeAllTabs(PromptConfirmation.values),
  startTor(PromptConfirmation.values),
  startProxyConnection(PromptConfirmation.values);

  final List<Enum> answers;

  const RememberedPrompt(this.answers);

  /// Whether this prompt only confirms, rather than offering a choice.
  bool get isConfirmation => answers == PromptConfirmation.values;
}

/// Reads [GeneralSettings.rememberedPrompts], dropping entries for prompts this
/// version does not know and answers that do not belong to their prompt — a
/// downgrade, or a prompt that changed its answers, then asks again instead of
/// failing to decode the settings.
Map<RememberedPrompt, String> parseRememberedPrompts(
  Map<String, dynamic>? json,
) {
  if (json == null) return const {};
  final prompts = RememberedPrompt.values.asNameMap();
  return {
    for (final MapEntry(:key, :value) in json.entries)
      if (prompts[key] case final prompt?)
        if (value is String && prompt.answers.any((a) => a.name == value))
          prompt: value,
  };
}
