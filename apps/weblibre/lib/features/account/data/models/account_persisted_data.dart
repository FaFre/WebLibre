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
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:fast_equatable/fast_equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:weblibre/features/account/data/models/persisted_session.dart';

part 'account_persisted_data.g.dart';

@CopyWith()
@JsonSerializable()
class AccountPersistedData with FastEquatable {
  final PersistedSession? session;
  final String? userId;
  final String? email;
  final String? displayName;
  final String? pendingCodeVerifier;
  final String? syncKey;

  AccountPersistedData({
    this.session,
    this.userId,
    this.email,
    this.displayName,
    this.pendingCodeVerifier,
    this.syncKey,
  });

  factory AccountPersistedData.fromJson(Map<String, dynamic> json) =>
      _$AccountPersistedDataFromJson(json);

  Map<String, dynamic> toJson() => _$AccountPersistedDataToJson(this);

  @override
  List<Object?> get hashParameters => [
    session,
    userId,
    email,
    displayName,
    pendingCodeVerifier,
    syncKey,
  ];
}
