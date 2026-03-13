import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart';
import 'package:weblibre/features/quotes/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';

class TabsEmptyPlaceholder extends ConsumerWidget {
  const TabsEmptyPlaceholder();

  static const _brandPurple = Color(0xFF9C83F8);
  static const _brandYellow = Color(0xFFFBDC6B);
  static const _brandGrey = Color(0xFFA7A7A7);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final quoteAsync = ref.watch(randomQuoteProvider);
    final viewportToolbarInsets = ref.watch(
      browserViewportToolbarInsetsControllerProvider,
    );

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    final bottomViewportInset =
        viewportToolbarInsets.effectiveBottomInsetPx / pixelRatio;

    Future<void> openNewTab() {
      return SearchRoute(
        tabType: settings.effectiveDefaultCreateTabType,
      ).push(context);
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.alphaBlend(
              _brandPurple.withValues(alpha: 0.06),
              colorScheme.surfaceContainerLowest,
            ),
            colorScheme.surface,
            Color.alphaBlend(
              _brandYellow.withValues(alpha: 0.05),
              colorScheme.surfaceContainerHigh,
            ),
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(-0.9, -0.95),
            child: _BackdropOrb(
              size: 220,
              color: _brandPurple.withValues(alpha: 0.14),
            ),
          ),
          Align(
            alignment: const Alignment(1.0, -0.35),
            child: _BackdropOrb(
              size: 180,
              color: _brandYellow.withValues(alpha: 0.14),
            ),
          ),
          Align(
            alignment: const Alignment(-0.75, 0.9),
            child: _BackdropOrb(
              size: 160,
              color: _brandGrey.withValues(alpha: 0.12),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  24,
                  32,
                  24,
                  32 + bottomViewportInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: math.max(
                      0,
                      constraints.maxHeight - 64 - bottomViewportInset,
                    ),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(32),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color.alphaBlend(
                                    _brandPurple.withValues(alpha: 0.18),
                                    colorScheme.surfaceContainerHighest,
                                  ),
                                  Color.alphaBlend(
                                    _brandYellow.withValues(alpha: 0.12),
                                    colorScheme.surfaceContainer,
                                  ),
                                ],
                              ),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.45,
                                ),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.shadow.withValues(
                                    alpha: 0.08,
                                  ),
                                  blurRadius: 32,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icon/icon.svg',
                                width: 72,
                                height: 72,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'WebLibre is ready',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'A browser that respects you. Open a tab and experience the web, libre.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainer.withValues(
                                alpha: 0.9,
                              ),
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Color.alphaBlend(
                                  _brandGrey.withValues(alpha: 0.18),
                                  colorScheme.outlineVariant,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        MdiIcons.formatQuoteOpen,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'A thought for the road',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                    IconButton.filledTonal(
                                      tooltip: 'Refresh quote',
                                      onPressed: () {
                                        ref.invalidate(randomQuoteProvider);
                                      },
                                      icon: const Icon(Icons.refresh_rounded),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                switch (quoteAsync) {
                                  AsyncData(:final value) => _QuoteBlock(
                                    quote: value,
                                  ),
                                  AsyncError() => Text(
                                    'Open a new tab and make this space your own.',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                  _ => const LinearProgressIndicator(
                                    minHeight: 3,
                                  ),
                                },
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed: openNewTab,
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Open new tab'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuoteBlock extends StatelessWidget {
  final Quote? quote;

  const _QuoteBlock({required this.quote});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (quote == null) {
      return Text(
        'Open a new tab and make this space your own.',
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurfaceVariant,
          height: 1.5,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '"${quote!.quote}"',
          style: theme.textTheme.bodyLarge?.copyWith(
            height: 1.55,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '- ${quote!.author}',
          style: theme.textTheme.titleSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (quote!.source case final String source when source.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            source,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _BackdropOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _BackdropOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
