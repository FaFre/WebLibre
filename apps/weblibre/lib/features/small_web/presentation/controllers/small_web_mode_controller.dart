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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/features/geckoview/domain/providers/selected_tab.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/tab_mode.dart';
import 'package:weblibre/features/small_web/presentation/controllers/small_web_session_controller.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

part 'small_web_mode_controller.g.dart';

@Riverpod(keepAlive: true)
class SmallWebModeController extends _$SmallWebModeController {
  String? _smallWebTabId;

  @override
  String? build() {
    ref.listen(selectedTabProvider, (previous, next) {
      _handleSelectedTabChange(next);
    });

    ref.listen(tabListProvider, (previous, next) {
      if (_smallWebTabId != null && !next.value.contains(_smallWebTabId)) {
        _smallWebTabId = null;
        state = null;
      }
    });

    return null;
  }

  void _handleSelectedTabChange(String? selectedTabId) {
    if (selectedTabId == _smallWebTabId && _smallWebTabId != null) {
      state = _smallWebTabId;
    } else if (state != null) {
      state = null;
    }
  }

  Future<void> enter() async {
    if (state != null) return;

    if (_smallWebTabId != null &&
        ref.read(tabListProvider).value.contains(_smallWebTabId)) {
      await ref.read(tabRepositoryProvider.notifier).selectTab(_smallWebTabId!);
      return;
    }

    final settings = ref.read(generalSettingsWithDefaultsProvider);
    final tabMode = TabMode.fromTabType(settings.smallWebTabType);

    final newTabId = await ref
        .read(tabRepositoryProvider.notifier)
        .addTab(tabMode: tabMode, selectTab: true);

    if (!ref.mounted) return;

    _smallWebTabId = newTabId;
    state = newTabId;

    await ref.read(smallWebSessionControllerProvider.notifier).discover();
  }

  Future<void> exit() async {
    if (_smallWebTabId == null) return;

    final tabId = _smallWebTabId!;
    _smallWebTabId = null;
    state = null;

    await ref.read(tabRepositoryProvider.notifier).closeTab(tabId);
  }
}
