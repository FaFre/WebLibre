// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'backup_directory.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(BackupDirectoryUri)
final backupDirectoryUriProvider = BackupDirectoryUriProvider._();

final class BackupDirectoryUriProvider
    extends $NotifierProvider<BackupDirectoryUri, Uri?> {
  BackupDirectoryUriProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backupDirectoryUriProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backupDirectoryUriHash();

  @$internal
  @override
  BackupDirectoryUri create() => BackupDirectoryUri();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uri? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uri?>(value),
    );
  }
}

String _$backupDirectoryUriHash() =>
    r'966118c9ec159615de5f37527fa8da4ca1e713d1';

abstract class _$BackupDirectoryUri extends $Notifier<Uri?> {
  Uri? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Uri?, Uri?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Uri?, Uri?>,
              Uri?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
