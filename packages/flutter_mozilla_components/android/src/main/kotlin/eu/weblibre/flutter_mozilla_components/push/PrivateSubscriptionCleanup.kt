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
import eu.weblibre.flutter_mozilla_components.lifecycle.PushOutbox
import kotlinx.coroutines.CancellationException
import org.ironfoxoss.unifiedpush.DistributorManager
import org.ironfoxoss.unifiedpush.SubscriptionsDB

/**
 * Removes the subscriptions of private browsing that a build before
 * [PrivatePushScopes] accepted, on push's dispatcher at each start.
 *
 * Each goes in two steps: the connector forgets the registration and sends its
 * UNREGISTER, in a receiver turn of its own, and only then does the row go, with
 * any change still pending for Gecko. The row is what the next start tries
 * again from, so a death between the two leaves the row behind, not a
 * registration that nothing would remove.
 *
 * Not [org.ironfoxoss.unifiedpush.UnifiedPushFeature.unsubscribe]: it removes
 * the row first and queues the UNREGISTER on the receiver's executor, so a death
 * before that task ran keeps the registration with no row left to retry from.
 *
 * One window is left, inside the connector: its `unregister` deletes its token
 * and then sends the UNREGISTER. A death between the two leaves the
 * registration at the distributor, and the retry has no token to send. Nothing
 * can link it any more (no row, and the delegate refuses the scope), so it is a
 * dead registration like those of F3 in `plans/PUSH_ACROSS_SWITCH_DEVICE_TEST_PLAN.md`,
 * to be removed with them by a reconciliation of the distributor's registrations.
 */
internal class PrivateSubscriptionCleanup(
    private val context: Context,
    private val db: SubscriptionsDB,
    private val distributors: DistributorManager,
    private val inTurn: suspend (() -> Unit) -> Unit = { block -> UnifiedPushReceiver.runExclusive { block() } },
) {
    /** How many private rows are left: one that failed, or all once [isClosed]. */
    suspend fun run(isClosed: () -> Boolean): Int {
        val scopes = db.listSubscriptions().map { it.scope }.filter(PrivatePushScopes::isPrivate)
        if (scopes.isEmpty()) return 0
        var removed = 0
        for (scope in scopes) {
            if (isClosed()) break
            try {
                inTurn { distributors.unregisterScope(context, scope) }
                db.remove(scope)
                PushOutbox.removed(scope)
                removed++
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                Log.w(TAG, "Could not remove a push subscription of private browsing; the next start tries again", e)
            }
        }
        if (removed > 0) Log.i(TAG, "Removed $removed push subscriptions of private browsing")
        return scopes.size - removed
    }

    private companion object {
        const val TAG = "Push"
    }
}
