// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_backup.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UserBackupService)
final userBackupServiceProvider = UserBackupServiceProvider._();

final class UserBackupServiceProvider
    extends $NotifierProvider<UserBackupService, void> {
  UserBackupServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userBackupServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userBackupServiceHash();

  @$internal
  @override
  UserBackupService create() => UserBackupService();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$userBackupServiceHash() => r'799251a65c07c2bd62b46f1883818c966ca6b587';

abstract class _$UserBackupService extends $Notifier<void> {
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
