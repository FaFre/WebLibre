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
import 'package:fast_equatable/fast_equatable.dart';

class SearchCreditsStatus with FastEquatable {
  final int availableCredits;
  final int monthlyAllowance;
  final DateTime? lastResetAt;
  final DateTime? lastIssuanceAt;
  final DateTime? currentPeriodEnd;

  SearchCreditsStatus({
    required this.availableCredits,
    this.monthlyAllowance = 0,
    this.lastResetAt,
    this.lastIssuanceAt,
    this.currentPeriodEnd,
  });

  factory SearchCreditsStatus.fromJson(Map<String, dynamic> json) {
    DateTime? parse(Object? v) => (v is String) ? DateTime.parse(v) : null;
    return SearchCreditsStatus(
      availableCredits: (json['available_credits'] as num?)?.toInt() ?? 0,
      monthlyAllowance: (json['monthly_allowance'] as num?)?.toInt() ?? 0,
      lastResetAt: parse(json['last_reset_at']),
      lastIssuanceAt: parse(json['last_issuance_at']),
      currentPeriodEnd: parse(json['current_period_end']),
    );
  }

  // Not `const` because `FastEquatable` carries a cached-hash field that
  // disallows const construction. Value-equality from the mixin means
  // `SearchCreditsStatus(availableCredits: 0) == SearchCreditsStatus.empty`
  // still holds, which is what Riverpod's `select` dedupe cares about.
  static final empty = SearchCreditsStatus(availableCredits: 0);

  @override
  List<Object?> get hashParameters => [
    availableCredits,
    monthlyAllowance,
    lastResetAt,
    lastIssuanceAt,
    currentPeriodEnd,
  ];
}
