/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxyRoutingSnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxyRoutingStatus
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxySettings
import org.json.JSONArray
import org.json.JSONObject

class GeckoContainerProxyApiImpl : GeckoContainerProxyApi {
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

    private fun GeckoProxyRoutingSnapshot.toJson(): JSONObject {
        return JSONObject().apply {
            put("generation", generation)
            put("proxies", JSONArray(proxies.map { it.toJson() }))
            put("relations", relations.toJsonWithListValues())
            put("directScopes", JSONObject(directScopes as Map<*, *>))
            put("siteAssignments", JSONObject(siteAssignments as Map<*, *>))
            put("strictContexts", strictContexts.toJsonWithListValues())
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
