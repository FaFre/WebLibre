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

class SubscriptionStatus with FastEquatable {
  final bool hasActiveSubscription;
  final DateTime? entitledUntil;
  final String status;
  final String? subscriptionStatus;
  final bool cancelAtPeriodEnd;
  final DateTime? currentPeriodEnd;
  final String? planLabel;

  SubscriptionStatus({
    required this.hasActiveSubscription,
    this.entitledUntil,
    required this.status,
    this.subscriptionStatus,
    required this.cancelAtPeriodEnd,
    this.currentPeriodEnd,
    this.planLabel,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      entitledUntil: json['entitled_until'] != null
          ? DateTime.parse(json['entitled_until'] as String)
          : null,
      status: json['status'] as String? ?? 'inactive',
      subscriptionStatus: json['subscription_status'] as String?,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      currentPeriodEnd: json['current_period_end'] != null
          ? DateTime.parse(json['current_period_end'] as String)
          : null,
      planLabel: json['plan_label'] as String?,
    );
  }

  bool get isActive => hasActiveSubscription;
  bool get isPaused => subscriptionStatus == 'paused';
  bool get isPastDue => subscriptionStatus == 'past_due';

  /// Subscription is on its way out: either explicitly scheduled to end at
  /// period end, already in `canceled` (grace period), or
  /// `scheduled_cancel`. The user can still resume from the portal until
  /// the period ends.
  bool get isWindingDown =>
      cancelAtPeriodEnd ||
      subscriptionStatus == 'canceled' ||
      subscriptionStatus == 'scheduled_cancel';

  /// Whether the backend reports any underlying subscription state at all.
  /// When false the user has never had a sub (or it was wiped) and the UI
  /// should offer "Subscribe" rather than a state-specific message.
  bool get hasSubscriptionRecord => subscriptionStatus != null;

  // Not `const` because `FastEquatable` carries a cached-hash field that
  // disallows const construction. Value-equality from the mixin means
  // `SubscriptionStatus.inactive == SubscriptionStatus(...same fields...)`
  // still holds, which is what Riverpod's `select` dedupe cares about.
  static final inactive = SubscriptionStatus(
    hasActiveSubscription: false,
    status: 'inactive',
    cancelAtPeriodEnd: false,
  );

  @override
  List<Object?> get hashParameters => [
    hasActiveSubscription,
    entitledUntil,
    status,
    subscriptionStatus,
    cancelAtPeriodEnd,
    currentPeriodEnd,
    planLabel,
  ];
}
