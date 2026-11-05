// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SubscriptionRepository)
final subscriptionRepositoryProvider = SubscriptionRepositoryProvider._();

final class SubscriptionRepositoryProvider
    extends $AsyncNotifierProvider<SubscriptionRepository, SubscriptionStatus> {
  SubscriptionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionRepositoryHash();

  @$internal
  @override
  SubscriptionRepository create() => SubscriptionRepository();
}

String _$subscriptionRepositoryHash() =>
    r'696ca30d325ce4acefa3407eea73de5f9a604dcb';

abstract class _$SubscriptionRepository
    extends $AsyncNotifier<SubscriptionStatus> {
  FutureOr<SubscriptionStatus> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SubscriptionStatus>, SubscriptionStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SubscriptionStatus>, SubscriptionStatus>,
              AsyncValue<SubscriptionStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
