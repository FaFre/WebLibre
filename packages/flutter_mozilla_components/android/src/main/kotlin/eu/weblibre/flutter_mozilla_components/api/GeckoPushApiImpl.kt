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
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/** UnifiedPush distributor management for the settings UI. */
class GeckoPushApiImpl : GeckoPushApi {
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val push
        get() = requireNotNull(GlobalComponents.components) { "Components not initialized" }.push

    override fun getPushStatus(callback: (Result<PushStatus>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) { push.status() }.toPigeon()
        }
    }

    override fun setDistributor(packageName: String, callback: (Result<Unit>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) { push.setDistributor(packageName) }
        }
    }

    override fun removeDistributor(callback: (Result<Unit>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) { push.removeDistributor() }
        }
    }

    override fun renewRegistration(callback: (Result<Unit>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) { push.renewRegistration() }
        }
    }

    override fun suspendForProfileSwitch(targetProfileId: String, callback: (Result<Unit>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) { push.suspendForProfileSwitch(targetProfileId) }
        }
    }

    override fun getSubscriptions(callback: (Result<List<PushSubscription>>) -> Unit) {
        respond(callback) {
            withContext(Dispatchers.IO) {
                push.subscriptions().map {
                    PushSubscription(scope = it.scope, hasEndpoint = it.hasEndpoint)
                }
            }
        }
    }

    private fun <T> respond(callback: (Result<T>) -> Unit, block: suspend () -> T) {
        coroutineScope.launch {
            try {
                callback(Result.success(block()))
            } catch (error: CancellationException) {
                throw error
            } catch (error: Throwable) {
                callback(Result.failure(error))
            }
        }
    }

    fun dispose() {
        coroutineScope.cancel()
    }
}
