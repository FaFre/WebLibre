// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sharing_intent.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sharingIntentStream)
final sharingIntentStreamProvider = SharingIntentStreamProvider._();

final class SharingIntentStreamProvider
    extends
        $FunctionalProvider<
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>,
          Raw<Stream<ReceivedIntentParameter>>
        >
    with $Provider<Raw<Stream<ReceivedIntentParameter>>> {
  SharingIntentStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharingIntentStreamProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharingIntentStreamHash();

  @$internal
  @override
  $ProviderElement<Raw<Stream<ReceivedIntentParameter>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Raw<Stream<ReceivedIntentParameter>> create(Ref ref) {
    return sharingIntentStream(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Raw<Stream<ReceivedIntentParameter>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Raw<Stream<ReceivedIntentParameter>>>(value),
    );
  }
}

String _$sharingIntentStreamHash() =>
    r'486f994fc0e01a2cffdb19d93f0a332f96a9850c';
