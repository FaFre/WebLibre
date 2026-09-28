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
import 'package:weblibre/features/proxy/data/forms/singbox_form_spec.dart';
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
  final ProxyProfileSaveError error;

  const SaveFailed(this.error);
}

/// Why an existing profile failed to load, kept as data (not a formatted
/// [String]) so [AppLocalizations]/[BuildContext] never has to reach this
/// controller — resolved to display text in
/// `presentation/utils/proxy_profile_draft_error_l10n.dart`. A plain class
/// (not a formatted message) because [ProxyProfileDraftState] compares it via
/// [FastEquatable], which needs real `==`/`hashCode`.
sealed class ProxyProfileLoadError {
  const ProxyProfileLoadError();
}

class ProxyProfileNotFoundError extends ProxyProfileLoadError {
  const ProxyProfileNotFoundError();

  @override
  bool operator ==(Object other) => other is ProxyProfileNotFoundError;

  @override
  int get hashCode => (ProxyProfileNotFoundError).hashCode;
}

class ProxyProfileLoadFailedError extends ProxyProfileLoadError {
  final Object error;

  const ProxyProfileLoadFailedError(this.error);

  @override
  bool operator ==(Object other) =>
      other is ProxyProfileLoadFailedError && other.error == error;

  @override
  int get hashCode => error.hashCode;
}

/// Why [ProxyProfileDraft.save] failed, kept as data for the same reason as
/// [ProxyProfileLoadError] — this controller has no [BuildContext] to
/// localize a message with. Resolved to display text in
/// `presentation/utils/proxy_profile_draft_error_l10n.dart`.
sealed class ProxyProfileSaveError {
  const ProxyProfileSaveError();
}

class ProxyProfileSaveAlreadySaving extends ProxyProfileSaveError {
  const ProxyProfileSaveAlreadySaving();
}

class ProxyProfileSaveNameRequired extends ProxyProfileSaveError {
  const ProxyProfileSaveNameRequired();
}

class ProxyProfileSaveStillLoading extends ProxyProfileSaveError {
  const ProxyProfileSaveStillLoading();
}

class ProxyProfileSaveLoadFailed extends ProxyProfileSaveError {
  final ProxyProfileLoadError loadError;

  const ProxyProfileSaveLoadFailed(this.loadError);
}

class ProxyProfileSaveConfigNotJson extends ProxyProfileSaveError {
  const ProxyProfileSaveConfigNotJson();
}

class ProxyProfileSaveSecretsNotJson extends ProxyProfileSaveError {
  const ProxyProfileSaveSecretsNotJson();
}

class ProxyProfileSaveFieldValidation extends ProxyProfileSaveError {
  final SingboxFormFieldError fieldError;

  const ProxyProfileSaveFieldValidation(this.fieldError);
}

/// The runtime (sing-box) rejected the encoded config. [nativeMessage] comes
/// straight from the native plugin, so it is not further localized — same
/// treatment as any other external/native error text in this app.
class ProxyProfileSaveRuntimeInvalid extends ProxyProfileSaveError {
  final String nativeMessage;

  const ProxyProfileSaveRuntimeInvalid(this.nativeMessage);
}

class ProxyProfileSaveUnexpectedError extends ProxyProfileSaveError {
  final Object error;

  const ProxyProfileSaveUnexpectedError(this.error);
}

@CopyWith()
class ProxyProfileDraftState with FastEquatable {
  final String? profileId;
  final ProxyProfile? existingProfile;
  final ProxyProfileLoadError? loadError;
  final String name;
  final SingboxProxyProfileType type;
  final Map<String, String> values;
  final String? dnsOverrideJson;
  final String customConfigJson;
  final String customSecretJson;
  final bool autostart;
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
    required this.autostart,
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
      autostart: false,
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
      autostart: false,
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
    autostart,
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
          loadError: const ProxyProfileNotFoundError(),
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
        autostart: profile.autostart,
        secretLoaded: true,
      );
    } catch (error) {
      if (!ref.mounted) return;
      state = state.copyWith(
        loadError: ProxyProfileLoadFailedError(error),
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

  void setAutostart(bool autostart) {
    state = state.copyWith(autostart: autostart);
  }

  Future<SaveOutcome> save() async {
    if (state.isSaving) {
      return const SaveFailed(ProxyProfileSaveAlreadySaving());
    }

    final draft = state;
    final trimmedName = draft.name.trim();
    if (trimmedName.isEmpty) {
      return const SaveFailed(ProxyProfileSaveNameRequired());
    }

    if (draft.isLoading) {
      return const SaveFailed(ProxyProfileSaveStillLoading());
    }

    if (draft.loadError != null) {
      return SaveFailed(ProxyProfileSaveLoadFailed(draft.loadError!));
    }

    final encoded = _encodeDraft(draft);
    switch (encoded) {
      case _DraftEncodeFailure(:final error):
        return SaveFailed(error);
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
            autostart: draft.autostart,
            createdAt: existing?.createdAt ?? DateTime.now(),
            updatedAt: DateTime.now(),
          );

          final validationMessage = await ref
              .read(singboxProxyRuntimeRepositoryProvider.notifier)
              .validateProfileDraft(profile, secretJson: secretJson);
          if (validationMessage != null) {
            return SaveFailed(
              ProxyProfileSaveRuntimeInvalid(validationMessage),
            );
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
                  autostart: draft.autostart,
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
          return SaveFailed(ProxyProfileSaveUnexpectedError(error));
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
  final ProxyProfileSaveError error;

  const _DraftEncodeFailure(this.error);
}

/// Validates and encodes the draft into wire-format JSON in a single pass.
/// For custom-outbound profiles we only check JSON shape; for spec-driven
/// types the spec carries field-level validation.
_DraftEncodeResult _encodeDraft(ProxyProfileDraftState draft) {
  if (draft.type == SingboxProxyProfileType.customOutbound) {
    final normalizedConfigJson = _normalizeJsonObject(draft.customConfigJson);
    if (normalizedConfigJson == null) {
      return const _DraftEncodeFailure(ProxyProfileSaveConfigNotJson());
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
      return const _DraftEncodeFailure(ProxyProfileSaveSecretsNotJson());
    }
    return _DraftEncodeSuccess(
      configJson: normalizedConfigJson,
      secretJson: normalizedSecretJson,
    );
  }

  final spec = singboxProxyFormSpecs[draft.type]!;
  final fieldError = spec.validate(draft.values);
  if (fieldError != null) {
    return _DraftEncodeFailure(ProxyProfileSaveFieldValidation(fieldError));
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
    ...?overlay,
  };
}
