// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_dialog_blocking.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddFeedDialogBlocking)
const addFeedDialogBlockingProvider = AddFeedDialogBlockingProvider._();

final class AddFeedDialogBlockingProvider
    extends $NotifierProvider<AddFeedDialogBlocking, void> {
  const AddFeedDialogBlockingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addFeedDialogBlockingProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addFeedDialogBlockingHash();

  @$internal
  @override
  AddFeedDialogBlocking create() => AddFeedDialogBlocking();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$addFeedDialogBlockingHash() =>
    r'513071d5e507dd292df6b4a3ee3ef7d2217db5bb';

abstract class _$AddFeedDialogBlocking extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    build();
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleValue(ref, null);
  }
}
