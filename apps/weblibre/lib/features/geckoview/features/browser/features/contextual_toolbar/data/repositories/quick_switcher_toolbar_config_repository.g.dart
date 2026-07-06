// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_switcher_toolbar_config_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(quickSwitcherToolbarConfigRepository)
final quickSwitcherToolbarConfigRepositoryProvider =
    QuickSwitcherToolbarConfigRepositoryProvider._();

final class QuickSwitcherToolbarConfigRepositoryProvider
    extends
        $FunctionalProvider<
          QuickSwitcherToolbarConfigRepository,
          QuickSwitcherToolbarConfigRepository,
          QuickSwitcherToolbarConfigRepository
        >
    with $Provider<QuickSwitcherToolbarConfigRepository> {
  QuickSwitcherToolbarConfigRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'quickSwitcherToolbarConfigRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$quickSwitcherToolbarConfigRepositoryHash();

  @$internal
  @override
  $ProviderElement<QuickSwitcherToolbarConfigRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  QuickSwitcherToolbarConfigRepository create(Ref ref) {
    return quickSwitcherToolbarConfigRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(QuickSwitcherToolbarConfigRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<QuickSwitcherToolbarConfigRepository>(value),
    );
  }
}

String _$quickSwitcherToolbarConfigRepositoryHash() =>
    r'5459350ebde214186e882d8316e66d438c6913d8';
