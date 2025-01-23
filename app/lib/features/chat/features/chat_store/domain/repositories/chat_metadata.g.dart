// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_metadata.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatMetadataRepositoryHash() =>
    r'72a0226ed7e87f452f4dfe44594bb30663c2db45';

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

abstract class _$ChatMetadataRepository
    extends BuildlessAutoDisposeNotifier<void> {
  late final String chatId;

  void build(
    String chatId,
  );
}

/// See also [ChatMetadataRepository].
@ProviderFor(ChatMetadataRepository)
const chatMetadataRepositoryProvider = ChatMetadataRepositoryFamily();

/// See also [ChatMetadataRepository].
class ChatMetadataRepositoryFamily extends Family<void> {
  /// See also [ChatMetadataRepository].
  const ChatMetadataRepositoryFamily();

  /// See also [ChatMetadataRepository].
  ChatMetadataRepositoryProvider call(
    String chatId,
  ) {
    return ChatMetadataRepositoryProvider(
      chatId,
    );
  }

  @override
  ChatMetadataRepositoryProvider getProviderOverride(
    covariant ChatMetadataRepositoryProvider provider,
  ) {
    return call(
      provider.chatId,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'chatMetadataRepositoryProvider';
}

/// See also [ChatMetadataRepository].
class ChatMetadataRepositoryProvider
    extends AutoDisposeNotifierProviderImpl<ChatMetadataRepository, void> {
  /// See also [ChatMetadataRepository].
  ChatMetadataRepositoryProvider(
    String chatId,
  ) : this._internal(
          () => ChatMetadataRepository()..chatId = chatId,
          from: chatMetadataRepositoryProvider,
          name: r'chatMetadataRepositoryProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$chatMetadataRepositoryHash,
          dependencies: ChatMetadataRepositoryFamily._dependencies,
          allTransitiveDependencies:
              ChatMetadataRepositoryFamily._allTransitiveDependencies,
          chatId: chatId,
        );

  ChatMetadataRepositoryProvider._internal(
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
  void runNotifierBuild(
    covariant ChatMetadataRepository notifier,
  ) {
    return notifier.build(
      chatId,
    );
  }

  @override
  Override overrideWith(ChatMetadataRepository Function() create) {
    return ProviderOverride(
      origin: this,
      override: ChatMetadataRepositoryProvider._internal(
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
  AutoDisposeNotifierProviderElement<ChatMetadataRepository, void>
      createElement() {
    return _ChatMetadataRepositoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ChatMetadataRepositoryProvider && other.chatId == chatId;
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
mixin ChatMetadataRepositoryRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;
}

class _ChatMetadataRepositoryProviderElement
    extends AutoDisposeNotifierProviderElement<ChatMetadataRepository, void>
    with ChatMetadataRepositoryRef {
  _ChatMetadataRepositoryProviderElement(super.provider);

  @override
  String get chatId => (origin as ChatMetadataRepositoryProvider).chatId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
