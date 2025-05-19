package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.feature.BrowserExtensionFeature
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoBrowserExtensionApi
import org.json.JSONArray
import org.json.JSONObject

class GeckoBrowserExtensionApiImpl : GeckoBrowserExtensionApi {
    private fun JSONObject.toMap(): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = this.keys()

        while (keys.hasNext()) {
            val key = keys.next()
            when (val value = this.get(key)) {
                is JSONObject -> map[key] = value.toMap()
                is JSONArray -> map[key] = value.toList()
//                JSONObject.NULL -> map[key] = null
                else -> map[key] = value
            }
        }

        return map
    }

    private fun JSONArray.toList(): List<Any> {
        val list = mutableListOf<Any>()
        for (i in 0 until this.length()) {
            when (val value = this.get(i)) {
                is JSONObject -> list.add(value.toMap())
                is JSONArray -> list.add(value.toList())
                JSONObject.NULL -> list.add(null as Any)
                else -> list.add(value)
            }
        }
        return list
    }

    override fun getMarkdown(htmlList: List<String>, callback: (Result<List<Any>>) -> Unit) {
        BrowserExtensionFeature.scheduleRequest("turndown", htmlList, object :
            ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                val resultArray = result.getJSONArray("result")
                callback(Result.success(resultArray.toList()))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }
}
