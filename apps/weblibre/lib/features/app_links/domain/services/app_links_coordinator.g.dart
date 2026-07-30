// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_links_coordinator.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
/// event handler, queries the native pending store on attach/resume/event, and
/// exposes resolution (including the remember-then-resolve flow). The presented
/// list is authoritative from the query and deduped by `requestId` — the event
/// is only a nudge to re-query.

@ProviderFor(AppLinksCoordinator)
final appLinksCoordinatorProvider = AppLinksCoordinatorProvider._();

/// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
/// event handler, queries the native pending store on attach/resume/event, and
/// exposes resolution (including the remember-then-resolve flow). The presented
/// list is authoritative from the query and deduped by `requestId` — the event
/// is only a nudge to re-query.
final class AppLinksCoordinatorProvider
    extends $NotifierProvider<AppLinksCoordinator, List<AppLinkPromptRequest>> {
  /// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
  /// event handler, queries the native pending store on attach/resume/event, and
  /// exposes resolution (including the remember-then-resolve flow). The presented
  /// list is authoritative from the query and deduped by `requestId` — the event
  /// is only a nudge to re-query.
  AppLinksCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appLinksCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appLinksCoordinatorHash();

  @$internal
  @override
  AppLinksCoordinator create() => AppLinksCoordinator();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<AppLinkPromptRequest> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<AppLinkPromptRequest>>(value),
    );
  }
}

String _$appLinksCoordinatorHash() =>
    r'183fc7ac1264a63c24b1d10f4a22cbfbf6046da7';

/// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
/// event handler, queries the native pending store on attach/resume/event, and
/// exposes resolution (including the remember-then-resolve flow). The presented
/// list is authoritative from the query and deduped by `requestId` — the event
/// is only a nudge to re-query.

abstract class _$AppLinksCoordinator
    extends $Notifier<List<AppLinkPromptRequest>> {
  List<AppLinkPromptRequest> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<List<AppLinkPromptRequest>, List<AppLinkPromptRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<AppLinkPromptRequest>,
                List<AppLinkPromptRequest>
              >,
              List<AppLinkPromptRequest>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
