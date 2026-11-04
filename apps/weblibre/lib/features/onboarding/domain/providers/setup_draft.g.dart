// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_draft.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetupDraftCWProxy {
  SetupDraft preset(SetupPreset preset);

  SetupDraft goals(Set<SetupGoal> goals);

  SetupDraft basicsEdits(List<UpdateGeneralSettingsFunc> basicsEdits);

  SetupDraft customizeEdits(List<UpdateGeneralSettingsFunc> customizeEdits);

  SetupDraft engineEdits(List<UpdateEngineSettingsFunc> engineEdits);

  SetupDraft layouts(Map<ModuleSurface, List<ModuleOrderEntry>> layouts);

  SetupDraft hardeningBaseline(bool? hardeningBaseline);

  SetupDraft installUBlock(bool? installUBlock);

  SetupDraft optimizedUBlockFilters(bool? optimizedUBlockFilters);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SetupDraft(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SetupDraft(...).copyWith(id: 12, name: "My name")
  /// ```
  SetupDraft call({
    SetupPreset preset,
    Set<SetupGoal> goals,
    List<UpdateGeneralSettingsFunc> basicsEdits,
    List<UpdateGeneralSettingsFunc> customizeEdits,
    List<UpdateEngineSettingsFunc> engineEdits,
    Map<ModuleSurface, List<ModuleOrderEntry>> layouts,
    bool? hardeningBaseline,
    bool? installUBlock,
    bool? optimizedUBlockFilters,
  });
}

/// Callable proxy for `copyWith` functionality.
/// Use as `instanceOfSetupDraft.copyWith(...)` or call `instanceOfSetupDraft.copyWith.fieldName(value)` for a single field.
class _$SetupDraftCWProxyImpl implements _$SetupDraftCWProxy {
  const _$SetupDraftCWProxyImpl(this._value);

  final SetupDraft _value;

  @override
  SetupDraft preset(SetupPreset preset) => call(preset: preset);

  @override
  SetupDraft goals(Set<SetupGoal> goals) => call(goals: goals);

  @override
  SetupDraft basicsEdits(List<UpdateGeneralSettingsFunc> basicsEdits) =>
      call(basicsEdits: basicsEdits);

  @override
  SetupDraft customizeEdits(List<UpdateGeneralSettingsFunc> customizeEdits) =>
      call(customizeEdits: customizeEdits);

  @override
  SetupDraft engineEdits(List<UpdateEngineSettingsFunc> engineEdits) =>
      call(engineEdits: engineEdits);

  @override
  SetupDraft layouts(Map<ModuleSurface, List<ModuleOrderEntry>> layouts) =>
      call(layouts: layouts);

  @override
  SetupDraft hardeningBaseline(bool? hardeningBaseline) =>
      call(hardeningBaseline: hardeningBaseline);

  @override
  SetupDraft installUBlock(bool? installUBlock) =>
      call(installUBlock: installUBlock);

  @override
  SetupDraft optimizedUBlockFilters(bool? optimizedUBlockFilters) =>
      call(optimizedUBlockFilters: optimizedUBlockFilters);

  /// Creates a new instance with the provided field values.
  /// Omitted fields keep their values; explicit `null` clears nullable fields.
  /// The public API rejects `null` for non-nullable fields. To update a single field use `SetupDraft(...).copyWith.fieldName(value)`.
  ///
  /// Example:
  /// ```dart
  /// SetupDraft(...).copyWith(id: 12, name: "My name")
  /// ```
  @override
  SetupDraft call({
    Object? preset = const $CopyWithPlaceholder(),
    Object? goals = const $CopyWithPlaceholder(),
    Object? basicsEdits = const $CopyWithPlaceholder(),
    Object? customizeEdits = const $CopyWithPlaceholder(),
    Object? engineEdits = const $CopyWithPlaceholder(),
    Object? layouts = const $CopyWithPlaceholder(),
    Object? hardeningBaseline = const $CopyWithPlaceholder(),
    Object? installUBlock = const $CopyWithPlaceholder(),
    Object? optimizedUBlockFilters = const $CopyWithPlaceholder(),
  }) {
    return SetupDraft(
      preset: preset == const $CopyWithPlaceholder() || preset == null
          ? _value.preset
          // ignore: cast_nullable_to_non_nullable
          : preset as SetupPreset,
      goals: goals == const $CopyWithPlaceholder() || goals == null
          ? _value.goals
          // ignore: cast_nullable_to_non_nullable
          : goals as Set<SetupGoal>,
      basicsEdits:
          basicsEdits == const $CopyWithPlaceholder() || basicsEdits == null
          ? _value.basicsEdits
          // ignore: cast_nullable_to_non_nullable
          : basicsEdits as List<UpdateGeneralSettingsFunc>,
      customizeEdits:
          customizeEdits == const $CopyWithPlaceholder() ||
              customizeEdits == null
          ? _value.customizeEdits
          // ignore: cast_nullable_to_non_nullable
          : customizeEdits as List<UpdateGeneralSettingsFunc>,
      engineEdits:
          engineEdits == const $CopyWithPlaceholder() || engineEdits == null
          ? _value.engineEdits
          // ignore: cast_nullable_to_non_nullable
          : engineEdits as List<UpdateEngineSettingsFunc>,
      layouts: layouts == const $CopyWithPlaceholder() || layouts == null
          ? _value.layouts
          // ignore: cast_nullable_to_non_nullable
          : layouts as Map<ModuleSurface, List<ModuleOrderEntry>>,
      hardeningBaseline: hardeningBaseline == const $CopyWithPlaceholder()
          ? _value.hardeningBaseline
          // ignore: cast_nullable_to_non_nullable
          : hardeningBaseline as bool?,
      installUBlock: installUBlock == const $CopyWithPlaceholder()
          ? _value.installUBlock
          // ignore: cast_nullable_to_non_nullable
          : installUBlock as bool?,
      optimizedUBlockFilters:
          optimizedUBlockFilters == const $CopyWithPlaceholder()
          ? _value.optimizedUBlockFilters
          // ignore: cast_nullable_to_non_nullable
          : optimizedUBlockFilters as bool?,
    );
  }
}

extension $SetupDraftCopyWith on SetupDraft {
  /// Returns a callable class used to build a new instance with modified fields.
  /// Example: `instanceOfSetupDraft.copyWith(...)` or `instanceOfSetupDraft.copyWith.fieldName(...)`.
  // ignore: library_private_types_in_public_api
  _$SetupDraftCWProxy get copyWith => _$SetupDraftCWProxyImpl(this);
}

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The onboarding's draft. The onboarding screen watches it while it is
/// mounted, which includes every route Customize pushes over it, so it ends
/// with the onboarding; [discard] ends it right after the commit, and a fresh
/// onboarding starts a fresh one.

@ProviderFor(SetupDraftController)
final setupDraftControllerProvider = SetupDraftControllerProvider._();

/// The onboarding's draft. The onboarding screen watches it while it is
/// mounted, which includes every route Customize pushes over it, so it ends
/// with the onboarding; [discard] ends it right after the commit, and a fresh
/// onboarding starts a fresh one.
final class SetupDraftControllerProvider
    extends $NotifierProvider<SetupDraftController, SetupDraft> {
  /// The onboarding's draft. The onboarding screen watches it while it is
  /// mounted, which includes every route Customize pushes over it, so it ends
  /// with the onboarding; [discard] ends it right after the commit, and a fresh
  /// onboarding starts a fresh one.
  SetupDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupDraftControllerHash();

  @$internal
  @override
  SetupDraftController create() => SetupDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetupDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetupDraft>(value),
    );
  }
}

String _$setupDraftControllerHash() =>
    r'92cbe1c8e447bdc5e2f8ea3063637e34c572c850';

/// The onboarding's draft. The onboarding screen watches it while it is
/// mounted, which includes every route Customize pushes over it, so it ends
/// with the onboarding; [discard] ends it right after the commit, and a fresh
/// onboarding starts a fresh one.

abstract class _$SetupDraftController extends $Notifier<SetupDraft> {
  SetupDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SetupDraft, SetupDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SetupDraft, SetupDraft>,
              SetupDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The general settings as they will be after the commit: the live settings
/// with the draft applied. What the onboarding's settings widgets show.
///
/// Reads the repository, never `storedGeneralSettingsProvider` or
/// `generalSettingsWithDefaultsProvider`: the draft scope overrides those
/// with this provider, and Riverpod detects
/// cycles by provider rather than by container. Watching it here would make
/// every rebuild after the first one throw a CircularDependencyError, although
/// the root and the scoped element are different.

@ProviderFor(draftGeneralSettings)
final draftGeneralSettingsProvider = DraftGeneralSettingsProvider._();

/// The general settings as they will be after the commit: the live settings
/// with the draft applied. What the onboarding's settings widgets show.
///
/// Reads the repository, never `storedGeneralSettingsProvider` or
/// `generalSettingsWithDefaultsProvider`: the draft scope overrides those
/// with this provider, and Riverpod detects
/// cycles by provider rather than by container. Watching it here would make
/// every rebuild after the first one throw a CircularDependencyError, although
/// the root and the scoped element are different.

final class DraftGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as they will be after the commit: the live settings
  /// with the draft applied. What the onboarding's settings widgets show.
  ///
  /// Reads the repository, never `storedGeneralSettingsProvider` or
  /// `generalSettingsWithDefaultsProvider`: the draft scope overrides those
  /// with this provider, and Riverpod detects
  /// cycles by provider rather than by container. Watching it here would make
  /// every rebuild after the first one throw a CircularDependencyError, although
  /// the root and the scoped element are different.
  DraftGeneralSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftGeneralSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftGeneralSettingsHash();

  @$internal
  @override
  $ProviderElement<GeneralSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GeneralSettings create(Ref ref) {
    return draftGeneralSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeneralSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeneralSettings>(value),
    );
  }
}

String _$draftGeneralSettingsHash() =>
    r'212e4f8b6d90b7ef80d6f360def8c3e588b55d95';

/// Like [draftGeneralSettings], for the engine settings, and for the same
/// reason reading the repository rather than `storedEngineSettingsProvider`
/// or `engineSettingsWithDefaultsProvider`.

@ProviderFor(draftEngineSettings)
final draftEngineSettingsProvider = DraftEngineSettingsProvider._();

/// Like [draftGeneralSettings], for the engine settings, and for the same
/// reason reading the repository rather than `storedEngineSettingsProvider`
/// or `engineSettingsWithDefaultsProvider`.

final class DraftEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// Like [draftGeneralSettings], for the engine settings, and for the same
  /// reason reading the repository rather than `storedEngineSettingsProvider`
  /// or `engineSettingsWithDefaultsProvider`.
  DraftEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftEngineSettingsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$draftEngineSettingsHash();

  @$internal
  @override
  $ProviderElement<EngineSettings> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  EngineSettings create(Ref ref) {
    return draftEngineSettings(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EngineSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EngineSettings>(value),
    );
  }
}

String _$draftEngineSettingsHash() =>
    r'9cd8e1079d66b0717fb1f2d1fb67ab345a751e18';
