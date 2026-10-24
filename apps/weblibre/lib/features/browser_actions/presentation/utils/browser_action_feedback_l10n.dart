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
import 'package:weblibre/features/browser_actions/domain/entities/browser_action_feedback.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

/// Display strings for [BrowserActionFeedback].
extension BrowserActionFeedbackL10n on BrowserActionFeedback {
  String message(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return switch (this) {
      BrowserActionFeedback.bookmarkAdded =>
        l10n.browserActions_bookmarkAddedMessage,
      BrowserActionFeedback.bookmarkRemoved =>
        l10n.browserActions_bookmarkRemovedMessage,
      BrowserActionFeedback.gesturesEnabled =>
        l10n.browserActions_gesturesEnabledMessage,
      BrowserActionFeedback.gesturesDisabled =>
        l10n.browserActions_gesturesDisabledMessage,
      BrowserActionFeedback.fontSizeAutomatic =>
        l10n.browserActions_fontSizeAutomaticMessage,
      BrowserActionFeedback.tabPinned => l10n.browserActions_tabPinnedMessage,
      BrowserActionFeedback.tabUnpinned =>
        l10n.browserActions_tabUnpinnedMessage,
      BrowserActionFeedback.homeScreenUnavailable =>
        l10n.browserActions_homeScreenUnavailableMessage,
      BrowserActionFeedback.readerViewUnavailable =>
        l10n.browserActions_readerViewUnavailableMessage,
      BrowserActionFeedback.noClosedTabs =>
        l10n.browserActions_noClosedTabsMessage,
    };
  }
}

/// Shows [feedback] as a snackbar.
void showBrowserActionFeedback(
  BuildContext context,
  BrowserActionFeedback feedback,
) {
  ui_helper.showInfoMessage(context, feedback.message(context));
}
