// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'split_view_inputs.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The size of the platform view the pages are drawn in, in dp: after bars,
/// side rail, safe areas and the keyboard inset. Reported by the browser view
/// from a `LayoutBuilder` right around the engine view.

@ProviderFor(BrowserContentGeometry)
final browserContentGeometryProvider = BrowserContentGeometryProvider._();

/// The size of the platform view the pages are drawn in, in dp: after bars,
/// side rail, safe areas and the keyboard inset. Reported by the browser view
/// from a `LayoutBuilder` right around the engine view.
final class BrowserContentGeometryProvider
    extends $NotifierProvider<BrowserContentGeometry, Size?> {
  /// The size of the platform view the pages are drawn in, in dp: after bars,
  /// side rail, safe areas and the keyboard inset. Reported by the browser view
  /// from a `LayoutBuilder` right around the engine view.
  BrowserContentGeometryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserContentGeometryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserContentGeometryHash();

  @$internal
  @override
  BrowserContentGeometry create() => BrowserContentGeometry();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Size? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Size?>(value),
    );
  }
}

String _$browserContentGeometryHash() =>
    r'9234fec4ff8845977bf263a71bb2a54fd4563713';

/// The size of the platform view the pages are drawn in, in dp: after bars,
/// side rail, safe areas and the keyboard inset. Reported by the browser view
/// from a `LayoutBuilder` right around the engine view.

abstract class _$BrowserContentGeometry extends $Notifier<Size?> {
  Size? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Size?, Size?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Size?, Size?>,
              Size?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// The separating hinge or half-open fold crossing the browser content, in
/// content-local dp, or null (see `separatingHingeInContent`). Reported by the
/// browser view with [BrowserContentGeometry].

@ProviderFor(BrowserContentHinge)
final browserContentHingeProvider = BrowserContentHingeProvider._();

/// The separating hinge or half-open fold crossing the browser content, in
/// content-local dp, or null (see `separatingHingeInContent`). Reported by the
/// browser view with [BrowserContentGeometry].
final class BrowserContentHingeProvider
    extends $NotifierProvider<BrowserContentHinge, Rect?> {
  /// The separating hinge or half-open fold crossing the browser content, in
  /// content-local dp, or null (see `separatingHingeInContent`). Reported by the
  /// browser view with [BrowserContentGeometry].
  BrowserContentHingeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'browserContentHingeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$browserContentHingeHash();

  @$internal
  @override
  BrowserContentHinge create() => BrowserContentHinge();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Rect? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Rect?>(value),
    );
  }
}

String _$browserContentHingeHash() =>
    r'5b53d955daf3c887badc70bea9defc00ceb63a2c';

/// The separating hinge or half-open fold crossing the browser content, in
/// content-local dp, or null (see `separatingHingeInContent`). Reported by the
/// browser view with [BrowserContentGeometry].

abstract class _$BrowserContentHinge extends $Notifier<Rect?> {
  Rect? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Rect?, Rect?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Rect?, Rect?>,
              Rect?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Whether the soft keyboard is up (settled, not animating).

@ProviderFor(splitKeyboardVisible)
final splitKeyboardVisibleProvider = SplitKeyboardVisibleProvider._();

/// Whether the soft keyboard is up (settled, not animating).

final class SplitKeyboardVisibleProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether the soft keyboard is up (settled, not animating).
  SplitKeyboardVisibleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitKeyboardVisibleProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitKeyboardVisibleHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return splitKeyboardVisible(ref);
  }
}

String _$splitKeyboardVisibleHash() =>
    r'0e0b99637f9c6d49fa086dac4840dc9eb660ddfb';

@ProviderFor(SplitViewChromeController)
final splitViewChromeControllerProvider = SplitViewChromeControllerProvider._();

final class SplitViewChromeControllerProvider
    extends $NotifierProvider<SplitViewChromeController, SplitViewChrome?> {
  SplitViewChromeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splitViewChromeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splitViewChromeControllerHash();

  @$internal
  @override
  SplitViewChromeController create() => SplitViewChromeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitViewChrome? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitViewChrome?>(value),
    );
  }
}

String _$splitViewChromeControllerHash() =>
    r'2fe0858c398342b85bd6e14e69b2283337b81566';

abstract class _$SplitViewChromeController extends $Notifier<SplitViewChrome?> {
  SplitViewChrome? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SplitViewChrome?, SplitViewChrome?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplitViewChrome?, SplitViewChrome?>,
              SplitViewChrome?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(splitTabIdentity)
final splitTabIdentityProvider = SplitTabIdentityFamily._();

final class SplitTabIdentityProvider
    extends
        $FunctionalProvider<
          SplitTabIdentity,
          SplitTabIdentity,
          SplitTabIdentity
        >
    with $Provider<SplitTabIdentity> {
  SplitTabIdentityProvider._({
    required SplitTabIdentityFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'splitTabIdentityProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$splitTabIdentityHash();

  @override
  String toString() {
    return r'splitTabIdentityProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<SplitTabIdentity> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SplitTabIdentity create(Ref ref) {
    final argument = this.argument as String;
    return splitTabIdentity(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplitTabIdentity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplitTabIdentity>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is SplitTabIdentityProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$splitTabIdentityHash() => r'79ca9488ce2631b21fbda6843e0a88a3053c1615';

final class SplitTabIdentityFamily extends $Family
    with $FunctionalFamilyOverride<SplitTabIdentity, String> {
  SplitTabIdentityFamily._()
    : super(
        retry: null,
        name: r'splitTabIdentityProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SplitTabIdentityProvider call(String tabId) =>
      SplitTabIdentityProvider._(argument: tabId, from: this);

  @override
  String toString() => r'splitTabIdentityProvider';
}
