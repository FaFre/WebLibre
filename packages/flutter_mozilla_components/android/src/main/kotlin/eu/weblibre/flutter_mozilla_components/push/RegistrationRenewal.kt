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
package eu.weblibre.flutter_mozilla_components.push

import android.content.Context
import android.util.Log
import kotlinx.coroutines.CancellationException
import org.ironfoxoss.unifiedpush.DistributorManager
import org.ironfoxoss.unifiedpush.SubscriptionsDB

/**
 * Registers the default instance and then each subscription, one connector call
 * per receiver turn, so a broadcast waits for at most one registration rather
 * than the batch. [org.ironfoxoss.unifiedpush.UnifiedPushFeature.renewRegistration]
 * would launch the same batch in one piece, beside the receiver.
 *
 * Each turn registers the row as it is then, not as the batch first listed it.
 * An unsubscribe removes its row before it queues its UNREGISTER on the same
 * executor, so a row still present in a turn is one whose UNREGISTER, if any,
 * comes after: a scope unsubscribed meanwhile is skipped rather than registered
 * again, and a re-subscription is registered with its current VAPID key.
 */
internal class RegistrationRenewal(
    private val context: Context,
    private val db: SubscriptionsDB,
    private val distributors: DistributorManager,
    private val inTurn: suspend (() -> Unit) -> Unit = { block -> UnifiedPushReceiver.runExclusive { block() } },
) {
    suspend fun run(isClosed: () -> Boolean) {
        if (isClosed()) return
        inTurn { distributors.registerDefaultRegistration(context) }
        // A private row is one [PrivateSubscriptionCleanup] could not remove
        // yet: never registered again, whatever became of that cleanup.
        val scopes = db.listSubscriptions().map { it.scope }.filterNot(PrivatePushScopes::isPrivate)
        for (scope in scopes) {
            if (isClosed()) return
            try {
                inTurn {
                    val live = db.getSubscription(scope, null) ?: return@inTurn
                    distributors.registerScope(context, live.scope, live.appServerKey)
                }
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.w(TAG, "Could not register a push subscription", e)
            }
        }
    }

    private companion object {
        const val TAG = "RegistrationRenewal"
    }
}
