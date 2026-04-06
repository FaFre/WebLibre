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

String _$desktopModeHash() => r'18550009e95a23ff82d30206ce81daa859c57c26';

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
