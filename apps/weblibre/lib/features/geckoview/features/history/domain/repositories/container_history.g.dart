// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_history.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Mutations that combine the visit→container relation (`visit_container`) with
/// Mozilla Places, the source of truth for the visits themselves.

@ProviderFor(ContainerHistoryRepository)
final containerHistoryRepositoryProvider =
    ContainerHistoryRepositoryProvider._();

/// Mutations that combine the visit→container relation (`visit_container`) with
/// Mozilla Places, the source of truth for the visits themselves.
final class ContainerHistoryRepositoryProvider
    extends $NotifierProvider<ContainerHistoryRepository, void> {
  /// Mutations that combine the visit→container relation (`visit_container`) with
  /// Mozilla Places, the source of truth for the visits themselves.
  ContainerHistoryRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerHistoryRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerHistoryRepositoryHash();

  @$internal
  @override
  ContainerHistoryRepository create() => ContainerHistoryRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$containerHistoryRepositoryHash() =>
    r'8872a421664c0ac8d6b0bd3ca76e1300677b0873';

/// Mutations that combine the visit→container relation (`visit_container`) with
/// Mozilla Places, the source of truth for the visits themselves.

abstract class _$ContainerHistoryRepository extends $Notifier<void> {
  void build();
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
    return element.handleCreate(ref, build);
  }
}
