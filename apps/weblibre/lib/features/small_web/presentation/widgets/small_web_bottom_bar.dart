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
import 'dart:math';

import 'package:fast_equatable/fast_equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/repositories/bookmarks.dart';
import 'package:weblibre/features/geckoview/features/bookmarks/domain/utils/bookmark_tree_utils.dart';
import 'package:weblibre/utils/ui_helper.dart' as ui_helper;

// What words does the wanderer whisper?
const _incantations = [
  'Discover',
  'Explore',
  'Uncover',
  'Venture',
  'Stumble',
  'Unearth',
  'Surface',
  'Traverse',
  'Journey',
  'Wander',
  'Drift',
  'Roam',
  'Seek',
  'Delve',
  'Forage',
  'Glimpse',
  'Meander',
  'Rummage',
  'Saunter',
  'Unveil',
  'Excavate',
  'Fathom',
  'Unravel',
  'Summon',
  'Conjure',
  'Invoke',
  'Divine',
  'Beckon',
  'Emerge',
  'Ascend',
  'Leap',
  'Untangle',
  'Illuminate',
  'Whisper',
  'Ponder',
  'Stray',
  'Ramble',
  'Chart',
  'Prowl',
  'Unwind',
  'Foray',
  'Plunge',
  'Scout',
  'Pilgrimage',
  'Gallivant',
  'Sift',
  'Decode',
  'Unfurl',
  'Kindle',
  'Peruse',
  'Dabble',
  'Peer',
  'Freefall',
  'Vault',
  'Burrow',
  'Glean',
  'Transmute',
  'Decipher',
  'Unmask',
  'Plumb',
  'Unseal',
  'Ignite',
  'Evoke',
  'Manifest',
  'Enchant',
  'Entrance',
  'Lure',
  'Coax',
  'Entice',
  'Eclipse',
  'Transcend',
  'Migrate',
  'Flit',
  'Tumble',
  'Cascade',
  'Zigzag',
  'Spiral',
  'Orbit',
  'Converge',
  'Gravitate',
  'Bloom',
  'Unfold',
  'Blossom',
  'Awaken',
  'Weave',
  'Channel',
  'Envision',
  'Muse',
  'Wonder',
  'Marvel',
  'Dream',
  'Reflect',
  'Behold',
  'Witness',
  'Unlock',
  'Pry',
  'Release',
  'Glide',
  'Soar',
  'Slip',
  'Navigate',
  'Bound',
  'Sweep',
  'Phase',
  'Warp',
  'Shift',
  'Blink',
  'Tiptoe',
  'Breeze',
  'Descend',
  'Immerse',
  'Wade',
  'Launch',
  'Spark',
  'Morph',
];

final _random = Random();

class SmallWebBottomBar extends HookConsumerWidget {
  final bool isLoading;
  final Uri? currentTabUrl;
  final String? currentTabTitle;
  final VoidCallback onDiscover;
  final VoidCallback onMenuTap;
  final VoidCallback onExit;

  const SmallWebBottomBar({
    super.key,
    required this.isLoading,
    required this.currentTabUrl,
    required this.currentTabTitle,
    required this.onDiscover,
    required this.onMenuTap,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = useState(_incantations.first);

    final tabUrl = currentTabUrl;
    final bookmarkable = tabUrl != null;
    final existingGuids = ref
        .watch(
          bookmarksRepositoryProvider.select(
            (async) => EquatableValue(
              bookmarkable
                  ? bookmarkGuidsForUrl(async.value, tabUrl)
                  : const <String>[],
            ),
          ),
        )
        .value;

    final isBookmarked = existingGuids.isNotEmpty;

    return SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            tooltip: 'Menu',
            onPressed: onMenuTap,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        onDiscover();
                        label.value =
                            _incantations[_random.nextInt(
                              _incantations.length,
                            )];
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.explore, size: 20),
                label: Text(label.value),
              ),
            ),
          ),
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            tooltip: isBookmarked ? 'Remove bookmark' : 'Add bookmark',
            onPressed: !bookmarkable
                ? null
                : () async {
                    if (isBookmarked) {
                      for (final guid in existingGuids) {
                        await ref
                            .read(bookmarksRepositoryProvider.notifier)
                            .delete(guid);
                      }
                      if (context.mounted) {
                        ui_helper.showInfoMessage(context, 'Bookmark removed');
                      }
                    } else {
                      await ref
                          .read(bookmarksRepositoryProvider.notifier)
                          .addBookmark(
                            parentGuid: BookmarkRoot.mobile.id,
                            url: tabUrl,
                            title: currentTabTitle ?? tabUrl.host,
                          );
                      if (context.mounted) {
                        ui_helper.showInfoMessage(context, 'Bookmark added');
                      }
                    }
                  },
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Exit Small Web',
            onPressed: onExit,
          ),
        ],
      ),
    );
  }
}
