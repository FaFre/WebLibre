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
    extends $NotifierProvider<AppLinksCoordinator, List<PendingAppLinkPrompt>> {
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
  Override overrideWithValue(List<PendingAppLinkPrompt> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PendingAppLinkPrompt>>(value),
    );
  }
}

String _$appLinksCoordinatorHash() =>
    r'bb34ca15b7f10fbb8bd394412faae62fc100e901';

/// Orchestrates Flutter-owned app-link prompts (§2.6): registers the availability
/// event handler, queries the native pending store on attach/resume/event, and
/// exposes resolution (including the remember-then-resolve flow). The presented
/// list is authoritative from the query and deduped by `requestId` — the event
/// is only a nudge to re-query.

abstract class _$AppLinksCoordinator
    extends $Notifier<List<PendingAppLinkPrompt>> {
  List<PendingAppLinkPrompt> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<List<PendingAppLinkPrompt>, List<PendingAppLinkPrompt>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                List<PendingAppLinkPrompt>,
                List<PendingAppLinkPrompt>
              >,
              List<PendingAppLinkPrompt>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
