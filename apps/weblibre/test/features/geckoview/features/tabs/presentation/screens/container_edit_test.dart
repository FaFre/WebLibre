import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/presentation/screens/container_edit.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';

void main() {
  testWidgets(
    'clearing proxy selection does not leave cookie isolation enabled in create mode',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => const <ProxyConnectionOption>[],
            ),
          ],
          child: MaterialApp(
            home: ContainerEditScreen.create(
              initialContainer: ContainerData(
                id: 'container-1',
                color: Colors.blue,
                orderKey: 'a',
                metadata: ContainerMetadata.withDefaults(
                  proxyConnectionId: const SingboxProxyConnectionId('missing-proxy'),
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
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => const <ProxyConnectionOption>[],
            ),
          ],
          child: MaterialApp(
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
}
