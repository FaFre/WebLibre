import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/captured_page_state.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

Future<void> showFetchMethodSheet(
  BuildContext context, {
  required Uri url,
  required Future<void> Function(Uri url) onPreview,
  required Future<void> Function(CapturedPageState captured) onOpenCapture,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _FetchMethodSheet(
      url: url,
      onPreview: onPreview,
      onOpenCapture: onOpenCapture,
    ),
  );
}

class _FetchMethodSheet extends ConsumerWidget {
  final Uri url;
  final Future<void> Function(Uri url) onPreview;
  final Future<void> Function(CapturedPageState captured) onOpenCapture;

  const _FetchMethodSheet({
    required this.url,
    required this.onPreview,
    required this.onOpenCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(metaSearchControllerProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Fetch Page Data', style: textTheme.titleLarge),
                  const SizedBox(height: 4),
                  UriBreadcrumb(
                    uri: url,
                    icon: UrlIcon([url], iconSize: 14, cacheOnly: true),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            for (final choice in FetchMethodChoice.values)
              _MethodTile(
                url: url,
                choice: choice,
                state: state,
                onPreview: onPreview,
                onOpenCapture: onOpenCapture,
              ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends ConsumerWidget {
  final Uri url;
  final FetchMethodChoice choice;
  final MetaSearchState state;
  final Future<void> Function(Uri url) onPreview;
  final Future<void> Function(CapturedPageState captured) onOpenCapture;

  const _MethodTile({
    required this.url,
    required this.choice,
    required this.state,
    required this.onPreview,
    required this.onOpenCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final busy = state.isMethodBusy(url, choice);
    final ready = state.isMethodReady(url, choice);
    final captured = state.capturedPage(url, choice);

    // The trafilatura "preview" goes through fetchPage/fetchErrorByUrl rather
    // than the capture pipeline, so its failures live in a different place
    // than a capture's downloadFailed status. Surface either as the tile's
    // error here (the card no longer shows per-method error chips).
    final String? errorMessage;
    if (busy || ready) {
      errorMessage = null;
    } else if (choice == FetchMethodChoice.trafilatura) {
      errorMessage = state.fetchError(url);
    } else if (captured?.status == CapturedPageStatus.downloadFailed) {
      errorMessage = captured?.errorMessage ?? 'Download failed — tap to retry';
    } else {
      errorMessage = null;
    }
    final failed = errorMessage != null;

    // Starting (or retrying) anything needs an open session; already-ready
    // artifacts can still be opened after the session closes.
    final enabled = !busy && (ready || state.hasOpenSession);

    // A disabled ListTile only dims its title automatically; the leading icon
    // and subtitle carry explicit colors, so dim them too (matching the title's
    // disabled color) to keep the whole tile reading as deactivated.
    final leadingColor = enabled
        ? colorScheme.onSurfaceVariant
        : theme.disabledColor;
    final subtitleColor = !enabled
        ? theme.disabledColor
        : (failed ? colorScheme.error : colorScheme.onSurfaceVariant);

    return ListTile(
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(choice.icon, color: leadingColor),
      title: Text(choice.title),
      subtitle: Text(
        failed ? errorMessage : choice.subtitle,
        style: textTheme.bodySmall?.copyWith(color: subtitleColor),
      ),
      trailing: _StatusIndicator(
        busy: busy,
        ready: ready,
        failed: failed,
        idleColor: leadingColor,
        colorScheme: colorScheme,
      ),
      onTap: enabled
          ? () => _handleTap(context, ref, ready, failed, captured)
          : null,
    );
  }

  Future<void> _handleTap(
    BuildContext context,
    WidgetRef ref,
    bool ready,
    bool failed,
    CapturedPageState? captured,
  ) async {
    if (ready) {
      Navigator.of(context).pop();
      if (choice == FetchMethodChoice.trafilatura) {
        await onPreview(url);
      } else if (captured != null) {
        await onOpenCapture(captured);
      }
      return;
    }

    // Keep the sheet open while a fetch/download runs so its per-method tile
    // shows the live spinner; the user opens the result from here once ready.

    // Trafilatura (re)fetch — the same call covers a first fetch and a retry
    // after a previous fetch error.
    if (choice == FetchMethodChoice.trafilatura) {
      await ref.read(metaSearchControllerProvider.notifier).fetchPage(url);
      return;
    }

    // A failed *download* (we still hold the captureId/downloadToken) only
    // needs the artifact re-fetched — no new upstream render. A server-side
    // capture failure has no token, so it falls through to a fresh capture.
    if (failed &&
        captured?.captureId != null &&
        captured?.downloadToken != null) {
      await ref
          .read(metaSearchControllerProvider.notifier)
          .retryCaptureDownload(url, choice);
      return;
    }

    await ref
        .read(metaSearchControllerProvider.notifier)
        .capturePage(
          url,
          choice: choice,
          // Render at the device's actual viewport so PDF/PNG snapshots
          // match what the user sees; singlefile ignores these fields.
          dimensions: currentDisplayCaptureDimensions(),
        );
  }
}

class _StatusIndicator extends StatelessWidget {
  final bool busy;
  final bool ready;
  final bool failed;
  final Color idleColor;
  final ColorScheme colorScheme;

  const _StatusIndicator({
    required this.busy,
    required this.ready,
    required this.failed,
    required this.idleColor,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (ready) {
      return Icon(Icons.check_circle, color: colorScheme.primary);
    }
    if (failed) {
      return Icon(Icons.refresh, color: colorScheme.error);
    }
    // Idle: mirror the leading icon so a disabled tile dims uniformly.
    return Icon(Icons.download_rounded, color: idleColor);
  }
}
