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
import 'package:flutter/widgets.dart';
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Settings copy for each [RememberedPrompt]. A confirmation's [label] names
/// the switch that turns its question on ("Ask before …").
extension RememberedPromptL10n on RememberedPrompt {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      RememberedPrompt.keepExternalTab =>
        l10n.rememberedPrompt_keepExternalTabLabel,
      RememberedPrompt.closeIsolatedTabs =>
        l10n.rememberedPrompt_closeIsolatedTabsLabel,
      RememberedPrompt.closeAllTabs => l10n.rememberedPrompt_closeAllTabsLabel,
      RememberedPrompt.startTor => l10n.rememberedPrompt_startTorLabel(
        torBrand,
      ),
      RememberedPrompt.startProxyConnection =>
        l10n.rememberedPrompt_startProxyConnectionLabel,
    };
  }

  String description(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      RememberedPrompt.keepExternalTab =>
        l10n.rememberedPrompt_keepExternalTabDescription,
      RememberedPrompt.closeIsolatedTabs =>
        l10n.rememberedPrompt_closeIsolatedTabsDescription,
      RememberedPrompt.closeAllTabs =>
        l10n.rememberedPrompt_closeAllTabsDescription,
      RememberedPrompt.startTor => l10n.rememberedPrompt_startTorDescription(
        torBrand,
      ),
      RememberedPrompt.startProxyConnection =>
        l10n.rememberedPrompt_startProxyConnectionDescription,
    };
  }

  /// Settings-search synonyms, for `settingsKeywords`.
  String keywords(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      RememberedPrompt.keepExternalTab =>
        l10n.rememberedPrompt_keepExternalTabKeywords,
      RememberedPrompt.closeIsolatedTabs =>
        l10n.rememberedPrompt_closeIsolatedTabsKeywords,
      RememberedPrompt.closeAllTabs =>
        l10n.rememberedPrompt_closeAllTabsKeywords,
      RememberedPrompt.startTor => l10n.rememberedPrompt_startTorKeywords,
      RememberedPrompt.startProxyConnection =>
        l10n.rememberedPrompt_startProxyConnectionKeywords,
    };
  }
}

extension KeepTabAnswerL10n on KeepTabAnswer {
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return switch (this) {
      KeepTabAnswer.keep => l10n.rememberedPrompt_answerKeep,
      KeepTabAnswer.discard => l10n.common_discard,
    };
  }
}

/// The label of [answer], one of the [RememberedPrompt.answers] of a prompt
/// that offers a choice.
///
/// Throws for an answer type with no label yet: a new choice prompt needs its
/// case here before the confirmations screen can list it.
String rememberedAnswerLabel(BuildContext context, Enum answer) {
  return switch (answer) {
    final KeepTabAnswer answer => answer.label(context),
    _ => throw ArgumentError.value(
      answer,
      'answer',
      'No label for this remembered answer',
    ),
  };
}
