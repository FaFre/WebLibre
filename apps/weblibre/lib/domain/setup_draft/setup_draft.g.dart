// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_draft.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

abstract class _$SetupDraftCWProxy {
  SetupDraft preset(SetupPreset preset);

  SetupDraft goals(Set<SetupGoal> goals);

  SetupDraft edits(List<SetupEdit> edits);

  SetupDraft engineEdits(List<UpdateEngineSettingsFunc> engineEdits);

  SetupDraft layouts(Map<ModuleSurface, List<ModuleOrderEntry>> layouts);

  SetupDraft toolbarButtons(
    Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbarButtons,
  );

  SetupDraft menuLayout(List<MenuSectionEntry>? menuLayout);

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
    List<SetupEdit> edits,
    List<UpdateEngineSettingsFunc> engineEdits,
    Map<ModuleSurface, List<ModuleOrderEntry>> layouts,
    Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbarButtons,
    List<MenuSectionEntry>? menuLayout,
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
  SetupDraft edits(List<SetupEdit> edits) => call(edits: edits);

  @override
  SetupDraft engineEdits(List<UpdateEngineSettingsFunc> engineEdits) =>
      call(engineEdits: engineEdits);

  @override
  SetupDraft layouts(Map<ModuleSurface, List<ModuleOrderEntry>> layouts) =>
      call(layouts: layouts);

  @override
  SetupDraft toolbarButtons(
    Map<ToolbarConfigLocation, List<ToolbarButtonConfig>> toolbarButtons,
  ) => call(toolbarButtons: toolbarButtons);

  @override
  SetupDraft menuLayout(List<MenuSectionEntry>? menuLayout) =>
      call(menuLayout: menuLayout);

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
    Object? edits = const $CopyWithPlaceholder(),
    Object? engineEdits = const $CopyWithPlaceholder(),
    Object? layouts = const $CopyWithPlaceholder(),
    Object? toolbarButtons = const $CopyWithPlaceholder(),
    Object? menuLayout = const $CopyWithPlaceholder(),
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
      edits: edits == const $CopyWithPlaceholder() || edits == null
          ? _value.edits
          // ignore: cast_nullable_to_non_nullable
          : edits as List<SetupEdit>,
      engineEdits:
          engineEdits == const $CopyWithPlaceholder() || engineEdits == null
          ? _value.engineEdits
          // ignore: cast_nullable_to_non_nullable
          : engineEdits as List<UpdateEngineSettingsFunc>,
      layouts: layouts == const $CopyWithPlaceholder() || layouts == null
          ? _value.layouts
          // ignore: cast_nullable_to_non_nullable
          : layouts as Map<ModuleSurface, List<ModuleOrderEntry>>,
      toolbarButtons:
          toolbarButtons == const $CopyWithPlaceholder() ||
              toolbarButtons == null
          ? _value.toolbarButtons
          // ignore: cast_nullable_to_non_nullable
          : toolbarButtons
                as Map<ToolbarConfigLocation, List<ToolbarButtonConfig>>,
      menuLayout: menuLayout == const $CopyWithPlaceholder()
          ? _value.menuLayout
          // ignore: cast_nullable_to_non_nullable
          : menuLayout as List<MenuSectionEntry>?,
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
/// The onboarding's draft: open while a fresh onboarding is owed, null
/// otherwise.
///
/// It opens and closes by itself, from the profile's onboarding revision
/// rather than from a route or widget: a profile that never completed an
/// onboarding gets a fresh draft, and the commit's `pushRevision` closes it.
/// A review after an update has a revision, so it never gets one and its
/// edits land in the profile directly. Kept alive because the edit layer's
/// kept-alive providers (`storedGeneralSettings` and the save controllers)
/// follow it.
///
/// [build] must watch nothing but that one answer, and keeps the open draft
/// across its rebuilds: while the revision is unknown (reloading, failed) the
/// draft stays as it is, open or closed, rather than dropping the user's
/// choices and every edit made until it is known again.
///
/// Only the edit and displayed layers may read it, never the live layer
/// services behave by: nothing reaches the browser before Done.

@ProviderFor(SetupDraftController)
final setupDraftControllerProvider = SetupDraftControllerProvider._();

/// The onboarding's draft: open while a fresh onboarding is owed, null
/// otherwise.
///
/// It opens and closes by itself, from the profile's onboarding revision
/// rather than from a route or widget: a profile that never completed an
/// onboarding gets a fresh draft, and the commit's `pushRevision` closes it.
/// A review after an update has a revision, so it never gets one and its
/// edits land in the profile directly. Kept alive because the edit layer's
/// kept-alive providers (`storedGeneralSettings` and the save controllers)
/// follow it.
///
/// [build] must watch nothing but that one answer, and keeps the open draft
/// across its rebuilds: while the revision is unknown (reloading, failed) the
/// draft stays as it is, open or closed, rather than dropping the user's
/// choices and every edit made until it is known again.
///
/// Only the edit and displayed layers may read it, never the live layer
/// services behave by: nothing reaches the browser before Done.
final class SetupDraftControllerProvider
    extends $NotifierProvider<SetupDraftController, SetupDraft?> {
  /// The onboarding's draft: open while a fresh onboarding is owed, null
  /// otherwise.
  ///
  /// It opens and closes by itself, from the profile's onboarding revision
  /// rather than from a route or widget: a profile that never completed an
  /// onboarding gets a fresh draft, and the commit's `pushRevision` closes it.
  /// A review after an update has a revision, so it never gets one and its
  /// edits land in the profile directly. Kept alive because the edit layer's
  /// kept-alive providers (`storedGeneralSettings` and the save controllers)
  /// follow it.
  ///
  /// [build] must watch nothing but that one answer, and keeps the open draft
  /// across its rebuilds: while the revision is unknown (reloading, failed) the
  /// draft stays as it is, open or closed, rather than dropping the user's
  /// choices and every edit made until it is known again.
  ///
  /// Only the edit and displayed layers may read it, never the live layer
  /// services behave by: nothing reaches the browser before Done.
  SetupDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupDraftControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupDraftControllerHash();

  @$internal
  @override
  SetupDraftController create() => SetupDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SetupDraft? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SetupDraft?>(value),
    );
  }
}

String _$setupDraftControllerHash() =>
    r'c303f118efe81756022e10f346728a5fc0811bc5';

/// The onboarding's draft: open while a fresh onboarding is owed, null
/// otherwise.
///
/// It opens and closes by itself, from the profile's onboarding revision
/// rather than from a route or widget: a profile that never completed an
/// onboarding gets a fresh draft, and the commit's `pushRevision` closes it.
/// A review after an update has a revision, so it never gets one and its
/// edits land in the profile directly. Kept alive because the edit layer's
/// kept-alive providers (`storedGeneralSettings` and the save controllers)
/// follow it.
///
/// [build] must watch nothing but that one answer, and keeps the open draft
/// across its rebuilds: while the revision is unknown (reloading, failed) the
/// draft stays as it is, open or closed, rather than dropping the user's
/// choices and every edit made until it is known again.
///
/// Only the edit and displayed layers may read it, never the live layer
/// services behave by: nothing reaches the browser before Done.

abstract class _$SetupDraftController extends $Notifier<SetupDraft?> {
  SetupDraft? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SetupDraft?, SetupDraft?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SetupDraft?, SetupDraft?>,
              SetupDraft?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The general settings as they will be after the commit: the profile's
/// with the draft applied, or the profile's while no draft is open. What the
/// onboarding's settings widgets show.

@ProviderFor(draftGeneralSettings)
final draftGeneralSettingsProvider = DraftGeneralSettingsProvider._();

/// The general settings as they will be after the commit: the profile's
/// with the draft applied, or the profile's while no draft is open. What the
/// onboarding's settings widgets show.

final class DraftGeneralSettingsProvider
    extends
        $FunctionalProvider<GeneralSettings, GeneralSettings, GeneralSettings>
    with $Provider<GeneralSettings> {
  /// The general settings as they will be after the commit: the profile's
  /// with the draft applied, or the profile's while no draft is open. What the
  /// onboarding's settings widgets show.
  DraftGeneralSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftGeneralSettingsProvider',
        isAutoDispose: false,
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
    r'e33d0a19d8fc25c6fdefcb2301acbcd20651c124';

/// Like [draftGeneralSettings], for the engine settings.

@ProviderFor(draftEngineSettings)
final draftEngineSettingsProvider = DraftEngineSettingsProvider._();

/// Like [draftGeneralSettings], for the engine settings.

final class DraftEngineSettingsProvider
    extends $FunctionalProvider<EngineSettings, EngineSettings, EngineSettings>
    with $Provider<EngineSettings> {
  /// Like [draftGeneralSettings], for the engine settings.
  DraftEngineSettingsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'draftEngineSettingsProvider',
        isAutoDispose: false,
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
    r'57fc1f2b2fc581aa4f45e8abde3047df4913f839';
