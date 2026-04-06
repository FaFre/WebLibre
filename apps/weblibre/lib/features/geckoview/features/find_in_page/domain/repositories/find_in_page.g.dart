// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'find_in_page.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(FindInPageRepository)
final findInPageRepositoryProvider = FindInPageRepositoryFamily._();

final class FindInPageRepositoryProvider
    extends $NotifierProvider<FindInPageRepository, String?> {
  FindInPageRepositoryProvider._({
    required FindInPageRepositoryFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'findInPageRepositoryProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$findInPageRepositoryHash();

  @override
  String toString() {
    return r'findInPageRepositoryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FindInPageRepository create() => FindInPageRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is FindInPageRepositoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$findInPageRepositoryHash() =>
    r'c289f136c27a22978f15668a13d7044eb39c3355';

final class FindInPageRepositoryFamily extends $Family
    with
        $ClassFamilyOverride<
          FindInPageRepository,
          String?,
          String?,
          String?,
          String?
        > {
  FindInPageRepositoryFamily._()
    : super(
        retry: null,
        name: r'findInPageRepositoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  FindInPageRepositoryProvider call(String? tabId) =>
      FindInPageRepositoryProvider._(argument: tabId, from: this);

  @override
  String toString() => r'findInPageRepositoryProvider';
}

abstract class _$FindInPageRepository extends $Notifier<String?> {
  late final _$args = ref.$arg as String?;
  String? get tabId => _$args;

  String? build(String? tabId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
