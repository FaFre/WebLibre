// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_settings_highlight.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Holds the [SettingsEntryDefinition.title] that a destination settings
/// screen should auto-scroll to and briefly pulse after navigation. Set by
/// the global settings search before pushing the destination route; consumed
/// (and cleared) by the matching entry once it has been highlighted.

@ProviderFor(PendingSettingsHighlight)
final pendingSettingsHighlightProvider = PendingSettingsHighlightProvider._();

/// Holds the [SettingsEntryDefinition.title] that a destination settings
/// screen should auto-scroll to and briefly pulse after navigation. Set by
/// the global settings search before pushing the destination route; consumed
/// (and cleared) by the matching entry once it has been highlighted.
final class PendingSettingsHighlightProvider
    extends $NotifierProvider<PendingSettingsHighlight, String?> {
  /// Holds the [SettingsEntryDefinition.title] that a destination settings
  /// screen should auto-scroll to and briefly pulse after navigation. Set by
  /// the global settings search before pushing the destination route; consumed
  /// (and cleared) by the matching entry once it has been highlighted.
  PendingSettingsHighlightProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingSettingsHighlightProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingSettingsHighlightHash();

  @$internal
  @override
  PendingSettingsHighlight create() => PendingSettingsHighlight();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$pendingSettingsHighlightHash() =>
    r'e64c23c22991e94ec6115ac27b5d7b9d33b801be';

/// Holds the [SettingsEntryDefinition.title] that a destination settings
/// screen should auto-scroll to and briefly pulse after navigation. Set by
/// the global settings search before pushing the destination route; consumed
/// (and cleared) by the matching entry once it has been highlighted.

abstract class _$PendingSettingsHighlight extends $Notifier<String?> {
  String? build();
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
    element.handleCreate(ref, build);
  }
}
