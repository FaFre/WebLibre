import 'dart:typed_data';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nullability/nullability.dart';
import 'package:search_backend/search_backend.dart';
import 'package:weblibre/features/search_credits/domain/repositories/web_search_settings.dart';
import 'package:weblibre/features/web_search/domain/controllers/search_controller.dart';
import 'package:weblibre/features/web_search/domain/entities/captured_page_state.dart';
import 'package:weblibre/features/web_search/domain/entities/fetch_method.dart';
import 'package:weblibre/features/web_search/presentation/widgets/search_result_metadata_chips.dart';
import 'package:weblibre/presentation/widgets/uri_breadcrumb.dart';
import 'package:weblibre/presentation/widgets/url_icon.dart';

class WebSearchResultCard extends ConsumerWidget {
  final CompactSearchResult result;

  final Future<void> Function(Uri url) onOpen;
  final Future<void> Function(Uri url) onFetch;
  final Future<void> Function(Uri url) onPreview;
  final Future<void> Function(CapturedPageState captured) onOpenCapture;

  const WebSearchResultCard({
    super.key,
    required this.result,
    required this.onOpen,
    required this.onFetch,
    required this.onPreview,
    required this.onOpenCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final imageUrl = (result.imgSrc?.isNotEmpty ?? false)
        ? result.imgSrc
        : (result.thumbnail?.isNotEmpty ?? false)
        ? result.thumbnail
        : null;

    final imageBytes = imageUrl.mapNotNull(
      (imageUrl) => ref.watch(
        metaSearchControllerProvider.select((s) => s.imagesByUrl[imageUrl]),
      ),
    );

    final document = ref.watch(
      metaSearchControllerProvider.select((s) => s.documentsByUrl[result.url]),
    );

    final queryLanguage = ref.watch(
      webSearchSettingsControllerProvider.select((s) => s.language),
    );

    return Card(
      color: colorScheme.surfaceContainerHigh,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => onOpen(result.url),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _UrlRow(result: result),
              const SizedBox(height: 16),
              _ContentRow(
                result: result,
                imageBytes: imageBytes,
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              if ((result.metadata ?? const []).isNotEmpty ||
                  document != null) ...[
                const SizedBox(height: 12),
                SearchResultMetadataChips(
                  metadata: result.metadata ?? const [],
                  pageMetadata: document?.metadata,
                  queryLanguage: queryLanguage,
                ),
              ],
              if (result.metadata case final metadata? when metadata.isNotEmpty)
                SearchResultMetadataExpandable(metadata: metadata),
              const SizedBox(height: 16),
              _FetchFooter(
                url: result.url,
                onFetch: onFetch,
                onPreview: onPreview,
                onOpenCapture: onOpenCapture,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UrlRow extends StatelessWidget {
  final CompactSearchResult result;

  const _UrlRow({required this.result});

  @override
  Widget build(BuildContext context) {
    return UriBreadcrumb(
      uri: result.url,
      icon: UrlIcon([result.url], iconSize: 16, cacheOnly: true),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  final CompactSearchResult result;
  final Uint8List? imageBytes;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ContentRow({
    required this.result,
    required this.imageBytes,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageBytes != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              imageBytes!,
              width: 88,
              height: 88,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.title,
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                ),
              ),
              if (result.publishedDate case final String date
                  when date.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (result.content case final String content
                  when content.trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                _ExpandableDescription(
                  text: content.trim(),
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(String date) {
    final parsed = DateTime.tryParse(date);

    if (parsed != null) {
      return DateFormat.yMMMd().format(parsed);
    }

    return date;
  }
}

/// Per-URL footer state, batched into a single select() so the footer only
/// rebuilds when something relevant to *this* URL changes.
///
/// `capturing`/`captures` are exposed for rendering, but they are NOT used in
/// [hashParameters] — Dart's built-in `Set`/`Map` compare by identity, so
/// including them would defeat the dedupe (the controller produces fresh
/// instances on every state mutation). Equality is driven instead by scalar
/// signatures derived from those collections, which is enough to detect any
/// change a single result card cares about.
class _FooterState with FastEquatable {
  final bool hasOpenSession;
  final bool isFetching;
  final bool isFetched;
  final String? fetchError;
  final Set<FetchMethodChoice> capturing;
  final Map<FetchMethodChoice, CapturedPageState> captures;
  final int _capturingSignature;
  final int _capturesSignature;

  _FooterState({
    required this.hasOpenSession,
    required this.isFetching,
    required this.isFetched,
    required this.fetchError,
    required this.capturing,
    required this.captures,
  }) : _capturingSignature = _hashCapturing(capturing),
       _capturesSignature = _hashCaptures(captures);

  static int _hashCapturing(Set<FetchMethodChoice> set) {
    // Order-independent hash so we don't depend on Set iteration order.
    var h = 0;
    for (final choice in set) {
      h ^= choice.index;
    }
    return h;
  }

  static int _hashCaptures(Map<FetchMethodChoice, CapturedPageState> map) {
    var h = 0;
    for (final entry in map.entries) {
      // status + errorMessage + localPath cover everything the footer renders
      // about a capture; any change that affects the rendered chip flips one
      // of these fields.
      final v = Object.hash(
        entry.key.index,
        entry.value.status.index,
        entry.value.errorMessage,
        entry.value.localPath,
        entry.value.captureId,
        entry.value.downloadToken,
      );
      h ^= v;
    }
    return h;
  }

  @override
  List<Object?> get hashParameters => [
    hasOpenSession,
    isFetching,
    isFetched,
    fetchError,
    _capturingSignature,
    _capturesSignature,
  ];
}

class _FetchFooter extends ConsumerWidget {
  final Uri url;

  final Future<void> Function(Uri url) onFetch;
  final Future<void> Function(Uri url) onPreview;
  final Future<void> Function(CapturedPageState captured) onOpenCapture;

  const _FetchFooter({
    required this.url,
    required this.onFetch,
    required this.onPreview,
    required this.onOpenCapture,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final footerState = ref.watch(
      metaSearchControllerProvider.select(
        (s) => _FooterState(
          hasOpenSession: s.hasOpenSession,
          isFetching: s.fetchingUrls.contains(url),
          isFetched: s.documentsByUrl.containsKey(url),
          fetchError: s.fetchErrorByUrl[url],
          capturing: s.capturingByUrl[url] ?? const {},
          captures: s.capturedPagesByUrl[url] ?? const {},
        ),
      ),
    );

    final readyChips = <Widget>[];
    final busyChips = <Widget>[];
    final errorChips = <Widget>[];

    for (final choice in FetchMethodChoice.values) {
      if (choice == FetchMethodChoice.trafilatura) {
        if (footerState.isFetched) {
          readyChips.add(
            _CaptureChip(choice: choice, onTap: () => onPreview(url)),
          );
        } else if (footerState.fetchError case final String err) {
          errorChips.add(
            _ErrorChip(
              choice: choice,
              errorMessage: err,
              canRetry: footerState.hasOpenSession,
              onRetry: () => ref
                  .read(metaSearchControllerProvider.notifier)
                  .fetchPage(url),
            ),
          );
        }
        continue;
      }

      final captured = footerState.captures[choice];

      if (captured != null && captured.status == CapturedPageStatus.ready) {
        readyChips.add(
          _CaptureChip(choice: choice, onTap: () => onOpenCapture(captured)),
        );
      } else if (captured != null &&
          captured.status == CapturedPageStatus.downloadFailed) {
        // Distinguish "download failed" (we have a captureId/downloadToken
        // and can retry just the artifact download — no new server work)
        // from "capture failed on server" (no captureId; would need a fresh
        // capture command, which costs another upstream render).
        final canRetryDownload =
            captured.captureId != null && captured.downloadToken != null;

        errorChips.add(
          _ErrorChip(
            choice: choice,
            errorMessage:
                captured.errorMessage ?? 'Capture failed for unknown reason.',
            canRetry: canRetryDownload && footerState.hasOpenSession,
            onRetry: () => ref
                .read(metaSearchControllerProvider.notifier)
                .retryCaptureDownload(url, choice),
          ),
        );
      } else if (_isMethodBusy(footerState, choice)) {
        busyChips.add(_BusyChip(choice: choice));
      }
    }

    final chips = [...readyChips, ...busyChips, ...errorChips];

    return Row(
      children: [
        Expanded(
          child: chips.isEmpty
              ? const SizedBox.shrink()
              : Wrap(spacing: 6, runSpacing: 6, children: chips),
        ),
        // Once the WebSocket session has closed, no further fetch/capture
        // commands can be issued — hide the button rather than have it
        // surface a generic "session is no longer available" error on every
        // tap. The chips above remain interactive (read-only).
        if (footerState.hasOpenSession) ...[
          const SizedBox(width: 8),
          FilledButton.tonalIcon(
            onPressed: () => onFetch(url),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Fetch'),
            style: FilledButton.styleFrom(elevation: 0),
          ),
        ],
      ],
    );
  }

  bool _isMethodBusy(_FooterState s, FetchMethodChoice method) {
    if (method == FetchMethodChoice.trafilatura) {
      return s.isFetching;
    }
    if (s.capturing.contains(method)) {
      return true;
    }
    final captured = s.captures[method];
    return captured != null &&
        (captured.status == CapturedPageStatus.capturing ||
            captured.status == CapturedPageStatus.downloading);
  }
}

class _CaptureChip extends StatelessWidget {
  final FetchMethodChoice choice;
  final Future<void> Function() onTap;

  const _CaptureChip({required this.choice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(choice.icon, size: 16),
      label: Text(choice.shortLabel),
      visualDensity: VisualDensity.compact,
      onPressed: () => onTap(),
    );
  }
}

/// Failed-fetch / failed-capture chip. Always rendered (red, with an error
/// outline icon) so the user can see *which* method failed; tapping pops a
/// dialog with the verbatim server message and an optional retry action.
class _ErrorChip extends StatelessWidget {
  final FetchMethodChoice choice;
  final String errorMessage;
  final bool canRetry;
  final Future<void> Function() onRetry;

  const _ErrorChip({
    required this.choice,
    required this.errorMessage,
    required this.canRetry,
    required this.onRetry,
  });

  Future<void> _showDetail(BuildContext context) async {
    final retry = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text('${choice.title} failed')),
            ],
          ),
          content: SingleChildScrollView(child: Text(errorMessage)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Close'),
            ),
            if (canRetry)
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('Retry'),
              ),
          ],
        );
      },
    );

    if (retry == true) {
      await onRetry();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionChip(
      avatar: Icon(Icons.error_outline, size: 16, color: colorScheme.error),
      label: Text(choice.shortLabel),
      visualDensity: VisualDensity.compact,
      side: BorderSide(color: colorScheme.error),
      labelStyle: TextStyle(color: colorScheme.error),
      onPressed: () => _showDetail(context),
    );
  }
}

class _BusyChip extends StatelessWidget {
  final FetchMethodChoice choice;

  const _BusyChip({required this.choice});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      label: Text(choice.shortLabel),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _ExpandableDescription extends HookWidget {
  static const _collapsedMaxLines = 4;

  final String text;
  final TextStyle? style;

  const _ExpandableDescription({required this.text, required this.style});

  @override
  Widget build(BuildContext context) {
    final expanded = useState(false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        expanded.value = !expanded.value;
      },
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        alignment: Alignment.topCenter,
        child: Text(
          text,
          maxLines: expanded.value ? null : _collapsedMaxLines,
          overflow: expanded.value ? TextOverflow.clip : TextOverflow.ellipsis,
          style: style,
        ),
      ),
    );
  }
}
