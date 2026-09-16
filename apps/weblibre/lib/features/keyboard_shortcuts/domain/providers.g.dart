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
