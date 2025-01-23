// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatModelHash() => r'e7538b9f0dd43ea64953164c5402e76fde96f5e9';

/// See also [chatModel].
@ProviderFor(chatModel)
final chatModelProvider = Provider<ChatOpenAI>.internal(
  chatModel,
  name: r'chatModelProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$chatModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatModelRef = ProviderRef<ChatOpenAI>;
String _$embeddingModelHash() => r'5d65c75df195a26adefac5a75f0e8f6b0f1b8590';

/// See also [embeddingModel].
@ProviderFor(embeddingModel)
final embeddingModelProvider = Provider<OpenAIEmbeddings>.internal(
  embeddingModel,
  name: r'embeddingModelProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$embeddingModelHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmbeddingModelRef = ProviderRef<OpenAIEmbeddings>;
String _$embeddingDimensionsHash() =>
    r'e34f544a18a7e2bd6a479b21f2016b0c0e2ba96c';

/// See also [embeddingDimensions].
@ProviderFor(embeddingDimensions)
final embeddingDimensionsProvider = Provider<int>.internal(
  embeddingDimensions,
  name: r'embeddingDimensionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$embeddingDimensionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef EmbeddingDimensionsRef = ProviderRef<int>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
