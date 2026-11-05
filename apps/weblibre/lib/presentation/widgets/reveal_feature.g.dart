// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reveal_feature.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Visibility switches the user declined to show when a deliberate action
/// needed them. The question is asked once per switch; after a "no",
/// the same action only points to Settings > Feature Control.

@ProviderFor(DeclinedVisibilityReveals)
final declinedVisibilityRevealsProvider = DeclinedVisibilityRevealsProvider._();

/// Visibility switches the user declined to show when a deliberate action
/// needed them. The question is asked once per switch; after a "no",
/// the same action only points to Settings > Feature Control.
final class DeclinedVisibilityRevealsProvider
    extends
        $NotifierProvider<DeclinedVisibilityReveals, Set<VisibilitySwitch>> {
  /// Visibility switches the user declined to show when a deliberate action
  /// needed them. The question is asked once per switch; after a "no",
  /// the same action only points to Settings > Feature Control.
  DeclinedVisibilityRevealsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'declinedVisibilityRevealsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$declinedVisibilityRevealsHash();

  @$internal
  @override
  DeclinedVisibilityReveals create() => DeclinedVisibilityReveals();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<VisibilitySwitch> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<VisibilitySwitch>>(value),
    );
  }
}

String _$declinedVisibilityRevealsHash() =>
    r'5ee3bd75c4e9f604b8eae79b91babfad25ca682b';

/// Visibility switches the user declined to show when a deliberate action
/// needed them. The question is asked once per switch; after a "no",
/// the same action only points to Settings > Feature Control.

abstract class _$DeclinedVisibilityReveals
    extends $Notifier<Set<VisibilitySwitch>> {
  Set<VisibilitySwitch> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<VisibilitySwitch>, Set<VisibilitySwitch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<VisibilitySwitch>, Set<VisibilitySwitch>>,
              Set<VisibilitySwitch>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Showing hidden features again, for deliberate actions only — a gesture,
/// shortcut or long press bound to the feature, or picking it in the settings
/// search. Automatic behavior never reveals anything. The dialog is
/// [askToRevealFeature]'s; this holds what it decides on, always against the
/// profile: such a reveal is a live change, never an onboarding draft's.

@ProviderFor(FeatureReveal)
final featureRevealProvider = FeatureRevealProvider._();

/// Showing hidden features again, for deliberate actions only — a gesture,
/// shortcut or long press bound to the feature, or picking it in the settings
/// search. Automatic behavior never reveals anything. The dialog is
/// [askToRevealFeature]'s; this holds what it decides on, always against the
/// profile: such a reveal is a live change, never an onboarding draft's.
final class FeatureRevealProvider
    extends $NotifierProvider<FeatureReveal, void> {
  /// Showing hidden features again, for deliberate actions only — a gesture,
  /// shortcut or long press bound to the feature, or picking it in the settings
  /// search. Automatic behavior never reveals anything. The dialog is
  /// [askToRevealFeature]'s; this holds what it decides on, always against the
  /// profile: such a reveal is a live change, never an onboarding draft's.
  FeatureRevealProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureRevealProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureRevealHash();

  @$internal
  @override
  FeatureReveal create() => FeatureReveal();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$featureRevealHash() => r'f2b977bc9fc214f55c920ad3544881892254bc78';

/// Showing hidden features again, for deliberate actions only — a gesture,
/// shortcut or long press bound to the feature, or picking it in the settings
/// search. Automatic behavior never reveals anything. The dialog is
/// [askToRevealFeature]'s; this holds what it decides on, always against the
/// profile: such a reveal is a live change, never an onboarding draft's.

abstract class _$FeatureReveal extends $Notifier<void> {
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
