import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:pluggable_transports_proxy/pluggable_transports_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:universal_io/io.dart';

part 'builtin_bridges.g.dart';

@Riverpod(keepAlive: true)
class BuiltinBridgesService extends _$BuiltinBridgesService {
  late final _bridgeFileFuture = path_provider
      .getApplicationSupportDirectory()
      .then((dir) => File(p.join(dir.path, 'builtin-bridges.json')));

  Future<DateTime?> lastUpdate() async {
    final bridgeFile = await _bridgeFileFuture;
    if (!await bridgeFile.exists()) {
      return null;
    }

    return bridgeFile.lastModified();
  }

  Future<void> updateStoredBuiltinBridges(BuiltInBridges bridges) async {
    final bridgeFile = await _bridgeFileFuture;
    await bridgeFile.writeAsString(jsonEncode(bridges.toJson()), flush: true);
  }

  Future<BuiltInBridges?> getStoredBuiltinBridges() async {
    final bridgeFile = await _bridgeFileFuture;
    if (!await bridgeFile.exists()) {
      return null;
    }

    final content = await bridgeFile.readAsString();
    return BuiltInBridges.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  Future<BuiltInBridges> getBundledBuiltinBridges() async {
    final content = await rootBundle.loadString(
      'assets/preferences/builtin-bridges.json',
    );
    return BuiltInBridges.fromJson(jsonDecode(content) as Map<String, dynamic>);
  }

  @override
  void build() {
    return;
  }
}
