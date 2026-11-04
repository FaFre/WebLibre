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

/// [items] as one list in the UI language, e.g. "Containers, Profiles" or
/// "容器、配置文件", so translators choose the separator.
///
/// Only for a list that stands on its own, after a colon or as a subtitle:
/// it never adds a conjunction, so it cannot end a sentence like "X and Y".
String formatList(AppLocalizations l10n, Iterable<String> items) =>
    items.join(l10n.listFormat_separator);
