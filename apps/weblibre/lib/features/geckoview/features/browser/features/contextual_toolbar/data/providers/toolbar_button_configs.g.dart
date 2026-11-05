// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'toolbar_button_configs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(toolbarButtonConfigs)
final toolbarButtonConfigsProvider = ToolbarButtonConfigsFamily._();

final class ToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ToolbarButtonConfig>>,
          List<ToolbarButtonConfig>,
          Stream<List<ToolbarButtonConfig>>
        >
    with
        $FutureModifier<List<ToolbarButtonConfig>>,
        $StreamProvider<List<ToolbarButtonConfig>> {
  ToolbarButtonConfigsProvider._({
    required ToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'toolbarButtonConfigsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarButtonConfigsHash();

  @override
  String toString() {
    return r'toolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<ToolbarButtonConfig>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return toolbarButtonConfigs(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarButtonConfigsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarButtonConfigsHash() =>
    r'913d2c8ca3b8b3f39f2247cafac068dc26abc566';

final class ToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  ToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'toolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      ToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'toolbarButtonConfigsProvider';
}

/// The configuration of [location] as the profile stores it: known buttons
/// only, the defaults while loading or empty. Never the onboarding draft.

@ProviderFor(profileToolbarButtonConfigs)
final profileToolbarButtonConfigsProvider =
    ProfileToolbarButtonConfigsFamily._();

/// The configuration of [location] as the profile stores it: known buttons
/// only, the defaults while loading or empty. Never the onboarding draft.

final class ProfileToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>
        >
    with $Provider<EquatableValue<List<ToolbarButtonConfig>>> {
  /// The configuration of [location] as the profile stores it: known buttons
  /// only, the defaults while loading or empty. Never the onboarding draft.
  ProfileToolbarButtonConfigsProvider._({
    required ProfileToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'profileToolbarButtonConfigsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileToolbarButtonConfigsHash();

  @override
  String toString() {
    return r'profileToolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<ToolbarButtonConfig>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return profileToolbarButtonConfigs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileToolbarButtonConfigsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileToolbarButtonConfigsHash() =>
    r'15b7ca880e6e35752f83b97c029ac68ecfabfa2c';

/// The configuration of [location] as the profile stores it: known buttons
/// only, the defaults while loading or empty. Never the onboarding draft.

final class ProfileToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  ProfileToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'profileToolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The configuration of [location] as the profile stores it: known buttons
  /// only, the defaults while loading or empty. Never the onboarding draft.

  ProfileToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      ProfileToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'profileToolbarButtonConfigsProvider';
}

/// The buttons of the toolbar at [location] as its editor shows and changes
/// them: in the onboarding the draft's (the profile's until the first
/// change), otherwise the profile's ([profileToolbarButtonConfigs]).
///
/// The edit layer. A change is computed with the pure edits
/// ([moveToolbarButton] and its siblings) and goes into the draft while one
/// is open; otherwise it is saved to the profile
/// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
/// that changed).
///
/// Those writes are optimistic: the editor shows a change at once, and the
/// next one is computed from it rather than from a store that has not caught
/// up. The change is held in [_pending], not only in `state`: every emission
/// of the store rebuilds this provider, and a rebuild replaces `state`. It is
/// dropped once the store shows it, or when a write fails.

@ProviderFor(ToolbarButtonLayout)
final toolbarButtonLayoutProvider = ToolbarButtonLayoutFamily._();

/// The buttons of the toolbar at [location] as its editor shows and changes
/// them: in the onboarding the draft's (the profile's until the first
/// change), otherwise the profile's ([profileToolbarButtonConfigs]).
///
/// The edit layer. A change is computed with the pure edits
/// ([moveToolbarButton] and its siblings) and goes into the draft while one
/// is open; otherwise it is saved to the profile
/// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
/// that changed).
///
/// Those writes are optimistic: the editor shows a change at once, and the
/// next one is computed from it rather than from a store that has not caught
/// up. The change is held in [_pending], not only in `state`: every emission
/// of the store rebuilds this provider, and a rebuild replaces `state`. It is
/// dropped once the store shows it, or when a write fails.
final class ToolbarButtonLayoutProvider
    extends
        $NotifierProvider<
          ToolbarButtonLayout,
          EquatableValue<List<ToolbarButtonConfig>>
        > {
  /// The buttons of the toolbar at [location] as its editor shows and changes
  /// them: in the onboarding the draft's (the profile's until the first
  /// change), otherwise the profile's ([profileToolbarButtonConfigs]).
  ///
  /// The edit layer. A change is computed with the pure edits
  /// ([moveToolbarButton] and its siblings) and goes into the draft while one
  /// is open; otherwise it is saved to the profile
  /// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
  /// that changed).
  ///
  /// Those writes are optimistic: the editor shows a change at once, and the
  /// next one is computed from it rather than from a store that has not caught
  /// up. The change is held in [_pending], not only in `state`: every emission
  /// of the store rebuilds this provider, and a rebuild replaces `state`. It is
  /// dropped once the store shows it, or when a write fails.
  ToolbarButtonLayoutProvider._({
    required ToolbarButtonLayoutFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'toolbarButtonLayoutProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$toolbarButtonLayoutHash();

  @override
  String toString() {
    return r'toolbarButtonLayoutProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ToolbarButtonLayout create() => ToolbarButtonLayout();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ToolbarButtonLayoutProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$toolbarButtonLayoutHash() =>
    r'90a7a154790e71a2dbd53d58ecaaf5e477cae41c';

/// The buttons of the toolbar at [location] as its editor shows and changes
/// them: in the onboarding the draft's (the profile's until the first
/// change), otherwise the profile's ([profileToolbarButtonConfigs]).
///
/// The edit layer. A change is computed with the pure edits
/// ([moveToolbarButton] and its siblings) and goes into the draft while one
/// is open; otherwise it is saved to the profile
/// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
/// that changed).
///
/// Those writes are optimistic: the editor shows a change at once, and the
/// next one is computed from it rather than from a store that has not caught
/// up. The change is held in [_pending], not only in `state`: every emission
/// of the store rebuilds this provider, and a rebuild replaces `state`. It is
/// dropped once the store shows it, or when a write fails.

final class ToolbarButtonLayoutFamily extends $Family
    with
        $ClassFamilyOverride<
          ToolbarButtonLayout,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  ToolbarButtonLayoutFamily._()
    : super(
        retry: null,
        name: r'toolbarButtonLayoutProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The buttons of the toolbar at [location] as its editor shows and changes
  /// them: in the onboarding the draft's (the profile's until the first
  /// change), otherwise the profile's ([profileToolbarButtonConfigs]).
  ///
  /// The edit layer. A change is computed with the pure edits
  /// ([moveToolbarButton] and its siblings) and goes into the draft while one
  /// is open; otherwise it is saved to the profile
  /// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
  /// that changed).
  ///
  /// Those writes are optimistic: the editor shows a change at once, and the
  /// next one is computed from it rather than from a store that has not caught
  /// up. The change is held in [_pending], not only in `state`: every emission
  /// of the store rebuilds this provider, and a rebuild replaces `state`. It is
  /// dropped once the store shows it, or when a write fails.

  ToolbarButtonLayoutProvider call(ToolbarConfigLocation location) =>
      ToolbarButtonLayoutProvider._(argument: location, from: this);

  @override
  String toString() => r'toolbarButtonLayoutProvider';
}

/// The buttons of the toolbar at [location] as its editor shows and changes
/// them: in the onboarding the draft's (the profile's until the first
/// change), otherwise the profile's ([profileToolbarButtonConfigs]).
///
/// The edit layer. A change is computed with the pure edits
/// ([moveToolbarButton] and its siblings) and goes into the draft while one
/// is open; otherwise it is saved to the profile
/// ([ToolbarButtonConfigRepository.saveAll], which writes only the buttons
/// that changed).
///
/// Those writes are optimistic: the editor shows a change at once, and the
/// next one is computed from it rather than from a store that has not caught
/// up. The change is held in [_pending], not only in `state`: every emission
/// of the store rebuilds this provider, and a rebuild replaces `state`. It is
/// dropped once the store shows it, or when a write fails.

abstract class _$ToolbarButtonLayout
    extends $Notifier<EquatableValue<List<ToolbarButtonConfig>>> {
  late final _$args = ref.$arg as ToolbarConfigLocation;
  ToolbarConfigLocation get location => _$args;

  EquatableValue<List<ToolbarButtonConfig>> build(
    ToolbarConfigLocation location,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              EquatableValue<List<ToolbarButtonConfig>>,
              EquatableValue<List<ToolbarButtonConfig>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EquatableValue<List<ToolbarButtonConfig>>,
                EquatableValue<List<ToolbarButtonConfig>>
              >,
              EquatableValue<List<ToolbarButtonConfig>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
/// with the default fallbacks and no long-press actions while the advanced
/// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
/// visibility are ordinary layout and stay as stored.

@ProviderFor(effectiveToolbarButtonConfigs)
final effectiveToolbarButtonConfigsProvider =
    EffectiveToolbarButtonConfigsFamily._();

/// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
/// with the default fallbacks and no long-press actions while the advanced
/// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
/// visibility are ordinary layout and stay as stored.

final class EffectiveToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>
        >
    with $Provider<EquatableValue<List<ToolbarButtonConfig>>> {
  /// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
  /// with the default fallbacks and no long-press actions while the advanced
  /// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
  /// visibility are ordinary layout and stay as stored.
  EffectiveToolbarButtonConfigsProvider._({
    required EffectiveToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'effectiveToolbarButtonConfigsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$effectiveToolbarButtonConfigsHash();

  @override
  String toString() {
    return r'effectiveToolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<ToolbarButtonConfig>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return effectiveToolbarButtonConfigs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EffectiveToolbarButtonConfigsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$effectiveToolbarButtonConfigsHash() =>
    r'28b3e38391a05cb831b211f421979f3011645c0e';

/// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
/// with the default fallbacks and no long-press actions while the advanced
/// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
/// visibility are ordinary layout and stay as stored.

final class EffectiveToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  EffectiveToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'effectiveToolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The configuration of [location] as it applies: [profileToolbarButtonConfigs]
  /// with the default fallbacks and no long-press actions while the advanced
  /// toolbar options are hidden (`layout.contextual_toolbar_advanced`). Order and
  /// visibility are ordinary layout and stay as stored.

  EffectiveToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      EffectiveToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'effectiveToolbarButtonConfigsProvider';
}

/// The buttons of [location] as the Toolbar & Layout preview draws them:
/// [ToolbarButtonLayout] as it applies, with the advanced options as the
/// displayed settings show them. Outside the onboarding the same as
/// [effectiveToolbarButtonConfigs], apart from a change still being written.
/// The browser's own toolbars read [effectiveToolbarButtonConfigs]
/// ([toolbarButtonConfigsShownBy]).
///
/// The displayed layer. Auto-disposed, like the editor it follows.

@ProviderFor(displayedToolbarButtonConfigs)
final displayedToolbarButtonConfigsProvider =
    DisplayedToolbarButtonConfigsFamily._();

/// The buttons of [location] as the Toolbar & Layout preview draws them:
/// [ToolbarButtonLayout] as it applies, with the advanced options as the
/// displayed settings show them. Outside the onboarding the same as
/// [effectiveToolbarButtonConfigs], apart from a change still being written.
/// The browser's own toolbars read [effectiveToolbarButtonConfigs]
/// ([toolbarButtonConfigsShownBy]).
///
/// The displayed layer. Auto-disposed, like the editor it follows.

final class DisplayedToolbarButtonConfigsProvider
    extends
        $FunctionalProvider<
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>,
          EquatableValue<List<ToolbarButtonConfig>>
        >
    with $Provider<EquatableValue<List<ToolbarButtonConfig>>> {
  /// The buttons of [location] as the Toolbar & Layout preview draws them:
  /// [ToolbarButtonLayout] as it applies, with the advanced options as the
  /// displayed settings show them. Outside the onboarding the same as
  /// [effectiveToolbarButtonConfigs], apart from a change still being written.
  /// The browser's own toolbars read [effectiveToolbarButtonConfigs]
  /// ([toolbarButtonConfigsShownBy]).
  ///
  /// The displayed layer. Auto-disposed, like the editor it follows.
  DisplayedToolbarButtonConfigsProvider._({
    required DisplayedToolbarButtonConfigsFamily super.from,
    required ToolbarConfigLocation super.argument,
  }) : super(
         retry: null,
         name: r'displayedToolbarButtonConfigsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$displayedToolbarButtonConfigsHash();

  @override
  String toString() {
    return r'displayedToolbarButtonConfigsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<EquatableValue<List<ToolbarButtonConfig>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EquatableValue<List<ToolbarButtonConfig>> create(Ref ref) {
    final argument = this.argument as ToolbarConfigLocation;
    return displayedToolbarButtonConfigs(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<List<ToolbarButtonConfig>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<EquatableValue<List<ToolbarButtonConfig>>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DisplayedToolbarButtonConfigsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$displayedToolbarButtonConfigsHash() =>
    r'c0d2a021618b97cee63bd0046a74f75f64afc309';

/// The buttons of [location] as the Toolbar & Layout preview draws them:
/// [ToolbarButtonLayout] as it applies, with the advanced options as the
/// displayed settings show them. Outside the onboarding the same as
/// [effectiveToolbarButtonConfigs], apart from a change still being written.
/// The browser's own toolbars read [effectiveToolbarButtonConfigs]
/// ([toolbarButtonConfigsShownBy]).
///
/// The displayed layer. Auto-disposed, like the editor it follows.

final class DisplayedToolbarButtonConfigsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          EquatableValue<List<ToolbarButtonConfig>>,
          ToolbarConfigLocation
        > {
  DisplayedToolbarButtonConfigsFamily._()
    : super(
        retry: null,
        name: r'displayedToolbarButtonConfigsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The buttons of [location] as the Toolbar & Layout preview draws them:
  /// [ToolbarButtonLayout] as it applies, with the advanced options as the
  /// displayed settings show them. Outside the onboarding the same as
  /// [effectiveToolbarButtonConfigs], apart from a change still being written.
  /// The browser's own toolbars read [effectiveToolbarButtonConfigs]
  /// ([toolbarButtonConfigsShownBy]).
  ///
  /// The displayed layer. Auto-disposed, like the editor it follows.

  DisplayedToolbarButtonConfigsProvider call(ToolbarConfigLocation location) =>
      DisplayedToolbarButtonConfigsProvider._(argument: location, from: this);

  @override
  String toString() => r'displayedToolbarButtonConfigsProvider';
}
