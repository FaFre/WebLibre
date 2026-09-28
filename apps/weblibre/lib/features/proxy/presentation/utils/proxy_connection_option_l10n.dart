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
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/presentation/utils/singbox_proxy_profile_type_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display subtitle for [ProxyConnectionOption].
extension ProxyConnectionOptionL10n on ProxyConnectionOption {
  String description(BuildContext context) =>
      profileType?.label(context) ??
      AppLocalizations.of(context).proxy_torConnectionSubtitle(torBrand);
}
