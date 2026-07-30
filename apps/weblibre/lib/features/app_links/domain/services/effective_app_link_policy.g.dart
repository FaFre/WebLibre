// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'effective_app_link_policy.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
/// null until the container/isolation inputs have loaded — resolving against
/// empty placeholders could misattribute an isolated container's tab to the
/// global bucket, so callers show a loading state instead.

@ProviderFor(effectiveAppLinkPolicy)
final effectiveAppLinkPolicyProvider = EffectiveAppLinkPolicyFamily._();

/// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
/// null until the container/isolation inputs have loaded — resolving against
/// empty placeholders could misattribute an isolated container's tab to the
/// global bucket, so callers show a loading state instead.

final class EffectiveAppLinkPolicyProvider
    extends
        $FunctionalProvider<
          EffectiveAppLinkPolicy?,
          EffectiveAppLinkPolicy?,
          EffectiveAppLinkPolicy?
        >
    with $Provider<EffectiveAppLinkPolicy?> {
  /// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
  /// null until the container/isolation inputs have loaded — resolving against
  /// empty placeholders could misattribute an isolated container's tab to the
  /// global bucket, so callers show a loading state instead.
  EffectiveAppLinkPolicyProvider._({
    required EffectiveAppLinkPolicyFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'effectiveAppLinkPolicyProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveAppLinkPolicyHash();

  @override
  String toString() {
    return r'effectiveAppLinkPolicyProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EffectiveAppLinkPolicy?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EffectiveAppLinkPolicy? create(Ref ref) {
    final argument = this.argument as String?;
    return effectiveAppLinkPolicy(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EffectiveAppLinkPolicy? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EffectiveAppLinkPolicy?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveAppLinkPolicyProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveAppLinkPolicyHash() =>
    r'da8101e842a9cf516eb18d817560813bc0cc94f0';

/// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
/// null until the container/isolation inputs have loaded — resolving against
/// empty placeholders could misattribute an isolated container's tab to the
/// global bucket, so callers show a loading state instead.

final class EffectiveAppLinkPolicyFamily extends $Family
    with $FunctionalFamilyOverride<EffectiveAppLinkPolicy?, String?> {
  EffectiveAppLinkPolicyFamily._()
    : super(
        retry: null,
        name: r'effectiveAppLinkPolicyProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Compute the [EffectiveAppLinkPolicy] for a tab's live contextId. Returns
  /// null until the container/isolation inputs have loaded — resolving against
  /// empty placeholders could misattribute an isolated container's tab to the
  /// global bucket, so callers show a loading state instead.

  EffectiveAppLinkPolicyProvider call(String? liveContextId) =>
      EffectiveAppLinkPolicyProvider._(argument: liveContextId, from: this);

  @override
  String toString() => r'effectiveAppLinkPolicyProvider';
}
