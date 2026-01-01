// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_extensions_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebExtensionsState)
final webExtensionsStateProvider = WebExtensionsStateFamily._();

final class WebExtensionsStateProvider
    extends
        $NotifierProvider<WebExtensionsState, Map<String, WebExtensionState>> {
  WebExtensionsStateProvider._({
    required WebExtensionsStateFamily super.from,
    required WebExtensionActionType super.argument,
  }) : super(
         retry: null,
         name: r'webExtensionsStateProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$webExtensionsStateHash();

  @override
  String toString() {
    return r'webExtensionsStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  WebExtensionsState create() => WebExtensionsState();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<String, WebExtensionState> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<String, WebExtensionState>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WebExtensionsStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$webExtensionsStateHash() =>
    r'6fb44ab543250f2b2554e410ee749fdd035cd4e7';

final class WebExtensionsStateFamily extends $Family
    with
        $ClassFamilyOverride<
          WebExtensionsState,
          Map<String, WebExtensionState>,
          Map<String, WebExtensionState>,
          Map<String, WebExtensionState>,
          WebExtensionActionType
        > {
  WebExtensionsStateFamily._()
    : super(
        retry: null,
        name: r'webExtensionsStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WebExtensionsStateProvider call(WebExtensionActionType actionType) =>
      WebExtensionsStateProvider._(argument: actionType, from: this);

  @override
  String toString() => r'webExtensionsStateProvider';
}

abstract class _$WebExtensionsState
    extends $Notifier<Map<String, WebExtensionState>> {
  late final _$args = ref.$arg as WebExtensionActionType;
  WebExtensionActionType get actionType => _$args;

  Map<String, WebExtensionState> build(WebExtensionActionType actionType);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              Map<String, WebExtensionState>,
              Map<String, WebExtensionState>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                Map<String, WebExtensionState>,
                Map<String, WebExtensionState>
              >,
              Map<String, WebExtensionState>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
