package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.feature.MLEngineFeature
import eu.weblibre.flutter_mozilla_components.feature.ResultConsumer
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoMlApi
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.MlProgressData
import eu.weblibre.flutter_mozilla_components.pigeons.MlProgressType
import eu.weblibre.flutter_mozilla_components.pigeons.MlProgressStatus
import io.flutter.plugin.common.BinaryMessenger
import org.json.JSONArray
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

class GeckoMlApiImpl(
    private val binaryMessenger: BinaryMessenger,
    private val stateEvents: GeckoStateEvents
) : GeckoMlApi {

    init {
        // Register progress callback with ML engine
        MLEngineFeature.progressCallback = { progressData ->
            emitProgress(progressData)
        }
    }

    private fun emitProgress(progressData: JSONObject) {
        try {
            val modelType = progressData.optString("modelType", "Unknown")
            val progress = progressData.optDouble("progress", 0.0)
            val typeString = progressData.optString("type", "")
            val statusString = progressData.optString("statusText", "")
            val totalLoaded = progressData.optLong("totalLoaded", 0)
            val currentLoaded = progressData.optLong("currentLoaded", 0)
            val total = progressData.optLong("total", 0)
            val units = progressData.optString("units", "bytes")
            val ok = progressData.optBoolean("ok", false)
            val id = if (progressData.has("id")) progressData.optString("id") else null

            // Map type string to enum
            val type = when (typeString) {
                "downloading" -> MlProgressType.DOWNLOADING
                "loading_from_cache" -> MlProgressType.LOADING_FROM_CACHE
                "running_inference" -> MlProgressType.RUNNING_INFERENCE
                else -> MlProgressType.DOWNLOADING
            }

            // Map status string to enum
            val status = when (statusString.uppercase()) {
                "INITIATE" -> MlProgressStatus.INITIATE
                "SIZE_ESTIMATE" -> MlProgressStatus.SIZE_ESTIMATE
                "IN_PROGRESS" -> MlProgressStatus.IN_PROGRESS
                "DONE" -> MlProgressStatus.DONE
                else -> MlProgressStatus.IN_PROGRESS
            }

            val mlProgress = MlProgressData(
                modelType = modelType,
                progress = progress,
                type = type,
                status = status,
                totalLoaded = totalLoaded,
                currentLoaded = currentLoaded,
                total = total,
                units = units,
                ok = ok,
                id = id
            )

            runOnUiThread {
                stateEvents.onMlProgress(System.currentTimeMillis(), mlProgress) { result ->
                    result.onFailure { error ->
                        android.util.Log.e("GeckoMlApi", "Failed to emit progress event: ${error.message}")
                    }
                }
            }
        } catch (e: Exception) {
            android.util.Log.e("GeckoMlApi", "Error parsing progress data", e)
        }
    }

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