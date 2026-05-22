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
import 'package:json_annotation/json_annotation.dart';

part 'proxy_dns_override.g.dart';

/// Mirrors sing-box's `dns.strategy` field.
enum ProxyDnsDomainStrategy { auto, preferIpv4, preferIpv6, ipv4Only, ipv6Only }

extension ProxyDnsDomainStrategyExt on ProxyDnsDomainStrategy {
  String get singboxValue => switch (this) {
    ProxyDnsDomainStrategy.auto => '',
    ProxyDnsDomainStrategy.preferIpv4 => 'prefer_ipv4',
    ProxyDnsDomainStrategy.preferIpv6 => 'prefer_ipv6',
    ProxyDnsDomainStrategy.ipv4Only => 'ipv4_only',
    ProxyDnsDomainStrategy.ipv6Only => 'ipv6_only',
  };
}

@JsonSerializable(includeIfNull: true)
class ProxyDnsOverride with FastEquatable {
  /// Single DNS server resolved through this profile's own outbound.
  final String? remoteServerAddress;

  final ProxyDnsDomainStrategy domainStrategy;

  ProxyDnsOverride({
    this.remoteServerAddress,
    this.domainStrategy = ProxyDnsDomainStrategy.preferIpv4,
  });

  factory ProxyDnsOverride.fromJson(Map<String, dynamic> json) =>
      _$ProxyDnsOverrideFromJson(json);

  Map<String, dynamic> toJson() => _$ProxyDnsOverrideToJson(this);

  @override
  List<Object?> get hashParameters => [remoteServerAddress, domainStrategy];
}
