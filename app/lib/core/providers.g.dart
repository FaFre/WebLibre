// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$routerHash() => r'25fc899b87c080600f6e1d87d510db333378bdfd';

/// See also [router].
@ProviderFor(router)
final routerProvider = Provider<GoRouter>.internal(
  router,
  name: r'routerProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$routerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RouterRef = ProviderRef<GoRouter>;
String _$willAcceptDropHash() => r'97b47784ef9101757602b4408d1f545ef2308830';

/// See also [WillAcceptDrop].
@ProviderFor(WillAcceptDrop)
final willAcceptDropProvider =
    AutoDisposeNotifierProvider<WillAcceptDrop, DropTargetData?>.internal(
  WillAcceptDrop.new,
  name: r'willAcceptDropProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$willAcceptDropHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WillAcceptDrop = AutoDisposeNotifier<DropTargetData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
