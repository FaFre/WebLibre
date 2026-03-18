import 'package:flutter/material.dart';
import 'package:flutter_material_design_icons/flutter_material_design_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/design/app_colors.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/domain/providers/tab_list.dart';
import 'package:weblibre/features/geckoview/domain/repositories/tab.dart';
import 'package:weblibre/features/geckoview/features/browser/presentation/providers/browser_viewport_toolbar_insets.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/container_data.dart';
import 'package:weblibre/features/geckoview/features/tabs/domain/providers/selected_container.dart';
import 'package:weblibre/features/geckoview/features/tabs/utils/container_colors.dart';
import 'package:weblibre/features/quotes/data/database/definitions.drift.dart';
import 'package:weblibre/features/quotes/domain/providers.dart';
import 'package:weblibre/features/user/domain/repositories/general_settings.dart';
import 'package:weblibre/presentation/widgets/browser_page.dart';

class BrowserHome extends ConsumerWidget {
  const BrowserHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final settings = ref.watch(generalSettingsWithDefaultsProvider);
    final quoteAsync = ref.watch(randomQuoteProvider);
    final hasTabs = ref.watch(
      tabListProvider.select((tabs) => tabs.value.isNotEmpty),
    );
    final viewportToolbarInsets = ref.watch(
      browserViewportToolbarInsetsControllerProvider,
    );

    final containerData = ref.watch(
      selectedContainerDataProvider.select((value) => value.value),
    );
    final hasContainerTabs = ref.watch(
      selectedContainerTabCountProvider.select(
        (data) => switch (data) {
          AsyncData(:final value) => value > 0,
          _ => false,
        },
      ),
    );

    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    final bottomViewportInset =
        viewportToolbarInsets.effectiveBottomInsetPx / pixelRatio;

    Future<void> openNewTab() {
      return SearchRoute(
        tabType: settings.effectiveDefaultCreateTabType,
      ).push(context);
    }

    Future<void> viewTabs() {
      return const TabViewRoute().push(context);
    }

    Future<void> resumeLatestTab() async {
      await ref.read(tabRepositoryProvider.notifier).resumeLatestTab();
    }

    Future<void> resumeLatestContainerTab() async {
      final containerId = ref.read(selectedContainerProvider);
      await ref
          .read(tabRepositoryProvider.notifier)
          .resumeLatestContainerTab(containerId);
    }

    return BrowserPage(
      child: BrowserPageContent(
        bottomViewportInset: bottomViewportInset,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (containerData != null)
              _ContainerHeader(container: containerData)
            else
              BrandHeader(colorScheme: colorScheme),
            const SizedBox(height: 24),
            if (!hasTabs) ...[
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
            ] else if (containerData != null) ...[
              Text(
                containerData.name?.isNotEmpty == true
                    ? containerData.name!
                    : 'Container',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                hasContainerTabs
                    ? 'No matching tab selected'
                    : 'No open tabs in this container',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 28),
            ],
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: Color.alphaBlend(
                    AppColors.brandGrey.withValues(alpha: 0.18),
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
                          color: theme.colorScheme.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(MdiIcons.formatQuoteOpen, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'A thought for the road',
                          style: theme.textTheme.titleMedium?.copyWith(
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
                    AsyncData(:final value) => _QuoteBlock(quote: value),
                    AsyncError() => Text(
                      'Open a new tab and make this space your own.',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    _ => const LinearProgressIndicator(minHeight: 3),
                  },
                ],
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                if (hasTabs)
                  OutlinedButton.icon(
                    onPressed: viewTabs,
                    icon: const Icon(Icons.tab_rounded),
                    label: const Text('View tabs'),
                  ),
                FilledButton.icon(
                  onPressed: openNewTab,
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('New tab'),
                ),
                if (hasContainerTabs)
                  FilledButton.tonalIcon(
                    onPressed: resumeLatestContainerTab,
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Resume last tab'),
                  )
                else if (hasTabs && containerData == null)
                  FilledButton.tonalIcon(
                    onPressed: resumeLatestTab,
                    icon: const Icon(Icons.history_rounded),
                    label: const Text('Resume last tab'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContainerHeader extends StatelessWidget {
  final ContainerData container;

  const _ContainerHeader({required this.container});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final containerColor = container.color;

    return Container(
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
              ContainerColors.forChip(containerColor),
              colorScheme.surfaceContainerHighest,
            ),
            Color.alphaBlend(
              containerColor.withValues(alpha: 0.12),
              colorScheme.surfaceContainer,
            ),
          ],
        ),
        border: Border.all(
          color: Color.alphaBlend(
            containerColor.withValues(alpha: 0.25),
            colorScheme.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: SvgPicture.asset('assets/icon/icon.svg', width: 72, height: 72),
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
