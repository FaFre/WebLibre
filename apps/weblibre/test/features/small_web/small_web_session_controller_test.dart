import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod/experimental/persist.dart';
import 'package:weblibre/features/small_web/data/models/small_web_source_kind.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/features/user/data/providers.dart';

void main() {
  test('a synchronously restored session is kept', () async {
    // The startup preload makes storage reads synchronous, which puts the
    // decoded session into `state` during the first build. Returning the
    // initial session from that build used to throw it away on every start.
    final Storage<String, String> storage = Storage.inMemory();
    await storage.write(
      'SmallWebSessionState',
      jsonEncode(SmallWebSessionState.initial(SmallWebSourceKind.wander)),
      const StorageOptions(),
    );

    final container = ProviderContainer(
      overrides: [
        riverpodDatabaseStorageProvider.overrideWith((ref) => storage),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container.read(smallWebSessionControllerProvider).value?.sourceKind,
      SmallWebSourceKind.wander,
    );
  });
}
