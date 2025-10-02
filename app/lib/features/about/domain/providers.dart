import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
Future<PackageInfo> packageInfo(Ref ref) async {
  return await PackageInfo.fromPlatform();
}

@Riverpod()
Future<String> geckoVersion(Ref ref) async {
  return await GeckoBrowserService().getGeckoVersion();
}
