// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_localizations.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// [AppLocalizations] for code that holds a [Ref] but no [BuildContext]:
/// notifiers and providers that put user-facing text into their state (error
/// messages, fallback titles).
///
/// Resolves exactly like the app's `MaterialApp` does — the in-app language
/// override from [effectiveAppLocaleProvider] first, the system locale list
/// otherwise — so this text always matches the UI it is shown in.
///
/// Kept alive because the long-lived repositories and controllers that read
/// it are. It rebuilds on its own when the in-app override changes; a system
/// language change reaches it through `MainApp`, which invalidates it from a
/// binding observer. The provider does not observe the binding itself so that
/// plain `test()` unit tests, which never initialize one, can still read it.

@ProviderFor(appLocalizations)
final appLocalizationsProvider = AppLocalizationsProvider._();

/// [AppLocalizations] for code that holds a [Ref] but no [BuildContext]:
/// notifiers and providers that put user-facing text into their state (error
/// messages, fallback titles).
///
/// Resolves exactly like the app's `MaterialApp` does — the in-app language
/// override from [effectiveAppLocaleProvider] first, the system locale list
/// otherwise — so this text always matches the UI it is shown in.
///
/// Kept alive because the long-lived repositories and controllers that read
/// it are. It rebuilds on its own when the in-app override changes; a system
/// language change reaches it through `MainApp`, which invalidates it from a
/// binding observer. The provider does not observe the binding itself so that
/// plain `test()` unit tests, which never initialize one, can still read it.

final class AppLocalizationsProvider
    extends
        $FunctionalProvider<
          AppLocalizations,
          AppLocalizations,
          AppLocalizations
        >
    with $Provider<AppLocalizations> {
  /// [AppLocalizations] for code that holds a [Ref] but no [BuildContext]:
  /// notifiers and providers that put user-facing text into their state (error
  /// messages, fallback titles).
  ///
  /// Resolves exactly like the app's `MaterialApp` does — the in-app language
  /// override from [effectiveAppLocaleProvider] first, the system locale list
  /// otherwise — so this text always matches the UI it is shown in.
  ///
  /// Kept alive because the long-lived repositories and controllers that read
  /// it are. It rebuilds on its own when the in-app override changes; a system
  /// language change reaches it through `MainApp`, which invalidates it from a
  /// binding observer. The provider does not observe the binding itself so that
  /// plain `test()` unit tests, which never initialize one, can still read it.
  AppLocalizationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLocalizationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLocalizationsHash();

  @$internal
  @override
  $ProviderElement<AppLocalizations> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppLocalizations create(Ref ref) {
    return appLocalizations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppLocalizations value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppLocalizations>(value),
    );
  }
}

String _$appLocalizationsHash() => r'2db987216a5d4dc0a637f694eb73f1d6a22297a7';
