// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_link_policy_replication.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Effective app-link protection (§2.3), recomputed whenever routing, strict
/// mode, contextual identities, or site assignments change.

@ProviderFor(appLinkProtection)
final appLinkProtectionProvider = AppLinkProtectionProvider._();

/// Effective app-link protection (§2.3), recomputed whenever routing, strict
/// mode, contextual identities, or site assignments change.

final class AppLinkProtectionProvider
    extends
        $FunctionalProvider<
          AppLinkProtection,
          AppLinkProtection,
          AppLinkProtection
        >
    with $Provider<AppLinkProtection> {
  /// Effective app-link protection (§2.3), recomputed whenever routing, strict
  /// mode, contextual identities, or site assignments change.
  AppLinkProtectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLinkProtectionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLinkProtectionHash();

  @$internal
  @override
  $ProviderElement<AppLinkProtection> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLinkProtection create(Ref ref) {
    return appLinkProtection(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLinkProtection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLinkProtection>(value),
    );
  }
}

String _$appLinkProtectionHash() => r'6aab203c9b7d2f2c8a73684ea0b624e09fe6179f';

/// The complete policy snapshot to push, or null until the real persisted
/// settings have loaded (the `...WithDefaults` loading placeholder is not valid
/// input, §2.8). Combines the user-intent settings with computed protection.

@ProviderFor(appLinkPolicySnapshot)
final appLinkPolicySnapshotProvider = AppLinkPolicySnapshotProvider._();

/// The complete policy snapshot to push, or null until the real persisted
/// settings have loaded (the `...WithDefaults` loading placeholder is not valid
/// input, §2.8). Combines the user-intent settings with computed protection.

final class AppLinkPolicySnapshotProvider
    extends
        $FunctionalProvider<
          AppLinkPolicySnapshot?,
          AppLinkPolicySnapshot?,
          AppLinkPolicySnapshot?
        >
    with $Provider<AppLinkPolicySnapshot?> {
  /// The complete policy snapshot to push, or null until the real persisted
  /// settings have loaded (the `...WithDefaults` loading placeholder is not valid
  /// input, §2.8). Combines the user-intent settings with computed protection.
  AppLinkPolicySnapshotProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLinkPolicySnapshotProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLinkPolicySnapshotHash();

  @$internal
  @override
  $ProviderElement<AppLinkPolicySnapshot?> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppLinkPolicySnapshot? create(Ref ref) {
    return appLinkPolicySnapshot(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLinkPolicySnapshot? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLinkPolicySnapshot?>(value),
    );
  }
}

String _$appLinkPolicySnapshotHash() =>
    r'6fe2dca118d7162561fc7f6280d1a0411d50972a';

/// Single serialised writer that mirrors the Dart-owned app-link policy to the
/// native profile-scoped store (§2.8), the sole policy source consulted by the
/// interceptor. Structured like `ProxySettingsReplication`; mounted from app root
/// after initialisation.

@ProviderFor(AppLinkPolicyReplication)
final appLinkPolicyReplicationProvider = AppLinkPolicyReplicationProvider._();

/// Single serialised writer that mirrors the Dart-owned app-link policy to the
/// native profile-scoped store (§2.8), the sole policy source consulted by the
/// interceptor. Structured like `ProxySettingsReplication`; mounted from app root
/// after initialisation.
final class AppLinkPolicyReplicationProvider
    extends $NotifierProvider<AppLinkPolicyReplication, void> {
  /// Single serialised writer that mirrors the Dart-owned app-link policy to the
  /// native profile-scoped store (§2.8), the sole policy source consulted by the
  /// interceptor. Structured like `ProxySettingsReplication`; mounted from app root
  /// after initialisation.
  AppLinkPolicyReplicationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLinkPolicyReplicationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLinkPolicyReplicationHash();

  @$internal
  @override
  AppLinkPolicyReplication create() => AppLinkPolicyReplication();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$appLinkPolicyReplicationHash() =>
    r'866e749328bef9f65c2124585d8c03d798802563';

/// Single serialised writer that mirrors the Dart-owned app-link policy to the
/// native profile-scoped store (§2.8), the sole policy source consulted by the
/// interceptor. Structured like `ProxySettingsReplication`; mounted from app root
/// after initialisation.

abstract class _$AppLinkPolicyReplication extends $Notifier<void> {
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
