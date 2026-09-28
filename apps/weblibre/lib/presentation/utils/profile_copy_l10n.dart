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
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// [AppLocalizations.profileCopy_restartsToWork] and
/// [AppLocalizations.profileCopy_asksPasswordAfterRestart] said together — one
/// call rather than two adjacent ARB messages, so the pair can't drift apart
/// the way separately-edited strings can.
String restartsThenAsksPassword(AppLocalizations l10n) =>
    '${l10n.profileCopy_restartsToWork} '
    '${l10n.profileCopy_asksPasswordAfterRestart}';

/// Shown when the restart a destructive operation needs cannot be scheduled.
///
/// Every call site unqueues its task before throwing this, so it is a clean
/// stop: nothing is pending and nothing was touched.
String restartCouldNotBeScheduled(AppLocalizations l10n) => l10n
    .profileCopy_restartCouldNotBeScheduled(l10n.profileCopy_nothingChanged);
