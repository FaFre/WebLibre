package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.AutocompleteResult
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryApi
import eu.weblibre.flutter_mozilla_components.pigeons.VisitInfo
import eu.weblibre.flutter_mozilla_components.pigeons.VisitType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

class GeckoHistoryApiImpl() : GeckoHistoryApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun getDetailedVisits(
        startMillis: Long,
        endMillis: Long,
        excludeTypes: List<VisitType>,
        callback: (Result<List<VisitInfo>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val visits = components.core.historyStorage.getDetailedVisits(
                    startMillis,
                    endMillis,
                    excludeTypes.map {
                        when (it) {
                            VisitType.LINK -> mozilla.components.concept.storage.VisitType.LINK
                            VisitType.TYPED -> mozilla.components.concept.storage.VisitType.TYPED
                            VisitType.BOOKMARK -> mozilla.components.concept.storage.VisitType.BOOKMARK
                            VisitType.EMBED -> mozilla.components.concept.storage.VisitType.EMBED
                            VisitType.REDIRECT_PERMANENT -> mozilla.components.concept.storage.VisitType.REDIRECT_PERMANENT
                            VisitType.REDIRECT_TEMPORARY -> mozilla.components.concept.storage.VisitType.REDIRECT_TEMPORARY
                            VisitType.DOWNLOAD -> mozilla.components.concept.storage.VisitType.DOWNLOAD
                            VisitType.FRAMED_LINK -> mozilla.components.concept.storage.VisitType.FRAMED_LINK
                            VisitType.RELOAD -> mozilla.components.concept.storage.VisitType.RELOAD
                        }
                    })

                callback(Result.success(visits.map {
                    VisitInfo(
                        url = it.url,
                        title = it.title,
                        visitTime = it.visitTime,
                        visitType = when (it.visitType) {
                            mozilla.components.concept.storage.VisitType.LINK -> VisitType.LINK
                            mozilla.components.concept.storage.VisitType.TYPED -> VisitType.TYPED
                            mozilla.components.concept.storage.VisitType.BOOKMARK -> VisitType.BOOKMARK
                            mozilla.components.concept.storage.VisitType.EMBED -> VisitType.EMBED
                            mozilla.components.concept.storage.VisitType.REDIRECT_PERMANENT -> VisitType.REDIRECT_PERMANENT
                            mozilla.components.concept.storage.VisitType.REDIRECT_TEMPORARY -> VisitType.REDIRECT_TEMPORARY
                            mozilla.components.concept.storage.VisitType.DOWNLOAD -> VisitType.DOWNLOAD
                            mozilla.components.concept.storage.VisitType.FRAMED_LINK -> VisitType.FRAMED_LINK
                            mozilla.components.concept.storage.VisitType.RELOAD -> VisitType.RELOAD
                        },
                        previewImageUrl = it.previewImageUrl,
                        isRemote = it.isRemote
                    )
                }
                ))
            }
        }
    }

    override fun deleteVisit(
        url: String,
        timestamp: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteVisit(url, timestamp);

                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteVisitsBetween(
        startMillis: Long,
        endMillis: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteVisitsBetween(startMillis, endMillis);

                callback(Result.success(Unit))
            }
        }
    }
}