// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_container.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$selectedContainerDataHash() =>
    r'1ec86a82e1fc4823a867285f05036c903633a165';

/// See also [selectedContainerData].
@ProviderFor(selectedContainerData)
final selectedContainerDataProvider =
    AutoDisposeStreamProvider<ContainerData?>.internal(
      selectedContainerData,
      name: r'selectedContainerDataProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedContainerDataHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedContainerDataRef = AutoDisposeStreamProviderRef<ContainerData?>;
String _$selectedContainerHash() => r'f3fbe035aff6902c8e140f02a3efeca20a75a70f';

/// See also [SelectedContainer].
@ProviderFor(SelectedContainer)
final selectedContainerProvider =
    NotifierProvider<SelectedContainer, String?>.internal(
      SelectedContainer.new,
      name: r'selectedContainerProvider',
      debugGetCreateSourceHash:
          const bool.fromEnvironment('dart.vm.product')
              ? null
              : _$selectedContainerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SelectedContainer = Notifier<String?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
