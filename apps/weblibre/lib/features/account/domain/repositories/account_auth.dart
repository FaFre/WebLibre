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
import 'dart:async';

import 'package:flutter_mozilla_components/flutter_mozilla_components.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase/supabase.dart';
import 'package:weblibre/core/filesystem.dart';
import 'package:weblibre/core/logger.dart';
import 'package:weblibre/core/providers/device_info.dart';
import 'package:weblibre/features/about/domain/providers.dart';
import 'package:weblibre/features/account/data/account_handoff_ledger.dart';
import 'package:weblibre/features/account/data/account_secure_store.dart';
import 'package:weblibre/features/account/data/models/account_auth_state.dart';
import 'package:weblibre/features/account/data/models/account_persisted_data.dart';
import 'package:weblibre/features/account/data/models/persisted_session.dart';
import 'package:weblibre/features/account/data/supabase_config.dart';
import 'package:weblibre/features/account/domain/services/handoff_redeem_client.dart';
import 'package:weblibre/features/account/domain/utils/pkce.dart';
import 'package:weblibre/features/proxy/domain/services/routed_http_client.dart';

// Re-export so call sites that already imported AccountAuthFlowException from
// this repository keep compiling after the redeem client split.
export 'package:weblibre/features/account/domain/services/handoff_redeem_client.dart'
    show AccountAuthFlowException;

part 'account_auth.g.dart';

/// Convert any thrown error into a message safe to show in the UI.
/// Untrusted exception strings (e.g. `e.toString()` for arbitrary HTTP /
/// platform errors) can include response bodies, headers, or auth tokens —
/// log them in full but never put them in user-visible state.
String _sanitizeAuthError(Object error, String fallback) {
  if (error is AccountAuthFlowException) {
    return error.userMessage;
  }
  if (error is AuthRetryableFetchException) {
    return 'Network error. Please check your connection and try again.';
  }
  if (error is AuthException) {
    return error.message;
  }
  return fallback;
}

@Riverpod(keepAlive: true)
class AccountAuthRepository extends _$AccountAuthRepository {
  StreamSubscription<AuthState>? _authSubscription;
  Timer? _signingInTimeout;
  Timer? _restoreRetryTimer;

  /// The live client, tracked here as well as on the state.
  ///
  /// Not a duplicate for convenience: `onDispose` has to close it, and reading
  /// `state` inside a life-cycle throws `UnmountedRefException` — the ref is
  /// already down by the time the callback runs. So the old
  /// `state.value?.client` threw on *every* disposal and rebuild of this
  /// provider, before it ever reached `dispose()`. Nothing surfaced it, because
  /// Riverpod reports a failing dispose callback to the zone rather than to the
  /// caller: the visible symptom was a leaked HTTP client and a still-running
  /// token-refresh timer per rebuild.
  SupabaseClient? _client;

  /// Handoff code currently being redeemed, or `null` when idle. The OS can
  /// deliver the `weblibre://account/callback` deep link more than once in
  /// quick succession (observed ~12ms apart on some devices, see issue #460).
  /// Without this guard each delivery starts a concurrent redeem of the same
  /// single-use code; the server burns the code for the first request and
  /// returns "already redeemed" for the rest, whose error then clobbers the
  /// winner's signed-in state. Tracking the in-flight code lets us drop the
  /// duplicate while still allowing a genuine retry once the first attempt
  /// has settled (cleared in the `finally` below).
  String? _redeemingCode;

  AccountSecureStore get _store => ref.read(accountSecureStoreProvider);
  HandoffRedeemClient get _redeemClient =>
      ref.read(handoffRedeemClientProvider);

  AccountAuthState get _currentOrEmpty => state.value ?? AccountAuthState();

  @override
  Future<AccountAuthState> build() async {
    ref.onDispose(() async {
      _signingInTimeout?.cancel();
      _restoreRetryTimer?.cancel();
      await _authSubscription?.cancel();
      final client = _client;
      _client = null;
      await client?.dispose();
    });

    _restoreRetryTimer?.cancel();
    _restoreRetryTimer = null;

    final data = await _store.read();

    if (data.session == null) {
      // Signed out, but not necessarily blank. A record can hold the identity
      // and the sync key with no session — that is exactly what the revoked-token
      // branch below leaves behind, and what an older backup restores. Dropping
      // the identity here would throw away the one thing that tells the user
      // *which* account to sign back into to finish the restore.
      return AccountAuthState(
        email: data.email,
        displayName: data.displayName ?? data.email,
        userId: data.userId,
        syncKey: data.syncKey,
      );
    }

    // Created outside the try so every failure path can close it. It owns a
    // token-refresh timer of its own, and `_scheduleRestoreRetry` re-runs this
    // build every 30 seconds while the network is down — so a client abandoned
    // on the error path is not one leak but one per retry, each still waking up
    // to talk to the account backend.
    final client = _createClient();

    try {
      final response = await client.auth.setSession(data.session!.refreshToken);

      if (response.session == null) {
        await client.dispose();
        return AccountAuthState();
      }

      final user = response.session!.user;
      await _persistSession(response.session!);

      // Committed only once nothing further can throw: past this point the
      // client belongs to the notifier, and the catch handlers below must not
      // close it out from under `_client`.
      _client = client;
      _listenToAuthState(client);

      return AccountAuthState(
        status: AccountAuthStatus.signedIn,
        email: user.email,
        displayName:
            user.userMetadata?['display_name'] as String? ??
            user.userMetadata?['full_name'] as String? ??
            user.email,
        userId: user.id,
        // The same rule `_persistSession` just applied to the stored record,
        // so the state cannot claim a key the store no longer holds.
        syncKey: _syncKeyForUser(data, user.id),
        client: client,
      );
    } on AuthRetryableFetchException catch (e) {
      // Transient network error — preserve session and retry shortly.
      await client.dispose();
      return _transientRestoreFailure(data, e);
    } on AuthException {
      // Definitive auth failure (expired/revoked token). Only the *session* goes:
      // a refresh token the server no longer honours says nothing about the
      // end-to-end sync key, which is not a session artefact but the thing that
      // decrypts the user's snapshots. Clearing both — as this used to — turned
      // an expired login into the destruction of the key, and restoring an older
      // backup is precisely the case that arrives with a stale token.
      //
      // The identity is kept beside it, so a later sign-in can prove the key
      // still belongs to the same account before reusing it.
      await client.dispose();
      await _store.clearSession();
      return _sessionExpiredState(data);
    } catch (e) {
      // Non-auth error (e.g. SocketException) — also transient, preserve.
      await client.dispose();
      return _transientRestoreFailure(data, e);
    }
  }

  /// What the user sees when a stored session is definitively no longer valid.
  ///
  /// The message is written here rather than passed as a fallback to
  /// [_sanitizeAuthError], which was unreachable: that helper returns
  /// `AuthException.message` for every `AuthException`, so the branch always
  /// rendered the server's own wording — "Invalid Refresh Token: Refresh Token
  /// Not Found" — which tells the user nothing about what happened or what to
  /// do, and least of all that their sync key survived.
  AccountAuthState _sessionExpiredState(AccountPersistedData data) =>
      AccountAuthState(
        status: AccountAuthStatus.error,
        email: data.email,
        displayName: data.displayName ?? data.email,
        userId: data.userId,
        syncKey: data.syncKey,
        lastError: data.syncKey != null
            ? 'Your saved sign-in is no longer valid. Sign in again to finish '
                  'restoring this account — your sync key is kept.'
            : 'Your saved sign-in is no longer valid. Sign in again to '
                  'continue.',
      );

  AccountAuthState _transientRestoreFailure(
    AccountPersistedData data,
    Object error,
  ) {
    _scheduleRestoreRetry();
    return AccountAuthState(
      status: AccountAuthStatus.error,
      email: data.email,
      displayName: data.displayName ?? data.email,
      userId: data.userId,
      syncKey: data.syncKey,
      lastError: _sanitizeAuthError(
        error,
        'Could not restore your account session. Retrying shortly.',
      ),
    );
  }

  void _scheduleRestoreRetry() {
    _restoreRetryTimer?.cancel();
    _restoreRetryTimer = Timer(const Duration(seconds: 30), () {
      if (ref.mounted) {
        ref.invalidateSelf();
      }
    });
  }

  // -- Auth state listener ---------------------------------------------------

  SupabaseClient _createClient() {
    return SupabaseClient(
      SupabaseConfig.supabaseUrl,
      SupabaseConfig.supabaseAnonKey,
      // Without this the client builds its own `http.Client`, and every call it
      // makes — session restore and the token refreshes its own timer schedules,
      // sync documents, subscription and credit lookups — opens a direct socket
      // to the account backend past whatever the user's routing says. It is
      // also the traffic that most identifies them, since it carries their
      // account's tokens.
      //
      // The general container's route rather than the selected tab's: none of
      // these requests describe what is being browsed, and the account is the
      // same account whichever tab happens to be in front.
      //
      // Not closed by `SupabaseClient.dispose()` — it only closes the transport
      // it created itself — which is what this shared, app-wide client needs.
      httpClient: ref.read(routedHttpClientProvider),
    );
  }

  void _listenToAuthState(SupabaseClient client) {
    unawaited(_authSubscription?.cancel());
    _authSubscription = client.auth.onAuthStateChange.listen((data) {
      // ignore: deprecated_member_use
      if (data.event == AuthChangeEvent.userDeleted) {
        // The account itself is gone, so there is nothing for the sync key to
        // belong to and no sign-in that could ever recover it.
        unawaited(_reportingFailure('forgetting the account', _forgetAccount));
      } else if (data.event == AuthChangeEvent.signedOut) {
        // *Not* the user's doing. This is what the client emits when a refresh
        // is definitively rejected mid-session — a revoked token, a password
        // changed on another device. Treating it as a deliberate sign-out is
        // how the startup path used to destroy the sync key, and doing it here
        // instead would have left exactly the same hole open at runtime.
        unawaited(
          _reportingFailure('ending a revoked session', _sessionRevoked),
        );
      } else if (data.event == AuthChangeEvent.tokenRefreshed &&
          data.session != null) {
        unawaited(
          _reportingFailure(
            'persisting a refreshed session',
            () => _persistSession(data.session!),
          ),
        );
      }
    });
  }

  /// Runs work started by the auth stream, which has no caller to throw at.
  ///
  /// Every branch of the listener touches secure storage, and a platform failure
  /// there would otherwise leave the zone's error handler as the only thing that
  /// ever heard about it.
  Future<void> _reportingFailure(
    String what,
    Future<void> Function() work,
  ) async {
    try {
      await work();
    } catch (error, stackTrace) {
      logger.e(
        'Account auth: $what failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// A session ended without the user asking for it.
  ///
  /// Same rule as the startup branch: the session goes, the identity and the
  /// end-to-end sync key stay, and the user is told to sign in again rather than
  /// simply finding themselves signed out with their snapshots undecryptable.
  Future<void> _sessionRevoked() async {
    final data = await _store.read();
    await _store.clearSession();
    await _closeClient();
    if (!ref.mounted) return;
    state = AsyncData(_sessionExpiredState(data));
  }

  /// Everything goes: the user asked to sign out, or the account no longer
  /// exists.
  Future<void> _forgetAccount() async {
    await _store.clear();
    // Stashed Privacy Pass tokens survive sign-out: they are anonymous
    // blobs already redeemed against the user's credit balance, and the
    // backend cannot link them back to the issuing account. Clearing them
    // here would destroy prepaid value with no refund path.
    await _closeClient();
    if (!ref.mounted) return;
    state = AsyncData(AccountAuthState());
  }

  Future<void> _closeClient() async {
    await _authSubscription?.cancel();
    _authSubscription = null;
    final client = _client;
    _client = null;
    await client?.dispose();
  }

  // -- Sign-in flow ----------------------------------------------------------

  Future<void> startSignIn() async {
    _signingInTimeout?.cancel();
    _signingInTimeout = null;
    state = AsyncData(
      _currentOrEmpty.copyWith(status: AccountAuthStatus.signingIn),
    );

    try {
      final codes = PkceCodes.generate();

      await _store.update(
        (data) => data.copyWith(pendingCodeVerifier: codes.verifier),
      );

      // A nonce the account web app echoes back unchanged. The callback
      // otherwise carries an opaque code and nothing that identifies it, so
      // without this there is no way to tell a real callback from one any app on
      // the device fired at us — and no way, on a cold start, to know which
      // profile the sign-in belongs to.
      // Named `handoffState` because `state` is the notifier's own.
      final handoffState = generateAccountHandoffState();
      await AccountHandoffLedger(filesystem.startupPaths).record(
        stateNonce: handoffState,
        profileId: filesystem.selectedProfile.uuid,
      );

      final queryParams = <String, String>{
        'mode': 'handoff',
        'code_challenge': codes.challenge,
        'state': handoffState,
      };

      final packageInfoData = ref.read(packageInfoProvider).value;
      if (packageInfoData != null) {
        queryParams['app_version'] =
            '${packageInfoData.version}+${packageInfoData.buildNumber}';
      }

      final deviceInfoData = ref.read(androidDeviceInfoProvider).value;
      if (deviceInfoData != null) {
        queryParams['device_name'] = deviceInfoData.deviceName;
      }

      final baseUri = Uri.parse(SupabaseConfig.accountWebUrl);
      final uri = baseUri.replace(queryParameters: queryParams);

      await GeckoBrowserService().openInCustomTab(url: uri, private: false);

      // Set the timer last so any earlier error path doesn't have to think
      // about cancelling a timer it never started. Guard the body so that a
      // timer fired after handleHandoffCode has reset _signingInTimeout to
      // null does nothing.
      late final Timer timer;
      timer = Timer(const Duration(minutes: 5), () {
        if (!identical(_signingInTimeout, timer)) return;
        _signingInTimeout = null;
        if (state.value?.status == AccountAuthStatus.signingIn) {
          state = AsyncData(
            AccountAuthState(
              status: AccountAuthStatus.error,
              lastError: 'Sign-in timed out. Please try again.',
            ),
          );
        }
      });
      _signingInTimeout = timer;
    } catch (e, s) {
      logger.e('startSignIn failed', error: e, stackTrace: s);
      state = AsyncData(
        _currentOrEmpty.copyWith(
          status: AccountAuthStatus.error,
          lastError: _sanitizeAuthError(
            e,
            'Could not open the sign-in page. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> cancelSignIn() async {
    _signingInTimeout?.cancel();
    _signingInTimeout = null;

    // Clear the pending code verifier so a late browser callback is rejected.
    await _store.update((data) => data.copyWith(pendingCodeVerifier: null));

    state = AsyncData(AccountAuthState());
  }

  Future<void> handleHandoffCode(String code) async {
    if (_redeemingCode == code) {
      logger.i('Ignoring duplicate handoff callback for in-flight code');
      return;
    }
    _redeemingCode = code;

    _signingInTimeout?.cancel();
    _signingInTimeout = null;
    state = AsyncData(
      _currentOrEmpty.copyWith(status: AccountAuthStatus.signingIn),
    );

    try {
      final data = await _store.read();
      final codeVerifier = data.pendingCodeVerifier;

      if (codeVerifier == null) {
        throw AccountAuthFlowException(
          'No pending sign-in found. Please start sign-in again.',
        );
      }

      final result = await _redeemClient.redeem(
        handoffCode: code,
        codeVerifier: codeVerifier,
      );

      final refreshToken = result.session['refresh_token'] as String;

      // The redeem response describes the same sign-in twice: once as a Supabase
      // session and once as an account record. Checked against each other before
      // anything is created or written, because the two used to be consumed
      // independently — the session's id decided what was persisted and which
      // sync key survived, while the account's id decided what the screen said
      // the user was signed in as. A response where they disagree would have
      // stored one identity and displayed another, with the key bound to
      // whichever the storage path happened to pick.
      final sessionUserId =
          (result.session['user'] as Map<String, dynamic>?)?['id'] as String?;
      final accountUserId = result.account['user_id'] as String?;
      if (sessionUserId != null &&
          accountUserId != null &&
          sessionUserId != accountUserId) {
        logger.e(
          'Handoff redeem returned a session and an account for different '
          'users; refusing the sign-in',
        );
        throw AccountAuthFlowException(
          'Sign-in could not be verified. Please try again.',
        );
      }

      final previousClient = _client;
      final newClient = _createClient();

      final AuthResponse authResponse;
      try {
        // `setSession` with no access token is a refresh call: it spends
        // [refreshToken] against `/token?grant_type=refresh_token` and comes back
        // with whatever the server issued in its place. With rotation on — the
        // Supabase default, and this client knows it, it has a branch for
        // `refresh_token_already_used` — the handoff token in `result.session`
        // is dead from this moment.
        authResponse = await newClient.auth.setSession(refreshToken);
      } catch (e) {
        await newClient.dispose();
        rethrow;
      }

      // So the response is the only source for what to persist. Storing
      // `result.session` instead wrote the token that had just been spent: the
      // session worked for the rest of the run, because the live client holds
      // the real one, and then the next cold start restored with a revoked token
      // and signed the user out of an account they had signed into minutes
      // earlier. It self-healed only if the client's own refresh timer happened
      // to fire first and overwrite the record.
      //
      // Not fixable by subscribing before the call instead: the `tokenRefreshed`
      // event `setSession` emits would then race this write rather than replace
      // it. `build()` has always taken the response here; this path was the one
      // that did not.
      final session = authResponse.session;
      if (session == null) {
        await newClient.dispose();
        throw AccountAuthFlowException(
          'Sign-in could not be completed. Please try again.',
        );
      }

      final newUserId = sessionUserId ?? accountUserId;
      if (newUserId != null && session.user.id != newUserId) {
        // The identity checked above was a claim in the redeem response; this is
        // the one the auth server just authenticated, and it is what gets stored
        // and what the sync key is bound to.
        logger.e(
          'The refreshed session names a different user than the redeem '
          'response; refusing the sign-in',
        );
        await newClient.dispose();
        throw AccountAuthFlowException(
          'Sign-in could not be verified. Please try again.',
        );
      }

      _client = newClient;
      await previousClient?.dispose();
      _listenToAuthState(newClient);

      // One write, through the same helper the restore and token-refresh paths
      // use — this path used to map the session fields itself, which is exactly
      // how it came to drift from them.
      final stored = await _persistSession(session, clearPendingSignIn: true);

      state = AsyncData(
        AccountAuthState(
          status: AccountAuthStatus.signedIn,
          // Read back from what was stored, falling back to the account half, so
          // the screen and the record can never name different users.
          email: stored.email ?? result.account['email'] as String?,
          displayName:
              stored.displayName ?? result.account['display_name'] as String?,
          userId: stored.userId,
          syncKey: stored.syncKey,
          client: newClient,
        ),
      );
    } catch (e, s) {
      logger.e('handleHandoffCode failed', error: e, stackTrace: s);
      state = AsyncData(
        _currentOrEmpty.copyWith(
          status: AccountAuthStatus.error,
          lastError: _sanitizeAuthError(e, 'Sign-in failed. Please try again.'),
        ),
      );
    } finally {
      // Only clear if we still own the flag — a later, distinct redeem could
      // have taken over while this one was awaiting.
      if (_redeemingCode == code) {
        _redeemingCode = null;
      }
    }
  }

  Future<void> signOut() async {
    // Unsubscribed *before* asking the server, because our own sign-out comes
    // back through `onAuthStateChange` as a `signedOut` event — and that handler
    // now deliberately keeps the identity and sync key. Left listening, it would
    // race the clear below and put back exactly what a deliberate sign-out is
    // supposed to remove.
    await _authSubscription?.cancel();
    _authSubscription = null;

    try {
      await _client?.auth.signOut();
    } catch (_) {
      // Sign out may fail if the session is already invalid
    }
    await _forgetAccount();
  }

  // -- Sync key management ---------------------------------------------------

  /// The sync key [current] may keep now that [newUserId] has signed in.
  ///
  /// The key survives a re-authentication on purpose: it is derived from the
  /// account password, and making the user re-enter it after every expired token
  /// would be noise. What it must not survive is a change of *account*. Keeping
  /// it across identities would attach one account's encryption key to another
  /// — snapshots written under the new account would be encrypted with a key the
  /// old one also holds, and a restore of the old account's data would appear to
  /// decrypt.
  ///
  /// Ownership has to be *proved*, not merely left uncontradicted. A record
  /// carrying a sync key but no [AccountPersistedData.userId] is not a record
  /// whose owner is "whoever asks": no path in this app writes a key without
  /// also writing the id it was derived under, so a key with no owner is a
  /// record that was hand-made, damaged, or restored from somewhere else —
  /// exactly the inputs that must not be trusted. The cost of being wrong the
  /// safe way is one password prompt, because the key is derived from the
  /// account password and can be re-entered; the cost of being wrong the other
  /// way is one account's encryption key silently attached to another's data.
  static String? _syncKeyForUser(AccountPersistedData current, String? userId) {
    if (current.syncKey == null) return null;
    if (current.userId != null && userId != null && userId == current.userId) {
      return current.syncKey;
    }

    logger.i(
      'Dropping the stored sync key: it is not proven to belong to the account '
      'that just signed in',
    );
    return null;
  }

  Future<void> setSyncKey(String key) async {
    await _store.update((data) => data.copyWith(syncKey: key));
    if (!ref.mounted) return;
    state = AsyncData(_currentOrEmpty.copyWith(syncKey: key));
  }

  Future<void> clearSyncKey() async {
    await _store.update((data) => data.copyWith(syncKey: null));
    if (!ref.mounted) return;
    state = AsyncData(_currentOrEmpty.copyWith(syncKey: null));
  }

  // -- Session persistence helpers ------------------------------------------

  /// Writes [session] onto whatever the record holds *now*.
  ///
  /// Through `update` rather than a read-then-write, because the caller is often
  /// the Supabase client's own refresh timer: it fires whenever it likes, and a
  /// blind write of a record read moments earlier is how a sync key set in
  /// between gets reverted.
  /// [clearPendingSignIn] retires the PKCE verifier in the same write, for the
  /// one caller that has just finished the exchange it belonged to.
  Future<AccountPersistedData> _persistSession(
    Session session, {
    bool clearPendingSignIn = false,
  }) {
    return _store.update(
      (current) => current.copyWith(
        session: PersistedSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken!,
          tokenType: session.tokenType,
          expiresIn: session.expiresIn ?? 3600,
        ),
        userId: session.user.id,
        email: session.user.email,
        displayName:
            session.user.userMetadata?['display_name'] as String? ??
            session.user.userMetadata?['full_name'] as String?,
        syncKey: _syncKeyForUser(current, session.user.id),
        pendingCodeVerifier: clearPendingSignIn
            ? null
            : current.pendingCodeVerifier,
      ),
    );
  }
}
