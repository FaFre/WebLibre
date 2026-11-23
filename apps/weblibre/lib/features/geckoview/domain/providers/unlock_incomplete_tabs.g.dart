// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_incomplete_tabs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Tabs whose unlock did not finish: the database says unlocked, but the
/// engine still keeps them from closing until a reconciliation succeeds.
///
/// Until then such a tab counts as locked everywhere the user looks: it keeps
/// its lock badge (with a warning), its close controls stay disabled, and its
/// menu offers to retry. The database alone saying "unlocked" never changes
/// what the user sees. Written only by `TabRepository`.

@ProviderFor(UnlockIncompleteTabs)
final unlockIncompleteTabsProvider = UnlockIncompleteTabsProvider._();

/// Tabs whose unlock did not finish: the database says unlocked, but the
/// engine still keeps them from closing until a reconciliation succeeds.
///
/// Until then such a tab counts as locked everywhere the user looks: it keeps
/// its lock badge (with a warning), its close controls stay disabled, and its
/// menu offers to retry. The database alone saying "unlocked" never changes
/// what the user sees. Written only by `TabRepository`.
final class UnlockIncompleteTabsProvider
    extends
        $NotifierProvider<UnlockIncompleteTabs, EquatableValue<Set<String>>> {
  /// Tabs whose unlock did not finish: the database says unlocked, but the
  /// engine still keeps them from closing until a reconciliation succeeds.
  ///
  /// Until then such a tab counts as locked everywhere the user looks: it keeps
  /// its lock badge (with a warning), its close controls stay disabled, and its
  /// menu offers to retry. The database alone saying "unlocked" never changes
  /// what the user sees. Written only by `TabRepository`.
  UnlockIncompleteTabsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockIncompleteTabsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockIncompleteTabsHash();

  @$internal
  @override
  UnlockIncompleteTabs create() => UnlockIncompleteTabs();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EquatableValue<Set<String>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EquatableValue<Set<String>>>(value),
    );
  }
}

String _$unlockIncompleteTabsHash() =>
    r'0207978fc7e9c07186cbcd0296f68009ed3e0356';

/// Tabs whose unlock did not finish: the database says unlocked, but the
/// engine still keeps them from closing until a reconciliation succeeds.
///
/// Until then such a tab counts as locked everywhere the user looks: it keeps
/// its lock badge (with a warning), its close controls stay disabled, and its
/// menu offers to retry. The database alone saying "unlocked" never changes
/// what the user sees. Written only by `TabRepository`.

abstract class _$UnlockIncompleteTabs
    extends $Notifier<EquatableValue<Set<String>>> {
  EquatableValue<Set<String>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<EquatableValue<Set<String>>, EquatableValue<Set<String>>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EquatableValue<Set<String>>,
                EquatableValue<Set<String>>
              >,
              EquatableValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
