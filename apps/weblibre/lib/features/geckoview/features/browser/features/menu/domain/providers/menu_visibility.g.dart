// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_visibility.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether the browser menu shows its Connection section for
/// [selectedTabId].
///
/// With the Tor and proxy controls shown, always. Hidden, the section still
/// stays while the tab needs a connection, any connection is active, or Tor
/// is part of the setup ([torInUse]: set to start automatically, configured,
/// routed), so its status and its controls are never out of reach (P5). The
/// section lists Tor by the same rule, so it never stays empty.

@ProviderFor(menuConnectionSectionShown)
final menuConnectionSectionShownProvider = MenuConnectionSectionShownFamily._();

/// Whether the browser menu shows its Connection section for
/// [selectedTabId].
///
/// With the Tor and proxy controls shown, always. Hidden, the section still
/// stays while the tab needs a connection, any connection is active, or Tor
/// is part of the setup ([torInUse]: set to start automatically, configured,
/// routed), so its status and its controls are never out of reach (P5). The
/// section lists Tor by the same rule, so it never stays empty.

final class MenuConnectionSectionShownProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the browser menu shows its Connection section for
  /// [selectedTabId].
  ///
  /// With the Tor and proxy controls shown, always. Hidden, the section still
  /// stays while the tab needs a connection, any connection is active, or Tor
  /// is part of the setup ([torInUse]: set to start automatically, configured,
  /// routed), so its status and its controls are never out of reach (P5). The
  /// section lists Tor by the same rule, so it never stays empty.
  MenuConnectionSectionShownProvider._({
    required MenuConnectionSectionShownFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'menuConnectionSectionShownProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$menuConnectionSectionShownHash();

  @override
  String toString() {
    return r'menuConnectionSectionShownProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    final argument = this.argument as String?;
    return menuConnectionSectionShown(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MenuConnectionSectionShownProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$menuConnectionSectionShownHash() =>
    r'ddb43f66d139fd7637b658427c57abc5e744aa51';

/// Whether the browser menu shows its Connection section for
/// [selectedTabId].
///
/// With the Tor and proxy controls shown, always. Hidden, the section still
/// stays while the tab needs a connection, any connection is active, or Tor
/// is part of the setup ([torInUse]: set to start automatically, configured,
/// routed), so its status and its controls are never out of reach (P5). The
/// section lists Tor by the same rule, so it never stays empty.

final class MenuConnectionSectionShownFamily extends $Family
    with $FunctionalFamilyOverride<bool, String?> {
  MenuConnectionSectionShownFamily._()
    : super(
        retry: null,
        name: r'menuConnectionSectionShownProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Whether the browser menu shows its Connection section for
  /// [selectedTabId].
  ///
  /// With the Tor and proxy controls shown, always. Hidden, the section still
  /// stays while the tab needs a connection, any connection is active, or Tor
  /// is part of the setup ([torInUse]: set to start automatically, configured,
  /// routed), so its status and its controls are never out of reach (P5). The
  /// section lists Tor by the same rule, so it never stays empty.

  MenuConnectionSectionShownProvider call(String? selectedTabId) =>
      MenuConnectionSectionShownProvider._(argument: selectedTabId, from: this);

  @override
  String toString() => r'menuConnectionSectionShownProvider';
}
