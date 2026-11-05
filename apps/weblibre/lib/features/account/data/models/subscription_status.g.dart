// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubscriptionStatus _$SubscriptionStatusFromJson(Map<String, dynamic> json) =>
    SubscriptionStatus(
      hasActiveSubscription: json['has_active_subscription'] as bool? ?? false,
      entitledUntil: json['entitled_until'] == null
          ? null
          : DateTime.parse(json['entitled_until'] as String),
      status: json['status'] as String? ?? 'inactive',
      subscriptionStatus: json['subscription_status'] as String?,
      cancelAtPeriodEnd: json['cancel_at_period_end'] as bool? ?? false,
      currentPeriodEnd: json['current_period_end'] == null
          ? null
          : DateTime.parse(json['current_period_end'] as String),
      planLabel: json['plan_label'] as String?,
    );
