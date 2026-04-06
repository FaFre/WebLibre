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
import 'package:flutter_test/flutter_test.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/entities/url_cleaner_result.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_rule.dart';
import 'package:weblibre/features/geckoview/features/open_link_tools/domain/services/url_cleaner_service.dart';

void main() {
  group('cleanUrl', () {
    group('basic rule matching', () {
      test('returns unchanged URL when no rules match', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.org',
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl('https://different.com?utm_source=test', rules);

        expect(result.changed, isFalse);
        expect(result.cleanedUrl, 'https://different.com?utm_source=test');
        expect(result.blocked, isFalse);
      });

      test('returns unchanged URL when no rules provided', () {
        final result = cleanUrl('https://example.com?foo=bar', []);

        expect(result.changed, isFalse);
        expect(result.cleanedUrl, 'https://example.com?foo=bar');
      });

      test('matches urlPattern case-insensitively', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['tracking'],
            ),
          ),
        ];

        final result = cleanUrl('HTTPS://EXAMPLE.COM?tracking=abc', rules);

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'HTTPS://EXAMPLE.COM');
      });

      test('skips provider when urlPattern is null', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'broken',
            data: UrlCleanerRuleData(rules: ['utm_source']),
          ),
        ];

        final result = cleanUrl('https://example.com?utm_source=test', rules);

        expect(result.changed, isFalse);
      });
    });

    group('query parameter removal (rules)', () {
      final rules = <UrlCleanerRule>[
        UrlCleanerRule(
          name: 'example',
          data: UrlCleanerRuleData(
            urlPattern: r'^https?://example\.com',
            rules: ['utm_source', 'utm_medium', 'utm_campaign'],
          ),
        ),
      ];

      test('removes single tracking parameter', () {
        final result = cleanUrl('https://example.com?utm_source=google', rules);

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com');
      });

      test('removes multiple tracking parameters', () {
        final result = cleanUrl(
          'https://example.com?utm_source=google&utm_medium=email&utm_campaign=sale',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com');
      });

      test('preserves non-tracked parameters', () {
        final result = cleanUrl(
          'https://example.com?page=1&utm_source=google&sort=date',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com?page=1&sort=date');
      });

      test('removes parameter with regex pattern', () {
        final regexRules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['p[fd]_rd_[a-z]*'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?pd_rd_foo=bar&pf_rd_baz=qux&keep=yes',
          regexRules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com?keep=yes');
      });

      test('handles parameter in fragment', () {
        final result = cleanUrl(
          'https://example.com?keep=yes#section&utm_source=test',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com?keep=yes#section');
      });
    });

    group('rawRules', () {
      test('removes matching raw regex pattern from URL', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'amazon',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://(?:[a-z0-9-]+\.)*?amazon\.com',
              rawRules: [r'\/ref=[^/?]*'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://www.amazon.com/dp/B08N5WRWNW/ref=cm_cr_arp_d_product_top?ie=UTF8',
          rules,
        );

        expect(result.changed, isTrue);
        expect(
          result.cleanedUrl,
          'https://www.amazon.com/dp/B08N5WRWNW?ie=UTF8',
        );
      });

      test('applies multiple rawRules', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rawRules: [r'\/ref=[^/?]*', r'\/tracking\/[^/?]*'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com/page/ref=abc/tracking/xyz?q=1',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com/page?q=1');
      });
    });

    group('removed match details', () {
      test('stores real query matches instead of regex patterns', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['p[fd]_rd_[a-z]*'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?pd_rd_foo=bar&pf_rd_baz=qux&keep=yes',
          rules,
        );

        expect(result.removedParams.map((p) => p.match), [
          'pd_rd_foo=bar',
          'pf_rd_baz=qux',
        ]);
        expect(
          result.removedParams.every(
            (p) => p.type == UrlCleanerMatchType.queryRule,
          ),
          isTrue,
        );
      });

      test('stores concrete raw regex matches', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'amazon',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://(?:[a-z0-9-]+\.)*?amazon\.com',
              rawRules: [r'\/ref=[^/?]*'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://www.amazon.com/dp/B08N5WRWNW/ref=cm_cr_arp_d_product_top?ie=UTF8',
          rules,
        );

        expect(result.removedParams, hasLength(1));
        expect(result.removedParams.single.type, UrlCleanerMatchType.rawRule);
        expect(
          result.removedParams.single.match,
          '/ref=cm_cr_arp_d_product_top',
        );
      });

      test('can remove one matched query parameter individually', () {
        final removed = RemovedParam(
          provider: 'example',
          param: 'utm_source',
          match: 'utm_source=google',
          type: UrlCleanerMatchType.queryRule,
        );

        final result = removeUrlCleanerMatch(
          'https://example.com?utm_source=google&utm_medium=email&keep=1',
          removed,
        );

        expect(result, 'https://example.com?utm_medium=email&keep=1');
      });

      test('can remove one matched raw segment individually', () {
        final removed = RemovedParam(
          provider: 'example',
          param: r'\/ref=[^/?]*',
          match: '/ref=aaa',
          type: UrlCleanerMatchType.rawRule,
        );

        final result = removeUrlCleanerMatch(
          'https://example.com/path/ref=aaa/ref=bbb?x=1',
          removed,
        );

        expect(result, 'https://example.com/path/ref=bbb?x=1');
      });

      test('can remove one matched referral parameter individually', () {
        final removed = RemovedParam(
          provider: 'example',
          param: 'tag',
          match: 'tag=affiliate123',
          type: UrlCleanerMatchType.referralRule,
        );

        final result = removeUrlCleanerMatch(
          'https://example.com?tag=affiliate123&ref_code=abc&keep=1',
          removed,
        );

        expect(result, 'https://example.com?ref_code=abc&keep=1');
      });
    });

    group('redirections', () {
      test('extracts URL from redirection pattern', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'google',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://(?:[a-z0-9-]+\.)*?google\.com',
              redirections: ['url=(.+)'],
            ),
          ),
        ];

        // url=(.+) greedily captures everything after url=, including &sa=D
        final result = cleanUrl(
          'https://www.google.com/url?url=https%3A%2F%2Fexample.com%2Fpage&sa=D',
          rules,
        );

        expect(result.changed, isTrue);
        // The greedy (.+) captures "https%3A%2F%2Fexample.com%2Fpage&sa=D"
        // which decodes to "https://example.com/page&sa=D"
        expect(result.cleanedUrl, 'https://example.com/page&sa=D');
      });

      test('extracts URL when it is the only parameter', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'redirect',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://redirect\.example\.com',
              redirections: ['url=(.+)'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://redirect.example.com?url=https%3A%2F%2Fexample.com%2Fpage',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com/page');
      });

      test('decodes URL-encoded redirection target', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'redirect',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://redirect\.example\.com',
              redirections: ['target=(.+)'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://redirect.example.com?target=https%3A%2F%2Fdest.com%2Fpath%3Fq%3Dhello%20world',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://dest.com/path?q=hello world');
      });

      test('skips to next provider after redirection', () {
        // After redirection, rawRules and rules of the same provider should NOT apply
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'redirect',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://redirect\.example\.com',
              redirections: ['target=(.+)'],
              rules: ['should_not_apply'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://redirect.example.com?target=https%3A%2F%2Fdest.com%3Fshould_not_apply%3Dvalue',
          rules,
        );

        // The redirected URL should still have should_not_apply since
        // rules of the same provider are skipped after redirection
        expect(result.cleanedUrl, 'https://dest.com?should_not_apply=value');
      });

      test('reapplies earlier providers after redirection', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'amazon',
            data: UrlCleanerRuleData(
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?amazon(?:\.[a-z]{2,}){1,}',
              rules: ['qid'],
              referralMarketing: ['tag'],
            ),
          ),
          UrlCleanerRule(
            name: 'google',
            data: UrlCleanerRuleData(
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?google(?:\.[a-z]{2,}){1,}',
              redirections: ['url=(.+)'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://www.google.com/url?url=https%3A%2F%2Fwww.amazon.com%2Fdp%2FB08N5WRWNW%3Fqid%3D123%26tag%3Dmytag-20',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://www.amazon.com/dp/B08N5WRWNW');
        expect(result.matchedProviders, containsAll(['google', 'amazon']));
      });
    });

    group('completeProvider (blocking)', () {
      test('marks URL as blocked when completeProvider is true', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'tracker',
            data: UrlCleanerRuleData(
              completeProvider: true,
              urlPattern: r'^https?://tracker\.example\.com',
            ),
          ),
        ];

        final result = cleanUrl('https://tracker.example.com/pixel', rules);

        expect(result.blocked, isTrue);
        expect(result.cleanedUrl, 'https://tracker.example.com/pixel');
      });

      test('does not block when completeProvider is false', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              // ignore: avoid_redundant_argument_values
              completeProvider: false,
              urlPattern: r'^https?://example\.com',
              rules: ['track'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?track=1', rules);

        expect(result.blocked, isFalse);
        expect(result.changed, isTrue);
      });
    });

    group('exceptions', () {
      test('skips provider when exception matches', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              exceptions: [r'^https?://example\.com/api/'],
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com/api/callback?utm_source=test',
          rules,
        );

        expect(result.changed, isFalse);
        expect(
          result.cleanedUrl,
          'https://example.com/api/callback?utm_source=test',
        );
      });

      test('applies rules when exception does not match', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'example',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              exceptions: [r'^https?://example\.com/api/'],
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com/page?utm_source=test',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com/page');
      });
    });

    group('referralMarketing', () {
      final rules = <UrlCleanerRule>[
        UrlCleanerRule(
          name: 'example',
          data: UrlCleanerRuleData(
            urlPattern: r'^https?://example\.com',
            rules: ['utm_source'],
            referralMarketing: ['tag', 'ref_code'],
          ),
        ),
      ];

      test('removes referral params by default', () {
        final result = cleanUrl(
          'https://example.com?utm_source=test&tag=affiliate123&ref_code=abc',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com');
      });

      test('preserves referral params when allowReferral is true', () {
        final result = cleanUrl(
          'https://example.com?utm_source=test&tag=affiliate123&ref_code=abc',
          rules,
          allowReferral: true,
        );

        expect(result.changed, isTrue);
        expect(
          result.cleanedUrl,
          'https://example.com?tag=affiliate123&ref_code=abc',
        );
        expect(
          result.removedParams.where(
            (p) => p.type == UrlCleanerMatchType.referralRule,
          ),
          hasLength(2),
        );
      });

      test(
        'finds referral params for manual selection when allowReferral is true',
        () {
          final result = cleanUrl(
            'https://example.com?tag=affiliate123&ref_code=abc',
            rules,
            allowReferral: true,
          );

          expect(result.changed, isFalse);
          expect(
            result.cleanedUrl,
            'https://example.com?tag=affiliate123&ref_code=abc',
          );
          expect(result.removedParams, hasLength(2));
          expect(
            result.removedParams.every(
              (p) => p.type == UrlCleanerMatchType.referralRule,
            ),
            isTrue,
          );
        },
      );
    });

    group('URL cleanup artifacts', () {
      test('removes trailing question mark', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['only_param'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?only_param=value', rules);

        expect(result.cleanedUrl, 'https://example.com');
      });

      test('cleans up ?& to ?', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['first'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?first=a&second=b', rules);

        expect(result.cleanedUrl, 'https://example.com?second=b');
      });

      test('cleans up trailing ampersand', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['last'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?keep=yes&last=remove',
          rules,
        );

        expect(result.cleanedUrl, 'https://example.com?keep=yes');
      });

      test('cleans up &# to #', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['tracked'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?tracked=x#section', rules);

        expect(result.cleanedUrl, 'https://example.com#section');
      });

      test('cleans up trailing hash', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['tracked'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?tracked=x#', rules);

        expect(result.cleanedUrl, 'https://example.com');
      });
    });

    group('scheme restoration', () {
      test('prepends https:// when scheme is missing', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'redirect',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://redirect\.com',
              redirections: ['url=(.+)'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://redirect.com?url=example.com%2Fpage',
          rules,
        );

        expect(result.cleanedUrl, 'https://example.com/page');
      });

      test('does not prepend when https:// present', () {
        final result = cleanUrl('https://example.com', []);
        expect(result.cleanedUrl, 'https://example.com');
      });

      test('does not prepend when http:// present', () {
        final result = cleanUrl('http://example.com', []);
        expect(result.cleanedUrl, 'http://example.com');
      });
    });

    group('multiple providers', () {
      test('applies rules from multiple matching providers', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'provider1',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
          UrlCleanerRule(
            name: 'provider2',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['fbclid'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?utm_source=google&fbclid=abc123&page=1',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com?page=1');
      });

      test('only applies matching providers', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'google',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://google\.com',
              rules: ['ved'],
            ),
          ),
          UrlCleanerRule(
            name: 'facebook',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://facebook\.com',
              rules: ['fbclid'],
            ),
          ),
        ];

        final result = cleanUrl('https://google.com?ved=abc&page=1', rules);

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://google.com?page=1');
      });
    });

    group('real-world ClearURLs catalog rules', () {
      test('cleans Amazon URL with tracking params', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'amazon',
            data: UrlCleanerRuleData(
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?amazon(?:\.[a-z]{2,}){1,}',
              rules: ['qid', 'sr', 'ref_?', 'keywords', 'crid', 'sprefix'],
              rawRules: [r'\/ref=[^/?]*'],
              referralMarketing: ['tag', 'ascsubtag'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://www.amazon.com/dp/B08N5WRWNW/ref=cm_cr_arp_d_product_top?qid=123&sr=8-1&keywords=widget&tag=mytag-20',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://www.amazon.com/dp/B08N5WRWNW');
        expect(result.blocked, isFalse);
      });

      test('cleans Google search URL', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'google',
            data: UrlCleanerRuleData(
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?google(?:\.[a-z]{2,}){1,}',
              rules: [
                'ved',
                'ei',
                'source',
                'oq',
                'esrc',
                'aqs',
                'sourceid',
                'sxsrf',
                'rlz',
              ],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://www.google.com/search?q=dart+programming&sourceid=chrome&ie=UTF-8&oq=dart+pro&aqs=chrome.0.69i59j69i57&sxsrf=abc&rlz=1C1',
          rules,
        );

        expect(result.changed, isTrue);
        // q and ie should remain
        expect(result.cleanedUrl, contains('q=dart+programming'));
        expect(result.cleanedUrl, isNot(contains('sourceid=')));
        expect(result.cleanedUrl, isNot(contains('oq=')));
        expect(result.cleanedUrl, isNot(contains('aqs=')));
        expect(result.cleanedUrl, isNot(contains('sxsrf=')));
        expect(result.cleanedUrl, isNot(contains('rlz=')));
      });

      test('blocks fls-na.amazon tracking domain', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'fls-na.amazon',
            data: UrlCleanerRuleData(
              completeProvider: true,
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?fls-na\.amazon(?:\.[a-z]{2,}){1,}',
            ),
          ),
        ];

        final result = cleanUrl(
          'https://fls-na.amazon.com/1/batch/1/OP',
          rules,
        );

        expect(result.blocked, isTrue);
      });

      test('handles Google redirect URL', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'google',
            data: UrlCleanerRuleData(
              urlPattern:
                  r'^https?://(?:[a-z0-9-]+\.)*?google(?:\.[a-z]{2,}){1,}',
              redirections: ['url=(.+)'],
              rules: ['ved', 'usg'],
            ),
          ),
        ];

        // When URL is the sole param, redirection works cleanly
        final result = cleanUrl(
          'https://www.google.com/url?url=https%3A%2F%2Fexample.com%2Farticle',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com/article');
      });
    });

    group('edge cases', () {
      test('handles URL with no query string', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com/page', rules);

        expect(result.changed, isFalse);
        expect(result.cleanedUrl, 'https://example.com/page');
      });

      test('handles URL with empty query string', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['foo'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?', rules);

        // Trailing ? gets cleaned up
        expect(result.cleanedUrl, 'https://example.com');
      });

      test('handles URL with only fragment', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['track'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com#section', rules);

        expect(result.changed, isFalse);
        expect(result.cleanedUrl, 'https://example.com#section');
      });

      test('handles URL with subdomain matching', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://(?:[a-z0-9-]+\.)*?example\.com',
              rules: ['track'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://sub.domain.example.com?track=1&keep=2',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://sub.domain.example.com?keep=2');
      });

      test('handles parameter values containing special characters', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?utm_source=my%20source&title=hello%26world',
          rules,
        );

        expect(result.changed, isTrue);
        expect(result.cleanedUrl, 'https://example.com?title=hello%26world');
      });
    });

    group('removedParams tracking', () {
      test('tracks removed query parameters with provider name', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test_provider',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source', 'utm_medium'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?utm_source=google&utm_medium=email&page=1',
          rules,
        );

        expect(result.removedParams, hasLength(2));
        expect(
          result.removedParams.map((p) => p.param),
          containsAll(['utm_source', 'utm_medium']),
        );
        expect(
          result.removedParams.every((p) => p.provider == 'test_provider'),
          isTrue,
        );
      });

      test('tracks rawRule removals', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'amazon',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://amazon\.com',
              rawRules: [r'\/ref=[^/?]*'],
            ),
          ),
        ];

        final result = cleanUrl('https://amazon.com/dp/B123/ref=sr_1_1', rules);

        expect(result.removedParams, hasLength(1));
        expect(result.removedParams.first.provider, 'amazon');
        expect(result.removedParams.first.param, r'\/ref=[^/?]*');
      });

      test('returns empty removedParams when nothing removed', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?page=1', rules);

        expect(result.removedParams, isEmpty);
        expect(result.changed, isFalse);
      });

      test('tracks params from multiple providers separately', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'provider_a',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
          UrlCleanerRule(
            name: 'provider_b',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['fbclid'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?utm_source=test&fbclid=abc',
          rules,
        );

        expect(result.removedParams, hasLength(2));
        expect(
          result.removedParams.any(
            (p) => p.provider == 'provider_a' && p.param == 'utm_source',
          ),
          isTrue,
        );
        expect(
          result.removedParams.any(
            (p) => p.provider == 'provider_b' && p.param == 'fbclid',
          ),
          isTrue,
        );
      });

      test('does not track unmatched rules', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source', 'not_present'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://example.com?utm_source=test&page=1',
          rules,
        );

        expect(result.removedParams, hasLength(1));
        expect(result.removedParams.first.param, 'utm_source');
      });

      test('tracks referralMarketing removals', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              referralMarketing: ['tag'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?tag=affiliate', rules);

        expect(result.removedParams, hasLength(1));
        expect(result.removedParams.first.param, 'tag');
      });
    });

    group('matchedProviders tracking', () {
      test('lists all matched provider names', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'provider_a',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['a'],
            ),
          ),
          UrlCleanerRule(
            name: 'provider_b',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['b'],
            ),
          ),
          UrlCleanerRule(
            name: 'no_match',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://other\.com',
              rules: ['c'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?a=1&b=2', rules);

        expect(
          result.matchedProviders,
          containsAll(['provider_a', 'provider_b']),
        );
        expect(result.matchedProviders, isNot(contains('no_match')));
      });

      test('includes blocked providers in matchedProviders', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'blocker',
            data: UrlCleanerRuleData(
              completeProvider: true,
              urlPattern: r'^https?://tracker\.com',
            ),
          ),
        ];

        final result = cleanUrl('https://tracker.com/pixel', rules);

        expect(result.matchedProviders, contains('blocker'));
      });
    });

    group('redirectedFrom tracking', () {
      test('records original URL when redirection occurs', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'redirect',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://redir\.com',
              redirections: ['url=(.+)'],
            ),
          ),
        ];

        final result = cleanUrl(
          'https://redir.com?url=https%3A%2F%2Fdest.com',
          rules,
        );

        expect(
          result.redirectedFrom,
          'https://redir.com?url=https%3A%2F%2Fdest.com',
        );
        expect(result.cleanedUrl, 'https://dest.com');
      });

      test('redirectedFrom is null when no redirection', () {
        final rules = <UrlCleanerRule>[
          UrlCleanerRule(
            name: 'test',
            data: UrlCleanerRuleData(
              urlPattern: r'^https?://example\.com',
              rules: ['utm_source'],
            ),
          ),
        ];

        final result = cleanUrl('https://example.com?utm_source=test', rules);

        expect(result.redirectedFrom, isNull);
      });
    });
  });
}
