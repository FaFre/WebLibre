// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_autofocus.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SearchAutofocusSuppression)
final searchAutofocusSuppressionProvider =
    SearchAutofocusSuppressionProvider._();

final class SearchAutofocusSuppressionProvider
    extends $NotifierProvider<SearchAutofocusSuppression, bool> {
  SearchAutofocusSuppressionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchAutofocusSuppressionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchAutofocusSuppressionHash();

  @$internal
  @override
  SearchAutofocusSuppression create() => SearchAutofocusSuppression();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$searchAutofocusSuppressionHash() =>
    r'088e84ab9af2da9a1adc2316c3c594374720cc9e';

abstract class _$SearchAutofocusSuppression extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
