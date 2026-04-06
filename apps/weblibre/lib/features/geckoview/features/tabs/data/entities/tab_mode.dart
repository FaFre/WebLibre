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

import 'package:weblibre/core/routing/routes.dart';
import 'package:weblibre/features/geckoview/features/tabs/data/entities/isolation_context.dart';

/// Persisted tab privacy/isolation mode.
///
/// Values map to integer values stored in the `tab_mode` column:
/// - 0 = regular
/// - 1 = private
/// - 2 = isolated
enum TabModeDbValue { regular, private, isolated }

sealed class TabMode {
  static const TabMode regular = RegularTabMode();
  static const TabMode private = PrivateTabMode();

  const TabMode();

  factory TabMode.isolated(String isolationContextId) =>
      IsolatedTabMode(isolationContextId);

  factory TabMode.newIsolated() => IsolatedTabMode(newIsolatedContextId());

  factory TabMode.fromTabType(TabType tabType) => switch (tabType) {
    TabType.private => TabMode.private,
    TabType.isolated => TabMode.newIsolated(),
    _ => TabMode.regular,
  };

  TabModeDbValue toDbValue() => switch (this) {
    RegularTabMode() => TabModeDbValue.regular,
    PrivateTabMode() => TabModeDbValue.private,
    IsolatedTabMode() => TabModeDbValue.isolated,
  };

  String? get isolationContextId => switch (this) {
    IsolatedTabMode(:final isolationContextId) => isolationContextId,
    _ => null,
  };

  TabType toTabType() => switch (this) {
    RegularTabMode() => TabType.regular,
    PrivateTabMode() => TabType.private,
    IsolatedTabMode() => TabType.isolated,
  };

  factory TabMode.fromDbValue(
    TabModeDbValue dbValue, {
    required String? isolationContextId,
  }) {
    return switch (dbValue) {
      TabModeDbValue.regular => regular,
      TabModeDbValue.private => private,
      TabModeDbValue.isolated when isolationContextId != null =>
        TabMode.isolated(isolationContextId),
      TabModeDbValue.isolated => regular,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TabMode &&
        other.toDbValue() == toDbValue() &&
        other.isolationContextId == isolationContextId;
  }

  @override
  int get hashCode => Object.hash(toDbValue(), isolationContextId);
}

final class RegularTabMode extends TabMode {
  const RegularTabMode();
}

final class PrivateTabMode extends TabMode {
  const PrivateTabMode();
}

final class IsolatedTabMode extends TabMode {
  @override
  final String isolationContextId;

  const IsolatedTabMode(this.isolationContextId);
}
