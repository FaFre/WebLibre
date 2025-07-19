package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.MLEngineFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoMlApi
import org.json.JSONArray
import org.json.JSONObject

class GeckoMlApiImpl : GeckoMlApi {
    private fun List<String>?.toJson(): JSONArray {
        return JSONArray().apply {
            this@toJson?.forEach { put(it) }
        }
    }

    override fun getContainerTopic(titles: List<String>, callback: (Result<String>) -> Unit) {
        MLEngineFeature.scheduleRequest("getContainerTopic", titles.toJson(), object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(result.getString("result")))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }
}