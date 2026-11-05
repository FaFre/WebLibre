// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_steps.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Steps that have not finished yet, and the outcome of the last run.
///
/// Persisted in the profile's riverpod storage with awaited writes rather than
/// `persist()`: the schedule is a checkpoint, and the commit has to know it
/// landed before it marks the onboarding complete. A step that fails stays
/// scheduled and is retried on the next start ([resume]); [failed] reports it.

@ProviderFor(SetupStepRunner)
final setupStepRunnerProvider = SetupStepRunnerProvider._();

/// Steps that have not finished yet, and the outcome of the last run.
///
/// Persisted in the profile's riverpod storage with awaited writes rather than
/// `persist()`: the schedule is a checkpoint, and the commit has to know it
/// landed before it marks the onboarding complete. A step that fails stays
/// scheduled and is retried on the next start ([resume]); [failed] reports it.
final class SetupStepRunnerProvider
    extends $NotifierProvider<SetupStepRunner, Set<SetupStep>> {
  /// Steps that have not finished yet, and the outcome of the last run.
  ///
  /// Persisted in the profile's riverpod storage with awaited writes rather than
  /// `persist()`: the schedule is a checkpoint, and the commit has to know it
  /// landed before it marks the onboarding complete. A step that fails stays
  /// scheduled and is retried on the next start ([resume]); [failed] reports it.
  SetupStepRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'setupStepRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$setupStepRunnerHash();

  @$internal
  @override
  SetupStepRunner create() => SetupStepRunner();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<SetupStep> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<SetupStep>>(value),
    );
  }
}

String _$setupStepRunnerHash() => r'f326d3629e3ba5715a5ada45a78ffeb1469d7751';

/// Steps that have not finished yet, and the outcome of the last run.
///
/// Persisted in the profile's riverpod storage with awaited writes rather than
/// `persist()`: the schedule is a checkpoint, and the commit has to know it
/// landed before it marks the onboarding complete. A step that fails stays
/// scheduled and is retried on the next start ([resume]); [failed] reports it.

abstract class _$SetupStepRunner extends $Notifier<Set<SetupStep>> {
  Set<SetupStep> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<SetupStep>, Set<SetupStep>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<SetupStep>, Set<SetupStep>>,
              Set<SetupStep>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
