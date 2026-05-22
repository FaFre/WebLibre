/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.BrowserExtensionFeature
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoContainerProxyApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoProxySettings
import org.json.JSONObject

class GeckoContainerProxyApiImpl : GeckoContainerProxyApi {
    override fun setProxyPort(port: Long) {
        ContainerProxyFeature.scheduleRequest("setProxyPort", port.toInt())
    }

    override fun addContainerProxy(contextId: String) {
        ContainerProxyFeature.scheduleRequest("addContainerProxy", contextId)
    }

    override fun removeContainerProxy(contextId: String) {
        ContainerProxyFeature.scheduleRequest("removeContainerProxy", contextId)
    }

    override fun upsertProxy(proxy: GeckoProxySettings) {
        ContainerProxyFeature.scheduleRequest("upsertProxy", proxy.toJson())
    }

    override fun removeProxy(proxyId: String) {
        ContainerProxyFeature.scheduleRequest("removeProxy", proxyId)
    }

    override fun setContainerProxy(contextId: String, proxyId: String) {
        ContainerProxyFeature.scheduleRequest(
            "setContainerProxy",
            JSONObject().apply {
                put("contextId", contextId)
                put("proxyId", proxyId)
            }
        )
    }

    override fun clearContainerProxy(contextId: String) {
        ContainerProxyFeature.scheduleRequest("clearContainerProxy", contextId)
    }

    override fun removeContainerProxyRelation(contextId: String, proxyId: String) {
        ContainerProxyFeature.scheduleRequest(
            "removeContainerProxyRelation",
            JSONObject().apply {
                put("contextId", contextId)
                put("proxyId", proxyId)
            }
        )
    }

    override fun setSiteAssignments(assignments: Map<String, String>) {
        ContainerProxyFeature.scheduleRequest("setSiteAssignments", JSONObject(assignments))
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
