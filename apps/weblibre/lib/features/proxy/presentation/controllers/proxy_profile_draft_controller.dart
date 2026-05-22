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
import 'dart:async';
import 'dart:convert';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter_singbox_proxy/flutter_singbox_proxy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/uuid.dart';
import 'package:weblibre/features/proxy/data/forms/singbox_form_specs.dart';
import 'package:weblibre/features/proxy/data/models/proxy_profile_seed.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_credentials.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_profiles.dart';
import 'package:weblibre/features/proxy/domain/repositories/singbox_proxy_runtime.dart';
import 'package:weblibre/features/user/data/database/definitions.drift.dart'
    show ProxyProfile;

part 'proxy_profile_draft_controller.g.dart';

const defaultCustomOutboundConfigJson = '''
{
  "type": "socks",
  "server": "127.0.0.1",
  "server_port": 1080
}''';

sealed class SaveOutcome {
  const SaveOutcome();
}

class SaveSucceeded extends SaveOutcome {
  const SaveSucceeded();
}

class SaveFailed extends SaveOutcome {
  final String message;

  const SaveFailed(this.message);
}

@CopyWith()
class ProxyProfileDraftState with FastEquatable {
  final String? profileId;
  final ProxyProfile? existingProfile;
  final String? loadError;
  final String name;
  final SingboxProxyProfileType type;
  final Map<String, String> values;
  final String? dnsOverrideJson;
  final String customConfigJson;
  final String customSecretJson;
  final bool isSaving;
  final bool secretLoaded;

  ProxyProfileDraftState({
    required this.profileId,
    required this.existingProfile,
    required this.loadError,
    required this.name,
    required this.type,
    required this.values,
    required this.dnsOverrideJson,
    required this.customConfigJson,
    required this.customSecretJson,
    required this.isSaving,
    required this.secretLoaded,
  });

  factory ProxyProfileDraftState.newProfile({ProxyProfileSeed? seed}) {
    final type = seed?.type ?? SingboxProxyProfileType.customOutbound;
    return ProxyProfileDraftState(
      profileId: null,
      existingProfile: null,
      loadError: null,
      name: seed?.name ?? '',
      type: type,
      values: _initialValuesForType(type, overlay: seed?.values),
      dnsOverrideJson: seed?.dnsOverrideJson,
      customConfigJson: defaultCustomOutboundConfigJson,
      customSecretJson: '',
      isSaving: false,
      secretLoaded: true,
    );
  }

  factory ProxyProfileDraftState.loadingExisting(String profileId) {
    return ProxyProfileDraftState(
      profileId: profileId,
      existingProfile: null,
      loadError: null,
      name: '',
      type: SingboxProxyProfileType.customOutbound,
      values: const {},
      dnsOverrideJson: null,
      customConfigJson: defaultCustomOutboundConfigJson,
      customSecretJson: '',
      isSaving: false,
      secretLoaded: false,
    );
  }

  bool get isEditing => profileId != null;

  bool get isLoading =>
      isEditing && existingProfile == null && loadError == null;

  @override
  List<Object?> get hashParameters => [
    profileId,
    existingProfile,
    loadError,
    name,
    type,
    values,
    dnsOverrideJson,
    customConfigJson,
    customSecretJson,
    isSaving,
    secretLoaded,
  ];
}

@riverpod
class ProxyProfileDraft extends _$ProxyProfileDraft {
  @override
  ProxyProfileDraftState build({String? profileId, ProxyProfileSeed? seed}) {
    if (profileId == null) {
      return ProxyProfileDraftState.newProfile(seed: seed);
    }

    unawaited(_loadExistingProfile(profileId));
    return ProxyProfileDraftState.loadingExisting(profileId);
  }

  Future<void> _loadExistingProfile(String profileId) async {
    try {
      final profile = await ref
          .read(singboxProxyProfilesRepositoryProvider.notifier)
          .findProfile(profileId);
      if (!ref.mounted) return;

      if (profile == null) {
        state = state.copyWith(
          loadError: 'Proxy profile not found.',
          secretLoaded: true,
        );
        return;
      }

      final secretJson = await ref
          .read(singboxProxyCredentialsRepositoryProvider.notifier)
          .readSecretJson(profile.id);
      if (!ref.mounted) return;

      final spec = singboxProxyFormSpecs[profile.type];
      state = state.copyWith(
        existingProfile: profile,
        name: profile.name,
        type: profile.type,
        values: spec == null
            ? const {}
            : spec.valuesFromJson(
                configJson: profile.configJson,
                secretJson: secretJson,
              ),
        dnsOverrideJson: profile.dnsOverrideJson,
        customConfigJson: profile.type == SingboxProxyProfileType.customOutbound
            ? profile.configJson
            : defaultCustomOutboundConfigJson,
        customSecretJson: profile.type == SingboxProxyProfileType.customOutbound
            ? secretJson ?? ''
            : '',
        secretLoaded: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        loadError: 'Failed to load proxy profile: $error',
        secretLoaded: true,
      );
    }
  }

  void setName(String name) {
    state = state.copyWith(name: name);
  }

  void setType(SingboxProxyProfileType type) {
    if (state.isEditing || state.type == type) return;
    state = state.copyWith(
      type: type,
      values: _initialValuesForType(type),
      customConfigJson: defaultCustomOutboundConfigJson,
      customSecretJson: '',
      secretLoaded: true,
    );
  }

  void setFieldValue(String key, String value) {
    state = state.copyWith(values: {...state.values, key: value});
  }

  void setDnsOverrideJson(String? json) {
    state = state.copyWith.dnsOverrideJson(json);
  }

  void setCustomConfigJson(String json) {
    state = state.copyWith(customConfigJson: json);
  }

  void setCustomSecretJson(String json) {
    state = state.copyWith(customSecretJson: json);
  }

  Future<SaveOutcome> save() async {
    if (state.isSaving) {
      return const SaveFailed('Profile is already saving.');
    }

    final draft = state;
    final trimmedName = draft.name.trim();
    if (trimmedName.isEmpty) {
      return const SaveFailed('Profile name is required.');
    }

    if (draft.isLoading) {
      return const SaveFailed('Profile is still loading, please wait.');
    }

    if (draft.loadError != null) {
      return SaveFailed(draft.loadError!);
    }

    final encoded = _encodeDraft(draft);
    switch (encoded) {
      case _DraftEncodeFailure(:final message):
        return SaveFailed(message);
      case _DraftEncodeSuccess(:final configJson, :final secretJson):
        state = state.copyWith(isSaving: true);

        try {
          final existing = draft.existingProfile;
          final profile = ProxyProfile(
            id: existing?.id ?? uuid.v4(),
            name: trimmedName,
            type: draft.type,
            configJson: configJson,
            dnsOverrideJson: draft.dnsOverrideJson,
            createdAt: existing?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final validationMessage = await ref
              .read(singboxProxyRuntimeRepositoryProvider.notifier)
              .validateProfileDraft(profile, secretJson: secretJson);
          if (validationMessage != null) {
            return SaveFailed(validationMessage);
          }

          if (existing == null) {
            await ref
                .read(singboxProxyProfilesRepositoryProvider.notifier)
                .createProfile(
                  name: trimmedName,
                  type: draft.type,
                  configJson: configJson,
                  secretJson: secretJson,
                  dnsOverrideJson: draft.dnsOverrideJson,
                );
          } else {
            await ref
                .read(singboxProxyProfilesRepositoryProvider.notifier)
                .updateProfile(profile);
            await ref
                .read(singboxProxyCredentialsRepositoryProvider.notifier)
                .writeSecretJson(profile.id, secretJson);
          }

          return const SaveSucceeded();
        } catch (error) {
          return SaveFailed('Failed to save proxy profile: $error');
        } finally {
          if (ref.mounted) {
            state = state.copyWith(isSaving: false);
          }
        }
    }
  }
}

sealed class _DraftEncodeResult {
  const _DraftEncodeResult();
}

class _DraftEncodeSuccess extends _DraftEncodeResult {
  final String configJson;
  final String? secretJson;

  const _DraftEncodeSuccess({
    required this.configJson,
    required this.secretJson,
  });
}

class _DraftEncodeFailure extends _DraftEncodeResult {
  final String message;

  const _DraftEncodeFailure(this.message);
}

/// Validates and encodes the draft into wire-format JSON in a single pass.
/// For custom-outbound profiles we only check JSON shape; for spec-driven
/// types the spec carries field-level validation.
_DraftEncodeResult _encodeDraft(ProxyProfileDraftState draft) {
  if (draft.type == SingboxProxyProfileType.customOutbound) {
    final normalizedConfigJson = _normalizeJsonObject(draft.customConfigJson);
    if (normalizedConfigJson == null) {
      return const _DraftEncodeFailure('Config must be a JSON object.');
    }

    final rawSecret = draft.customSecretJson.trim();
    if (rawSecret.isEmpty) {
      return _DraftEncodeSuccess(
        configJson: normalizedConfigJson,
        secretJson: null,
      );
    }
    final normalizedSecretJson = _normalizeJsonObject(draft.customSecretJson);
    if (normalizedSecretJson == null) {
      return const _DraftEncodeFailure('Secrets must be a JSON object.');
    }
    return _DraftEncodeSuccess(
      configJson: normalizedConfigJson,
      secretJson: normalizedSecretJson,
    );
  }

  final spec = singboxProxyFormSpecs[draft.type]!;
  final validationMessage = spec.validate(draft.values);
  if (validationMessage != null) {
    return _DraftEncodeFailure(validationMessage);
  }
  return _DraftEncodeSuccess(
    configJson: spec.toConfigJson(draft.values),
    secretJson: spec.toSecretJson(draft.values),
  );
}

String? _normalizeJsonObject(String rawJson) {
  try {
    final decoded = jsonDecode(rawJson) as Object?;
    if (decoded is! Map<String, dynamic>) {
      return null;
    }
    return const JsonEncoder.withIndent('  ').convert(decoded);
  } catch (_) {
    return null;
  }
}

Map<String, String> _initialValuesForType(
  SingboxProxyProfileType type, {
  Map<String, String>? overlay,
}) {
  final spec = singboxProxyFormSpecs[type];
  if (spec == null) return overlay == null ? const {} : Map.of(overlay);

  return {
    for (final field in spec.fields)
      if (field.defaultValue != null) field.key: field.defaultValue!,
    if (overlay != null) ...overlay,
  };
}
