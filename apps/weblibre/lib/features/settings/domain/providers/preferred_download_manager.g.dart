// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferred_download_manager.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The download manager remembered from the chooser's "Always use this app",
/// or null while every download asks.
///
/// Native owns the value: the chooser that sets it also runs in Custom Tabs,
/// which have no Flutter engine. This reads it back when the settings screen
/// asks, so a choice made since then shows after an [Ref.invalidate].

@ProviderFor(PreferredDownloadManagerChoice)
final preferredDownloadManagerChoiceProvider =
    PreferredDownloadManagerChoiceProvider._();

/// The download manager remembered from the chooser's "Always use this app",
/// or null while every download asks.
///
/// Native owns the value: the chooser that sets it also runs in Custom Tabs,
/// which have no Flutter engine. This reads it back when the settings screen
/// asks, so a choice made since then shows after an [Ref.invalidate].
final class PreferredDownloadManagerChoiceProvider
    extends
        $AsyncNotifierProvider<
          PreferredDownloadManagerChoice,
          PreferredDownloadManager?
        > {
  /// The download manager remembered from the chooser's "Always use this app",
  /// or null while every download asks.
  ///
  /// Native owns the value: the chooser that sets it also runs in Custom Tabs,
  /// which have no Flutter engine. This reads it back when the settings screen
  /// asks, so a choice made since then shows after an [Ref.invalidate].
  PreferredDownloadManagerChoiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'preferredDownloadManagerChoiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$preferredDownloadManagerChoiceHash();

  @$internal
  @override
  PreferredDownloadManagerChoice create() => PreferredDownloadManagerChoice();
}

String _$preferredDownloadManagerChoiceHash() =>
    r'85275893a5bd443b8fb09319d32571ffcee60c43';

/// The download manager remembered from the chooser's "Always use this app",
/// or null while every download asks.
///
/// Native owns the value: the chooser that sets it also runs in Custom Tabs,
/// which have no Flutter engine. This reads it back when the settings screen
/// asks, so a choice made since then shows after an [Ref.invalidate].

abstract class _$PreferredDownloadManagerChoice
    extends $AsyncNotifier<PreferredDownloadManager?> {
  FutureOr<PreferredDownloadManager?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<PreferredDownloadManager?>,
              PreferredDownloadManager?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PreferredDownloadManager?>,
                PreferredDownloadManager?
              >,
              AsyncValue<PreferredDownloadManager?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
