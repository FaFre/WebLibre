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
import 'package:weblibre/features/app_update/domain/entities/component_identity.dart';
import 'package:weblibre/features/app_update/domain/entities/update_assessment.dart';

/// Installed against offered, per component (plan 4.3). Compares the two
/// builds directly, so skipped releases need no special case. `changed` is the
/// answer whenever ordering is uncertain.
class ComponentComparator {
  const ComponentComparator();

  static final _dotted = RegExp(r'^\d+(\.\d+)*$');
  static final _buildId = RegExp(r'^\d{14}$');

  /// Components whose equal versions are ordered by a timestamp build ID.
  static const _buildIdOrdered = {
    ComponentId.gecko,
    ComponentId.androidComponents,
    ComponentId.applicationServices,
  };

  List<ComponentChange> compareAll(
    Map<ComponentId, ComponentIdentity> installed,
    Map<ComponentId, ComponentIdentity> target,
  ) => [
    for (final id in ComponentId.values)
      _change(
        id,
        installed[id] ?? ComponentUnknown(),
        target[id] ?? ComponentUnknown(),
      ),
  ];

  ComponentChange _change(
    ComponentId id,
    ComponentIdentity installed,
    ComponentIdentity target,
  ) => ComponentChange(
    id: id,
    installed: installed,
    target: target,
    kind: compare(id, installed, target),
  );

  ComponentChangeKind compare(
    ComponentId id,
    ComponentIdentity installed,
    ComponentIdentity target,
  ) {
    if (installed is ComponentNotBundled && target is ComponentNotBundled) {
      return ComponentChangeKind.unchanged;
    }
    if (installed is! ComponentKnown || target is! ComponentKnown) {
      return ComponentChangeKind.unknown;
    }
    if (installed == target) return ComponentChangeKind.unchanged;

    if (!_dotted.hasMatch(installed.version) ||
        !_dotted.hasMatch(target.version)) {
      return ComponentChangeKind.changed;
    }

    final order = _compareDotted(installed.version, target.version);
    if (order != 0) {
      return order < 0
          ? ComponentChangeKind.upgraded
          : ComponentChangeKind.downgraded;
    }

    // Same version.
    if (_buildIdOrdered.contains(id)) {
      final a = installed.buildId;
      final b = target.buildId;
      if (a != null &&
          b != null &&
          _buildId.hasMatch(a) &&
          _buildId.hasMatch(b)) {
        final byBuild = a.compareTo(b);
        if (byBuild == 0) {
          return installed.revision == target.revision
              ? ComponentChangeKind.unchanged
              : ComponentChangeKind.changed;
        }
        return byBuild < 0
            ? ComponentChangeKind.upgraded
            : ComponentChangeKind.downgraded;
      }
    }
    // Equal version, but build ID or revision differs and can't be ordered.
    return ComponentChangeKind.changed;
  }

  /// Segments are compared as digit strings, never parsed: a signed
  /// catalogue may carry a segment longer than any integer type.
  static int _compareDotted(String a, String b) {
    final pa = a.split('.');
    final pb = b.split('.');
    final length = pa.length > pb.length ? pa.length : pb.length;
    for (var i = 0; i < length; i++) {
      final order = _compareSegment(
        i < pa.length ? pa[i] : '0',
        i < pb.length ? pb[i] : '0',
      );
      if (order != 0) return order;
    }
    return 0;
  }

  static final _leadingZeros = RegExp(r'^0+(?=\d)');

  static int _compareSegment(String a, String b) {
    final x = a.replaceFirst(_leadingZeros, '');
    final y = b.replaceFirst(_leadingZeros, '');
    if (x.length != y.length) return x.length.compareTo(y.length);
    return x.compareTo(y);
  }
}
