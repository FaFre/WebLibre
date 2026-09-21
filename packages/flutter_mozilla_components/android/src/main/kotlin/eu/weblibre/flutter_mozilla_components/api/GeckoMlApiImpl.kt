package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.feature.MLEngineFeature
import eu.weblibre.flutter_mozilla_components.feature.awaitResult
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
                stateEvents.onMlProgress(EventSequence.next(), mlProgress) { result ->
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

    override suspend fun predictDocumentTopic(documents: List<String>): String =
        awaitResult({ MLEngineFeature.scheduleRequest("predictDocumentTopic", documents.toJson(), it) }) { result ->
            result.getString("result")
        }

    override suspend fun generateDocumentEmbeddings(documents: List<String>): List<Any?> =
        awaitResult({ MLEngineFeature.scheduleRequest("generateDocumentEmbeddings", documents.toJson(), it) }) { result ->
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

            embeddings
        }

    override suspend fun clearMlCache() {
        awaitResult({ MLEngineFeature.scheduleRequest("clearMlCache", JSONObject(), it) }) { }
    }

}
