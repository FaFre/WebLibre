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
import 'package:weblibre/features/app_links/domain/services/effective_routing.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/models/site_assignment.dart';
import 'package:weblibre/features/proxy/data/proxy_connection.dart';

SiteAssignment _assignment(String site, {String? contextId}) =>
    SiteAssignment(id: site, contextualIdentity: contextId, assignedSite: site);

void main() {
  group('resolveContainerAssignment', () {
    test('explicit proxy connection wins', () {
      final assignment = resolveContainerAssignment(
        contextId: 'ctx',
        proxyConnectionId: const TorProxyConnectionId(),
        bypassGlobalProxy: false,
      );
      expect(assignment, isA<ExplicitProxyAssignment>());
    });

    test('bypassGlobalProxy with no proxy is direct scoped to the context', () {
      final assignment = resolveContainerAssignment(
        contextId: 'ctx',
        proxyConnectionId: null,
        bypassGlobalProxy: true,
      );
      expect(assignment, isA<DirectProxyAssignment>());
      expect((assignment as DirectProxyAssignment).scopeId, 'ctx');
    });

    test('no proxy and no bypass inherits', () {
      final assignment = resolveContainerAssignment(
        contextId: 'ctx',
        proxyConnectionId: null,
        bypassGlobalProxy: false,
      );
      expect(assignment, isA<InheritProxyAssignment>());
    });
  });

  group('resolveIsolationContextRouting', () {
    test('any explicit proxy wins (lowest sorted id)', () {
      final routing = resolveIsolationContextRouting([
        ProxyAssignment.inherit(),
        ProxyAssignment.explicit('zeta'),
        ProxyAssignment.explicit('alpha'),
        ProxyAssignment.direct('scope'),
      ]);
      expect(routing.chosen, isA<ExplicitProxyAssignment>());
      expect((routing.chosen as ExplicitProxyAssignment).proxyId, 'alpha');
      expect(routing.distinctAssignmentCount, 4);
    });

    test('direct wins only when no container inherits', () {
      final routing = resolveIsolationContextRouting([
        ProxyAssignment.direct('scopeB'),
        ProxyAssignment.direct('scopeA'),
      ]);
      expect(routing.chosen, isA<DirectProxyAssignment>());
      expect((routing.chosen as DirectProxyAssignment).scopeId, 'scopeA');
    });

    test('direct plus inherit collapses to inherit', () {
      final routing = resolveIsolationContextRouting([
        ProxyAssignment.direct('scope'),
        ProxyAssignment.inherit(),
      ]);
      expect(routing.chosen, isA<InheritProxyAssignment>());
      expect(routing.distinctAssignmentCount, 2);
      expect(routing.assignmentLabels, ['inherit', 'direct:scope']);
    });
  });

  group('isAssignmentProtected', () {
    test('explicit is always protected', () {
      expect(
        isAssignmentProtected(
          ProxyAssignment.explicit('p'),
          protectGeneralContext: false,
        ),
        isTrue,
      );
    });

    test('direct is never protected', () {
      expect(
        isAssignmentProtected(
          ProxyAssignment.direct('s'),
          protectGeneralContext: true,
        ),
        isFalse,
      );
    });

    test('inherit follows the general context', () {
      expect(
        isAssignmentProtected(
          ProxyAssignment.inherit(),
          protectGeneralContext: true,
        ),
        isTrue,
      );
      expect(
        isAssignmentProtected(
          ProxyAssignment.inherit(),
          protectGeneralContext: false,
        ),
        isFalse,
      );
    });
  });

  group('protectedTargetPatternForSite', () {
    test('wildcard entry includes subdomains and ignores port', () {
      final pattern = protectedTargetPatternForSite(
        Uri.parse('https://*.example.com'),
      );
      expect(pattern.scheme, 'https');
      expect(pattern.hostOrSuffix, 'example.com');
      expect(pattern.includeSubdomains, isTrue);
      expect(pattern.port, isNull);
    });

    test('exact entry preserves effective port', () {
      final defaultPort = protectedTargetPatternForSite(
        Uri.parse('https://example.com'),
      );
      expect(defaultPort.hostOrSuffix, 'example.com');
      expect(defaultPort.includeSubdomains, isFalse);
      expect(defaultPort.port, 443);

      final explicitPort = protectedTargetPatternForSite(
        Uri.parse('http://example.com:8080'),
      );
      expect(explicitPort.port, 8080);
    });
  });

  group('computeProtectedTargetPatterns', () {
    test('keeps only assignments in a protected or strict container', () {
      final patterns = computeProtectedTargetPatterns(
        assignments: [
          _assignment('https://proxied.example', contextId: 'proxied'),
          _assignment('https://direct.example', contextId: 'direct'),
          _assignment('https://strict.example', contextId: 'strict'),
          _assignment('https://unassigned.example', contextId: null),
        ],
        protectedOrStrictContextIds: {'proxied', 'strict'},
      );

      final hosts = patterns.map((p) => p.hostOrSuffix).toSet();
      expect(hosts, {'proxied.example', 'strict.example'});
    });

    test('deduplicates identical patterns', () {
      final patterns = computeProtectedTargetPatterns(
        assignments: [
          _assignment('https://dup.example', contextId: 'a'),
          _assignment('https://dup.example', contextId: 'a'),
        ],
        protectedOrStrictContextIds: {'a'},
      );
      expect(patterns.length, 1);
    });
  });
}
