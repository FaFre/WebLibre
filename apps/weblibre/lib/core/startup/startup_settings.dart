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
 */
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/startup/models/startup_config.dart';
import 'package:weblibre/core/startup/startup_config_store.dart';

part 'startup_settings.g.dart';

/// The one writer for `startup_config.json`.
///
/// Global rather than per-profile on purpose: it decides which profile starts, so
/// storing it inside a profile would make the answer depend on the question. It
/// is deliberately not a `riverpod_persist` setting for the same reason — those
/// live in the profile's database, which is not open when this is read.
@Riverpod(keepAlive: true)
StartupConfigStore startupConfigStore(Ref ref) =>
    StartupConfigStore(filesystem.startupPaths);

/// Whether startup asks which profile to open.
@Riverpod(keepAlive: true)
class ProfilePromptSetting extends _$ProfilePromptSetting {
  @override
  Future<ProfilePromptMode> build() async {
    final config = await ref.watch(startupConfigStoreProvider).read();
    return config.profilePrompt;
  }

  Future<void> setMode(ProfilePromptMode mode) async {
    final config = await ref
        .read(startupConfigStoreProvider)
        .setProfilePrompt(mode);
    state = AsyncData(config.profilePrompt);
  }
}
