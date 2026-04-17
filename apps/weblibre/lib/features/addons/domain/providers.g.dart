// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AddonDetails)
final addonDetailsProvider = AddonDetailsFamily._();

final class AddonDetailsProvider
    extends $AsyncNotifierProvider<AddonDetails, AddonInfo?> {
  AddonDetailsProvider._({
    required AddonDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonDetailsHash();

  @override
  String toString() {
    return r'addonDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddonDetails create() => AddonDetails();

  @override
  bool operator ==(Object other) {
    return other is AddonDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonDetailsHash() => r'26b4a33e9d17aced1d3fb5c6ff28921f611ca5b0';

final class AddonDetailsFamily extends $Family
    with
        $ClassFamilyOverride<
          AddonDetails,
          AsyncValue<AddonInfo?>,
          AddonInfo?,
          FutureOr<AddonInfo?>,
          String
        > {
  AddonDetailsFamily._()
    : super(
        retry: null,
        name: r'addonDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonDetailsProvider call(String addonId) =>
      AddonDetailsProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonDetailsProvider';
}

abstract class _$AddonDetails extends $AsyncNotifier<AddonInfo?> {
  late final _$args = ref.$arg as String;
  String get addonId => _$args;

  FutureOr<AddonInfo?> build(String addonId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AddonInfo?>, AddonInfo?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AddonInfo?>, AddonInfo?>,
              AsyncValue<AddonInfo?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(addonStoreInfo)
final addonStoreInfoProvider = AddonStoreInfoFamily._();

final class AddonStoreInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<AddonStoreInfo?>,
          AddonStoreInfo?,
          FutureOr<AddonStoreInfo?>
        >
    with $FutureModifier<AddonStoreInfo?>, $FutureProvider<AddonStoreInfo?> {
  AddonStoreInfoProvider._({
    required AddonStoreInfoFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonStoreInfoProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonStoreInfoHash();

  @override
  String toString() {
    return r'addonStoreInfoProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AddonStoreInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AddonStoreInfo?> create(Ref ref) {
    final argument = this.argument as String;
    return addonStoreInfo(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is AddonStoreInfoProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonStoreInfoHash() => r'0024a540ecf6f1d55243d9dc963e04fbc212275e';

final class AddonStoreInfoFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AddonStoreInfo?>, String> {
  AddonStoreInfoFamily._()
    : super(
        retry: null,
        name: r'addonStoreInfoProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonStoreInfoProvider call(String addonId) =>
      AddonStoreInfoProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonStoreInfoProvider';
}

@ProviderFor(lastAddonUpdateAttempt)
final lastAddonUpdateAttemptProvider = LastAddonUpdateAttemptFamily._();

final class LastAddonUpdateAttemptProvider
    extends
        $FunctionalProvider<
          AsyncValue<AddonUpdateAttemptInfo?>,
          AddonUpdateAttemptInfo?,
          FutureOr<AddonUpdateAttemptInfo?>
        >
    with
        $FutureModifier<AddonUpdateAttemptInfo?>,
        $FutureProvider<AddonUpdateAttemptInfo?> {
  LastAddonUpdateAttemptProvider._({
    required LastAddonUpdateAttemptFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'lastAddonUpdateAttemptProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$lastAddonUpdateAttemptHash();

  @override
  String toString() {
    return r'lastAddonUpdateAttemptProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<AddonUpdateAttemptInfo?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<AddonUpdateAttemptInfo?> create(Ref ref) {
    final argument = this.argument as String;
    return lastAddonUpdateAttempt(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is LastAddonUpdateAttemptProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$lastAddonUpdateAttemptHash() =>
    r'79847d9f5720fea1f742d57c3b17272ffd980cc1';

final class LastAddonUpdateAttemptFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<AddonUpdateAttemptInfo?>, String> {
  LastAddonUpdateAttemptFamily._()
    : super(
        retry: null,
        name: r'lastAddonUpdateAttemptProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  LastAddonUpdateAttemptProvider call(String addonId) =>
      LastAddonUpdateAttemptProvider._(argument: addonId, from: this);

  @override
  String toString() => r'lastAddonUpdateAttemptProvider';
}

@ProviderFor(AddonUpdateCheck)
final addonUpdateCheckProvider = AddonUpdateCheckFamily._();

final class AddonUpdateCheckProvider
    extends
        $NotifierProvider<AddonUpdateCheck, AsyncValue<AddonUpdateRunResult>> {
  AddonUpdateCheckProvider._({
    required AddonUpdateCheckFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'addonUpdateCheckProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$addonUpdateCheckHash();

  @override
  String toString() {
    return r'addonUpdateCheckProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AddonUpdateCheck create() => AddonUpdateCheck();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<AddonUpdateRunResult> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<AddonUpdateRunResult>>(
        value,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AddonUpdateCheckProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$addonUpdateCheckHash() => r'4ef375b5cd9b0eb89fbbdaff3f93a35482191af5';

final class AddonUpdateCheckFamily extends $Family
    with
        $ClassFamilyOverride<
          AddonUpdateCheck,
          AsyncValue<AddonUpdateRunResult>,
          AsyncValue<AddonUpdateRunResult>,
          AsyncValue<AddonUpdateRunResult>,
          String
        > {
  AddonUpdateCheckFamily._()
    : super(
        retry: null,
        name: r'addonUpdateCheckProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  AddonUpdateCheckProvider call(String addonId) =>
      AddonUpdateCheckProvider._(argument: addonId, from: this);

  @override
  String toString() => r'addonUpdateCheckProvider';
}

abstract class _$AddonUpdateCheck
    extends $Notifier<AsyncValue<AddonUpdateRunResult>> {
  late final _$args = ref.$arg as String;
  String get addonId => _$args;

  AsyncValue<AddonUpdateRunResult> build(String addonId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<AddonUpdateRunResult>,
              AsyncValue<AddonUpdateRunResult>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<AddonUpdateRunResult>,
                AsyncValue<AddonUpdateRunResult>
              >,
              AsyncValue<AddonUpdateRunResult>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

@ProviderFor(AddonList)
final addonListProvider = AddonListProvider._();

final class AddonListProvider
    extends $AsyncNotifierProvider<AddonList, List<AddonInfo>> {
  AddonListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonListHash();

  @$internal
  @override
  AddonList create() => AddonList();
}

String _$addonListHash() => r'7625b69a433d073e186571453e39b557d8b48a5d';

abstract class _$AddonList extends $AsyncNotifier<List<AddonInfo>> {
  FutureOr<List<AddonInfo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<AddonInfo>>, List<AddonInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<AddonInfo>>, List<AddonInfo>>,
              AsyncValue<List<AddonInfo>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AddonBusyIds)
final addonBusyIdsProvider = AddonBusyIdsProvider._();

final class AddonBusyIdsProvider
    extends $NotifierProvider<AddonBusyIds, Set<String>> {
  AddonBusyIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addonBusyIdsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addonBusyIdsHash();

  @$internal
  @override
  AddonBusyIds create() => AddonBusyIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$addonBusyIdsHash() => r'6f9761320d42b2b5132936797617fdb13b718dd3';

abstract class _$AddonBusyIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(PinnedAddonIds)
final pinnedAddonIdsProvider = PinnedAddonIdsProvider._();

final class PinnedAddonIdsProvider
    extends $NotifierProvider<PinnedAddonIds, Set<String>> {
  PinnedAddonIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pinnedAddonIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pinnedAddonIdsHash();

  @$internal
  @override
  PinnedAddonIds create() => PinnedAddonIds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$pinnedAddonIdsHash() => r'4f46cd69d4817e6e19e4d04f4fdcf83d5e2efb8c';

abstract class _$PinnedAddonIds extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(BulkAddonUpdate)
final bulkAddonUpdateProvider = BulkAddonUpdateProvider._();

final class BulkAddonUpdateProvider
    extends $NotifierProvider<BulkAddonUpdate, AsyncValue<void>> {
  BulkAddonUpdateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bulkAddonUpdateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bulkAddonUpdateHash();

  @$internal
  @override
  BulkAddonUpdate create() => BulkAddonUpdate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$bulkAddonUpdateHash() => r'2605711734f9eb6af70e721a4337556a7ea85512';

abstract class _$BulkAddonUpdate extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
