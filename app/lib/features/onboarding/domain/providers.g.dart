// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(OnboardingModeNotifier)
final onboardingModeProvider = OnboardingModeNotifierProvider._();

final class OnboardingModeNotifierProvider
    extends $NotifierProvider<OnboardingModeNotifier, OnboardingMode> {
  OnboardingModeNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingModeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingModeNotifierHash();

  @$internal
  @override
  OnboardingModeNotifier create() => OnboardingModeNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingMode value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingMode>(value),
    );
  }
}

String _$onboardingModeNotifierHash() =>
    r'bbb8e7ec1c85699566750d90c92c273e031d654b';

abstract class _$OnboardingModeNotifier extends $Notifier<OnboardingMode> {
  OnboardingMode build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<OnboardingMode, OnboardingMode>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingMode, OnboardingMode>,
              OnboardingMode,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(EulaAcceptedNotifier)
final eulaAcceptedProvider = EulaAcceptedNotifierProvider._();

final class EulaAcceptedNotifierProvider
    extends $NotifierProvider<EulaAcceptedNotifier, bool> {
  EulaAcceptedNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eulaAcceptedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eulaAcceptedNotifierHash();

  @$internal
  @override
  EulaAcceptedNotifier create() => EulaAcceptedNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$eulaAcceptedNotifierHash() =>
    r'dafd708ac5cb586e8ca9cccc6d708598c5daab0e';

abstract class _$EulaAcceptedNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
