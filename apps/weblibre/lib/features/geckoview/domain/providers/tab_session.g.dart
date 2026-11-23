// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tab_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Commands to one tab's page, or the selected tab's.
///
/// The navigations here are the ones a user asks for, so each wakes a
/// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
/// the engine drops any load into a sleeping tab, and the navigation would
/// otherwise do nothing. A tab whose routing is not ready stays asleep, and
/// the navigation does not run. In a frozen container's tab the user is asked
/// "Resume {container} and open?" instead, and the navigation runs once the
/// container is resumed.

@ProviderFor(TabSession)
final tabSessionProvider = TabSessionFamily._();

/// Commands to one tab's page, or the selected tab's.
///
/// The navigations here are the ones a user asks for, so each wakes a
/// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
/// the engine drops any load into a sleeping tab, and the navigation would
/// otherwise do nothing. A tab whose routing is not ready stays asleep, and
/// the navigation does not run. In a frozen container's tab the user is asked
/// "Resume {container} and open?" instead, and the navigation runs once the
/// container is resumed.
final class TabSessionProvider extends $NotifierProvider<TabSession, void> {
  /// Commands to one tab's page, or the selected tab's.
  ///
  /// The navigations here are the ones a user asks for, so each wakes a
  /// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
  /// the engine drops any load into a sleeping tab, and the navigation would
  /// otherwise do nothing. A tab whose routing is not ready stays asleep, and
  /// the navigation does not run. In a frozen container's tab the user is asked
  /// "Resume {container} and open?" instead, and the navigation runs once the
  /// container is resumed.
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

String _$tabSessionHash() => r'6f4006e26774b8400214f6176d00f111a895d991';

/// Commands to one tab's page, or the selected tab's.
///
/// The navigations here are the ones a user asks for, so each wakes a
/// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
/// the engine drops any load into a sleeping tab, and the navigation would
/// otherwise do nothing. A tab whose routing is not ready stays asleep, and
/// the navigation does not run. In a frozen container's tab the user is asked
/// "Resume {container} and open?" instead, and the navigation runs once the
/// container is resumed.

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

  /// Commands to one tab's page, or the selected tab's.
  ///
  /// The navigations here are the ones a user asks for, so each wakes a
  /// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
  /// the engine drops any load into a sleeping tab, and the navigation would
  /// otherwise do nothing. A tab whose routing is not ready stays asleep, and
  /// the navigation does not run. In a frozen container's tab the user is asked
  /// "Resume {container} and open?" instead, and the navigation runs once the
  /// container is resumed.

  TabSessionProvider call({required String? tabId}) =>
      TabSessionProvider._(argument: tabId, from: this);

  @override
  String toString() => r'tabSessionProvider';
}

/// Commands to one tab's page, or the selected tab's.
///
/// The navigations here are the ones a user asks for, so each wakes a
/// sleeping tab first (5.2.1 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`):
/// the engine drops any load into a sleeping tab, and the navigation would
/// otherwise do nothing. A tab whose routing is not ready stays asleep, and
/// the navigation does not run. In a frozen container's tab the user is asked
/// "Resume {container} and open?" instead, and the navigation runs once the
/// container is resumed.

abstract class _$TabSession extends $Notifier<void> {
  late final _$args = ref.$arg as String?;
  String? get tabId => _$args;

  void build({required String? tabId});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(tabId: _$args));
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
