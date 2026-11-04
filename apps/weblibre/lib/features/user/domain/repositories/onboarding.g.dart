// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

final class OnboardingRepositoryProvider
    extends $NotifierProvider<OnboardingRepository, void> {
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  OnboardingRepository create() => OnboardingRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$onboardingRepositoryHash() =>
    r'ef1050ec75641b1d2b08dd018fa344be09ccded3';

abstract class _$OnboardingRepository extends $Notifier<void> {
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

/// The last onboarding revision this profile completed, or null before the
/// first one. Follows the database, so a completed onboarding is seen by
/// everything that reads it without anyone refreshing it.

@ProviderFor(completedOnboardingRevision)
final completedOnboardingRevisionProvider =
    CompletedOnboardingRevisionProvider._();

/// The last onboarding revision this profile completed, or null before the
/// first one. Follows the database, so a completed onboarding is seen by
/// everything that reads it without anyone refreshing it.

final class CompletedOnboardingRevisionProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, Stream<int?>>
    with $FutureModifier<int?>, $StreamProvider<int?> {
  /// The last onboarding revision this profile completed, or null before the
  /// first one. Follows the database, so a completed onboarding is seen by
  /// everything that reads it without anyone refreshing it.
  CompletedOnboardingRevisionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'completedOnboardingRevisionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$completedOnboardingRevisionHash();

  @$internal
  @override
  $StreamProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<int?> create(Ref ref) {
    return completedOnboardingRevision(ref);
  }
}

String _$completedOnboardingRevisionHash() =>
    r'd75118fb85d1d8504aef8444f4138f03cef181d7';
