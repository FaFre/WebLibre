import 'package:flutter/material.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';
import 'package:weblibre/features/proxy/domain/providers/proxy_connection_options.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/proxy/presentation/controllers/ensure_proxy_started.dart';

void main() {
  testWidgets(
    'prompts and retries sing-box start when runtime provider is in error',
    (tester) async {
      final runtimeRepository = _ErrorRuntimeRepository();
      final container = ContainerData(
        id: 'container-1',
        color: Colors.blue,
        orderKey: 'a',
        metadata: ContainerMetadata.withDefaults(
          proxyConnectionId: const SingboxProxyConnectionId('profile-1'),
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            singboxProxyRuntimeRepositoryProvider.overrideWith(
              () => runtimeRepository,
            ),
            proxyConnectionOptionsProvider.overrideWith(
              (ref) => [
                ProxyConnectionOption(
                  id: const SingboxProxyConnectionId('profile-1'),
                  title: 'Mullvad',
                  subtitle: 'SOCKS',
                ),
              ],
            ),
          ],
          child: MaterialApp(home: _EnsureProxyHarness(container: container)),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open container'));
      await tester.pumpAndSettle();

      expect(find.text('Start Proxy Connection?'), findsOneWidget);
      expect(
        find.textContaining('This tab needs Mullvad'),
        findsOneWidget,
      );

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(runtimeRepository.startedProfileIds, ['profile-1']);
      expect(find.text('result:true'), findsOneWidget);
    },
  );
}

class _EnsureProxyHarness extends ConsumerStatefulWidget {
  final ContainerData container;

  const _EnsureProxyHarness({required this.container});

  @override
  ConsumerState<_EnsureProxyHarness> createState() =>
      _EnsureProxyHarnessState();
}

class _EnsureProxyHarnessState extends ConsumerState<_EnsureProxyHarness> {
  bool? _result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('result:${_result ?? 'pending'}'),
          TextButton(
            onPressed: () async {
              final result = await ensureProxyStartedForContainer(
                context,
                ref,
                widget.container,
              );
              if (!mounted) return;
              setState(() {
                _result = result;
              });
            },
            child: const Text('Open container'),
          ),
        ],
      ),
    );
  }
}

class _ErrorRuntimeRepository extends SingboxProxyRuntimeRepository {
  final startedProfileIds = <String>[];

  @override
  Future<SingboxProxyRuntimeState> build() {
    return Future<SingboxProxyRuntimeState>.error(StateError('runtime failed'));
  }

  @override
  Future<SingboxProxyRuntimeState> startProfile(
    String profileId, {
    SingboxProxyRuntimeOptions? options,
  }) async {
    startedProfileIds.add(profileId);
    return SingboxProxyRuntimeState(
      status: SingboxProxyRuntimeStatus.running,
      endpoints: [
        SingboxProxyRuntimeEndpoint(
          profileId: const SingboxProxyConnectionId('profile-1').encode(),
          host: '127.0.0.1',
          port: 1080,
          username: '',
          password: '',
        ),
      ],
    );
  }
}
