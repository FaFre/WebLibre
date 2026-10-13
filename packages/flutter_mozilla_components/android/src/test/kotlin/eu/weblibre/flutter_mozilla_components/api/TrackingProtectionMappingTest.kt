/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.api

import eu.weblibre.flutter_mozilla_components.pigeons.TrackerLogCategory
import eu.weblibre.flutter_mozilla_components.pigeons.TrackerLogEntry
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingStatisticsRecord
import eu.weblibre.flutter_mozilla_components.pigeons.TrackingStatisticsType
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertNull
import mozilla.components.concept.engine.EngineSession.TrackingProtectionPolicy.TrackingCategory
import mozilla.components.concept.engine.content.blocking.TrackerLog
import mozilla.components.concept.engine.content.blocking.TrackingProtectionEvent

class TrackingProtectionMappingTest {
    @Test
    fun `tracker log keeps origin, both category lists and the cookie flag`() {
        val log = TrackerLog(
            url = "https://tracker.example",
            loadedCategories = listOf(TrackingCategory.AD),
            blockedCategories = listOf(
                TrackingCategory.FINGERPRINTING,
                TrackingCategory.SCRIPTS_AND_SUB_RESOURCES,
            ),
            cookiesHasBeenBlocked = true,
            unBlockedBySmartBlock = true,
        )

        assertEquals(
            TrackerLogEntry(
                url = "https://tracker.example",
                blockedCategories = listOf(
                    TrackerLogCategory.FINGERPRINTING,
                    TrackerLogCategory.SCRIPTS_AND_SUB_RESOURCES,
                ),
                loadedCategories = listOf(TrackerLogCategory.AD),
                cookiesBlocked = true,
                unblockedBySmartBlock = true,
            ),
            log.toTrackerLogEntry(),
        )
    }

    @Test
    fun `composite and test categories carry no meaning of their own`() {
        listOf(
            TrackingCategory.NONE,
            TrackingCategory.TEST,
            TrackingCategory.RECOMMENDED,
            TrackingCategory.STRICT,
        ).forEach { assertEquals(TrackerLogCategory.OTHER, it.toTrackerLogCategory()) }
    }

    @Test
    fun `every statistics type maps to its own record type`() {
        val expected = mapOf(
            TrackingProtectionEvent.OTHER_COOKIES_BLOCKED to TrackingStatisticsType.OTHER_COOKIES,
            TrackingProtectionEvent.TRACKERS to TrackingStatisticsType.TRACKERS,
            TrackingProtectionEvent.TRACKING_COOKIES to TrackingStatisticsType.TRACKING_COOKIES,
            TrackingProtectionEvent.CRYPTOMINERS to TrackingStatisticsType.CRYPTOMINERS,
            TrackingProtectionEvent.FINGERPRINTERS to TrackingStatisticsType.FINGERPRINTERS,
            TrackingProtectionEvent.SOCIAL to TrackingStatisticsType.SOCIAL,
            TrackingProtectionEvent.SUSPICIOUS_FINGERPRINTERS to
                TrackingStatisticsType.SUSPICIOUS_FINGERPRINTERS,
            TrackingProtectionEvent.BOUNCETRACKERS to TrackingStatisticsType.BOUNCE_TRACKERS,
        )

        expected.forEach { (type, recordType) ->
            assertEquals(
                TrackingStatisticsRecord(type = recordType, count = 3, date = "2026-10-01"),
                TrackingProtectionEvent(type = type, count = 3, date = "2026-10-01")
                    .toTrackingStatisticsRecord(),
            )
        }
    }

    @Test
    fun `a type this API does not know is dropped rather than failing the read`() {
        assertNull(TrackingProtectionEvent(type = 99, count = 1, date = null).toTrackingStatisticsRecord())
    }
}
