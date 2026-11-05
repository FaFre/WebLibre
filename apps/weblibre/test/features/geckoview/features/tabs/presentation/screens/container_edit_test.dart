import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_edit.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/onboarding.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';
import 'package:weblibre/presentation/widgets/hidden_feature_gate.dart';

void main() {
  testWidgets(
    'clearing proxy selection does not leave cookie isolation enabled in create mode',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            // The visibility switches are read from the settings; without this a
            // real settings database opens and outlives the test.
            generalSettingsWithDefaultsProvider.overrideWithValue(
              GeneralSettings.withDefaults(),
            ),
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => const <ProxyConnectionOption>[],
            ),
            singboxProxyProfilesRepositoryProvider.overrideWith(
              () => _LoadedProfilesRepository(const []),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ContainerEditScreen.create(
              initialContainer: ContainerData(
                id: 'container-1',
                color: Colors.blue,
                orderKey: 'a',
                metadata: ContainerMetadata.withDefaults(
                  proxyConnectionId: const SingboxProxyConnectionId(
                    'missing-proxy',
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proxy Connection'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      final cookieIsolationTile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Cookie Isolation'),
      );

      expect(cookieIsolationTile.value, isFalse);
      expect(find.text('None'), findsOneWidget);
    },
  );

  testWidgets(
    'dismissing proxy picker does not leave cookie isolation enabled in create mode',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            // The visibility switches are read from the settings; without this a
            // real settings database opens and outlives the test.
            generalSettingsWithDefaultsProvider.overrideWithValue(
              GeneralSettings.withDefaults(),
            ),
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => const <ProxyConnectionOption>[],
            ),
            singboxProxyProfilesRepositoryProvider.overrideWith(
              () => _LoadedProfilesRepository(const []),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ContainerEditScreen.create(
              initialContainer: ContainerData(
                id: 'container-1',
                color: Colors.blue,
                orderKey: 'a',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Proxy Connection'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      final cookieIsolationTile = tester.widget<SwitchListTile>(
        find.widgetWithText(SwitchListTile, 'Cookie Isolation'),
      );

      expect(cookieIsolationTile.value, isFalse);
      expect(find.text('New Container'), findsOneWidget);
    },
  );

  testWidgets('does not offer to clear selected proxy while profiles load', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No onboarding owed: no draft, the displayed layer is the live one.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          // The visibility switches are read from the settings; without this a
          // real settings database opens and outlives the test.
          generalSettingsWithDefaultsProvider.overrideWithValue(
            GeneralSettings.withDefaults(),
          ),
          proxyConnectionOptionsProvider.overrideWith(
            (ref) => const <ProxyConnectionOption>[],
          ),
          singboxProxyProfilesRepositoryProvider.overrideWith(
            () => _LoadingProfilesRepository(),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerEditScreen.create(
            initialContainer: ContainerData(
              id: 'container-1',
              color: Colors.blue,
              orderKey: 'a',
              metadata: ContainerMetadata.withDefaults(
                proxyConnectionId: const SingboxProxyConnectionId('profile-1'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Loading proxy...'), findsOneWidget);

    await tester.tap(find.text('Proxy Connection'));
    await tester.pumpAndSettle();

    expect(find.text('Unknown proxy'), findsNothing);
    expect(find.text('Clear'), findsNothing);
  });

  testWidgets('hidden options are left out, even one that is on', (
    tester,
  ) async {
    // Expert details hidden: strict mode, app links and the bypass are
    // hidden, and so is the proxy row with connections off. Strict mode is
    // on, but does not apply while hidden, so it is left out too.
    final settings = GeneralSettings.withDefaults()
        .withVisibilitySwitch(VisibilitySwitch.expertDetails, enabled: false)
        .withVisibilitySwitch(VisibilitySwitch.connections, enabled: false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // No onboarding owed: no draft, the displayed layer is the live one.
          completedOnboardingRevisionProvider.overrideWithValue(
            const AsyncData(OnboardingRepository.targetRevision),
          ),
          generalSettingsWithDefaultsProvider.overrideWithValue(settings),
          proxyConnectionOptionsProvider.overrideWith(
            (ref) => const <ProxyConnectionOption>[],
          ),
          singboxProxyProfilesRepositoryProvider.overrideWith(
            () => _LoadedProfilesRepository(const []),
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ContainerEditScreen.edit(
            initialContainer: ContainerDataWithCount(
              id: 'container-1',
              color: Colors.blue,
              orderKey: 'a',
              tabCount: 0,
              metadata: ContainerMetadata.withDefaults(
                contextualIdentity: 'context-1',
                strictMode: true,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Strict Mode'), findsNothing);
    expect(find.text('Proxy Connection'), findsNothing);
    expect(find.text('Bypass Global Proxy'), findsNothing);
    expect(find.text('Isolated App Link Settings'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Opacity && widget.opacity == hiddenFeatureOpacity,
      ),
      findsNothing,
    );
  });

  group('editing a container without cookie isolation', () {
    Future<void> pumpEditScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            // No onboarding owed: no draft, the displayed layer is the live one.
            completedOnboardingRevisionProvider.overrideWithValue(
              const AsyncData(OnboardingRepository.targetRevision),
            ),
            // The visibility switches are read from the settings; without this a
            // real settings database opens and outlives the test.
            generalSettingsWithDefaultsProvider.overrideWithValue(
              GeneralSettings.withDefaults(),
            ),
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => const <ProxyConnectionOption>[],
            ),
            singboxProxyProfilesRepositoryProvider.overrideWith(
              () => _LoadedProfilesRepository(const []),
            ),
          ],
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: ContainerEditScreen.edit(
              initialContainer: ContainerDataWithCount(
                id: 'container-1',
                color: Colors.blue,
                orderKey: 'a',
                tabCount: 0,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('says why the proxy row is locked', (tester) async {
      await pumpEditScreen(tester);

      final proxyTile = find.widgetWithText(ListTile, 'Proxy Connection');
      expect(
        find.descendant(
          of: proxyTile,
          matching: find.text('Requires cookie isolation to be enabled'),
        ),
        findsOneWidget,
      );

      await tester.ensureVisible(proxyTile);
      await tester.pumpAndSettle();
      await tester.tap(proxyTile);
      await tester.pumpAndSettle();

      expect(find.text('Cookie isolation is off'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      expect(find.text('Cookie isolation is off'), findsNothing);
    });

    testWidgets('explains a locked switch instead of ignoring the tap', (
      tester,
    ) async {
      await pumpEditScreen(tester);

      final strictModeTile = find.widgetWithText(SwitchListTile, 'Strict Mode');
      await tester.ensureVisible(strictModeTile);
      await tester.pumpAndSettle();
      await tester.tap(strictModeTile);
      await tester.pumpAndSettle();

      expect(find.text('Cookie isolation is off'), findsOneWidget);
      expect(tester.widget<SwitchListTile>(strictModeTile).value, isFalse);
    });

    testWidgets('opens the explanation from the keyboard', (tester) async {
      await pumpEditScreen(tester);

      final proxyTile = find.widgetWithText(ListTile, 'Proxy Connection');
      await tester.ensureVisible(proxyTile);
      await tester.pumpAndSettle();
      final wrapper = tester.element(
        find.ancestor(of: proxyTile, matching: find.byType(InkWell)).first,
      );

      bool wrapperFocused() {
        final focused = FocusManager.instance.primaryFocus?.context;
        if (focused == null) return false;
        if (focused == wrapper) return true;
        var found = false;
        focused.visitAncestorElements((element) {
          found = element == wrapper;
          return !found;
        });
        return found;
      }

      for (var i = 0; i < 20 && !wrapperFocused(); i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
      }
      expect(wrapperFocused(), isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      expect(find.text('Cookie isolation is off'), findsOneWidget);
    });
  });
}

class _LoadedProfilesRepository extends SingboxProxyProfilesRepository {
  final List<ProxyProfile> profiles;

  _LoadedProfilesRepository(this.profiles);

  @override
  Stream<List<ProxyProfile>> build() => Stream.value(profiles);
}

class _LoadingProfilesRepository extends SingboxProxyProfilesRepository {
  @override
  Stream<List<ProxyProfile>> build() async* {
    await Completer<void>().future;
  }
}
