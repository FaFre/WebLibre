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
import 'package:flutter/services.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/utils/error_l10n.dart';

/// The sentence to show when starting, stopping or deleting a proxy failed
/// with [error].
///
/// A failure that names the profile it is about says so in a sentence of its
/// own. Anything else is the detail [framed] puts into the caller's sentence
/// ("Failed to start proxy: …") — sing-box's reason for a start that failed
/// on no particular profile, a platform error's message, never an object's
/// `toString`.
String describeProxyFailure(
  AppLocalizations l10n,
  Object error, {
  required String Function(String detail) framed,
}) => switch (error) {
  SingboxStartException(:final profileName?, :final reason) =>
    l10n.proxy_profileCouldNotStart(profileName, reason),
  SingboxStartException(:final reason) => framed(reason),
  SingboxProfilesRejected(:final rejections) =>
    rejections.values
        .map(
          (rejection) =>
              l10n.proxy_profileRejected(rejection.name, rejection.message),
        )
        .join('\n'),
  PlatformException(:final message?) when message.trim().isNotEmpty => framed(
    message,
  ),
  // The code is an identifier, not something to show.
  PlatformException() => framed(l10n.failureWidget_unknownError),
  _ => framed(describeError(l10n, error)),
};
