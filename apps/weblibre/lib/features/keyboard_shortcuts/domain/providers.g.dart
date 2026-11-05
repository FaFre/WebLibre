// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether menus show the key that runs each row.
///
/// Android cannot say whether a hardware keyboard is attached, so this goes by
/// what usually comes with one: a pointer in use, or a window wide enough to be
/// a tablet or desktop. A phone held in hand gets no hints to crowd its rows.

@ProviderFor(showKeyboardShortcutHints)
final showKeyboardShortcutHintsProvider = ShowKeyboardShortcutHintsProvider._();

/// Whether menus show the key that runs each row.
///
/// Android cannot say whether a hardware keyboard is attached, so this goes by
/// what usually comes with one: a pointer in use, or a window wide enough to be
/// a tablet or desktop. A phone held in hand gets no hints to crowd its rows.

final class ShowKeyboardShortcutHintsProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether menus show the key that runs each row.
  ///
  /// Android cannot say whether a hardware keyboard is attached, so this goes by
  /// what usually comes with one: a pointer in use, or a window wide enough to be
  /// a tablet or desktop. A phone held in hand gets no hints to crowd its rows.
  ShowKeyboardShortcutHintsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showKeyboardShortcutHintsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showKeyboardShortcutHintsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return showKeyboardShortcutHints(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$showKeyboardShortcutHintsHash() =>
    r'badcd8eb4b1cb528016a52b0f16820264b1fabd2';

/// The chord a menu row names beside [action]: its first binding while
/// hints are shown ([showKeyboardShortcutHints]), null otherwise. The
/// bindings are only read while hints show, so a phone never loads them for
/// its menus.

@ProviderFor(keyboardShortcutHintChord)
final keyboardShortcutHintChordProvider = KeyboardShortcutHintChordFamily._();

/// The chord a menu row names beside [action]: its first binding while
/// hints are shown ([showKeyboardShortcutHints]), null otherwise. The
/// bindings are only read while hints show, so a phone never loads them for
/// its menus.

final class KeyboardShortcutHintChordProvider
    extends $FunctionalProvider<KeyChord?, KeyChord?, KeyChord?>
    with $Provider<KeyChord?> {
  /// The chord a menu row names beside [action]: its first binding while
  /// hints are shown ([showKeyboardShortcutHints]), null otherwise. The
  /// bindings are only read while hints show, so a phone never loads them for
  /// its menus.
  KeyboardShortcutHintChordProvider._({
    required KeyboardShortcutHintChordFamily super.from,
    required BrowserAction super.argument,
  }) : super(
         retry: null,
         name: r'keyboardShortcutHintChordProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$keyboardShortcutHintChordHash();

  @override
  String toString() {
    return r'keyboardShortcutHintChordProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<KeyChord?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KeyChord? create(Ref ref) {
    final argument = this.argument as BrowserAction;
    return keyboardShortcutHintChord(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KeyChord? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KeyChord?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is KeyboardShortcutHintChordProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$keyboardShortcutHintChordHash() =>
    r'80a014ca65e531ab4bb9b5e347f5626642ce58aa';

/// The chord a menu row names beside [action]: its first binding while
/// hints are shown ([showKeyboardShortcutHints]), null otherwise. The
/// bindings are only read while hints show, so a phone never loads them for
/// its menus.

final class KeyboardShortcutHintChordFamily extends $Family
    with $FunctionalFamilyOverride<KeyChord?, BrowserAction> {
  KeyboardShortcutHintChordFamily._()
    : super(
        retry: null,
        name: r'keyboardShortcutHintChordProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The chord a menu row names beside [action]: its first binding while
  /// hints are shown ([showKeyboardShortcutHints]), null otherwise. The
  /// bindings are only read while hints show, so a phone never loads them for
  /// its menus.

  KeyboardShortcutHintChordProvider call(BrowserAction action) =>
      KeyboardShortcutHintChordProvider._(argument: action, from: this);

  @override
  String toString() => r'keyboardShortcutHintChordProvider';
}
