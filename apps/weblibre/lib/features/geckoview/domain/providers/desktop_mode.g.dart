// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'desktop_mode.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DesktopMode)
final desktopModeProvider = DesktopModeFamily._();

final class DesktopModeProvider extends $NotifierProvider<DesktopMode, bool> {
  DesktopModeProvider._({
    required DesktopModeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'desktopModeProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$desktopModeHash();

  @override
  String toString() {
    return r'desktopModeProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DesktopMode create() => DesktopMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DesktopModeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$desktopModeHash() => r'e755b0a36f7079006047896cb8f2a7be484dea90';

final class DesktopModeFamily extends $Family
    with $ClassFamilyOverride<DesktopMode, bool, bool, bool, String> {
  DesktopModeFamily._()
    : super(
        retry: null,
        name: r'desktopModeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  DesktopModeProvider call(String tabId) =>
      DesktopModeProvider._(argument: tabId, from: this);

  @override
  String toString() => r'desktopModeProvider';
}

abstract class _$DesktopMode extends $Notifier<bool> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  bool build(String tabId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

/// Always-mounted helper that instantiates the selected tab's [DesktopMode]
/// notifier so the per-site desktop-mode rule is applied on navigation even when
/// no tab menu or site sheet is open. Mounted by the browser view. [DesktopMode]
/// is keepAlive, so once built for a tab its navigation listener keeps running
/// for that tab's lifetime; this just guarantees it gets built when a tab
/// becomes selected (e.g. after opening a ruled site from the address bar).

@ProviderFor(desktopModeRuleApplier)
final desktopModeRuleApplierProvider = DesktopModeRuleApplierProvider._();

/// Always-mounted helper that instantiates the selected tab's [DesktopMode]
/// notifier so the per-site desktop-mode rule is applied on navigation even when
/// no tab menu or site sheet is open. Mounted by the browser view. [DesktopMode]
/// is keepAlive, so once built for a tab its navigation listener keeps running
/// for that tab's lifetime; this just guarantees it gets built when a tab
/// becomes selected (e.g. after opening a ruled site from the address bar).

final class DesktopModeRuleApplierProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Always-mounted helper that instantiates the selected tab's [DesktopMode]
  /// notifier so the per-site desktop-mode rule is applied on navigation even when
  /// no tab menu or site sheet is open. Mounted by the browser view. [DesktopMode]
  /// is keepAlive, so once built for a tab its navigation listener keeps running
  /// for that tab's lifetime; this just guarantees it gets built when a tab
  /// becomes selected (e.g. after opening a ruled site from the address bar).
  DesktopModeRuleApplierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'desktopModeRuleApplierProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$desktopModeRuleApplierHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return desktopModeRuleApplier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$desktopModeRuleApplierHash() =>
    r'4a99102da5dc11869bfb96d439cc88652a190b39';
