// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_initialization.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appInitializationServiceHash() =>
    r'9966be978ea4990c56a3aba347e7979921bf6b2b';

/// See also [AppInitializationService].
@ProviderFor(AppInitializationService)
final appInitializationServiceProvider =
    NotifierProvider<
      AppInitializationService,
      Result<({bool initialized, String? stage, List<ErrorMessage> errors})>
    >.internal(
      AppInitializationService.new,
      name: r'appInitializationServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$appInitializationServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AppInitializationService =
    Notifier<
      Result<({bool initialized, String? stage, List<ErrorMessage> errors})>
    >;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
