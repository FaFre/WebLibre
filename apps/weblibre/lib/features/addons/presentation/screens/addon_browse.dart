/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
import 'dart:async';

import 'package:fading_scroll/fading_scroll.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/addons/domain/providers.dart';
import 'package:weblibre/features/addons/presentation/widgets/addon_listing_card.dart';

class AddonBrowseView extends HookConsumerWidget {
  const AddonBrowseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(addonStoreAppFilterProvider);

    final searchController = useTextEditingController();
    final query = useState<String>('');
    final debounceTimer = useRef<Timer?>(null);

    useEffect(
      () =>
          () => debounceTimer.value?.cancel(),
      const [],
    );

    final listingsAsync = ref.watch(
      searchAddonListingsProvider(query.value, app),
    );

    final installed = ref.watch(
      addonListProvider.select(
        (value) =>
            value.value?.where((a) => a.isInstalled).map((a) => a.id).toSet() ??
            const <String>{},
      ),
    );

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<AddonStoreApp>(
              segments: const [
                ButtonSegment(
                  value: AddonStoreApp.android,
                  icon: Icon(Icons.phone_android),
                  label: Text('Android'),
                ),
                ButtonSegment(
                  value: AddonStoreApp.firefox,
                  icon: Icon(Icons.desktop_windows),
                  label: Text('Desktop'),
                ),
              ],
              selected: {app},
              onSelectionChanged: (selection) => ref
                  .read(addonStoreAppFilterProvider.notifier)
                  .setApp(selection.first),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search addons.mozilla.org',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.value.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        query.value = '';
                      },
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (text) {
              debounceTimer.value?.cancel();
              debounceTimer.value = Timer(
                const Duration(milliseconds: 400),
                () => query.value = text,
              );
            },
          ),
        ),
        if (app == AddonStoreApp.firefox)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: _DesktopCompatibilityWarning(),
          ),
        Expanded(
          child: listingsAsync.when(
            skipLoadingOnReload: true,
            data: (listings) =>
                _ListingList(listings: listings, installedIds: installed),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 40),
                    const SizedBox(height: 12),
                    const Text('Failed to load extensions'),
                    const SizedBox(height: 8),
                    Text(error.toString(), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DesktopCompatibilityWarning extends StatelessWidget {
  const _DesktopCompatibilityWarning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.tertiaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.tertiary),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.tertiary, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Desktop extensions are not reviewed for mobile. Some may not '
              'work, may crash, or may behave unexpectedly on Android.',
              style: TextStyle(
                color: theme.colorScheme.onTertiaryContainer,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingList extends StatelessWidget {
  final List<AddonListing> listings;
  final Set<String> installedIds;

  const _ListingList({required this.listings, required this.installedIds});

  @override
  Widget build(BuildContext context) {
    if (listings.isEmpty) {
      return const Center(child: Text('No extensions found.'));
    }

    return FadingScroll(
      fadingSize: 25,
      builder: (context, controller) {
        return ListView.builder(
          controller: controller,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: listings.length,
          itemBuilder: (context, index) {
            final listing = listings[index];
            return AddonListingCard(
              listing: listing,
              isInstalled: installedIds.contains(listing.id),
              onTap: () async {
                await AddonListingDetailsRoute(
                  addonId: listing.id,
                  $extra: listing,
                ).push<void>(context);
              },
            );
          },
        );
      },
    );
  }
}
