// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TabSession)
final tabSessionProvider = TabSessionFamily._();

final class TabSessionProvider extends $NotifierProvider<TabSession, void> {
  TabSessionProvider._({
    required TabSessionFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'tabSessionProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tabSessionHash();

  @override
  String toString() {
    return r'tabSessionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TabSession create() => TabSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TabSessionProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tabSessionHash() => r'4b7206863e205dfeee6201ba6072e742c43ab6f3';

final class TabSessionFamily extends $Family
    with $ClassFamilyOverride<TabSession, void, void, void, String?> {
  TabSessionFamily._()
    : super(
        retry: null,
        name: r'tabSessionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TabSessionProvider call({required String? tabId}) =>
      TabSessionProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabSessionProvider';
}

abstract class _$TabSession extends $Notifier<void> {
  late final _$args = ref.$arg as String?;
  String? get tabId => _$args;

  void build({required String? tabId});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(tabId: _$args));
  }
}

@ProviderFor(selectedTabSessionNotifier)
final selectedTabSessionProvider = SelectedTabSessionNotifierProvider._();

final class SelectedTabSessionNotifierProvider
    extends
        $FunctionalProvider<Raw<TabSession>, Raw<TabSession>, Raw<TabSession>>
    with $Provider<Raw<TabSession>> {
  SelectedTabSessionNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedTabSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedTabSessionNotifierHash();

  @$internal
  @override
  $ProviderElement<Raw<TabSession>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Raw<TabSession> create(Ref ref) {
    return selectedTabSessionNotifier(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<TabSession> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Raw<TabSession>>(value),
    );
  }
}

String _$selectedTabSessionNotifierHash() =>
    r'3945a3a3faf615e1c95819abda276f3e251d5b4c';
