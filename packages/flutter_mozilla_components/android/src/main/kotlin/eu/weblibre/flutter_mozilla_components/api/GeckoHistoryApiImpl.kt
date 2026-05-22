package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.DocumentType
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoHistoryApi
import eu.weblibre.flutter_mozilla_components.pigeons.FrecencyThresholdOption
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryHighlight
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryHighlightWeights
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryMetadata
import eu.weblibre.flutter_mozilla_components.pigeons.HistoryMetadataKey
import eu.weblibre.flutter_mozilla_components.pigeons.HistorySuggestion
import eu.weblibre.flutter_mozilla_components.pigeons.PageObservation
import eu.weblibre.flutter_mozilla_components.pigeons.TopFrecentSiteInfo
import eu.weblibre.flutter_mozilla_components.pigeons.VisitInfo
import eu.weblibre.flutter_mozilla_components.pigeons.VisitType
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.concept.storage.HistoryMetadataObservation
import kotlin.time.Duration.Companion.milliseconds

class GeckoHistoryApiImpl() : GeckoHistoryApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    }

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    private fun Map<String, DownloadState>.toVisitInfoList(
        startMillis: Long,
        endMillis: Long,
    ): List<VisitInfo> =
        values
            .filter {
                isDisplayableItem(it.status) &&
                        it.createdTime >= startMillis && it.createdTime <= endMillis
            }
            .distinctBy { Pair(it.fileName, it.status) }
            .sortedByDescending { it.createdTime } // sort from newest to oldest
            .map { it.toVisitInfo() }

    private fun isDisplayableItem(status: DownloadState.Status) =
        status != DownloadState.Status.CANCELLED

    private fun DownloadState.toVisitInfo() =
        VisitInfo(
            url = url,
            visitType = VisitType.DOWNLOAD,
            visitTime = createdTime,
            title = filePath,
            previewImageUrl = contentType,
            isRemote = false,
            contentId = id
        )

    override fun getDetailedVisits(
        startMillis: Long,
        endMillis: Long,
        excludeTypes: List<VisitType>,
        callback: (Result<List<VisitInfo>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                var visits = components.core.historyStorage.getDetailedVisits(
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
                    }).map {
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

                if (!excludeTypes.contains(VisitType.DOWNLOAD)) {
                    visits = visits + components.core.store.state.downloads.toVisitInfoList(
                        startMillis,
                        endMillis
                    )
                }

                callback(
                    Result.success(
                        visits
                    )
                )
            }
        }
    }

    override fun getVisitsPaginated(
        offset: Long,
        count: Long,
        excludeTypes: List<VisitType>,
        callback: (Result<List<VisitInfo>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                var visits = components.core.historyStorage.getVisitsPaginated(
                    offset,
                    count,
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
                    }).map {
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

                if (!excludeTypes.contains(VisitType.DOWNLOAD)) {
                    callback(Result.failure(Throwable("Downloads not supported yet")))
//                    visits = visits + components.core.store.state.downloads.toVisitInfoList(startMillis, endMillis)
                }

                callback(
                    Result.success(
                        visits
                    )
                )
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

    override fun deleteDownload(
        id: String,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.useCases.downloadsUseCases.removeDownload(id)

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

    override fun getHistoryHighlights(
        weights: HistoryHighlightWeights,
        limit: Long,
        callback: (Result<List<HistoryHighlight>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val conceptWeights = mozilla.components.concept.storage.HistoryHighlightWeights(
                    viewTime = weights.viewTime,
                    frequency = weights.frequency,
                )
                val highlights = components.core.historyStorage.getHistoryHighlights(
                    conceptWeights,
                    limit.toInt(),
                ).map {
                    HistoryHighlight(
                        score = it.score,
                        placeId = it.placeId.toLong(),
                        url = it.url,
                        title = it.title,
                        previewImageUrl = it.previewImageUrl,
                    )
                }
                callback(Result.success(highlights))
            }
        }
    }

    private fun mozilla.components.concept.storage.DocumentType.toPigeon(): DocumentType =
        when (this) {
            mozilla.components.concept.storage.DocumentType.Regular -> DocumentType.REGULAR
            mozilla.components.concept.storage.DocumentType.Media -> DocumentType.MEDIA
        }

    private fun DocumentType.toConcept(): mozilla.components.concept.storage.DocumentType =
        when (this) {
            DocumentType.REGULAR -> mozilla.components.concept.storage.DocumentType.Regular
            DocumentType.MEDIA -> mozilla.components.concept.storage.DocumentType.Media
        }

    private fun HistoryMetadataKey.toConcept(): mozilla.components.concept.storage.HistoryMetadataKey =
        mozilla.components.concept.storage.HistoryMetadataKey(
            url = url,
            searchTerm = searchTerm,
            referrerUrl = referrerUrl,
        )

    private fun mozilla.components.concept.storage.HistoryMetadata.toPigeon(): HistoryMetadata =
        HistoryMetadata(
            key = HistoryMetadataKey(
                url = key.url,
                searchTerm = key.searchTerm,
                referrerUrl = key.referrerUrl,
            ),
            title = title,
            createdAt = createdAt,
            updatedAt = updatedAt,
            totalViewTime = totalViewTime.toLong(),
            documentType = documentType.toPigeon(),
            previewImageUrl = previewImageUrl,
        )

    override fun getTopFrecentSites(
        limit: Long,
        frecencyThreshold: FrecencyThresholdOption,
        callback: (Result<List<TopFrecentSiteInfo>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val conceptThreshold = when (frecencyThreshold) {
                    FrecencyThresholdOption.NONE ->
                        mozilla.components.concept.storage.FrecencyThresholdOption.NONE
                    FrecencyThresholdOption.SKIP_ONE_TIME_PAGES ->
                        mozilla.components.concept.storage.FrecencyThresholdOption.SKIP_ONE_TIME_PAGES
                }
                val sites = components.core.historyStorage.getTopFrecentSites(
                    limit.toInt(),
                    conceptThreshold,
                ).map {
                    TopFrecentSiteInfo(
                        url = it.url,
                        title = it.title,
                    )
                }
                callback(Result.success(sites))
            }
        }
    }

    override fun getLatestHistoryMetadataForUrl(
        url: String,
        callback: (Result<HistoryMetadata?>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val metadata = components.core.historyStorage
                    .getLatestHistoryMetadataForUrl(url)
                    ?.toPigeon()
                callback(Result.success(metadata))
            }
        }
    }

    override fun getLatestHistoryMetadataForUrls(
        urls: List<String>,
        callback: (Result<List<HistoryMetadata?>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                // Run lookups concurrently so Rust JNI calls don't serialize
                // per-URL on the Pigeon roundtrip. Order is preserved by
                // `awaitAll` honoring the input ordering.
                val results = coroutineScope {
                    urls.map { url ->
                        async {
                            components.core.historyStorage
                                .getLatestHistoryMetadataForUrl(url)
                                ?.toPigeon()
                        }
                    }.awaitAll()
                }
                callback(Result.success(results))
            }
        }
    }

    override fun getVisited(
        urls: List<String>,
        callback: (Result<List<Boolean>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val visited = components.core.historyStorage.getVisited(urls)
                callback(Result.success(visited))
            }
        }
    }

    override fun getSuggestions(
        query: String,
        limit: Long,
        callback: (Result<List<HistorySuggestion>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val suggestions = components.core.historyStorage
                    .getSuggestions(query, limit.toInt())
                    .map {
                        HistorySuggestion(
                            url = it.url,
                            title = it.title,
                            score = it.score.toLong(),
                        )
                    }
                callback(Result.success(suggestions))
            }
        }
    }

    override fun queryHistoryMetadata(
        query: String,
        limit: Long,
        callback: (Result<List<HistoryMetadata>>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                val results = components.core.historyStorage
                    .queryHistoryMetadata(query, limit.toInt())
                    .map { it.toPigeon() }
                callback(Result.success(results))
            }
        }
    }

    override fun recordObservation(
        url: String,
        observation: PageObservation,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.recordObservation(
                    url,
                    mozilla.components.concept.storage.PageObservation(
                        title = observation.title,
                        previewImageUrl = observation.previewImageUrl,
                    ),
                )
                callback(Result.success(Unit))
            }
        }
    }

    override fun noteHistoryMetadataViewTime(
        key: HistoryMetadataKey,
        viewTimeMs: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.noteHistoryMetadataObservation(
                    key.toConcept(),
                    HistoryMetadataObservation.ViewTimeObservation(
                        viewTime = viewTimeMs.toInt(),
                    ),
                )
                callback(Result.success(Unit))
            }
        }
    }

    override fun noteHistoryMetadataDocumentType(
        key: HistoryMetadataKey,
        documentType: DocumentType,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.noteHistoryMetadataObservation(
                    key.toConcept(),
                    HistoryMetadataObservation.DocumentTypeObservation(
                        documentType = documentType.toConcept(),
                    ),
                )
                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteVisitsFor(
        url: String,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteVisitsFor(url)
                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteVisitsSince(
        sinceMillis: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteVisitsSince(sinceMillis)
                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteEverything(
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage.deleteEverything()
                callback(Result.success(Unit))
            }
        }
    }

    override fun deleteHistoryMetadataOlderThan(
        olderThanMillis: Long,
        callback: (Result<Unit>) -> Unit
    ) {
        coroutineScope.launch {
            withContext(Dispatchers.Main) {
                components.core.historyStorage
                    .deleteHistoryMetadataOlderThan(olderThanMillis)
                callback(Result.success(Unit))
            }
        }
    }
}
