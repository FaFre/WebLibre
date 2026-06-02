import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_credits_repository.dart';
import 'package:weblibre/features/search_credits/domain/repositories/search_token_stash_repository.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/captured_page_state.dart';
import 'package:weblibre/features/web_search/presentation/dialogs/fetch_method_dialog.dart';
import 'package:weblibre/features/web_search/presentation/open_in_new_tab.dart';
import 'package:weblibre/features/web_search/presentation/screens/page_preview.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_result_card.dart';
import 'package:weblibre/features/web_search/presentation/widgets/web_search_infobox_card.dart';
import 'package:weblibre/presentation/widgets/failure_widget.dart';

/// Number of result cards from the bottom at which to prefetch the next
/// page. With a backend page size of 10, four cards of look-ahead means
/// the next page is requested when the user reaches result 6/10 — enough
/// runway for the round-trip on a typical mobile connection without
/// firing the request when it's still ambiguous whether the user will
/// actually scroll further.
const _loadMoreThreshold = 4;

/// Combined credits+tokens balance below which the small "low credits"
/// chip surfaces in the app bar. Picked so the user gets ample warning
/// (~one full page worth of token spend) before running out mid-session.
const _lowCreditWarningThreshold = 25;

/// Resolves [WebSearchOpenTarget] for the *next* result tap.
///
/// We resolve lazily (per-tap) instead of capturing once at section build
/// time so the user can change the tab-type or container selectors in the
/// search header *after* a search completes and have those choices honoured
/// on subsequent taps.
typedef WebSearchOpenTargetResolver = WebSearchOpenTarget Function();

class WebSearchResultsSection extends HookConsumerWidget {
  final WebSearchOpenTargetResolver resolveOpenTarget;

  const WebSearchResultsSection({super.key, required this.resolveOpenTarget});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    useOnAppLifecycleStateChange((previous, current) async {
      if (current == AppLifecycleState.resumed) {
        await ref.read(searchCreditsRepositoryProvider.notifier).refresh();
      }
    });

    Future<void> openUri(Uri uri) {
      return ref
          .read(webSearchTabOpenerProvider)
          .open(context, ref, uri, target: resolveOpenTarget());
    }

    Future<void> showPreview(Uri uri) {
      return Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) =>
              PagePreviewScreen(uri: uri, resolveOpenTarget: resolveOpenTarget),
        ),
      );
    }

    Future<void> openCapture(CapturedPageState captured) async {
      final captureId = captured.captureId;
      if (captureId == null || captured.localPath == null) {
        return;
      }
      await ref
          .read(webSearchTabOpenerProvider)
          .openCapture(
            context,
            ref,
            captureId: captureId,
            sourceUrl: captured.sourceUrl,
            target: resolveOpenTarget(),
            contentType: captured.contentType,
            method: captured.method,
            variant: captured.variant,
          );
    }

    Future<void> onFetch(Uri uri) {
      return showFetchMethodSheet(
        context,
        url: uri,
        onPreview: showPreview,
        onOpenCapture: openCapture,
      );
    }

    // We re-render the whole results sliver on any controller state change
    // because we need the full results/infos lists below. The `select` for
    // the empty-error message is therefore subsumed by this watch.
    final state = ref.watch(metaSearchControllerProvider);

    if (state.status == WebSearchStatus.needsCredits) {
      return const SliverToBoxAdapter(child: _NeedsCredits());
    }

    if (state.status == WebSearchStatus.error && state.results.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FailureWidget(
            title: 'Search failed',
            exception: state.errorMessage,
          ),
        ),
      );
    }

    if (state.status == WebSearchStatus.submitting && state.results.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Searching the web...'),
            ],
          ),
        ),
      );
    }

    if (state.results.isNotEmpty || state.infos.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        sliver: SliverMainAxisGroup(
          slivers: [
            if (state.infos.length == 1)
              SliverToBoxAdapter(
                child: WebSearchInfoboxCard(
                  info: state.infos.first,
                  onOpen: openUri,
                ),
              )
            else if (state.infos.length > 1)
              SliverToBoxAdapter(
                child: WebSearchInfoboxCarousel(
                  infos: state.infos,
                  onOpen: openUri,
                ),
              ),
            if (state.infos.isNotEmpty && state.results.isNotEmpty)
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
            SliverList.separated(
              itemCount: state.results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                // Prefetch the next page once the user is within
                // _loadMoreThreshold cards of the end. Scheduled in a
                // post-frame callback because triggering state writes
                // during build is not allowed; the controller no-ops if
                // a load is already in flight, so re-scheduling on
                // rebuilds is safe.
                if (state.hasMore &&
                    !state.isLoadingMore &&
                    index >= state.results.length - _loadMoreThreshold) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    unawaited(
                      ref
                          .read(metaSearchControllerProvider.notifier)
                          .loadNextPage(),
                    );
                  });
                }
                final result = state.results[index];
                return WebSearchResultCard(
                  key: ValueKey(result.url),
                  result: result,
                  onOpen: openUri,
                  onFetch: onFetch,
                );
              },
            ),
            if (state.hasMore || state.isLoadingMore)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: state.isLoadingMore
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    if (state.query.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'No results found for "${state.query}".',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox.shrink());
  }
}

class WebSearchStatusChip extends ConsumerWidget {
  const WebSearchStatusChip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creditsAsync = ref.watch(searchCreditsRepositoryProvider);
    final stashAsync = ref.watch(searchTokenStashCountProvider);

    if (!creditsAsync.hasValue || !stashAsync.hasValue) {
      return const SizedBox.shrink();
    }

    final credits = creditsAsync.value!.availableCredits;
    final stash = stashAsync.value!;

    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (credits + stash >= _lowCreditWarningThreshold) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => AccountSettingsRoute().push(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.stars_rounded, color: colorScheme.primary, size: 18),
              const SizedBox(width: 6),
              Text(
                '$credits credits  |  $stash tokens',
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NeedsCredits extends StatelessWidget {
  const _NeedsCredits();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'No search credits or tokens are available for a new web search.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Buy a search pack'),
            onPressed: () async {
              await launchUrl(
                Uri.parse('${SupabaseConfig.accountWebUrl}?view=search-pack'),
                mode: LaunchMode.inAppBrowserView,
              );
            },
          ),
        ],
      ),
    );
  }
}
