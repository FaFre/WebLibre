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
import 'package:weblibre/features/proxy/presentation/controllers/proxy_profile_draft_controller.dart';
import 'package:weblibre/features/proxy/presentation/utils/singbox_form_field_l10n.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

/// Display text for [ProxyProfileLoadError].
extension ProxyProfileLoadErrorL10n on ProxyProfileLoadError {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this;

    return switch (error) {
      ProxyProfileNotFoundError() => l10n.proxy_loadErrorNotFound,
      ProxyProfileLoadFailedError(:final error) => l10n.proxy_loadErrorFailed(
        '$error',
      ),
    };
  }
}

/// Display text for [ProxyProfileSaveError], kept out of the controller for
/// the same reason as [ProxyProfileLoadErrorL10n].
extension ProxyProfileSaveErrorL10n on ProxyProfileSaveError {
  String describe(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final error = this;

    return switch (error) {
      ProxyProfileSaveAlreadySaving() => l10n.proxy_saveErrorAlreadySaving,
      ProxyProfileSaveNameRequired() => l10n.proxy_saveErrorNameRequired,
      ProxyProfileSaveStillLoading() => l10n.proxy_saveErrorStillLoading,
      ProxyProfileSaveLoadFailed(:final loadError) => loadError.describe(
        context,
      ),
      ProxyProfileSaveConfigNotJson() => l10n.proxy_saveErrorConfigNotJson,
      ProxyProfileSaveSecretsNotJson() => l10n.proxy_saveErrorSecretsNotJson,
      ProxyProfileSaveFieldValidation(:final fieldError) => fieldError.describe(
        context,
      ),
      // Native/runtime text — not further localized, same as any other
      // external error message in this app.
      ProxyProfileSaveRuntimeInvalid(:final nativeMessage) => nativeMessage,
      ProxyProfileSaveUnexpectedError(:final error) =>
        l10n.proxy_saveErrorUnexpected('$error'),
    };
  }
}
