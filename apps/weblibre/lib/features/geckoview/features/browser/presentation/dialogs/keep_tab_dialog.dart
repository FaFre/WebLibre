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
import 'package:weblibre/core/providers/provider_read.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/remembered_prompt_l10n.dart';
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';

/// Asks whether to keep the tab back is about to leave.
///
/// [rememberable] offers "Don't ask again" and answers from
/// [RememberedPrompt.keepExternalTab] without asking once that is set. Only a
/// tab another app opened is remembered: back to the search screen is a
/// different question, and always asks.
///
/// Returns null when the dialog is dismissed, which keeps the user on the tab.
Future<KeepTabAnswer?> showKeepTabDialog(
  BuildContext context,
  ProviderRead read, {
  required bool rememberable,
}) async {
  Widget buildDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return RememberablePromptDialog<KeepTabAnswer>(
      title: Text(l10n.browser_keepTabTitle),
      content: Text(l10n.browser_keepTabContent),
      cancellable: false,
      offerRemember: rememberable,
      answers: [
        PromptAnswerAction(
          answer: KeepTabAnswer.discard,
          label: KeepTabAnswer.discard.label(context),
        ),
        PromptAnswerAction(
          answer: KeepTabAnswer.keep,
          label: KeepTabAnswer.keep.label(context),
          primary: true,
        ),
      ],
    );
  }

  if (!rememberable) {
    final result = await showRememberablePromptDialog<KeepTabAnswer>(
      context,
      builder: buildDialog,
    );
    return result?.answer;
  }

  return await askUnlessRemembered<KeepTabAnswer>(
    context,
    read,
    RememberedPrompt.keepExternalTab,
    builder: buildDialog,
  );
}
