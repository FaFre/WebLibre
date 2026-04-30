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
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/user/data/models/ublock_asset.dart';
import 'package:weblibre/features/user/data/models/ublock_filter_list_settings.dart';

UBlockAssetsRegistry _makeRegistry({
  List<MapEntry<String, UBlockAssetEntry>>? extra,
}) {
  final entries = <String, UBlockAssetEntry>{
    'ublock-filters': const UBlockAssetEntry(
      content: 'filters',
      group: UBlockAssetGroup.$default,
      parent: 'uBlock filters',
      title: 'uBlock filters – Ads',
      tags: 'ads',
      contentURL: ['https://example.com/filters.txt'],
    ),
    'ublock-privacy': const UBlockAssetEntry(
      content: 'filters',
      group: UBlockAssetGroup.$default,
      parent: 'uBlock filters',
      title: 'uBlock filters – Privacy',
      tags: 'privacy',
      contentURL: ['https://example.com/privacy.txt'],
    ),
    'easylist': const UBlockAssetEntry(
      content: 'filters',
      group: UBlockAssetGroup.ads,
      title: 'EasyList',
      tags: 'ads',
      preferred: true,
      contentURL: ['https://example.com/easylist.txt'],
    ),
    'DEU-0': const UBlockAssetEntry(
      content: 'filters',
      group: UBlockAssetGroup.regions,
      off: true,
      title: '🇩🇪de: EasyList Germany',
      tags: 'ads german deutsch',
      lang: 'de',
      contentURL: ['https://example.com/deu.txt'],
    ),
    'NLD-0': const UBlockAssetEntry(
      content: 'filters',
      group: UBlockAssetGroup.regions,
      off: true,
      title: '🇳🇱nl: EasyList Dutch',
      tags: 'ads dutch nederlands',
      lang: 'nl',
      contentURL: ['https://example.com/nld.txt'],
    ),
    'assets.json': const UBlockAssetEntry(
      content: 'internal',
      updateAfter: 13,
      contentURL: ['https://example.com/assets.json'],
    ),
  };

  if (extra != null) {
    for (final e in extra) {
      entries[e.key] = e.value;
    }
  }

  return UBlockAssetsRegistry(entries);
}

void main() {
  group('UBlockAssetsRegistry', () {
    test('defaultEnabledTokens excludes off:true entries', () {
      final registry = _makeRegistry();
      expect(
        registry.defaultEnabledTokens,
        containsAll(['ublock-filters', 'ublock-privacy', 'easylist']),
      );
      expect(registry.defaultEnabledTokens, isNot(contains('DEU-0')));
      expect(registry.defaultEnabledTokens, isNot(contains('NLD-0')));
      expect(registry.defaultEnabledTokens, isNot(contains('assets.json')));
    });

    test('tokensMatchingLocales matches primary language code', () {
      final registry = _makeRegistry();
      expect(registry.tokensMatchingLocales(['de-DE']), containsAll(['DEU-0']));
      expect(
        registry.tokensMatchingLocales(['de-DE']),
        isNot(contains('NLD-0')),
      );
      expect(registry.tokensMatchingLocales(['nl-NL']), containsAll(['NLD-0']));
      expect(
        registry.tokensMatchingLocales(['nl-NL']),
        isNot(contains('DEU-0')),
      );
    });

    test('tokensMatchingLocales matches multiple locales', () {
      final registry = _makeRegistry();
      final matched = registry.tokensMatchingLocales(['de-DE', 'nl-NL']);
      expect(matched, containsAll(['DEU-0', 'NLD-0']));
    });

    test('tokensMatchingLocales only matches off:true entries', () {
      final registry = _makeRegistry();
      final matched = registry.tokensMatchingLocales(['en-US']);
      expect(matched, isEmpty);
    });

    test('buildGroupedParentTree creates correct hierarchy', () {
      final registry = _makeRegistry();
      final tree = registry.buildGroupedParentTree();

      expect(tree, contains(UBlockAssetGroup.$default));
      expect(tree[UBlockAssetGroup.$default]!, contains('uBlock filters'));
      expect(
        tree[UBlockAssetGroup.$default]!['uBlock filters'],
        containsAll(['ublock-filters', 'ublock-privacy']),
      );
      expect(tree, contains(UBlockAssetGroup.ads));
      expect(tree[UBlockAssetGroup.ads]!, contains(null));
      expect(tree[UBlockAssetGroup.ads]![null], contains('easylist'));
      expect(tree, contains(UBlockAssetGroup.regions));
    });

    test('fromJson parses a full assets.json structure', () {
      final json =
          jsonDecode('''
      {
        "assets.json": {
          "content": "internal",
          "updateAfter": 13,
          "contentURL": ["https://raw.githubusercontent.com/gorhill/uBlock/master/assets/assets.json"]
        },
        "ublock-filters": {
          "content": "filters",
          "group": "default",
          "parent": "uBlock filters",
          "title": "uBlock filters – Ads",
          "contentURL": "https://example.com/filters.txt",
          "off": true
        }
      }
      ''')
              as Map<String, dynamic>;

      final registry = UBlockAssetsRegistry.fromJson(json);
      expect(registry['ublock-filters'], isNotNull);
      expect(registry['ublock-filters']!.group, UBlockAssetGroup.$default);
      expect(registry['ublock-filters']!.parent, 'uBlock filters');
      expect(registry['ublock-filters']!.off, true);
      expect(registry['ublock-filters']!.contentURL, [
        'https://example.com/filters.txt',
      ]);
      expect(registry['assets.json'], isNotNull);
      expect(registry.defaultEnabledTokens, isEmpty);
    });
  });

  group('UBlockFilterListSettings', () {
    final registry = _makeRegistry();

    test('managedDefaults enables default-on lists without auto tokens', () {
      final settings = UBlockFilterListSettings.managedDefaults(registry);

      expect(settings.enabled, true);
      expect(
        settings.enabledStockListTokens,
        containsAll(['ublock-filters', 'ublock-privacy', 'easylist']),
      );
      expect(settings.autoSelectRegionalLists, false);
      expect(settings.autoEnabledStockListTokens, isEmpty);
    });

    test('resolveFinalList merges manual + auto + external with dedup', () {
      final settings = UBlockFilterListSettings(
        enabled: true,
        enabledStockListTokens: ['ublock-filters', 'easylist'],
        autoEnabledStockListTokens: ['DEU-0', 'ublock-filters'],
        externalFilterLists: [
          UBlockExternalList(url: 'https://example.com/external.txt'),
        ],
      );

      final list = settings.resolveFinalList();

      expect(list.first, 'user-filters');
      expect(
        list,
        containsAll([
          'ublock-filters',
          'easylist',
          'DEU-0',
          'https://example.com/external.txt',
        ]),
      );
      expect(list.where((t) => t == 'ublock-filters').length, 1);
    });

    test('resolveFinalList returns empty when disabled', () {
      final settings = UBlockFilterListSettings(
        enabled: false,
        enabledStockListTokens: ['ublock-filters'],
      );

      expect(settings.resolveFinalList(), isEmpty);
    });

    test('isTokenEnabled checks both manual and auto lists', () {
      final settings = UBlockFilterListSettings(
        enabled: true,
        enabledStockListTokens: ['easylist'],
        autoEnabledStockListTokens: ['DEU-0'],
      );

      expect(settings.isTokenEnabled('easylist'), true);
      expect(settings.isTokenEnabled('DEU-0'), true);
      expect(settings.isTokenEnabled('ublock-filters'), false);
    });

    test(
      'toggling off an auto-only token removes it from autoEnabledStockListTokens',
      () {
        final settings = UBlockFilterListSettings(
          enabled: true,
          enabledStockListTokens: ['easylist'],
          autoEnabledStockListTokens: ['DEU-0', 'NLD-0'],
        );

        final updated = settings.copyWith(
          enabledStockListTokens: [...settings.enabledStockListTokens]
            ..remove('DEU-0'),
          autoEnabledStockListTokens: [...settings.autoEnabledStockListTokens]
            ..remove('DEU-0'),
        );

        expect(updated.autoEnabledStockListTokens, isNot(contains('DEU-0')));
        expect(updated.autoEnabledStockListTokens, contains('NLD-0'));
        expect(updated.isTokenEnabled('DEU-0'), false);
        expect(updated.isTokenEnabled('NLD-0'), true);
      },
    );

    test(
      'toggling off a manual-only token removes it from enabledStockListTokens',
      () {
        final settings = UBlockFilterListSettings(
          enabled: true,
          enabledStockListTokens: ['easylist', 'ublock-filters'],
          autoEnabledStockListTokens: ['DEU-0'],
        );

        final updated = settings.copyWith(
          enabledStockListTokens: [...settings.enabledStockListTokens]
            ..remove('easylist'),
          autoEnabledStockListTokens: [...settings.autoEnabledStockListTokens]
            ..remove('easylist'),
        );

        expect(updated.enabledStockListTokens, isNot(contains('easylist')));
        expect(updated.enabledStockListTokens, contains('ublock-filters'));
        expect(updated.isTokenEnabled('easylist'), false);
      },
    );

    test(
      'toggling off a token in both sets removes it from both',
      () {
        final settings = UBlockFilterListSettings(
          enabled: true,
          enabledStockListTokens: ['DEU-0', 'easylist'],
          autoEnabledStockListTokens: ['DEU-0', 'NLD-0'],
        );

        expect(settings.isTokenEnabled('DEU-0'), true);

        final updated = settings.copyWith(
          enabledStockListTokens: [...settings.enabledStockListTokens]
            ..remove('DEU-0'),
          autoEnabledStockListTokens: [...settings.autoEnabledStockListTokens]
            ..remove('DEU-0'),
        );

        expect(updated.enabledStockListTokens, isNot(contains('DEU-0')));
        expect(updated.autoEnabledStockListTokens, isNot(contains('DEU-0')));
        expect(updated.isTokenEnabled('DEU-0'), false);
        expect(updated.isTokenEnabled('NLD-0'), true);
        expect(updated.isTokenEnabled('easylist'), true);
      },
    );

    test('toggling on a disabled token adds to enabledStockListTokens', () {
      final settings = UBlockFilterListSettings(
        enabled: true,
        enabledStockListTokens: ['easylist'],
        autoEnabledStockListTokens: ['DEU-0'],
      );

      final updated = settings.copyWith.enabledStockListTokens([
        ...settings.enabledStockListTokens,
        'ublock-filters',
      ]);

      expect(updated.enabledStockListTokens, contains('ublock-filters'));
      expect(updated.isTokenEnabled('ublock-filters'), true);
    });

    test('disabling auto-select clears autoEnabledStockListTokens', () {
      final settings = UBlockFilterListSettings(
        enabled: true,
        enabledStockListTokens: ['easylist'],
        autoEnabledStockListTokens: ['DEU-0'],
        autoSelectRegionalLists: true,
      );

      final updated = settings.copyWith(
        autoSelectRegionalLists: false,
        autoEnabledStockListTokens: [],
      );

      expect(updated.autoSelectRegionalLists, false);
      expect(updated.autoEnabledStockListTokens, isEmpty);
      expect(updated.enabledStockListTokens, contains('easylist'));
    });

    test(
      're-enabling auto-select recomputes autoEnabledStockListTokens from registry',
      () {
        var settings = UBlockFilterListSettings(
          enabled: true,
          enabledStockListTokens: ['easylist'],
          autoSelectRegionalLists: false,
          autoEnabledStockListTokens: [],
        );

        final langCodes = ['de-DE', 'nl-NL'];
        final autoTokens = registry.tokensMatchingLocales(langCodes);
        settings = settings.copyWith(
          autoSelectRegionalLists: true,
          autoEnabledStockListTokens: autoTokens,
        );

        expect(settings.autoSelectRegionalLists, true);
        expect(
          settings.autoEnabledStockListTokens,
          containsAll(['DEU-0', 'NLD-0']),
        );
      },
    );

    test('fromJson/toJson round-trips with new fields', () {
      final settings = UBlockFilterListSettings(
        enabled: true,
        enabledStockListTokens: ['easylist'],
        autoEnabledStockListTokens: ['DEU-0'],
        autoSelectRegionalLists: true,
        externalFilterLists: [
          UBlockExternalList(
            url: 'https://example.com/list.txt',
            description: 'Test list',
          ),
        ],
      );

      final json = settings.toJson();
      final restored = UBlockFilterListSettings.fromJson(json);

      expect(restored.enabled, settings.enabled);
      expect(restored.enabledStockListTokens, settings.enabledStockListTokens);
      expect(
        restored.autoEnabledStockListTokens,
        settings.autoEnabledStockListTokens,
      );
      expect(
        restored.autoSelectRegionalLists,
        settings.autoSelectRegionalLists,
      );
      expect(restored.externalFilterLists, settings.externalFilterLists);
    });

    test('fromJson defaults new fields for legacy data', () {
      final legacyJson = {
        'enabled': true,
        'enabledStockListTokens': ['easylist'],
        'externalFilterLists': [],
      };

      final restored = UBlockFilterListSettings.fromJson(legacyJson);

      expect(restored.autoEnabledStockListTokens, isEmpty);
      expect(restored.autoSelectRegionalLists, false);
    });
  });
}
