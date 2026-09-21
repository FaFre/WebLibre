/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPushApi
import eu.weblibre.flutter_mozilla_components.pigeons.PushStatus
import eu.weblibre.flutter_mozilla_components.pigeons.PushSubscription
import eu.weblibre.flutter_mozilla_components.push.toPigeon
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.cancel
import kotlinx.coroutines.withContext

/** UnifiedPush distributor management for the settings UI. */
class GeckoPushApiImpl : GeckoPushApi {
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val push
        get() = requireNotNull(GlobalComponents.components) { "Components not initialized" }.push

    override suspend fun getPushStatus(): PushStatus = inScope {
        withContext(Dispatchers.IO) { push.status() }.toPigeon()
    }

    override suspend fun setDistributor(packageName: String) {
        inScope { withContext(Dispatchers.IO) { push.setDistributor(packageName) } }
    }

    override suspend fun removeDistributor() {
        inScope { withContext(Dispatchers.IO) { push.removeDistributor() } }
    }

    override suspend fun renewRegistration() {
        inScope { withContext(Dispatchers.IO) { push.renewRegistration() } }
    }

    override suspend fun suspendPushForRestart() {
        inScope { withContext(Dispatchers.IO) { push.suspendForRestart() } }
    }

    override suspend fun getSubscriptions(): List<PushSubscription> = inScope {
        withContext(Dispatchers.IO) {
            push.subscriptions().map {
                PushSubscription(scope = it.scope, hasEndpoint = it.hasEndpoint)
            }
        }
    }

    /** Runs [block] in [coroutineScope] rather than the caller's coroutine, so [dispose] cancels it. */
    private suspend fun <T> inScope(block: suspend () -> T): T =
        coroutineScope.async { block() }.await()

    fun dispose() {
        coroutineScope.cancel()
    }
}
