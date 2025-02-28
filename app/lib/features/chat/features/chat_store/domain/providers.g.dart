// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatControllerHash() => r'493264a4413ffc2d767d73a90634e1a1744cfcfd';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [chatController].
@ProviderFor(chatController)
const chatControllerProvider = ChatControllerFamily();

/// See also [chatController].
class ChatControllerFamily extends Family<DriftChatController> {
  /// See also [chatController].
  const ChatControllerFamily();

  /// See also [chatController].
  ChatControllerProvider call(String chatId) {
    return ChatControllerProvider(chatId);
  }

  @override
  ChatControllerProvider getProviderOverride(
    covariant ChatControllerProvider provider,
  ) {
    return call(provider.chatId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatControllerProvider';
}

/// See also [chatController].
class ChatControllerProvider extends AutoDisposeProvider<DriftChatController> {
  /// See also [chatController].
  ChatControllerProvider(String chatId)
    : this._internal(
        (ref) => chatController(ref as ChatControllerRef, chatId),
        from: chatControllerProvider,
        name: r'chatControllerProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatControllerHash,
        dependencies: ChatControllerFamily._dependencies,
        allTransitiveDependencies:
            ChatControllerFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatControllerProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  Override overrideWith(
    DriftChatController Function(ChatControllerRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatControllerProvider._internal(
        (ref) => create(ref as ChatControllerRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<DriftChatController> createElement() {
    return _ChatControllerProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatControllerProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatControllerRef on AutoDisposeProviderRef<DriftChatController> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatControllerProviderElement
    extends AutoDisposeProviderElement<DriftChatController>
    with ChatControllerRef {
  _ChatControllerProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatControllerProvider).chatId;
}

String _$chatMetadataHash() => r'e50f492ae69168c9f9c4df89e29424b72b681e27';

/// See also [chatMetadata].
@ProviderFor(chatMetadata)
const chatMetadataProvider = ChatMetadataFamily();

/// See also [chatMetadata].
class ChatMetadataFamily extends Family<AsyncValue<ChatMetadata?>> {
  /// See also [chatMetadata].
  const ChatMetadataFamily();

  /// See also [chatMetadata].
  ChatMetadataProvider call(String chatId) {
    return ChatMetadataProvider(chatId);
  }

  @override
  ChatMetadataProvider getProviderOverride(
    covariant ChatMetadataProvider provider,
  ) {
    return call(provider.chatId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMetadataProvider';
}

/// See also [chatMetadata].
class ChatMetadataProvider extends AutoDisposeStreamProvider<ChatMetadata?> {
  /// See also [chatMetadata].
  ChatMetadataProvider(String chatId)
    : this._internal(
        (ref) => chatMetadata(ref as ChatMetadataRef, chatId),
        from: chatMetadataProvider,
        name: r'chatMetadataProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatMetadataHash,
        dependencies: ChatMetadataFamily._dependencies,
        allTransitiveDependencies:
            ChatMetadataFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatMetadataProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
  }) : super.internal();

  final String chatId;

  @override
  Override overrideWith(
    Stream<ChatMetadata?> Function(ChatMetadataRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ChatMetadataProvider._internal(
        (ref) => create(ref as ChatMetadataRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<ChatMetadata?> createElement() {
    return _ChatMetadataProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMetadataProvider && other.chatId == chatId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ChatMetadataRef on AutoDisposeStreamProviderRef<ChatMetadata?> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMetadataProviderElement
    extends AutoDisposeStreamProviderElement<ChatMetadata?>
    with ChatMetadataRef {
  _ChatMetadataProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMetadataProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
