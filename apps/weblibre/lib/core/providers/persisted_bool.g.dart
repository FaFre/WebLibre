// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persisted_bool.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PersistedBool)
final persistedBoolProvider = PersistedBoolFamily._();

final class PersistedBoolProvider
    extends $NotifierProvider<PersistedBool, bool> {
  PersistedBoolProvider._({
    required PersistedBoolFamily super.from,
    required PersistedBoolKey super.argument,
  }) : super(
         retry: null,
         name: r'persistedBoolProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$persistedBoolHash();

  @override
  String toString() {
    return r'persistedBoolProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PersistedBool create() => PersistedBool();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PersistedBoolProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$persistedBoolHash() => r'97fd7ed82dfde444fddf4475a3982be00f5f197a';

final class PersistedBoolFamily extends $Family
    with
        $ClassFamilyOverride<
          PersistedBool,
          bool,
          bool,
          bool,
          PersistedBoolKey
        > {
  PersistedBoolFamily._()
    : super(
        retry: null,
        name: r'persistedBoolProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PersistedBoolProvider call(PersistedBoolKey key) =>
      PersistedBoolProvider._(argument: key, from: this);

  @override
  String toString() => r'persistedBoolProvider';
}

abstract class _$PersistedBool extends $Notifier<bool> {
  late final _$args = ref.$arg as PersistedBoolKey;
  PersistedBoolKey get key => _$args;

  bool build(PersistedBoolKey key);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
