// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_commit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SetupCommitJournal _$SetupCommitJournalFromJson(Map<String, dynamic> json) =>
    SetupCommitJournal(
      general: json['general'] as Map<String, dynamic>,
      engine: json['engine'] as Map<String, dynamic>,
      hardeningBaseline: json['hardeningBaseline'] as bool,
      layouts: _layoutsFromJson(json['layouts'] as Map<String, dynamic>),
      toolbarButtons:
          (json['toolbarButtons'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>)
                  .map(
                    (e) => const _ToolbarButtonConfigConverter().fromJson(
                      e as Map<String, dynamic>,
                    ),
                  )
                  .toList(),
            ),
          ) ??
          const {},
      menuLayout: _menuLayoutFromJson(json['menuLayout']),
      steps: (json['steps'] as List<dynamic>)
          .map((e) => $enumDecode(_$SetupStepEnumMap, e))
          .toSet(),
      targetRevision: (json['targetRevision'] as num).toInt(),
    );

Map<String, dynamic> _$SetupCommitJournalToJson(SetupCommitJournal instance) =>
    <String, dynamic>{
      'general': instance.general,
      'engine': instance.engine,
      'hardeningBaseline': instance.hardeningBaseline,
      'layouts': _layoutsToJson(instance.layouts),
      'toolbarButtons': instance.toolbarButtons.map(
        (k, e) => MapEntry(
          k,
          e.map(const _ToolbarButtonConfigConverter().toJson).toList(),
        ),
      ),
      'menuLayout': _menuLayoutToJson(instance.menuLayout),
      'steps': instance.steps.map((e) => _$SetupStepEnumMap[e]!).toList(),
      'targetRevision': instance.targetRevision,
    };

const _$SetupStepEnumMap = {
  SetupStep.hardeningBaseline: 'hardeningBaseline',
  SetupStep.installUBlock: 'installUBlock',
  SetupStep.optimizedUBlockFilters: 'optimizedUBlockFilters',
};

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies an onboarding draft, once, and finishes an interrupted one.
///
/// 1. The draft is resolved against the current settings into a
///    [SetupCommitJournal], which is written durably.
/// 2. The journal is applied: settings, hardening, module layouts, toolbar
///    buttons, the menu. Each write is "set this to that", so applying it
///    again changes nothing. Hardening
///    the engine refuses does not stop the commit: it becomes an external
///    step ([SetupStep.hardeningBaseline]).
/// 3. The onboarding revision is pushed: from here on onboarding never shows
///    again.
/// 4. The external steps are scheduled, then the journal is deleted.
/// 5. The external steps run. One that fails stays scheduled for the next
///    start and is reported. [SetupStepRunner] runs nothing while a journal is
///    still open, so they never run ahead of an unfinished onboarding.
///
/// If the process dies anywhere in 2–4, [resumeInterrupted] finishes the
/// journal on the next start, before the router decides whether onboarding
/// is owed.
///
/// Visibility switches and module layouts are written as plain values: none
/// of the clean-up the old container and isolated-tab tiles ran is triggered
/// (P1).

@ProviderFor(SetupCommitService)
final setupCommitServiceProvider = SetupCommitServiceProvider._();

/// Applies an onboarding draft, once, and finishes an interrupted one.
///
/// 1. The draft is resolved against the current settings into a
///    [SetupCommitJournal], which is written durably.
/// 2. The journal is applied: settings, hardening, module layouts, toolbar
///    buttons, the menu. Each write is "set this to that", so applying it
///    again changes nothing. Hardening
///    the engine refuses does not stop the commit: it becomes an external
///    step ([SetupStep.hardeningBaseline]).
/// 3. The onboarding revision is pushed: from here on onboarding never shows
///    again.
/// 4. The external steps are scheduled, then the journal is deleted.
/// 5. The external steps run. One that fails stays scheduled for the next
///    start and is reported. [SetupStepRunner] runs nothing while a journal is
///    still open, so they never run ahead of an unfinished onboarding.
///
/// If the process dies anywhere in 2–4, [resumeInterrupted] finishes the
/// journal on the next start, before the router decides whether onboarding
/// is owed.
///
/// Visibility switches and module layouts are written as plain values: none
/// of the clean-up the old container and isolated-tab tiles ran is triggered
/// (P1).
final class SetupCommitServiceProvider
    extends $NotifierProvider<SetupCommitService, void> {
  /// Applies an onboarding draft, once, and finishes an interrupted one.
  ///
  /// 1. The draft is resolved against the current settings into a
  ///    [SetupCommitJournal], which is written durably.
  /// 2. The journal is applied: settings, hardening, module layouts, toolbar
  ///    buttons, the menu. Each write is "set this to that", so applying it
  ///    again changes nothing. Hardening
  ///    the engine refuses does not stop the commit: it becomes an external
  ///    step ([SetupStep.hardeningBaseline]).
  /// 3. The onboarding revision is pushed: from here on onboarding never shows
  ///    again.
  /// 4. The external steps are scheduled, then the journal is deleted.
  /// 5. The external steps run. One that fails stays scheduled for the next
  ///    start and is reported. [SetupStepRunner] runs nothing while a journal is
  ///    still open, so they never run ahead of an unfinished onboarding.
  ///
  /// If the process dies anywhere in 2–4, [resumeInterrupted] finishes the
  /// journal on the next start, before the router decides whether onboarding
  /// is owed.
  ///
  /// Visibility switches and module layouts are written as plain values: none
  /// of the clean-up the old container and isolated-tab tiles ran is triggered
  /// (P1).
  SetupCommitServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupCommitServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupCommitServiceHash();

  @$internal
  @override
  SetupCommitService create() => SetupCommitService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$setupCommitServiceHash() =>
    r'a3cca118aed61499cbb9de0aca8d6b48ab336a2c';

/// Applies an onboarding draft, once, and finishes an interrupted one.
///
/// 1. The draft is resolved against the current settings into a
///    [SetupCommitJournal], which is written durably.
/// 2. The journal is applied: settings, hardening, module layouts, toolbar
///    buttons, the menu. Each write is "set this to that", so applying it
///    again changes nothing. Hardening
///    the engine refuses does not stop the commit: it becomes an external
///    step ([SetupStep.hardeningBaseline]).
/// 3. The onboarding revision is pushed: from here on onboarding never shows
///    again.
/// 4. The external steps are scheduled, then the journal is deleted.
/// 5. The external steps run. One that fails stays scheduled for the next
///    start and is reported. [SetupStepRunner] runs nothing while a journal is
///    still open, so they never run ahead of an unfinished onboarding.
///
/// If the process dies anywhere in 2–4, [resumeInterrupted] finishes the
/// journal on the next start, before the router decides whether onboarding
/// is owed.
///
/// Visibility switches and module layouts are written as plain values: none
/// of the clean-up the old container and isolated-tab tiles ran is triggered
/// (P1).

abstract class _$SetupCommitService extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
