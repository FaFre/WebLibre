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

    override fun predictDocumentTopic(documents: List<String>, callback: (Result<String>) -> Unit) {
        MLEngineFeature.scheduleRequest("predictDocumentTopic", documents.toJson(), object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                callback(Result.success(result.getString("result")))
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

    override fun generateDocumentEmbeddings(
        documents: List<String>,
        callback: (Result<List<Any?>>) -> Unit
    ) {
        MLEngineFeature.scheduleRequest("generateDocumentEmbeddings", documents.toJson(), object : ResultConsumer<JSONObject> {
            override fun success(result: JSONObject) {
                try {
                    val encodedResult = result.getString("result")
                    val decodedJsonArray = JSONArray(encodedResult)
                    val embeddings = mutableListOf<List<Double>>()

                    for (i in 0 until decodedJsonArray.length()) {
                        val embeddingArray = decodedJsonArray.getJSONArray(i)
                        val embedding = mutableListOf<Double>()

                        for (j in 0 until embeddingArray.length()) {
                            embedding.add(embeddingArray.getDouble(j))
                        }
                        embeddings.add(embedding)
                    }

                    callback(Result.success(embeddings))
                } catch (e: Exception) {
                    callback(Result.failure(e))
                }
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                callback(Result.failure(Exception("$errorCode $errorMessage $errorDetails")))
            }
        })
    }

}