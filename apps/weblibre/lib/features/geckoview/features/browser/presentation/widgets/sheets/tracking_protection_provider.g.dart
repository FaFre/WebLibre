// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracking_protection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that checks if a specific tab has a tracking protection exception
/// Automatically rebuilds when repository changes after mutations

@ProviderFor(hasTrackingProtectionException)
final hasTrackingProtectionExceptionProvider =
    HasTrackingProtectionExceptionFamily._();

/// Provider that checks if a specific tab has a tracking protection exception
/// Automatically rebuilds when repository changes after mutations

final class HasTrackingProtectionExceptionProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Provider that checks if a specific tab has a tracking protection exception
  /// Automatically rebuilds when repository changes after mutations
  HasTrackingProtectionExceptionProvider._({
    required HasTrackingProtectionExceptionFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'hasTrackingProtectionExceptionProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hasTrackingProtectionExceptionHash();

  @override
  String toString() {
    return r'hasTrackingProtectionExceptionProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return hasTrackingProtectionException(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HasTrackingProtectionExceptionProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hasTrackingProtectionExceptionHash() =>
    r'3c6c2d4a2c75d52c33211bc8da8191185fb6c542';

/// Provider that checks if a specific tab has a tracking protection exception
/// Automatically rebuilds when repository changes after mutations

final class HasTrackingProtectionExceptionFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  HasTrackingProtectionExceptionFamily._()
    : super(
        retry: null,
        name: r'hasTrackingProtectionExceptionProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider that checks if a specific tab has a tracking protection exception
  /// Automatically rebuilds when repository changes after mutations

  HasTrackingProtectionExceptionProvider call(String tabId) =>
      HasTrackingProtectionExceptionProvider._(argument: tabId, from: this);

  @override
  String toString() => r'hasTrackingProtectionExceptionProvider';
}
