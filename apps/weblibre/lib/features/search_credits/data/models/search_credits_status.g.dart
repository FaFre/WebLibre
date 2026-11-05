// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_credits_status.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SearchCreditsStatus _$SearchCreditsStatusFromJson(Map<String, dynamic> json) =>
    SearchCreditsStatus(
      availableCredits: (json['available_credits'] as num?)?.toInt() ?? 0,
      monthlyAllowance: (json['monthly_allowance'] as num?)?.toInt() ?? 0,
      lastResetAt: SearchCreditsStatus._lenientDateTime(json['last_reset_at']),
      lastIssuanceAt: SearchCreditsStatus._lenientDateTime(
        json['last_issuance_at'],
      ),
      currentPeriodEnd: SearchCreditsStatus._lenientDateTime(
        json['current_period_end'],
      ),
    );
