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
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';

/// Asks before closing all tabs, unless "Don't ask again" was ticked
/// ([RememberedPrompt.closeAllTabs]). Returns whether to close them.
Future<bool> showCloseAllTabsDialog(BuildContext context, ProviderRead read) {
  final l10n = AppLocalizations.of(context);

  return confirmUnlessRemembered(
    context,
    read,
    RememberedPrompt.closeAllTabs,
    icon: const Icon(Icons.warning),
    title: l10n.browser_closeAllTabsTitle,
    content: l10n.browser_closeAllTabsContent,
    confirmLabel: l10n.common_close,
  );
}
