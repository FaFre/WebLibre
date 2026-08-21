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
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/features/account/data/account_adoption.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

part 'account_adoption_provider.g.dart';

/// The account session waiting to be claimed, if there is one.
///
/// Auto-disposed and re-read rather than kept: it is answered once and then
/// stops existing, and a cached "yes" would outlive the adoption that resolved
/// it.
@riverpod
Future<UnclaimedAccountRecord?> unclaimedAccountRecord(Ref ref) =>
    findUnclaimedAccountRecord(profileId: filesystem.selectedProfile.uuid);

/// Claims the record for the active profile and signs in with it.
@riverpod
class AccountAdoption extends _$AccountAdoption {
  @override
  void build() {}

  Future<void> adopt(UnclaimedAccountRecord record) async {
    await adoptAccountRecord(
      record,
      profileId: filesystem.selectedProfile.uuid,
    );

    ref.invalidate(unclaimedAccountRecordProvider);
    // The repository reads the record at build time, so re-running it is what
    // turns the adopted session into a signed-in state.
    ref.invalidate(accountAuthRepositoryProvider);
  }

  Future<void> discard(UnclaimedAccountRecord record) async {
    await discardAccountRecord(record);
    ref.invalidate(unclaimedAccountRecordProvider);
  }
}
