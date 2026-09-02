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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'proxy_diagnostics_settings.g.dart';

/// Verbosity the sing-box runtime is started with.
///
/// Deliberately not the whole of sing-box's level list. Below `warn` the log
/// stops carrying the errors a user needs in order to report anything, and the
/// levels above it are not a preference — they are an instrument.
///
/// [warn] is what the browser runs on. From [info] upwards sing-box writes
/// roughly a line per *connection* — the SOCKS inbound, the DNS router (on
/// cache hits too) and the outbound each contribute one — and every line is
/// forwarded to Dart over the platform channel on the main thread. On a page
/// with a few hundred subresources that is a few thousand main-thread messages,
/// which is why the verbose levels are opt-in and worth turning back off.
enum ProxyLogLevel { warn, info, debug, trace }

extension ProxyLogLevelX on ProxyLogLevel {
  String get label => switch (this) {
    ProxyLogLevel.warn => 'Warnings and errors',
    ProxyLogLevel.info => 'Info',
    ProxyLogLevel.debug => 'Debug',
    ProxyLogLevel.trace => 'Trace',
  };

  String get description => switch (this) {
    ProxyLogLevel.warn => 'Normal operation. Problems are still logged.',
    ProxyLogLevel.info => 'Every connection and DNS lookup. Slows browsing.',
    ProxyLogLevel.debug => 'Info plus protocol detail. Slows browsing.',
    ProxyLogLevel.trace => 'Everything sing-box can say. Slows browsing a lot.',
  };

  /// Whether this level makes sing-box log per connection, which is the point
  /// at which the log stops being free.
  bool get isVerbose => this != ProxyLogLevel.warn;
}

@CopyWith()
@JsonSerializable(includeIfNull: true, constructor: 'withDefaults')
class ProxyDiagnosticsSettings with FastEquatable {
  /// Verbosity the sing-box runtime is started with. Applied by restarting the
  /// runtime, because sing-box reads `log.level` from the config it is given.
  ///
  /// A stored value this build does not know falls back to the default rather
  /// than throwing: this is read on the path that starts the proxy, and a level
  /// nobody can name is no reason to leave the user without one.
  @JsonKey(unknownEnumValue: ProxyLogLevel.warn)
  final ProxyLogLevel logLevel;

  ProxyDiagnosticsSettings({required this.logLevel});

  ProxyDiagnosticsSettings.withDefaults({ProxyLogLevel? logLevel})
    : logLevel = logLevel ?? ProxyLogLevel.warn;

  factory ProxyDiagnosticsSettings.fromJson(Map<String, dynamic> json) =>
      _$ProxyDiagnosticsSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$ProxyDiagnosticsSettingsToJson(this);

  @override
  List<Object?> get hashParameters => [logLevel];
}
