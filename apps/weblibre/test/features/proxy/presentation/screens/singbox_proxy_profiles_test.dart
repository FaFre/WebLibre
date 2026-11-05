import 'package:flutter/material.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tor/flutter_tor.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profile_editor.dart';
import 'package:weblibre/features/proxy/presentation/screens/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/profile_tile.dart';
import 'package:weblibre/features/proxy/presentation/widgets/profile_list/tor_tile.dart';
import 'package:weblibre/features/tor/domain/services/tor_proxy.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_routing_settings.dart';
import 'package:weblibre/features/user/data/models/tor_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_routing_settings.dart';
import 'package:weblibre/features/user/domain/repositories/tor_settings.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';

void main() {
  testWidgets('deleting a running profile stops through runtime repository', (
    tester,
  ) async {
    final profile = _profile(id: 'profile-1', name: 'Mullvad');
    final profilesRepository = _FakeProfilesRepository([profile]);
    final runtimeRepository = _FakeRuntimeRepository(
      SingboxProxyRuntimeState(
        status: SingboxProxyRuntimeStatus.running,
        endpoints: [
          SingboxProxyRuntimeEndpoint(
            profileId: SingboxProxyConnectionId(profile.id).encode(),
            host: '127.0.0.1',
            port: 12080,
            username: 'user',
            password: 'pass',
          ),
        ],
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No onboarding owed: no draft, the displayed layer is the live one.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          // Tor's routes, read by `torInUse` for the list: none.
          watchContainersWithCountProvider.overrideWith(
            (ref) => Stream.value(const []),
          ),
          proxyRoutingSettingsWithDefaultsProvider.overrideWithValue(
            ProxyRoutingSettings.withDefaults(),
          ),
          // The Add button follows the connections switch.
          generalSettingsWithDefaultsProvider.overrideWithValue(
            GeneralSettings.withDefaults(),
          ),
          singboxProxyProfilesRepositoryProvider.overrideWith(
            () => profilesRepository,
          ),
          singboxProxyRuntimeRepositoryProvider.overrideWith(
            () => runtimeRepository,
          ),
          // The Tor tile reads its autostart flag from the settings database.
          torSettingsRepositoryProvider.overrideWith(
            _FakeTorSettingsRepository.new,
          ),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SingboxProxyProfilesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mullvad'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(ProfileTile),
        matching: find.byIcon(Icons.more_vert),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Stop and Delete'), findsOneWidget);

    await tester.tap(find.text('Stop and Delete'));
    await tester.pumpAndSettle();

    expect(runtimeRepository.deletedProfileIds, ['profile-1']);
  });

  testWidgets(
    'a profile the runtime is restarting shows as starting, not stopped',
    (tester) async {
      // Starting any profile reloads every running one. For the duration the
      // runtime reports no endpoints at all, which read as "stopped": switches
      // flicked off and the running tiles moved down and back.
      final restarting = _profile(id: 'profile-1', name: 'Restarting');
      final stopped = _profile(id: 'profile-2', name: 'Stopped');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            // Tor's routes, read by `torInUse` for the list: none.
            watchContainersWithCountProvider.overrideWith(
              (ref) => Stream.value(const []),
            ),
            proxyRoutingSettingsWithDefaultsProvider.overrideWithValue(
              ProxyRoutingSettings.withDefaults(),
            ),
            // The Add button follows the connections switch.
            generalSettingsWithDefaultsProvider.overrideWithValue(
              GeneralSettings.withDefaults(),
            ),
            singboxProxyProfilesRepositoryProvider.overrideWith(
              () => _FakeProfilesRepository([stopped, restarting]),
            ),
            singboxProxyRuntimeRepositoryProvider.overrideWith(
              () => _FakeRuntimeRepository(
                SingboxProxyRuntimeState(
                  status: SingboxProxyRuntimeStatus.starting,
                  endpoints: const [],
                ),
              ),
            ),
            singboxProxyStartingConnectionsProvider.overrideWith(
              () => _FakeStartingConnections({
                SingboxProxyConnectionId(restarting.id).encode(),
              }),
            ),
            torSettingsRepositoryProvider.overrideWith(
              _FakeTorSettingsRepository.new,
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SingboxProxyProfilesScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      Finder tileOf(String name) => find.ancestor(
        of: find.text(name),
        matching: find.byType(ProfileTile),
      );

      expect(
        find.descendant(
          of: tileOf('Restarting'),
          matching: find.byTooltip('Starting…'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: tileOf('Restarting'),
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsNothing,
      );
      expect(
        find.descendant(
          of: tileOf('Stopped'),
          matching: find.byIcon(Icons.play_arrow_rounded),
        ),
        findsOneWidget,
      );
      // Still sorted with the running ones.
      expect(
        tester.getTopLeft(tileOf('Restarting')).dy,
        lessThan(tester.getTopLeft(tileOf('Stopped')).dy),
      );
    },
  );

  testWidgets('proxy URI import populates structured editor fields', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      profilesRepository: _FakeProfilesRepository([]),
      seed: ProxyProfileSeed(
        type: SingboxProxyProfileType.vless,
        name: 'Imported VLESS',
        values: {
          'server': 'vless.example.com',
          'server_port': '443',
          'uuid': '00000000-0000-0000-0000-000000000000',
          'flow': 'xtls-rprx-vision',
          'tls.server_name': 'front.example.com',
        },
      ),
    );

    expect(find.text('Imported VLESS'), findsOneWidget);
    expect(find.text('VLESS'), findsOneWidget);
    expect(find.text('Connection'), findsWidgets);
    expect(find.text('Credentials'), findsOneWidget);
    expect(find.text('TLS'), findsOneWidget);
    expect(_fieldText(tester, 'Server Address *'), 'vless.example.com');
    expect(_fieldText(tester, 'Server Port *'), '443');
    expect(
      _fieldText(tester, 'UUID *'),
      '00000000-0000-0000-0000-000000000000',
    );
  });

  testWidgets('adding a connection and an unused Tor follow the switch', (
    tester,
  ) async {
    // Hidden, everything stays listed but grayed out: adding a connection or
    // starting an unused Tor asks to show it first
    // (`connections.import_vpn_proxy`).
    Future<void> pump(GeneralSettings settings, {TorSettings? tor}) async {
      await tester.pumpWidget(
        ProviderScope(
          key: UniqueKey(),
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            generalSettingsWithDefaultsProvider.overrideWithValue(settings),
            singboxProxyProfilesRepositoryProvider.overrideWith(
              () => _FakeProfilesRepository([_profile(id: 'p', name: 'Kept')]),
            ),
            singboxProxyRuntimeRepositoryProvider.overrideWith(
              () => _FakeRuntimeRepository(
                SingboxProxyRuntimeState(
                  status: SingboxProxyRuntimeStatus.stopped,
                  endpoints: const [],
                ),
              ),
            ),
            torSettingsRepositoryProvider.overrideWith(
              () => _FakeTorSettingsRepository(tor),
            ),
            // Tor is stopped and nothing routes through it, for `torInUse`.
            torProxyServiceProvider.overrideWith(_StoppedTorProxyService.new),
            watchContainersWithCountProvider.overrideWith(
              (ref) => Stream.value(const []),
            ),
            proxyRoutingSettingsWithDefaultsProvider.overrideWithValue(
              ProxyRoutingSettings.withDefaults(),
            ),
          ],
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SingboxProxyProfilesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    final hidden = GeneralSettings.withDefaults().withVisibilitySwitch(
      VisibilitySwitch.connections,
      enabled: false,
    );

    Finder grayed(Finder finder) => find.ancestor(
      of: finder,
      matching: find.byWidgetPredicate(
        (widget) => widget is Opacity && widget.opacity == hiddenFeatureOpacity,
      ),
    );

    await pump(hidden);
    expect(find.text('Kept'), findsOneWidget);
    expect(grayed(find.text('Add Profile')), findsOneWidget);
    // An unused, stopped Tor is grayed out too.
    expect(grayed(find.byType(TorProfileTile)), findsOneWidget);

    // Set to start automatically — which may have failed — it stays usable,
    // so it can be repaired or turned off (P5).
    await pump(hidden, tor: TorSettings.withDefaults(autostart: true));
    expect(find.byType(TorProfileTile), findsOneWidget);
    expect(grayed(find.byType(TorProfileTile)), findsNothing);

    await pump(GeneralSettings.withDefaults());
    expect(find.text('Add Profile'), findsOneWidget);
    expect(grayed(find.text('Add Profile')), findsNothing);
    expect(grayed(find.byType(TorProfileTile)), findsNothing);
  });

  testWidgets('WireGuard config import populates WireGuard form fields', (
    tester,
  ) async {
    await _pumpEditor(
      tester,
      profilesRepository: _FakeProfilesRepository([]),
      seed: ProxyProfileSeed(
        type: SingboxProxyProfileType.wireguard,
        values: {
          'server': 'wg.example.com',
          'server_port': '51820',
          'local_address': '10.0.0.2/32',
          'private_key': 'private-key',
          'peer_public_key': 'peer-public-key',
        },
      ),
    );

    expect(_fieldText(tester, 'Server Address *'), 'wg.example.com');
    expect(_fieldText(tester, 'Server Port *'), '51820');
    expect(_fieldText(tester, 'Local Address *'), '10.0.0.2/32');
    expect(_fieldText(tester, 'Private Key *'), 'private-key');
  });
}

Future<void> _pumpEditor(
  WidgetTester tester, {
  required _FakeProfilesRepository profilesRepository,
  String? profileId,
  ProxyProfileSeed? seed,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // No onboarding owed: no draft, the displayed layer is the live one.
        completedOnboardingRevisionProvider.overrideWithValue(
          const AsyncData(OnboardingRepository.targetRevision),
        ),
        singboxProxyProfilesRepositoryProvider.overrideWith(
          () => profilesRepository,
        ),
        singboxProxyCredentialsRepositoryProvider.overrideWith(
          _FakeCredentialsRepository.new,
        ),
        // The editor reads which features are shown; the defaults show
        // every one, so the DNS override section is there.
        generalSettingsWithDefaultsProvider.overrideWith(
          (ref) => GeneralSettings.withDefaults(),
        ),
        singboxProxyRuntimeRepositoryProvider.overrideWith(
          () => _FakeRuntimeRepository(
            SingboxProxyRuntimeState(
              status: SingboxProxyRuntimeStatus.stopped,
              endpoints: const [],
            ),
          ),
        ),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SingboxProxyProfileEditorScreen(profileId: profileId, seed: seed),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

String _fieldText(WidgetTester tester, String labelText) {
  final textField = tester.widget<TextField>(
    find.ancestor(of: find.text(labelText), matching: find.byType(TextField)),
  );
  return textField.controller!.text;
}

ProxyProfile _profile({
  required String id,
  required String name,
  SingboxProxyProfileType type = SingboxProxyProfileType.customOutbound,
  String configJson = '{"type":"socks"}',
}) {
  final createdAt = DateTime(2026);

  return ProxyProfile(
    id: id,
    name: name,
    type: type,
    configJson: configJson,
    autostart: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

class _FakeProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;

  _FakeProfilesRepository(this.profiles);

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _FakeTorSettingsRepository extends TorSettingsRepository {
  _FakeTorSettingsRepository([TorSettings? settings])
    : _settings = settings ?? TorSettings.withDefaults();

  final TorSettings _settings;

  @override
  Stream<TorSettings> build() => Stream.value(_settings);
}

class _FakeCredentialsRepository extends SingboxProxyCredentialsRepository {
  @override
  Future<String?> readSecretJson(String profileId) async => null;

  @override
  void build() {}
}

class _FakeStartingConnections extends SingboxProxyStartingConnections {
  _FakeStartingConnections(this._starting);

  final Set<String> _starting;

  @override
  Set<String> build() => _starting;
}

class _FakeRuntimeRepository extends SingboxProxyRuntimeRepository {
  final SingboxProxyRuntimeState initialState;
  final deletedProfileIds = <String>[];

  _FakeRuntimeRepository(this.initialState);

  @override
  Future<SingboxProxyRuntimeState> build() async => initialState;

  @override
  Future<void> deleteProfile(String profileId) async {
    deletedProfileIds.add(profileId);
  }
}

class _StoppedTorProxyService extends TorProxyService {
  @override
  Stream<TorStatus> build() async* {
    yield TorStatus(isRunning: false, bootstrapProgress: 0);
  }
}
