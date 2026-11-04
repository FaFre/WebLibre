/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/misc.dart' show ProviderListenable;
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/proxy_diagnostics_settings.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/repositories/proxy_diagnostics_settings.dart';

class _General extends GeneralSettingsRepository {
  _General(this.initial);

  final GeneralSettings initial;

  @override
  Stream<GeneralSettings> build() => Stream.value(initial);

  void set(GeneralSettings settings) => state = AsyncData(settings);
}

class _Engine extends EngineSettingsRepository {
  @override
  Stream<EngineSettings> build() => Stream.value(
    EngineSettings.withDefaults(
      javascriptEnabled: false,
      userAgent: 'Custom/1.0',
      enterpriseRootsEnabled: true,
      httpsOnlyMode: HttpsOnlyMode.disabled,
    ),
  );
}

class _Diagnostics extends ProxyDiagnosticsSettingsRepository {
  @override
  Stream<ProxyDiagnosticsSettings> build() => Stream.value(
    ProxyDiagnosticsSettings.withDefaults(logLevel: ProxyLogLevel.debug),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final hidden = GeneralSettings.withDefaults().withVisibilitySwitch(
    VisibilitySwitch.expertDetails,
    enabled: false,
  );

  late ProviderContainer container;
  late _General general;

  setUp(() {
    general = _General(hidden);
    container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(() => general),
        engineSettingsRepositoryProvider.overrideWith(_Engine.new),
        proxyDiagnosticsSettingsRepositoryProvider.overrideWith(
          _Diagnostics.new,
        ),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<List<T?>> record<T>(ProviderListenable<T?> provider) async {
    final values = <T?>[];
    final subscription = container.listen(
      provider,
      (_, next) => values.add(next),
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    await pumpEventQueue();
    return values;
  }

  test('the engine gets the hidden values while hidden, the stored ones '
      'once shown again', () async {
    final values = await record(loadedEngineSettingsProvider);
    // Nothing until both partitions have loaded.
    expect(values.first, isNull);

    final whileHidden = values.last!;
    expect(whileHidden.javascriptEnabled, isTrue);
    expect(whileHidden.userAgent, isNull);
    expect(whileHidden.enterpriseRootsEnabled, isFalse);
    // Advanced privacy is shown: its change applies.
    expect(whileHidden.httpsOnlyMode, HttpsOnlyMode.disabled);

    general.set(
      hidden.withVisibilitySwitch(
        VisibilitySwitch.expertDetails,
        enabled: true,
      ),
    );
    await pumpEventQueue();

    final shown = values.last!;
    expect(shown.javascriptEnabled, isFalse);
    expect(shown.userAgent, 'Custom/1.0');
    expect(shown.enterpriseRootsEnabled, isTrue);
  });

  test('the proxy log level follows the switch too', () async {
    final values = await record(loadedProxyLogLevelProvider);
    expect(values.last, ProxyLogLevel.warn);

    general.set(
      hidden.withVisibilitySwitch(
        VisibilitySwitch.expertDetails,
        enabled: true,
      ),
    );
    await pumpEventQueue();
    expect(values.last, ProxyLogLevel.debug);
  });

  test('settings screens read the stored values', () async {
    await record(loadedEngineSettingsProvider);
    expect(
      container.read(storedEngineSettingsProvider).javascriptEnabled,
      false,
    );
    expect(
      container.read(engineSettingsWithDefaultsProvider).javascriptEnabled,
      true,
    );
  });
}
