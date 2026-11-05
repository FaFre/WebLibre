// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kept_when.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether [kept] holds now.

@ProviderFor(keptWhenHolds)
final keptWhenHoldsProvider = KeptWhenHoldsFamily._();

/// Whether [kept] holds now.

final class KeptWhenHoldsProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [kept] holds now.
  KeptWhenHoldsProvider._({
    required KeptWhenHoldsFamily super.from,
    required KeptWhen super.argument,
  }) : super(
         retry: null,
         name: r'keptWhenHoldsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$keptWhenHoldsHash();

  @override
  String toString() {
    return r'keptWhenHoldsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as KeptWhen;
    return keptWhenHolds(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KeptWhenHoldsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$keptWhenHoldsHash() => r'68af8e79a3737c6bb66b13beac72622c7843d90b';

/// Whether [kept] holds now.

final class KeptWhenHoldsFamily extends $Family
    with $FunctionalFamilyOverride<bool, KeptWhen> {
  KeptWhenHoldsFamily._()
    : super(
        retry: null,
        name: r'keptWhenHoldsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [kept] holds now.

  KeptWhenHoldsProvider call(KeptWhen kept) =>
      KeptWhenHoldsProvider._(argument: kept, from: this);

  @override
  String toString() => r'keptWhenHoldsProvider';
}

/// The visibility switches that hide something gated by [conditions], in
/// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
/// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
/// followed only while its feature is hidden.

@ProviderFor(missingSwitches)
final missingSwitchesProvider = MissingSwitchesFamily._();

/// The visibility switches that hide something gated by [conditions], in
/// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
/// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
/// followed only while its feature is hidden.

final class MissingSwitchesProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<VisibilitySwitch>>,
          EquatableValue<List<VisibilitySwitch>>,
          EquatableValue<List<VisibilitySwitch>>
        >
    with $Provider<EquatableValue<List<VisibilitySwitch>>> {
  /// The visibility switches that hide something gated by [conditions], in
  /// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
  /// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
  /// followed only while its feature is hidden.
  MissingSwitchesProvider._({
    required MissingSwitchesFamily super.from,
    required HiddenFeatureConditions super.argument,
  }) : super(
         retry: null,
         name: r'missingSwitchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$missingSwitchesHash();

  @override
  String toString() {
    return r'missingSwitchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<VisibilitySwitch>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<VisibilitySwitch>> create(Ref ref) {
    final argument = this.argument as HiddenFeatureConditions;
    return missingSwitches(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<VisibilitySwitch>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<VisibilitySwitch>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MissingSwitchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$missingSwitchesHash() => r'fc166a0e4a47b14c3a1bac2dec5fa529eb58ad01';

/// The visibility switches that hide something gated by [conditions], in
/// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
/// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
/// followed only while its feature is hidden.

final class MissingSwitchesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<VisibilitySwitch>>,
          HiddenFeatureConditions
        > {
  MissingSwitchesFamily._()
    : super(
        retry: null,
        name: r'missingSwitchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The visibility switches that hide something gated by [conditions], in
  /// [VisibilitySwitch] order, empty while it is shown. Follows the displayed
  /// settings, so in the onboarding the draft's; a condition's [KeptWhen] is
  /// followed only while its feature is hidden.

  MissingSwitchesProvider call(HiddenFeatureConditions conditions) =>
      MissingSwitchesProvider._(argument: conditions, from: this);

  @override
  String toString() => r'missingSwitchesProvider';
}

/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.

@ProviderFor(connectionsInUse)
final connectionsInUseProvider = ConnectionsInUseProvider._();

/// Whether there are connections to come back to: a saved profile, a global
/// route, one running, or Tor set up in any way ([torInUse] — autostart that
/// failed and container or isolated-group routes included). The Proxy
/// category then stays in Settings even while connections are hidden, so the
/// existing ones keep their status, repair and stop controls (P5); the list
/// itself hides adding new ones.

final class ConnectionsInUseProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether there are connections to come back to: a saved profile, a global
  /// route, one running, or Tor set up in any way ([torInUse] — autostart that
  /// failed and container or isolated-group routes included). The Proxy
  /// category then stays in Settings even while connections are hidden, so the
  /// existing ones keep their status, repair and stop controls (P5); the list
  /// itself hides adding new ones.
  ConnectionsInUseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'connectionsInUseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$connectionsInUseHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return connectionsInUse(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$connectionsInUseHash() => r'a38b5dd78650cb9fcbace033e008f093541cf067';
