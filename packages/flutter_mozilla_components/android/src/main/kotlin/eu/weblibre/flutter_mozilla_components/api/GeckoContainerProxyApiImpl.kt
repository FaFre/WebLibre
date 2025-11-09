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
}