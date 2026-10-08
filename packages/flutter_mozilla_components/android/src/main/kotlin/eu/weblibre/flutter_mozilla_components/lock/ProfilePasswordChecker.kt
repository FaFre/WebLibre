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
package eu.weblibre.flutter_mozilla_components.lock

import android.content.Context
import android.os.SystemClock
import android.util.Log
import androidx.annotation.MainThread
import eu.weblibre.flutter_mozilla_components.FlutterEngineCoordinator
import eu.weblibre.flutter_mozilla_components.pigeons.ProfileLockFlutterApi
import eu.weblibre.flutter_mozilla_components.pigeons.ProfilePasswordOutcome
import eu.weblibre.flutter_mozilla_components.pigeons.ProfilePasswordReply
import eu.weblibre.flutter_mozilla_components.pigeons.StartupFlutterError
import kotlinx.coroutines.delay
import kotlinx.coroutines.withTimeoutOrNull

/**
 * Checks a profile password for a Custom Tab or PWA window, in Dart.
 *
 * Dart holds the password's Argon2 verifier and the wrong-attempt record, and
 * checks one attempt per profile at a time across every screen. Checking here
 * as well would be a second implementation that can disagree, and a second
 * count of wrong attempts that does not throttle the first.
 *
 * A cold-started window has no Dart to ask, so the app half is started for
 * it, the same engine `MainActivity` hosts.
 */
internal object ProfilePasswordChecker {
    private const val TAG = "ProfilePasswordChecker"

    /** Covers a cold start of the app half plus one Argon2 run on a slow phone. */
    private const val ANSWER_TIMEOUT_MS = 45_000L

    /** How often an app half that is not listening yet is asked again. */
    private const val RETRY_INTERVAL_MS = 250L

    /** Pigeon's code for a channel nobody listens on yet. */
    private const val CHANNEL_ERROR = "channel-error"

    /** Starts the app half ahead of a check, so the person's typing hides the wait. */
    @MainThread
    fun prepare(context: Context) {
        FlutterEngineCoordinator.ensureStarted(context)
    }

    /**
     * Dart's answer for [password], or null when it never gave one.
     *
     * Null and [ProfilePasswordOutcome.FAILED] both mean "not unlocked"; the
     * caller does not have to tell them apart.
     */
    @MainThread
    suspend fun check(
        context: Context,
        profileId: String,
        password: String,
    ): ProfilePasswordReply? {
        // Held for the whole wait: a MainActivity destroyed meanwhile would
        // otherwise take the engine this check is waiting on with it.
        FlutterEngineCoordinator.retainForExternalTask()
        try {
            if (!FlutterEngineCoordinator.ensureStarted(context)) return null

            val deadline = SystemClock.elapsedRealtime() + ANSWER_TIMEOUT_MS
            while (true) {
                val remaining = deadline - SystemClock.elapsedRealtime()
                if (remaining <= 0) return null

                val engine = FlutterEngineCoordinator.obtain(context)
                val api = ProfileLockFlutterApi(engine.dartExecutor.binaryMessenger)

                val reply = try {
                    withTimeoutOrNull(remaining) {
                        api.checkProfilePassword(profileId, password)
                    } ?: return null
                } catch (e: StartupFlutterError) {
                    if (e.code != CHANNEL_ERROR) {
                        Log.e(TAG, "The app half could not check the password: ${e.code}")
                        return null
                    }
                    // Dart is still starting and has not set up its handler.
                    null
                }

                // Until it has activated a profile, Dart cannot read the
                // verifier either.
                if (reply != null && reply.outcome != ProfilePasswordOutcome.UNAVAILABLE) {
                    return reply
                }

                delay(RETRY_INTERVAL_MS)
            }
        } finally {
            FlutterEngineCoordinator.releaseForExternalTask()
        }
    }
}
