/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.feature.RoutingDemand
import eu.weblibre.flutter_mozilla_components.feature.RoutingDemands
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxyRoutingSnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxyRoutingStatus
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxySettings
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoRoutingDemand
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import org.json.JSONArray
import org.json.JSONObject

class GeckoContainerProxyApiImpl(
    /**
     * Main-thread scope in production, because the reply travels back over the
     * Flutter binary messenger and that is only safe to touch from the platform
     * thread. A supervisor job keeps one failed wait from cancelling the next.
     */
    private val scope: CoroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
) : GeckoContainerProxyApi {
    fun dispose() {
        scope.cancel()
    }

    override fun applySnapshot(
        snapshot: GeckoProxyRoutingSnapshot,
        callback: (Result<Long>) -> Unit
    ) {
        ContainerProxyFeature.applySnapshot(
            snapshot.toJson(),
            snapshot.generation,
            object : ResultConsumer<JSONObject> {
                override fun success(result: JSONObject) {
                    callback(Result.success(snapshot.generation))
                }

                override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                    callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
                }
            }
        )
    }

    override fun healthcheck(callback: (Result<Boolean>) -> Unit) {
        ContainerProxyFeature.scheduleRequestWithResponse("healthcheck", Unit, object :
            ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                val resultStatus = result.getBoolean("result")
                callback(Result.success(resultStatus))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun routingStatus(): GeckoProxyRoutingStatus {
        val generation = ContainerProxyFeature.acknowledgedSnapshotGeneration()
        return GeckoProxyRoutingStatus(
            ready = generation != null,
            acknowledgedGeneration = generation,
        )
    }

    override fun takeRoutingDemand(): GeckoRoutingDemand? =
        RoutingDemands.take()?.toPigeon()

    override fun nextRoutingDemand(callback: (Result<GeckoRoutingDemand>) -> Unit) {
        // Never times out: a launch can arrive at any point while the isolate is
        // alive. Disposal still replies with failure so Dart can leave its loop.
        scope.launch {
            try {
                val demand = RoutingDemands.next()
                callback(Result.success(demand.toPigeon()))
            } catch (e: CancellationException) {
                callback(Result.failure(e))
            }
        }
    }

    private fun RoutingDemand.toPigeon() =
        GeckoRoutingDemand(contextId = contextId, proxyIds = proxyIds)

    private fun GeckoProxyRoutingSnapshot.toJson(): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put("proxies", JSONArray(proxies.map { it.toJson() }))
            put("relations", relations.toJsonWithListValues())
            put("directScopes", JSONObject(directScopes as Map<*, *>))
            put("siteAssignments", JSONObject(siteAssignments as Map<*, *>))
            put("strictContexts", strictContexts.toJsonWithListValues())
            // Relations naming one of these block, but only until the start
            // behind them settles — the extension holds their requests instead
            // of answering with the emergency break. Distinct from the seed's
            // `provisional`, which says the whole snapshot is about to be
            // replaced; see ContainerProxyFeature.seedAwaitsPush.
            put("awaitingProxies", JSONArray(awaitingProxyIds))
        }
    }

    private fun Map<String, List<String>>.toJsonWithListValues(): JSONObject {
        return JSONObject().apply {
            forEach { (key, values) -> put(key, JSONArray(values)) }
        }
    }

    private fun GeckoProxySettings.toJson(): JSONObject {
        return JSONObject().apply {
            put("id", id)
            put("title", title)
            put("type", type)
            put("host", host)
            put("port", port)
            username?.let { put("username", it) }
            password?.let { put("password", it) }
            put("proxyDNS", proxyDNS)
            put("doNotProxyLocal", doNotProxyLocal)
        }
    }
}
