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
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/domain/feature_policy/feature_policy.dart';
import 'package:weblibre/features/user/data/models/engine_settings.dart';
import 'package:weblibre/features/user/data/models/general_settings.dart';
import 'package:weblibre/features/user/data/models/rfp_target.dart';
import 'package:weblibre/features/user/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/engine_settings.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/features/user/domain/services/fingerprinting.dart';

const _saved = '+WebGLRenderInfo';

class _HiddenGeneralSettings extends GeneralSettingsRepository {
  @override
  Stream<GeneralSettings> build() => Stream.value(
    VisibilitySwitch.values.fold(
      GeneralSettings.withDefaults(),
      (settings, visibilitySwitch) =>
          settings.withVisibilitySwitch(visibilitySwitch, enabled: false),
    ),
  );
}

class _SavedOverrides extends EngineSettingsRepository {
  @override
  Stream<EngineSettings> build() => Stream.value(
    EngineSettings.withDefaults(fingerprintingProtectionOverrides: _saved),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('the editor shows saved overrides while they are hidden', () async {
    final container = ProviderContainer(
      overrides: [
        generalSettingsRepositoryProvider.overrideWith(
          _HiddenGeneralSettings.new,
        ),
        engineSettingsRepositoryProvider.overrideWith(_SavedOverrides.new),
        fingerprintTargetsProvider.overrideWith(
          (ref) => Future.value([
            RFPTarget(name: 'WebGLRenderInfo', id: 1, keywords: const []),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(generalSettingsRepositoryProvider, (_, _) {})
      ..listen(engineSettingsRepositoryProvider, (_, _) {});
    await container.read(generalSettingsRepositoryProvider.future);
    await container.read(engineSettingsRepositoryProvider.future);

    // Hidden: the engine applies the default (H1)…
    expect(
      container
          .read(engineSettingsWithDefaultsProvider)
          .fingerprintingProtectionOverrides,
      isNot(_saved),
    );

    // …but the editor shows, and edits, what was saved.
    final overrides = await container.read(
      fingerprintOverrideSettingsProvider.future,
    );
    expect(overrides.value.toString(), _saved);
  });
}
