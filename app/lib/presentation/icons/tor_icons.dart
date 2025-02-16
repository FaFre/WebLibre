import 'package:flutter/widgets.dart';

enum TorIcons implements IconData {
  authority(0xf101),
  badexit(0xf102),
  bridge(0xf103),
  country(0xf104),
  directory(0xf105),
  exit(0xf106),
  experimental(0xf107),
  fallbackdir(0xf108),
  fast(0xf109),
  fingerprint(0xf10a),
  guard(0xf10b),
  hibernating(0xf10c),
  hsdir(0xf10d),
  ipv4(0xf10e),
  ipv6exit(0xf10f),
  ipv6(0xf110),
  noedconsensus(0xf111),
  notrecommended(0xf112),
  onionAlt(0xf113),
  onion(0xf114),
  outdated(0xf115),
  reachableipv4(0xf116),
  reachableipv6(0xf117),
  relay(0xf118),
  running(0xf119),
  stable(0xf11a),
  tshirt(0xf11b),
  unmeasured(0xf11c),
  unreachableipv4(0xf11d),
  unreachableipv6(0xf11e),
  v2dir(0xf11f),
  valid(0xf120);

  const TorIcons(this.codePoint);

  @override
  final int codePoint;

  @override
  String get fontFamily => 'TorIcons';

  @override
  List<String>? get fontFamilyFallback => null;

  @override
  String? get fontPackage => null;

  @override
  bool get matchTextDirection => false;

  @override
  String toString() => 'TorIcons.$name';
}
