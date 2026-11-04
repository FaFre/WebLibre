// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'legacy_container_options.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LegacyContainerOptions)
final legacyContainerOptionsProvider = LegacyContainerOptionsProvider._();

final class LegacyContainerOptionsProvider
    extends $NotifierProvider<LegacyContainerOptions, void> {
  LegacyContainerOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'legacyContainerOptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$legacyContainerOptionsHash();

  @$internal
  @override
  LegacyContainerOptions create() => LegacyContainerOptions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$legacyContainerOptionsHash() =>
    r'a63e500df487eb484ecb2e7415d6bd9b9cf2eab7';

abstract class _$LegacyContainerOptions extends $Notifier<void> {
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
