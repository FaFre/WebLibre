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
import 'package:weblibre/core/branding/proxy_brands.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/domain/entities/remembered_prompt.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/icons/tor_icons.dart';
import 'package:weblibre/presentation/widgets/remembered_prompt.dart';

/// Asks to start Tor for a tab that needs it, for [RememberedPrompt.startTor].
/// Show it through [askUnlessRemembered].
class TorDialog extends StatelessWidget {
  const TorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final appColors = AppColors.of(context);
    return RememberablePromptDialog<PromptConfirmation>(
      icon: Icon(TorIcons.onionAlt, color: appColors.torPurple),
      title: Text(l10n.tor_proxyLabel(torBrand)),
      content: Text(l10n.tor_dialogContent(torBrand)),
      answers: [
        PromptAnswerAction(
          answer: PromptConfirmation.confirmed,
          label: l10n.tor_actionEnable,
          primary: true,
        ),
      ],
    );
  }
}
