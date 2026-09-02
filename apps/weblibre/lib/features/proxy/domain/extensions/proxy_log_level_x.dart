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
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';

/// Maps the persisted setting onto the runtime's wire enum.
///
/// Kept apart from [ProxyLogLevel] itself so the stored value stays ours: the
/// pigeon enum is generated and free to be reordered or renamed, and a settings
/// row must not change meaning when it is.
extension ProxyLogLevelRuntimeX on ProxyLogLevel {
  SingboxProxyLogLevel get singboxLevel => switch (this) {
    ProxyLogLevel.warn => SingboxProxyLogLevel.warn,
    ProxyLogLevel.info => SingboxProxyLogLevel.info,
    ProxyLogLevel.debug => SingboxProxyLogLevel.debug,
    ProxyLogLevel.trace => SingboxProxyLogLevel.trace,
  };
}
