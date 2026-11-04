// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setup_follow_ups.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Goals whose setup opens once the browser is showing, after the commit.
///
/// In memory only: a sign-in or a lock set up from here is the user's
/// request in this session. If the process ends first, nothing is pending and
/// nothing was half-done, which is what cancelling has to leave behind
/// (acceptance scenario 28).

@ProviderFor(PendingGoalSetups)
final pendingGoalSetupsProvider = PendingGoalSetupsProvider._();

/// Goals whose setup opens once the browser is showing, after the commit.
///
/// In memory only: a sign-in or a lock set up from here is the user's
/// request in this session. If the process ends first, nothing is pending and
/// nothing was half-done, which is what cancelling has to leave behind
/// (acceptance scenario 28).
final class PendingGoalSetupsProvider
    extends $NotifierProvider<PendingGoalSetups, List<SetupGoal>> {
  /// Goals whose setup opens once the browser is showing, after the commit.
  ///
  /// In memory only: a sign-in or a lock set up from here is the user's
  /// request in this session. If the process ends first, nothing is pending and
  /// nothing was half-done, which is what cancelling has to leave behind
  /// (acceptance scenario 28).
  PendingGoalSetupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingGoalSetupsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingGoalSetupsHash();

  @$internal
  @override
  PendingGoalSetups create() => PendingGoalSetups();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<SetupGoal> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<SetupGoal>>(value),
    );
  }
}

String _$pendingGoalSetupsHash() => r'c4c9257773c08b67c0c1b9bd2ca58f348df7c72d';

/// Goals whose setup opens once the browser is showing, after the commit.
///
/// In memory only: a sign-in or a lock set up from here is the user's
/// request in this session. If the process ends first, nothing is pending and
/// nothing was half-done, which is what cancelling has to leave behind
/// (acceptance scenario 28).

abstract class _$PendingGoalSetups extends $Notifier<List<SetupGoal>> {
  List<SetupGoal> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<SetupGoal>, List<SetupGoal>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<SetupGoal>, List<SetupGoal>>,
              List<SetupGoal>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
