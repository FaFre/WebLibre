// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMessageRepositoryHash() =>
    r'34055588fb83fd3d4a91219e96a0c5e961af5212';

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

abstract class _$ChatMessageRepository
    extends BuildlessAutoDisposeNotifier<void> {
  late final String chatId;

  void build(String chatId);
}

/// See also [ChatMessageRepository].
@ProviderFor(ChatMessageRepository)
const chatMessageRepositoryProvider = ChatMessageRepositoryFamily();

/// See also [ChatMessageRepository].
class ChatMessageRepositoryFamily extends Family<void> {
  /// See also [ChatMessageRepository].
  const ChatMessageRepositoryFamily();

  /// See also [ChatMessageRepository].
  ChatMessageRepositoryProvider call(String chatId) {
    return ChatMessageRepositoryProvider(chatId);
  }

  @override
  ChatMessageRepositoryProvider getProviderOverride(
    covariant ChatMessageRepositoryProvider provider,
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
  String? get name => r'chatMessageRepositoryProvider';
}

/// See also [ChatMessageRepository].
class ChatMessageRepositoryProvider
    extends AutoDisposeNotifierProviderImpl<ChatMessageRepository, void> {
  /// See also [ChatMessageRepository].
  ChatMessageRepositoryProvider(String chatId)
    : this._internal(
        () => ChatMessageRepository()..chatId = chatId,
        from: chatMessageRepositoryProvider,
        name: r'chatMessageRepositoryProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatMessageRepositoryHash,
        dependencies: ChatMessageRepositoryFamily._dependencies,
        allTransitiveDependencies:
            ChatMessageRepositoryFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatMessageRepositoryProvider._internal(
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
  void runNotifierBuild(covariant ChatMessageRepository notifier) {
    return notifier.build(chatId);
  }

  @override
  Override overrideWith(ChatMessageRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMessageRepositoryProvider._internal(
        () => create()..chatId = chatId,
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
  AutoDisposeNotifierProviderElement<ChatMessageRepository, void>
  createElement() {
    return _ChatMessageRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMessageRepositoryProvider && other.chatId == chatId;
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
mixin ChatMessageRepositoryRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMessageRepositoryProviderElement
    extends AutoDisposeNotifierProviderElement<ChatMessageRepository, void>
    with ChatMessageRepositoryRef {
  _ChatMessageRepositoryProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMessageRepositoryProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
