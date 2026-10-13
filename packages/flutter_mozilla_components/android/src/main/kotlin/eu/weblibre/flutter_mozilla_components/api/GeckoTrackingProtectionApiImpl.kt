/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoTrackingProtectionApi
import eu.weblibre.flutter_mozilla_components.pigeons.TrackerLogCategory
import eu.weblibre.flutter_mozilla_components.pigeons.TrackerLogEntry
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingProtectionException
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingStatistics
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingStatisticsRecord
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingStatisticsType
import kotlinx.coroutines.suspendCancellableCoroutine
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.TrackingCategory
import mozilla.components.concept.engine.content.blocking.TrackerLog
import mozilla.components.concept.engine.content.blocking.TrackingProtectionEvent
import mozilla.components.concept.engine.content.blocking.TrackingProtectionException as MozillaTrackingProtectionException
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException

/**
 * Implementation of GeckoTrackingProtectionApi that manages per-site
 * Enhanced Tracking Protection exceptions using Mozilla Android Components'
 * TrackingProtectionUseCases.
 */
class GeckoTrackingProtectionApiImpl : GeckoTrackingProtectionApi {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override suspend fun containsException(tabId: String): Boolean =
        suspendCancellableCoroutine { continuation ->
            components.useCases.trackingProtectionUseCases.containsException(tabId) { hasException ->
                continuation.resume(hasException)
            }
        }

    override fun addException(tabId: String) {
        components.useCases.trackingProtectionUseCases.addException(tabId)
    }

    override fun removeException(tabId: String) {
        components.useCases.trackingProtectionUseCases.removeException(tabId)
    }

    override suspend fun removeExceptionByUrl(url: String) {
        // Create a simple TrackingProtectionException implementation for removal
        val exception = object : MozillaTrackingProtectionException {
            override val url: String = url
        }
        // The Mozilla API is synchronous, so this is done once the call returns
        components.useCases.trackingProtectionUseCases.removeException(exception)
    }

    override suspend fun fetchExceptions(): List<TrackingProtectionException> =
        suspendCancellableCoroutine { continuation ->
            components.useCases.trackingProtectionUseCases.fetchExceptions { mozillaExceptions ->
                val pigeonExceptions = mozillaExceptions.map { mozillaException ->
                    TrackingProtectionException(url = mozillaException.url)
                }
                continuation.resume(pigeonExceptions)
            }
        }

    override suspend fun removeAllExceptions() {
        suspendCancellableCoroutine<Unit> { continuation ->
            components.useCases.trackingProtectionUseCases.removeAllExceptions {
                continuation.resume(Unit)
            }
        }
    }

    override suspend fun fetchTrackerLog(tabId: String): List<TrackerLogEntry> =
        suspendCancellableCoroutine { continuation ->
            components.useCases.trackingProtectionUseCases.fetchTrackingLogs(
                tabId,
                onSuccess = { logs -> continuation.resume(logs.map { it.toTrackerLogEntry() }) },
                onError = { continuation.resumeWithException(it) },
            )
        }

    /**
     * Reads the whole database: Gecko keeps one row per type and day and never
     * prunes them, so this stays small, and one read keeps the all-time total
     * and any recent window consistent with each other. The queries need a
     * Looper; pigeon runs this on the main thread.
     */
    override suspend fun fetchTrackingStatistics(): TrackingStatistics {
        val engine = components.core.engine
        val earliest = suspendCancellableCoroutine<Long?> { continuation ->
            engine.getEarliestTrackingProtectionDate(
                onSuccess = { continuation.resume(it) },
                onError = { continuation.resumeWithException(it) },
            )
        }
        val records = if (earliest == null) {
            emptyList()
        } else {
            suspendCancellableCoroutine { continuation ->
                engine.getTrackingProtectionEventsByDateRange(
                    dateFrom = 0,
                    dateTo = System.currentTimeMillis(),
                    onSuccess = { events ->
                        continuation.resume(events.mapNotNull { it.toTrackingStatisticsRecord() })
                    },
                    onError = { continuation.resumeWithException(it) },
                )
            }
        }

        return TrackingStatistics(earliestRecordMillis = earliest, records = records)
    }
}

internal fun TrackerLog.toTrackerLogEntry() = TrackerLogEntry(
    url = url,
    blockedCategories = blockedCategories.map { it.toTrackerLogCategory() },
    loadedCategories = loadedCategories.map { it.toTrackerLogCategory() },
    cookiesBlocked = cookiesHasBeenBlocked,
    unblockedBySmartBlock = unBlockedBySmartBlock,
)

internal fun TrackingCategory.toTrackerLogCategory() = when (this) {
    TrackingCategory.AD -> TrackerLogCategory.AD
    TrackingCategory.ANALYTICS -> TrackerLogCategory.ANALYTICS
    TrackingCategory.SOCIAL -> TrackerLogCategory.SOCIAL
    TrackingCategory.CONTENT -> TrackerLogCategory.CONTENT
    TrackingCategory.CRYPTOMINING -> TrackerLogCategory.CRYPTOMINING
    TrackingCategory.FINGERPRINTING -> TrackerLogCategory.FINGERPRINTING
    TrackingCategory.MOZILLA_SOCIAL -> TrackerLogCategory.MOZILLA_SOCIAL
    TrackingCategory.EMAIL -> TrackerLogCategory.EMAIL
    TrackingCategory.SCRIPTS_AND_SUB_RESOURCES -> TrackerLogCategory.SCRIPTS_AND_SUB_RESOURCES
    TrackingCategory.NONE,
    TrackingCategory.TEST,
    TrackingCategory.RECOMMENDED,
    TrackingCategory.STRICT,
    -> TrackerLogCategory.OTHER
}

/** Null for a type AC knows but this API does not, so a newer engine adds rows rather than failing. */
internal fun TrackingProtectionEvent.toTrackingStatisticsRecord(): TrackingStatisticsRecord? {
    val type = when (type) {
        TrackingProtectionEvent.OTHER_COOKIES_BLOCKED -> TrackingStatisticsType.OTHER_COOKIES
        TrackingProtectionEvent.TRACKERS -> TrackingStatisticsType.TRACKERS
        TrackingProtectionEvent.TRACKING_COOKIES -> TrackingStatisticsType.TRACKING_COOKIES
        TrackingProtectionEvent.CRYPTOMINERS -> TrackingStatisticsType.CRYPTOMINERS
        TrackingProtectionEvent.FINGERPRINTERS -> TrackingStatisticsType.FINGERPRINTERS
        TrackingProtectionEvent.SOCIAL -> TrackingStatisticsType.SOCIAL
        TrackingProtectionEvent.SUSPICIOUS_FINGERPRINTERS -> TrackingStatisticsType.SUSPICIOUS_FINGERPRINTERS
        TrackingProtectionEvent.BOUNCETRACKERS -> TrackingStatisticsType.BOUNCE_TRACKERS
        else -> return null
    }
    return TrackingStatisticsRecord(type = type, count = count.toLong(), date = date)
}
