// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_drop.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WillAcceptDrop)
const willAcceptDropProvider = WillAcceptDropProvider._();

final class WillAcceptDropProvider
    extends $NotifierProvider<WillAcceptDrop, DropTargetData?> {
  const WillAcceptDropProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'willAcceptDropProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$willAcceptDropHash();

  @$internal
  @override
  WillAcceptDrop create() => WillAcceptDrop();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DropTargetData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DropTargetData?>(value),
    );
  }
}

String _$willAcceptDropHash() => r'97b47784ef9101757602b4408d1f545ef2308830';

abstract class _$WillAcceptDrop extends $Notifier<DropTargetData?> {
  DropTargetData? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DropTargetData?, DropTargetData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DropTargetData?, DropTargetData?>,
              DropTargetData?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
