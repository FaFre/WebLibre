// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'site_permissions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SitePermissionsRepository)
final sitePermissionsRepositoryProvider = SitePermissionsRepositoryFamily._();

final class SitePermissionsRepositoryProvider
    extends
        $AsyncNotifierProvider<SitePermissionsRepository, SitePermissions?> {
  SitePermissionsRepositoryProvider._({
    required SitePermissionsRepositoryFamily super.from,
    required ({String origin, bool isPrivate}) super.argument,
  }) : super(
         retry: null,
         name: r'sitePermissionsRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sitePermissionsRepositoryHash();

  @override
  String toString() {
    return r'sitePermissionsRepositoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  SitePermissionsRepository create() => SitePermissionsRepository();

  @override
  bool operator ==(Object other) {
    return other is SitePermissionsRepositoryProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sitePermissionsRepositoryHash() =>
    r'b821fbd3a457f5b9cfc6c9d398c93f09c6b30b0b';

final class SitePermissionsRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          SitePermissionsRepository,
          AsyncValue<SitePermissions?>,
          SitePermissions?,
          FutureOr<SitePermissions?>,
          ({String origin, bool isPrivate})
        > {
  SitePermissionsRepositoryFamily._()
    : super(
        retry: null,
        name: r'sitePermissionsRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  SitePermissionsRepositoryProvider call({
    required String origin,
    required bool isPrivate,
  }) => SitePermissionsRepositoryProvider._(
    argument: (origin: origin, isPrivate: isPrivate),
    from: this,
  );

  @override
  String toString() => r'sitePermissionsRepositoryProvider';
}

abstract class _$SitePermissionsRepository
    extends $AsyncNotifier<SitePermissions?> {
  late final _$args = ref.$arg as ({String origin, bool isPrivate});
  String get origin => _$args.origin;
  bool get isPrivate => _$args.isPrivate;

  FutureOr<SitePermissions?> build({
    required String origin,
    required bool isPrivate,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SitePermissions?>, SitePermissions?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SitePermissions?>, SitePermissions?>,
              AsyncValue<SitePermissions?>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(origin: _$args.origin, isPrivate: _$args.isPrivate),
    );
  }
}
