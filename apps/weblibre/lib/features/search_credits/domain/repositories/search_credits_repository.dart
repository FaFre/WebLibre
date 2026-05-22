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
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';
import 'package:weblibre/features/search_credits/data/models/search_credits_status.dart';

part 'search_credits_repository.g.dart';

@Riverpod(keepAlive: true)
class SearchCreditsRepository extends _$SearchCreditsRepository {
  @override
  Future<SearchCreditsStatus> build() async {
    final authState = ref.watch(accountAuthRepositoryProvider).value;
    if (authState == null || !authState.isSignedIn) {
      // Signed-out is not an error; it's a known zero-credit state.
      return SearchCreditsStatus.empty;
    }

    // Don't swallow RPC failures as `SearchCreditsStatus.empty` — that
    // renders identically to a real zero balance and would prompt the
    // user to "buy more" when the actual fix is to retry. Let errors
    // propagate so the AsyncValue carries them and consumers can show an
    // error state with a retry CTA.
    final client = authState.client!;
    final response = await client.rpc('get_my_search_balance').single();
    return SearchCreditsStatus.fromJson(response);
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    // Swallow the propagated error — `refresh()` is fire-and-forget from
    // pull-to-refresh / lifecycle hooks. The new state (success or error)
    // is what consumers re-render from via `ref.watch`.
    try {
      await future;
    } catch (_) {
      // intentionally ignored — see comment above
    }
  }
}
