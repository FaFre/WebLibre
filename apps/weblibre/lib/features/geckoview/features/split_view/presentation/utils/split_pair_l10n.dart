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
import 'package:weblibre/features/geckoview/features/split_view/domain/entities/split_pair.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

extension SplitViewErrorL10n on SplitViewError {
  /// The snackbar text for a pair that could not be formed.
  String describe(AppLocalizations l10n) => switch (kind) {
    SplitViewErrorKind.mixedPrivacy => l10n.splitView_mixedPrivacy,
    SplitViewErrorKind.routingNotReady => l10n.splitView_routingNotReady,
    SplitViewErrorKind.sameTab ||
    SplitViewErrorKind.missingTab ||
    SplitViewErrorKind.notApplied ||
    // Never shown: callers drop a superseded request silently.
    SplitViewErrorKind.superseded => l10n.splitView_couldNotOpen,
  };
}
