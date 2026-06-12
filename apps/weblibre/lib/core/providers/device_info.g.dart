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

String _$androidDeviceInfoHash() => r'54a5ceafce6ed9260b18baaec18d131f3c7d3833';

abstract class _$AndroidDeviceInfo
    extends $AsyncNotifier<AndroidDeviceInfoData?> {
  FutureOr<AndroidDeviceInfoData?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}
