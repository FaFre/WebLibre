// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_backend.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatBackendHash() => r'befdad9878bf0a1a8a196af5e3006978026eb8ba';

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

abstract class _$ChatBackend extends BuildlessAutoDisposeNotifier<void> {
  late final String chatId;

  void build(String chatId);
}

/// See also [ChatBackend].
@ProviderFor(ChatBackend)
const chatBackendProvider = ChatBackendFamily();

/// See also [ChatBackend].
class ChatBackendFamily extends Family<void> {
  /// See also [ChatBackend].
  const ChatBackendFamily();

  /// See also [ChatBackend].
  ChatBackendProvider call(String chatId) {
    return ChatBackendProvider(chatId);
  }

  @override
  ChatBackendProvider getProviderOverride(
    covariant ChatBackendProvider provider,
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
  String? get name => r'chatBackendProvider';
}

/// See also [ChatBackend].
class ChatBackendProvider
    extends AutoDisposeNotifierProviderImpl<ChatBackend, void> {
  /// See also [ChatBackend].
  ChatBackendProvider(String chatId)
    : this._internal(
        () => ChatBackend()..chatId = chatId,
        from: chatBackendProvider,
        name: r'chatBackendProvider',
        debugGetCreateSourceHash:
            const bool.fromEnvironment('dart.vm.product')
                ? null
                : _$chatBackendHash,
        dependencies: ChatBackendFamily._dependencies,
        allTransitiveDependencies: ChatBackendFamily._allTransitiveDependencies,
        chatId: chatId,
      );

  ChatBackendProvider._internal(
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
  void runNotifierBuild(covariant ChatBackend notifier) {
    return notifier.build(chatId);
  }

  @override
  Override overrideWith(ChatBackend Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatBackendProvider._internal(
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
  AutoDisposeNotifierProviderElement<ChatBackend, void> createElement() {
    return _ChatBackendProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatBackendProvider && other.chatId == chatId;
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
mixin ChatBackendRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatBackendProviderElement
    extends AutoDisposeNotifierProviderElement<ChatBackend, void>
    with ChatBackendRef {
  _ChatBackendProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatBackendProvider).chatId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
