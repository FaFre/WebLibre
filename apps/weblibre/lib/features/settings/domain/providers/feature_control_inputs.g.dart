// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_control_inputs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [FeatureControlInputs], for every screen that shows the visibility
/// switches (Settings > Feature Control, the onboarding's "Show or hide
/// features"). Watched before anything is tapped, so a change is decided
/// with loaded values.

@ProviderFor(featureControlInputs)
final featureControlInputsProvider = FeatureControlInputsProvider._();

/// [FeatureControlInputs], for every screen that shows the visibility
/// switches (Settings > Feature Control, the onboarding's "Show or hide
/// features"). Watched before anything is tapped, so a change is decided
/// with loaded values.

final class FeatureControlInputsProvider
    extends
        $FunctionalProvider<
          FeatureControlInputs,
          FeatureControlInputs,
          FeatureControlInputs
        >
    with $Provider<FeatureControlInputs> {
  /// [FeatureControlInputs], for every screen that shows the visibility
  /// switches (Settings > Feature Control, the onboarding's "Show or hide
  /// features"). Watched before anything is tapped, so a change is decided
  /// with loaded values.
  FeatureControlInputsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureControlInputsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureControlInputsHash();

  @$internal
  @override
  $ProviderElement<FeatureControlInputs> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FeatureControlInputs create(Ref ref) {
    return featureControlInputs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureControlInputs value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureControlInputs>(value),
    );
  }
}

String _$featureControlInputsHash() =>
    r'4619169316bd0233d0ac23204a2ed386a3fad876';
