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

  /// The imported JSON the form's values are saved over, so keys the form has
  /// no field for survive the import. Null when the source was not JSON.
  final String? baseConfigJson;

  /// What the import had to leave out or wants the user to know before
  /// saving. Shown above the form.
  final List<ProxyImportNote> notes;

  ProxyProfileSeed({
    required this.type,
    this.name,
    this.values = const {},
    this.dnsOverrideJson,
    this.baseConfigJson,
    this.notes = const [],
  });

  @override
  List<Object?> get hashParameters => [
    type,
    name,
    values,
    dnsOverrideJson,
    baseConfigJson,
    notes,
  ];
}

/// Something an import could not carry over as it was, kept as data and worded
/// where it is shown.
sealed class ProxyImportNote with FastEquatable {
  ProxyImportNote();
}

/// The config named more DNS servers than a profile holds; only the first is
/// used.
class ProxyImportExtraDnsServers extends ProxyImportNote {
  final String used;
  final List<String> dropped;

  ProxyImportExtraDnsServers({required this.used, required this.dropped});

  @override
  List<Object?> get hashParameters => [used, dropped];
}

/// The tunnel carries only some address ranges, so sites outside them cannot
/// be reached through it.
class ProxyImportSplitTunnel extends ProxyImportNote {
  final List<String> allowedIps;

  ProxyImportSplitTunnel(this.allowedIps);

  @override
  List<Object?> get hashParameters => [allowedIps];
}
