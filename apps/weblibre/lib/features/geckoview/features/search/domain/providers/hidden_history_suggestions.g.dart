// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hidden_history_suggestions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// History suggestions deleted during this search, by [historySuggestionKey].
///
/// A deleted page leaves the list at once but its visits go only when the
/// Undo for it is gone, as in Fenix: Places cannot take back a deleted visit.

@ProviderFor(HiddenHistorySuggestions)
final hiddenHistorySuggestionsProvider = HiddenHistorySuggestionsProvider._();

/// History suggestions deleted during this search, by [historySuggestionKey].
///
/// A deleted page leaves the list at once but its visits go only when the
/// Undo for it is gone, as in Fenix: Places cannot take back a deleted visit.
final class HiddenHistorySuggestionsProvider
    extends $NotifierProvider<HiddenHistorySuggestions, Set<String>> {
  /// History suggestions deleted during this search, by [historySuggestionKey].
  ///
  /// A deleted page leaves the list at once but its visits go only when the
  /// Undo for it is gone, as in Fenix: Places cannot take back a deleted visit.
  HiddenHistorySuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hiddenHistorySuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hiddenHistorySuggestionsHash();

  @$internal
  @override
  HiddenHistorySuggestions create() => HiddenHistorySuggestions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$hiddenHistorySuggestionsHash() =>
    r'4f94f9aff39c184a21b8f1f5538f4a6a89038001';

/// History suggestions deleted during this search, by [historySuggestionKey].
///
/// A deleted page leaves the list at once but its visits go only when the
/// Undo for it is gone, as in Fenix: Places cannot take back a deleted visit.

abstract class _$HiddenHistorySuggestions extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
