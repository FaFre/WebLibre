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
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import mozilla.components.browser.state.state.content.DownloadState
import mozilla.components.concept.storage.HistoryMetadataObservation
import kotlin.time.Duration.Companion.milliseconds

class GeckoHistoryApiImpl() : GeckoHistoryApi {
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

    override suspend fun getDetailedVisits(
        startMillis: Long,
        endMillis: Long,
        excludeTypes: List<VisitType>
    ): List<VisitInfo> {
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

        return visits
    }

    override suspend fun getVisitsPaginated(
        offset: Long,
        count: Long,
        excludeTypes: List<VisitType>
    ): List<VisitInfo> {
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
            throw Throwable("Downloads not supported yet")
//                    visits = visits + components.core.store.state.downloads.toVisitInfoList(startMillis, endMillis)
        }

        return visits
    }

    override suspend fun deleteVisit(
        url: String,
        timestamp: Long
    ) {
        components.core.historyStorage.deleteVisit(url, timestamp);
    }

    override suspend fun deleteDownload(
        id: String
    ) {
        components.useCases.downloadsUseCases.removeDownload(id)
    }

    override suspend fun deleteVisitsBetween(
        startMillis: Long,
        endMillis: Long
    ) {
        components.core.historyStorage.deleteVisitsBetween(startMillis, endMillis);
    }

    override suspend fun getHistoryHighlights(
        weights: HistoryHighlightWeights,
        limit: Long
    ): List<HistoryHighlight> {
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
        return highlights
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

    override suspend fun getTopFrecentSites(
        limit: Long,
        frecencyThreshold: FrecencyThresholdOption
    ): List<TopFrecentSiteInfo> {
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
        return sites
    }

    override suspend fun getLatestHistoryMetadataForUrl(
        url: String
    ): HistoryMetadata? {
        val metadata = components.core.historyStorage
            .getLatestHistoryMetadataForUrl(url)
            ?.toPigeon()
        return metadata
    }

    override suspend fun getLatestHistoryMetadataForUrls(
        urls: List<String>
    ): List<HistoryMetadata?> {
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
        return results
    }

    override suspend fun getVisited(
        urls: List<String>
    ): List<Boolean> {
        val visited = components.core.historyStorage.getVisited(urls)
        return visited
    }

    override suspend fun getSuggestions(
        query: String,
        limit: Long
    ): List<HistorySuggestion> {
        val suggestions = components.core.historyStorage
            .getSuggestions(query, limit.toInt())
            .map {
                HistorySuggestion(
                    url = it.url,
                    title = it.title,
                    score = it.score.toLong(),
                )
            }
        return suggestions
    }

    override suspend fun queryHistoryMetadata(
        query: String,
        limit: Long
    ): List<HistoryMetadata> {
        val results = components.core.historyStorage
            .queryHistoryMetadata(query, limit.toInt())
            .map { it.toPigeon() }
        return results
    }

    override suspend fun recordObservation(
        url: String,
        observation: PageObservation
    ) {
        components.core.historyStorage.recordObservation(
            url,
            mozilla.components.concept.storage.PageObservation(
                title = observation.title,
                previewImageUrl = observation.previewImageUrl,
            ),
        )
    }

    override suspend fun noteHistoryMetadataViewTime(
        key: HistoryMetadataKey,
        viewTimeMs: Long
    ) {
        components.core.historyStorage.noteHistoryMetadataObservation(
            key.toConcept(),
            HistoryMetadataObservation.ViewTimeObservation(
                viewTime = viewTimeMs.toInt(),
            ),
        )
    }

    override suspend fun noteHistoryMetadataDocumentType(
        key: HistoryMetadataKey,
        documentType: DocumentType
    ) {
        components.core.historyStorage.noteHistoryMetadataObservation(
            key.toConcept(),
            HistoryMetadataObservation.DocumentTypeObservation(
                documentType = documentType.toConcept(),
            ),
        )
    }

    override suspend fun deleteVisitsFor(
        url: String
    ) {
        components.core.historyStorage.deleteVisitsFor(url)
    }

    override suspend fun deleteVisitsSince(
        sinceMillis: Long
    ) {
        components.core.historyStorage.deleteVisitsSince(sinceMillis)
    }

    override suspend fun deleteEverything() {
        components.core.historyStorage.deleteEverything()
    }

    override suspend fun deleteHistoryMetadataOlderThan(
        olderThanMillis: Long
    ) {
        components.core.historyStorage
            .deleteHistoryMetadataOlderThan(olderThanMillis)
    }
}
