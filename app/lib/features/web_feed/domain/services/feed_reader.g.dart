// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_reader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedReader)
const feedReaderProvider = FeedReaderProvider._();

final class FeedReaderProvider extends $NotifierProvider<FeedReader, void> {
  const FeedReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedReaderHash();

  @$internal
  @override
  FeedReader create() => FeedReader();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$feedReaderHash() => r'5d1ca364fe7ad702628a7f2bbd3e706876bc3111';

abstract class _$FeedReader extends $Notifier<void> {
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
