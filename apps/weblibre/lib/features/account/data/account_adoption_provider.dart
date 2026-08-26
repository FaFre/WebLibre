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
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/features/account/data/account_adoption.dart';
import 'package:weblibre/features/account/domain/repositories/account_auth.dart';

part 'account_adoption_provider.g.dart';

/// The profile an adoption files the record under.
///
/// Read through a provider rather than straight off [filesystem] so the
/// controller can be driven in a test without activating the process-wide
/// profile singleton. In the app it is exactly `filesystem.selectedProfile`, and
/// it cannot change while the process lives — `activate` refuses to rebind.
@Riverpod(keepAlive: true)
String adoptingProfileId(Ref ref) => filesystem.selectedProfile.uuid;

/// The account session waiting to be claimed, if there is one.
///
/// Auto-disposed and re-read rather than kept: it is answered once and then
/// stops existing, and a cached "yes" would outlive the adoption that resolved
/// it.
@riverpod
Future<UnclaimedAccountRecord?> unclaimedAccountRecord(Ref ref) =>
    findUnclaimedAccountRecord(profileId: ref.watch(adoptingProfileIdProvider));

/// Claims the record for the active profile and signs in with it.
///
/// `keepAlive`, and that is the whole point rather than an optimisation. The
/// tile invokes this through `ref.read(...notifier)`, which holds no
/// subscription; an auto-disposed notifier is therefore scheduled for disposal
/// at the end of the very next event loop — long before a secure-storage
/// platform round trip returns. Every `ref` use after that first `await` threw
/// `UnmountedRefException`, so the record moved to its new key and *nothing
/// else happened*: no provider was invalidated, the signed-out card stayed on
/// screen, and the error surfaced only as an unhandled async throw. To the user
/// that is a button that does nothing.
///
/// Holding [AsyncValue] state also gives the tile something to render: the
/// operation takes a storage round trip plus a network session restore, and it
/// can fail.
@Riverpod(keepAlive: true)
class AccountAdoption extends _$AccountAdoption {
  /// `AsyncValue<void>` held directly rather than an `AsyncNotifier`, so the
  /// initial state is a settled [AsyncData] instead of the [AsyncLoading] an
  /// async `build` sits in for its first microtask. The tile reads `isLoading`
  /// as "an answer is being carried out", and a controller that starts out
  /// loading would both grey the buttons on the first frame and make the
  /// re-entrancy guard below swallow the very first tap.
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Files the record under this profile, then drives the account state to
  /// whatever the adopted session actually turns out to be.
  ///
  /// The re-read of the auth repository is awaited rather than fired off,
  /// because "did this work" is precisely what the caller is showing progress
  /// for. It resolves to signed-in, or to the error tile when the session can no
  /// longer be restored — either is an answer; a silently unchanged screen is
  /// not.
  Future<void> adopt(UnclaimedAccountRecord record) => _run(
    'Adopting the account record',
    () async {
      await adoptAccountRecord(
        record,
        profileId: ref.read(adoptingProfileIdProvider),
      );

      // The repository reads the record at build time, so re-running it is what
      // turns the adopted session into a signed-in state. Awaited, so the
      // spinner covers the network round trip the restore actually costs.
      ref.invalidate(accountAuthRepositoryProvider);
      await ref.read(accountAuthRepositoryProvider.future);

      // Last, not first: while the re-read is in flight the card is still the
      // thing on screen showing the spinner, and dropping it out from under the
      // user mid-operation would look like the same silent nothing this whole
      // controller exists to fix.
      ref.invalidate(unclaimedAccountRecordProvider);
    },
  );

  Future<void> discard(UnclaimedAccountRecord record) =>
      _run('Discarding the account record', () async {
        await discardAccountRecord(record);
        ref.invalidate(unclaimedAccountRecordProvider);
      });

  /// One answer at a time, and every failure recorded rather than thrown at the
  /// caller's `onPressed`.
  ///
  /// A second tap joins the first operation instead of starting a rival one:
  /// both halves of this controller move a record between two keys, and running
  /// two of them concurrently means the second works from a key the first has
  /// already deleted.
  Future<void> _run(String what, Future<void> Function() operation) {
    final pending = _inFlight;
    if (pending != null) return pending;

    return _inFlight = _perform(what, operation);
  }

  Future<void>? _inFlight;

  Future<void> _perform(String what, Future<void> Function() operation) async {
    state = const AsyncLoading();

    final result = await AsyncValue.guard(operation);
    _inFlight = null;

    result.whenOrNull(
      error: (error, stackTrace) =>
          logger.e('$what failed', error: error, stackTrace: stackTrace),
    );

    if (!ref.mounted) return;
    state = result;
  }
}
