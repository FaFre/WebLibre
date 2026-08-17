import 'package:drift/native.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weblibre/data/database/functions/lexo_rank_functions.dart';
import 'package:weblibre/features/user/data/database/database.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';

void main() {
  // EngineSettings.withDefaults seeds `locales` from the platform dispatcher.
  TestWidgetsFlutterBinding.ensureInitialized();

  late UserDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = UserDatabase(
      NativeDatabase.memory(
        setup: (database) {
          registerLexorankFunctions(database);
        },
      ),
    );

    container = ProviderContainer(
      overrides: [userDatabaseProvider.overrideWith((ref) => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  EngineSettingsRepository repository() =>
      container.read(engineSettingsRepositoryProvider.notifier);

  group('custom DoH resolvers', () {
    // The list is stored as a JSON document in a TEXT column, which the
    // repository has to decode by hand. Miss that step and every resolver the
    // user saves is written correctly and then silently gone on next launch.
    test('saved resolvers survive the round trip', () async {
      await repository().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(
            url: 'https://dnsforge.de/ads',
            name: 'dnsforge (adblock)',
          ),
          CustomDohProvider(url: 'https://dnsforge.de/dns-query'),
        ]),
      );

      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, [
        CustomDohProvider(
          url: 'https://dnsforge.de/ads',
          name: 'dnsforge (adblock)',
        ),
        CustomDohProvider(url: 'https://dnsforge.de/dns-query'),
      ]);
    });

    test('selecting a saved resolver survives the round trip', () async {
      const url = 'https://dnsforge.de/ads';

      await repository().updateSettings(
        (current) => current.copyWith
            .customDohProviders([CustomDohProvider(url: url)])
            .copyWith
            .dohProviderUrl(url),
      );

      final settings = await repository().fetchSettings();

      expect(settings.dohProviderUrl, url);
      expect(BuiltInDohProviders.isBuiltin(settings.dohProviderUrl), isFalse);
    });

    test('removing the last resolver is persisted as an empty list', () async {
      await repository().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(url: 'https://dnsforge.de/ads'),
        ]),
      );
      await repository().updateSettings(
        (current) => current.copyWith.customDohProviders([]),
      );

      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, isEmpty);
    });

    test('defaults to no saved resolvers', () async {
      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, isEmpty);
      expect(settings.dohProviderUrl, BuiltInDohProviders.quad9.url);
    });
  });

  group('resolvers saved before the list existed', () {
    const legacyUrl = 'https://dnsforge.de/ads';

    // Replicates the pre-list database state: a custom resolver that lives
    // nowhere but `dohProviderUrl`.
    Future<void> seedLegacyResolver() => repository().updateSettings(
      (current) => current.copyWith.dohProviderUrl(legacyUrl),
    );

    test('are adopted into the saved list on read', () async {
      await seedLegacyResolver();

      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, [CustomDohProvider(url: legacyUrl)]);
      expect(settings.dohProviderUrl, legacyUrl);
    });

    test('survive switching to a built-in provider', () async {
      // The regression this guards: adopting only for display loses the
      // resolver the moment the selection moves off it.
      await seedLegacyResolver();

      await repository().updateSettings(
        (current) =>
            current.copyWith.dohProviderUrl(BuiltInDohProviders.quad9.url),
      );

      final settings = await repository().fetchSettings();

      expect(settings.dohProviderUrl, BuiltInDohProviders.quad9.url);
      expect(settings.customDohProviders, [CustomDohProvider(url: legacyUrl)]);
    });

    test('are adopted once, not on every read', () async {
      await seedLegacyResolver();

      await repository().updateSettings(
        (current) => current.copyWith.dohSettingsMode(DohSettingsMode.max),
      );
      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, hasLength(1));
    });

    test('can be named, keeping the selection on the renamed entry', () async {
      await seedLegacyResolver();

      await repository().updateSettings(
        (current) => current.copyWith.customDohProviders([
          CustomDohProvider(url: legacyUrl, name: 'dnsforge (adblock)'),
        ]),
      );

      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, [
        CustomDohProvider(url: legacyUrl, name: 'dnsforge (adblock)'),
      ]);
      expect(settings.dohProviderUrl, legacyUrl);
    });

    test('stay deleted when the selection moves off them', () async {
      await seedLegacyResolver();

      // What the delete button does for the selected resolver.
      await repository().updateSettings(
        (current) => current.copyWith
            .customDohProviders([])
            .copyWith
            .dohProviderUrl(current.dohDefaultProviderUrl),
      );

      final settings = await repository().fetchSettings();

      expect(settings.customDohProviders, isEmpty);
      expect(settings.dohProviderUrl, BuiltInDohProviders.quad9.url);
    });
  });

  group('CustomDohProvider.displayName', () {
    test('uses the name when one was given', () {
      expect(
        CustomDohProvider(
          url: 'https://dnsforge.de/ads',
          name: 'dnsforge (adblock)',
        ).displayName,
        'dnsforge (adblock)',
      );
    });

    test('falls back to the host when unnamed', () {
      expect(
        CustomDohProvider(url: 'https://dnsforge.de/ads').displayName,
        'dnsforge.de',
      );
    });

    test('falls back to the host when the name is blank', () {
      expect(
        CustomDohProvider(
          url: 'https://dnsforge.de/ads',
          name: '  ',
        ).displayName,
        'dnsforge.de',
      );
    });
  });
}
