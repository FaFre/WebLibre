// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'keyboard_shortcut_settings.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KeyboardShortcutSettingsRepository)
final keyboardShortcutSettingsRepositoryProvider =
    KeyboardShortcutSettingsRepositoryProvider._();

final class KeyboardShortcutSettingsRepositoryProvider
    extends
        $NotifierProvider<
          KeyboardShortcutSettingsRepository,
          KeyboardShortcutSettings
        > {
  KeyboardShortcutSettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'keyboardShortcutSettingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$keyboardShortcutSettingsRepositoryHash();

  @$internal
  @override
  KeyboardShortcutSettingsRepository create() =>
      KeyboardShortcutSettingsRepository();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyboardShortcutSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyboardShortcutSettings>(value),
    );
  }
}

String _$keyboardShortcutSettingsRepositoryHash() =>
    r'8a4d15cbc524fa6b500e09128c926433756741ea';

abstract class _$KeyboardShortcutSettingsRepository
    extends $Notifier<KeyboardShortcutSettings> {
  KeyboardShortcutSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<KeyboardShortcutSettings, KeyboardShortcutSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KeyboardShortcutSettings, KeyboardShortcutSettings>,
              KeyboardShortcutSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The chords the browser currently reserves, by action; empty while keyboard
/// shortcuts are switched off.
///
/// Kept as its own provider so the map is only rebuilt when the settings
/// change, which is what lets the shortcut widgets memoize on it.

@ProviderFor(effectiveKeyboardShortcuts)
final effectiveKeyboardShortcutsProvider =
    EffectiveKeyboardShortcutsProvider._();

/// The chords the browser currently reserves, by action; empty while keyboard
/// shortcuts are switched off.
///
/// Kept as its own provider so the map is only rebuilt when the settings
/// change, which is what lets the shortcut widgets memoize on it.

final class EffectiveKeyboardShortcutsProvider
    extends
        $FunctionalProvider<
          Map<BrowserAction, List<KeyChord>>,
          Map<BrowserAction, List<KeyChord>>,
          Map<BrowserAction, List<KeyChord>>
        >
    with $Provider<Map<BrowserAction, List<KeyChord>>> {
  /// The chords the browser currently reserves, by action; empty while keyboard
  /// shortcuts are switched off.
  ///
  /// Kept as its own provider so the map is only rebuilt when the settings
  /// change, which is what lets the shortcut widgets memoize on it.
  EffectiveKeyboardShortcutsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'effectiveKeyboardShortcutsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$effectiveKeyboardShortcutsHash();

  @$internal
  @override
  $ProviderElement<Map<BrowserAction, List<KeyChord>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<BrowserAction, List<KeyChord>> create(Ref ref) {
    return effectiveKeyboardShortcuts(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<BrowserAction, List<KeyChord>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<BrowserAction, List<KeyChord>>>(
        value,
      ),
    );
  }
}

String _$effectiveKeyboardShortcutsHash() =>
    r'e3d379129233c281357dc46df5d7d1d1b5cdb5f8';
