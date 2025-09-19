// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindInPageController)
const findInPageControllerProvider = FindInPageControllerFamily._();

final class FindInPageControllerProvider
    extends $NotifierProvider<FindInPageController, FindInPageState> {
  const FindInPageControllerProvider._({
    required FindInPageControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'findInPageControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findInPageControllerHash();

  @override
  String toString() {
    return r'findInPageControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindInPageController create() => FindInPageController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FindInPageState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FindInPageState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findInPageControllerHash() =>
    r'85e6b69edcd66a961d51326b01336a969d37fac1';

final class FindInPageControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          FindInPageController,
          FindInPageState,
          FindInPageState,
          FindInPageState,
          String
        > {
  const FindInPageControllerFamily._()
    : super(
        retry: null,
        name: r'findInPageControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FindInPageControllerProvider call(String tabId) =>
      FindInPageControllerProvider._(argument: tabId, from: this);

  @override
  String toString() => r'findInPageControllerProvider';
}

abstract class _$FindInPageController extends $Notifier<FindInPageState> {
  late final _$args = ref.$arg as String;
  String get tabId => _$args;

  FindInPageState build(String tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<FindInPageState, FindInPageState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<FindInPageState, FindInPageState>,
              FindInPageState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
