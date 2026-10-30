/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.addons

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ProfileContext
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.RuntimeEnvironment
import org.robolectric.annotation.Config

private const val ADDON = "addon@example.org"
private const val NOW = 1_800_000_000_000L

/**
 * Permissions accepted from an add-on update notification (#688).
 *
 * The receiver records them and the next update attempt consumes them, so a
 * grant that fails to match lets the notification come straight back, and one
 * that matches too much updates an add-on past what the user agreed to.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AddonUpdateGrantsTest {
    private val application: Context = RuntimeEnvironment.getApplication()

    private fun profile(dirName: String) = ProfileContext(application, "profiles/$dirName")

    @Test
    fun `an accepted update passes once`() {
        val context = profile("once")
        AddonUpdateGrants.grant(context, ADDON, listOf("tabs", "https://*/*"), listOf("locationInfo"), NOW)

        assertTrue(
            AddonUpdateGrants.consume(context, ADDON, listOf("tabs", "https://*/*"), listOf("locationInfo"), NOW),
        )
        assertFalse(
            AddonUpdateGrants.consume(context, ADDON, listOf("tabs", "https://*/*"), listOf("locationInfo"), NOW),
        )
    }

    @Test
    fun `an update asking for more than was shown prompts again`() {
        val context = profile("more")
        AddonUpdateGrants.grant(context, ADDON, listOf("tabs"), emptyList(), NOW)

        assertFalse(AddonUpdateGrants.consume(context, ADDON, listOf("tabs", "history"), emptyList(), NOW))
        // Still there for the update it was made for.
        assertTrue(AddonUpdateGrants.consume(context, ADDON, listOf("tabs"), emptyList(), NOW))
    }

    @Test
    fun `data collection is not covered by a permission of the same name`() {
        val context = profile("kinds")
        AddonUpdateGrants.grant(context, ADDON, listOf("bookmarksInfo"), emptyList(), NOW)

        assertFalse(AddonUpdateGrants.consume(context, ADDON, emptyList(), listOf("bookmarksInfo"), NOW))
    }

    @Test
    fun `a grant expires`() {
        val context = profile("expiry")
        AddonUpdateGrants.grant(context, ADDON, listOf("tabs"), emptyList(), NOW)
        val later = NOW + AddonUpdateGrants.GRANT_LIFETIME_MS + 1

        assertEquals(emptySet(), AddonUpdateGrants.pendingAddonIds(context, later))
        assertFalse(AddonUpdateGrants.consume(context, ADDON, listOf("tabs"), emptyList(), later))
    }

    @Test
    fun `pending grants are listed until cleared`() {
        val context = profile("pending")
        AddonUpdateGrants.grant(context, ADDON, listOf("tabs"), emptyList(), NOW)
        AddonUpdateGrants.grant(context, "other@example.org", listOf("tabs"), emptyList(), NOW)

        assertEquals(setOf(ADDON, "other@example.org"), AddonUpdateGrants.pendingAddonIds(context, NOW))

        AddonUpdateGrants.clear(context, ADDON)

        assertEquals(setOf("other@example.org"), AddonUpdateGrants.pendingAddonIds(context, NOW))
    }

    @Test
    fun `one profile's grant does not update another's add-on`() {
        AddonUpdateGrants.grant(profile("first"), ADDON, listOf("tabs"), emptyList(), NOW)

        assertFalse(AddonUpdateGrants.consume(profile("second"), ADDON, listOf("tabs"), emptyList(), NOW))
    }
}
