// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_filter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LogFilter)
final logFilterProvider = LogFilterProvider._();

final class LogFilterProvider extends $NotifierProvider<LogFilter, Level> {
  LogFilterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'logFilterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$logFilterHash();

  @$internal
  @override
  LogFilter create() => LogFilter();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Level value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Level>(value),
    );
  }
}

String _$logFilterHash() => r'b2ee125735571998293b0396907938c38a54d0b5';

abstract class _$LogFilter extends $Notifier<Level> {
  Level build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Level, Level>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Level, Level>,
              Level,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
