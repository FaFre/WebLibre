package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.PrefManagerFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoPrefApi
import org.json.JSONObject
import org.json.JSONArray

class GeckoPrefApiImpl : GeckoPrefApi {
    private fun List<String>?.toJson(): JSONArray {
        return JSONArray().apply {
            this@toJson?.forEach { put(it) }
        }
    }

    fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = this.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            when (val value = this.get(key)) {
                is JSONObject -> map[key] = value.toMap()
//                is JSONArray -> map[key] = value.toList()
//                JSONObject.NULL -> map[key] = null
                else -> map[key] = value
            }
        }

        return map
    }

    override fun getPrefs(
        preferenceFilter: List<String>?,
        callback: (Result<Map<String, Any>>) -> Unit
    ) {
        PrefManagerFeature.scheduleRequest("getPrefs", preferenceFilter.toJson(), object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(result.getJSONObject("result").toMap()))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun applyPrefs(prefBuffer: String, callback: (Result<Map<String, Any>>) -> Unit) {
        PrefManagerFeature.scheduleRequest("parsePrefsAndApply", prefBuffer, object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(result.getJSONObject("result").toMap()))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun resetPrefs(preferenceNames: List<String>?, callback: (Result<Unit>) -> Unit) {
        PrefManagerFeature.scheduleRequest("resetPrefs", preferenceNames.toJson(), object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(Unit))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }


}