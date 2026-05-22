import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/captured_page_state.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/domain/services/capture_artifact_downloader.dart';

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
                  Text(
                    url.toString(),
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final busy = state.isMethodBusy(url, choice);
    final ready = state.isMethodReady(url, choice);
    final captured = state.capturedPage(url, choice);
    final failed = captured?.status == CapturedPageStatus.downloadFailed;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Icon(choice.icon, color: colorScheme.onSurfaceVariant),
      title: Text(choice.title),
      subtitle: Text(
        failed
            ? (captured?.errorMessage ?? 'Download failed — tap to retry')
            : choice.subtitle,
        style: textTheme.bodySmall?.copyWith(
          color: failed ? colorScheme.error : colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: _StatusIndicator(
        busy: busy,
        ready: ready,
        failed: failed,
        colorScheme: colorScheme,
      ),
      onTap: busy ? null : () => _handleTap(context, ref, ready, failed, captured),
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

    Navigator.of(context).pop();

    if (failed && captured != null) {
      await ref
          .read(metaSearchControllerProvider.notifier)
          .retryCaptureDownload(url, choice);
      return;
    }

    if (choice == FetchMethodChoice.trafilatura) {
      await ref.read(metaSearchControllerProvider.notifier).fetchPage(url);
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
  final ColorScheme colorScheme;

  const _StatusIndicator({
    required this.busy,
    required this.ready,
    required this.failed,
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
    return Icon(
      Icons.download_rounded,
      color: colorScheme.onSurfaceVariant,
    );
  }
}
