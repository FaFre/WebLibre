/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.maintenance

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.json.JSONObject

class PreferenceSnapshotTest {
    private fun roundTrip(snapshot: PreferenceSnapshot) =
        PreferenceSnapshot.fromJson(JSONObject(snapshot.toJson().toString()))

    @Test
    fun everyPreferenceTypeSurvivesTheRoundTrip() {
        val snapshot = PreferenceSnapshot(
            files = mapOf(
                "fxaAppState" to mapOf(
                    "flag" to true,
                    "count" to 7,
                    "stamp" to 1_700_000_000_000L,
                    "ratio" to 0.5f,
                    "token" to "abc",
                    "engines" to setOf("bookmarks", "history"),
                ),
            ),
            defaultKeys = mapOf("lastSync" to 42L),
        )

        val restored = roundTrip(snapshot)
        val values = restored.files.getValue("fxaAppState")

        assertEquals(true, values["flag"])
        assertEquals(7, values["count"])
        assertEquals(1_700_000_000_000L, values["stamp"])
        assertEquals(0.5f, values["ratio"])
        assertEquals("abc", values["token"])
        assertEquals(setOf("bookmarks", "history"), values["engines"])
        assertEquals(42L, restored.defaultKeys["lastSync"])
    }

    @Test
    fun aStringSetStaysASetAndNotAString() {
        // `putStringSet` and `putString` are different operations; guessing wrong
        // throws ClassCastException on the next read, long after the restore
        // reported success.
        val snapshot = PreferenceSnapshot(
            files = mapOf("syncEngines" to mapOf("enabled" to setOf("tabs"))),
        )

        val value = roundTrip(snapshot).files.getValue("syncEngines")["enabled"]

        assertTrue(value is Set<*>, "expected a Set, got ${value?.javaClass}")
    }

    @Test
    fun aLongIsNotNarrowedToAnInt() {
        val snapshot = PreferenceSnapshot(defaultKeys = mapOf("stamp" to 3_000_000_000L))

        val value = roundTrip(snapshot).defaultKeys["stamp"]

        assertTrue(value is Long, "expected a Long, got ${value?.javaClass}")
        assertEquals(3_000_000_000L, value)
    }

    @Test
    fun anUnknownTypeIsDroppedRatherThanGuessed() {
        val json = JSONObject(
            """
            {
              "version": 1,
              "files": {},
              "defaultKeys": {
                "good": {"type": "string", "value": "kept"},
                "future": {"type": "blob", "value": "?"}
              }
            }
            """.trimIndent(),
        )

        val snapshot = PreferenceSnapshot.fromJson(json)

        assertEquals(mapOf<String, Any>("good" to "kept"), snapshot.defaultKeys)
    }

    @Test
    fun anEmptySnapshotIsValidBecauseNotEveryProfileSignedIn() {
        assertTrue(PreferenceSnapshot.EMPTY.isEmpty)
        assertTrue(roundTrip(PreferenceSnapshot.EMPTY).isEmpty)
    }

    @Test
    fun aSnapshotWithValuesIsNotEmpty() {
        val snapshot = PreferenceSnapshot(defaultKeys = mapOf("a" to "b"))

        assertFalse(snapshot.isEmpty)
        assertFalse(roundTrip(snapshot).isEmpty)
    }

    @Test
    fun malformedEntriesDoNotTakeTheWholeSnapshotDown() {
        val json = JSONObject(
            """
            {
              "version": 1,
              "files": {"fxaAppState": {"token": {"type": "string", "value": "kept"}}},
              "defaultKeys": {"broken": "not-an-object"}
            }
            """.trimIndent(),
        )

        val snapshot = PreferenceSnapshot.fromJson(json)

        assertEquals("kept", snapshot.files.getValue("fxaAppState")["token"])
        assertTrue(snapshot.defaultKeys.isEmpty())
    }
}

/** The token-ownership rule, which decides what a delete removes. */
class PwaTokenOwnershipTest {
    private val profile = "0199a0b1-1111-7111-8111-111111111111"
    private val other = "0199a0b1-2222-7222-8222-222222222222"

    private fun key(startUrl: String, profileId: String, contextId: String? = null) =
        "token_$startUrl::$profileId" + (contextId?.let { "::$it" } ?: "")

    @Test
    fun matchesItsOwnProfileWithAndWithoutAContainer() {
        assertTrue(
            PwaShortcutParticipant.belongsToProfile(
                key("https://example.com/", profile),
                profile,
            ),
        )
        assertTrue(
            PwaShortcutParticipant.belongsToProfile(
                key("https://example.com/", profile, "work"),
                profile,
            ),
        )
    }

    @Test
    fun doesNotMatchAnotherProfile() {
        assertFalse(
            PwaShortcutParticipant.belongsToProfile(
                key("https://example.com/", other),
                profile,
            ),
        )
    }

    @Test
    fun aStartUrlContainingTheUuidIsNotOwnership() {
        // The decisive case: "contains the uuid" would delete another profile's
        // token whenever the site's URL happened to mention it.
        assertFalse(
            PwaShortcutParticipant.belongsToProfile(
                key("https://example.com/$profile", other),
                profile,
            ),
        )
    }

    @Test
    fun keysThatAreNotTokensAreIgnored() {
        assertFalse(PwaShortcutParticipant.belongsToProfile("other_key", profile))
        assertFalse(PwaShortcutParticipant.belongsToProfile("token_novalue", profile))
    }
}
