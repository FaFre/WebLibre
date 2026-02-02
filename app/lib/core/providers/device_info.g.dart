// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AndroidDeviceInfo)
final androidDeviceInfoProvider = AndroidDeviceInfoProvider._();

final class AndroidDeviceInfoProvider
    extends $AsyncNotifierProvider<AndroidDeviceInfo, AndroidDeviceInfoData?> {
  AndroidDeviceInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'androidDeviceInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$androidDeviceInfoHash();

  @$internal
  @override
  AndroidDeviceInfo create() => AndroidDeviceInfo();
}

String _$androidDeviceInfoHash() => r'05c6cc63a6ee34f137aef538d65e8ab94b9cca89';

abstract class _$AndroidDeviceInfo
    extends $AsyncNotifier<AndroidDeviceInfoData?> {
  FutureOr<AndroidDeviceInfoData?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<AndroidDeviceInfoData?>, AndroidDeviceInfoData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AndroidDeviceInfoData?>,
                AndroidDeviceInfoData?
              >,
              AsyncValue<AndroidDeviceInfoData?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
