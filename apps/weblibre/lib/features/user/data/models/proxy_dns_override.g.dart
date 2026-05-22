// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'proxy_dns_override.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProxyDnsOverride _$ProxyDnsOverrideFromJson(Map<String, dynamic> json) =>
    ProxyDnsOverride(
      remoteServerAddress: json['remoteServerAddress'] as String?,
      domainStrategy:
          $enumDecodeNullable(
            _$ProxyDnsDomainStrategyEnumMap,
            json['domainStrategy'],
          ) ??
          ProxyDnsDomainStrategy.preferIpv4,
    );

Map<String, dynamic> _$ProxyDnsOverrideToJson(
  ProxyDnsOverride instance,
) => <String, dynamic>{
  'remoteServerAddress': instance.remoteServerAddress,
  'domainStrategy': _$ProxyDnsDomainStrategyEnumMap[instance.domainStrategy]!,
};

const _$ProxyDnsDomainStrategyEnumMap = {
  ProxyDnsDomainStrategy.auto: 'auto',
  ProxyDnsDomainStrategy.preferIpv4: 'preferIpv4',
  ProxyDnsDomainStrategy.preferIpv6: 'preferIpv6',
  ProxyDnsDomainStrategy.ipv4Only: 'ipv4Only',
  ProxyDnsDomainStrategy.ipv6Only: 'ipv6Only',
};
