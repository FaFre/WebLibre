// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qa_memory_chain.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$qAMemoryChainHash() => r'f05ff182416cd8ac8c35f046081652f8964684a8';

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

abstract class _$QAMemoryChain extends BuildlessAutoDisposeNotifier<void> {
  late final String chatId;
  late final String? mainDocumentId;
  late final String? contextId;

  void build({
    required String chatId,
    String? mainDocumentId,
    String? contextId,
  });
}

/// See also [QAMemoryChain].
@ProviderFor(QAMemoryChain)
const qAMemoryChainProvider = QAMemoryChainFamily();

/// See also [QAMemoryChain].
class QAMemoryChainFamily extends Family<void> {
  /// See also [QAMemoryChain].
  const QAMemoryChainFamily();

  /// See also [QAMemoryChain].
  QAMemoryChainProvider call({
    required String chatId,
    String? mainDocumentId,
    String? contextId,
  }) {
    return QAMemoryChainProvider(
      chatId: chatId,
      mainDocumentId: mainDocumentId,
      contextId: contextId,
    );
  }

  @override
  QAMemoryChainProvider getProviderOverride(
    covariant QAMemoryChainProvider provider,
  ) {
    return call(
      chatId: provider.chatId,
      mainDocumentId: provider.mainDocumentId,
      contextId: provider.contextId,
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
  String? get name => r'qAMemoryChainProvider';
}

/// See also [QAMemoryChain].
class QAMemoryChainProvider
    extends AutoDisposeNotifierProviderImpl<QAMemoryChain, void> {
  /// See also [QAMemoryChain].
  QAMemoryChainProvider({
    required String chatId,
    String? mainDocumentId,
    String? contextId,
  }) : this._internal(
          () => QAMemoryChain()
            ..chatId = chatId
            ..mainDocumentId = mainDocumentId
            ..contextId = contextId,
          from: qAMemoryChainProvider,
          name: r'qAMemoryChainProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$qAMemoryChainHash,
          dependencies: QAMemoryChainFamily._dependencies,
          allTransitiveDependencies:
              QAMemoryChainFamily._allTransitiveDependencies,
          chatId: chatId,
          mainDocumentId: mainDocumentId,
          contextId: contextId,
        );

  QAMemoryChainProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.chatId,
    required this.mainDocumentId,
    required this.contextId,
  }) : super.internal();

  final String chatId;
  final String? mainDocumentId;
  final String? contextId;

  @override
  void runNotifierBuild(
    covariant QAMemoryChain notifier,
  ) {
    return notifier.build(
      chatId: chatId,
      mainDocumentId: mainDocumentId,
      contextId: contextId,
    );
  }

  @override
  Override overrideWith(QAMemoryChain Function() create) {
    return ProviderOverride(
      origin: this,
      override: QAMemoryChainProvider._internal(
        () => create()
          ..chatId = chatId
          ..mainDocumentId = mainDocumentId
          ..contextId = contextId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        chatId: chatId,
        mainDocumentId: mainDocumentId,
        contextId: contextId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<QAMemoryChain, void> createElement() {
    return _QAMemoryChainProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is QAMemoryChainProvider &&
        other.chatId == chatId &&
        other.mainDocumentId == mainDocumentId &&
        other.contextId == contextId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, chatId.hashCode);
    hash = _SystemHash.combine(hash, mainDocumentId.hashCode);
    hash = _SystemHash.combine(hash, contextId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin QAMemoryChainRef on AutoDisposeNotifierProviderRef<void> {
  /// The parameter `chatId` of this provider.
  String get chatId;

  /// The parameter `mainDocumentId` of this provider.
  String? get mainDocumentId;

  /// The parameter `contextId` of this provider.
  String? get contextId;
}

class _QAMemoryChainProviderElement
    extends AutoDisposeNotifierProviderElement<QAMemoryChain, void>
    with QAMemoryChainRef {
  _QAMemoryChainProviderElement(super.provider);

  @override
  String get chatId => (origin as QAMemoryChainProvider).chatId;
  @override
  String? get mainDocumentId =>
      (origin as QAMemoryChainProvider).mainDocumentId;
  @override
  String? get contextId => (origin as QAMemoryChainProvider).contextId;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
