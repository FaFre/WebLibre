// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_reader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FeedReader)
final feedReaderProvider = FeedReaderProvider._();

final class FeedReaderProvider extends $NotifierProvider<FeedReader, void> {
  FeedReaderProvider._()
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

String _$feedReaderHash() => r'bf6ba987b1a5ee18145316b42c3b0899e2d87aa5';

abstract class _$FeedReader extends $Notifier<void> {
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
