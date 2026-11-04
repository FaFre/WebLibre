import 'package:flutter/material.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/browser/domain/repositories/site_permissions.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/widgets/sheets/permissions_section.dart';
import 'package:weblibre/l10n/generated/app_localizations.dart';

class _SitePermissionsRepository extends SitePermissionsRepository {
  @override
  Future<SitePermissions?> build({
    required String origin,
    required bool isPrivate,
  }) async => SitePermissions(
    origin: origin,
    savedAt: 0,
    persistentStorage: SitePermissionStatus.allowed,
  );
}

void main() {
  testWidgets(
    'explains saved site data protection and updates with the locale',
    (tester) async {
      final locale = ValueNotifier(const Locale('en'));
      addTearDown(locale.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sitePermissionsRepositoryProvider(
              origin: 'https://example.com',
              isPrivate: false,
            ).overrideWith(_SitePermissionsRepository.new),
          ],
          child: ValueListenableBuilder<Locale>(
            valueListenable: locale,
            builder: (context, locale, child) => MaterialApp(
              locale: locale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const Scaffold(
                body: SingleChildScrollView(
                  child: PermissionsSection(
                    origin: 'https://example.com',
                    isPrivate: false,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Protect Saved Site Data'), findsOneWidget);
      expect(
        find.text("Keep this site's data even when storage space is low."),
        findsOneWidget,
      );

      locale.value = const Locale('de');
      await tester.pumpAndSettle();

      expect(find.text('Protect Saved Site Data'), findsNothing);
      expect(find.text('Gespeicherte Website-Daten schützen'), findsOneWidget);
      expect(
        find.text(
          'Website-Daten auch bei wenig freiem Speicherplatz behalten.',
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
