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
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';

/// Pre-filled state handed to the create-mode editor when the user reached it
/// through a guided method (file import, clipboard, QR, etc.).
///
/// Carries structured [values] for [SingboxProxyFormSpec]-driven types.
/// [dnsOverrideJson] is applied to the editor's DNS override section when
/// present.
class ProxyProfileSeed with FastEquatable {
  final SingboxProxyProfileType type;
  final String? name;
  final Map<String, String> values;
  final String? dnsOverrideJson;

  ProxyProfileSeed({
    required this.type,
    this.name,
    this.values = const {},
    this.dnsOverrideJson,
  });

  @override
  List<Object?> get hashParameters => [type, name, values, dnsOverrideJson];
}
