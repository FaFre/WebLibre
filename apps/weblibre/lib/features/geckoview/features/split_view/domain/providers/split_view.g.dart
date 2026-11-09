// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_view.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The one split pair, held in memory for the life of the Flutter engine.
///
/// Keep-alive so the pair outlives every widget, route and sheet. Rotation
/// and resizing keep it (handled in place); an engine recreation or process
/// death loses it. Nothing is persisted.

@ProviderFor(SplitViewController)
final splitViewControllerProvider = SplitViewControllerProvider._();

/// The one split pair, held in memory for the life of the Flutter engine.
///
/// Keep-alive so the pair outlives every widget, route and sheet. Rotation
/// and resizing keep it (handled in place); an engine recreation or process
/// death loses it. Nothing is persisted.
final class SplitViewControllerProvider
    extends $NotifierProvider<SplitViewController, SplitPair?> {
  /// The one split pair, held in memory for the life of the Flutter engine.
  ///
  /// Keep-alive so the pair outlives every widget, route and sheet. Rotation
  /// and resizing keep it (handled in place); an engine recreation or process
  /// death loses it. Nothing is persisted.
  SplitViewControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitViewControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitViewControllerHash();

  @$internal
  @override
  SplitViewController create() => SplitViewController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitPair? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitPair?>(value),
    );
  }
}

String _$splitViewControllerHash() =>
    r'f24d1fbecffd39c7a30d39fa91ca56c916b3dc42';

/// The one split pair, held in memory for the life of the Flutter engine.
///
/// Keep-alive so the pair outlives every widget, route and sheet. Rotation
/// and resizing keep it (handled in place); an engine recreation or process
/// death loses it. Nothing is persisted.

abstract class _$SplitViewController extends $Notifier<SplitPair?> {
  SplitPair? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SplitPair?, SplitPair?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplitPair?, SplitPair?>,
              SplitPair?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ends the pair when one of its tabs is closed. Started with the browser
/// (`SplitViewHost`), the only place a pair can be formed.

@ProviderFor(splitViewReconciliation)
final splitViewReconciliationProvider = SplitViewReconciliationProvider._();

/// Ends the pair when one of its tabs is closed. Started with the browser
/// (`SplitViewHost`), the only place a pair can be formed.

final class SplitViewReconciliationProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Ends the pair when one of its tabs is closed. Started with the browser
  /// (`SplitViewHost`), the only place a pair can be formed.
  SplitViewReconciliationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitViewReconciliationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitViewReconciliationHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return splitViewReconciliation(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$splitViewReconciliationHash() =>
    r'66d8bd95b0a9b0fff8cfda85183f5006f16953db';

/// The pair while split view is shown, whatever is selected; else null.

@ProviderFor(splitPairShown)
final splitPairShownProvider = SplitPairShownProvider._();

/// The pair while split view is shown, whatever is selected; else null.

final class SplitPairShownProvider
    extends $FunctionalProvider<SplitPair?, SplitPair?, SplitPair?>
    with $Provider<SplitPair?> {
  /// The pair while split view is shown, whatever is selected; else null.
  SplitPairShownProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitPairShownProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitPairShownHash();

  @$internal
  @override
  $ProviderElement<SplitPair?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SplitPair? create(Ref ref) {
    return splitPairShown(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitPair? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitPair?>(value),
    );
  }
}

String _$splitPairShownHash() => r'7751c51f16e0d28051e8b1792c68276901f6dcd9';

/// The shown pair while it contains the selected tab; else null, and the
/// browser shows one page as usual.

@ProviderFor(activeSplitPair)
final activeSplitPairProvider = ActiveSplitPairProvider._();

/// The shown pair while it contains the selected tab; else null, and the
/// browser shows one page as usual.

final class ActiveSplitPairProvider
    extends $FunctionalProvider<SplitPair?, SplitPair?, SplitPair?>
    with $Provider<SplitPair?> {
  /// The shown pair while it contains the selected tab; else null, and the
  /// browser shows one page as usual.
  ActiveSplitPairProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeSplitPairProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeSplitPairHash();

  @$internal
  @override
  $ProviderElement<SplitPair?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SplitPair? create(Ref ref) {
    return activeSplitPair(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitPair? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitPair?>(value),
    );
  }
}

String _$activeSplitPairHash() => r'9a8f2fc6dc475f0502440da78e0dc743b190ab8c';

/// Whether [tabId] belongs to the shown pair, for badges.

@ProviderFor(isSplitMember)
final isSplitMemberProvider = IsSplitMemberFamily._();

/// Whether [tabId] belongs to the shown pair, for badges.

final class IsSplitMemberProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether [tabId] belongs to the shown pair, for badges.
  IsSplitMemberProvider._({
    required IsSplitMemberFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isSplitMemberProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isSplitMemberHash();

  @override
  String toString() {
    return r'isSplitMemberProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String;
    return isSplitMember(ref, argument);
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
    return other is IsSplitMemberProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isSplitMemberHash() => r'1c4de684ec87ae47e4ec9c8005151d92d735a037';

/// Whether [tabId] belongs to the shown pair, for badges.

final class IsSplitMemberFamily extends $Family
    with $FunctionalFamilyOverride<bool, String> {
  IsSplitMemberFamily._()
    : super(
        retry: null,
        name: r'isSplitMemberProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether [tabId] belongs to the shown pair, for badges.

  IsSplitMemberProvider call(String tabId) =>
      IsSplitMemberProvider._(argument: tabId, from: this);

  @override
  String toString() => r'isSplitMemberProvider';
}

/// The containers of both members of the shown pair (null: unassigned).
///
/// Depends on the members only, not on which one is selected, so it does not
/// reload when focus moves between the panes: the home predicate reads it in
/// exactly that moment.

@ProviderFor(splitPairContainerIds)
final splitPairContainerIdsProvider = SplitPairContainerIdsProvider._();

/// The containers of both members of the shown pair (null: unassigned).
///
/// Depends on the members only, not on which one is selected, so it does not
/// reload when focus moves between the panes: the home predicate reads it in
/// exactly that moment.

final class SplitPairContainerIdsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Set<String?>>,
          Set<String?>,
          FutureOr<Set<String?>>
        >
    with $FutureModifier<Set<String?>>, $FutureProvider<Set<String?>> {
  /// The containers of both members of the shown pair (null: unassigned).
  ///
  /// Depends on the members only, not on which one is selected, so it does not
  /// reload when focus moves between the panes: the home predicate reads it in
  /// exactly that moment.
  SplitPairContainerIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitPairContainerIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitPairContainerIdsHash();

  @$internal
  @override
  $FutureProviderElement<Set<String?>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Set<String?>> create(Ref ref) {
    return splitPairContainerIds(ref);
  }
}

String _$splitPairContainerIdsHash() =>
    r'c71e891184182644d23296d75d5b0849181441e7';
