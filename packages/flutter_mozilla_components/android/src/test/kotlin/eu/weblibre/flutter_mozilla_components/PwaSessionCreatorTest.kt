/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import android.content.Intent
import kotlin.test.assertEquals
import kotlin.test.assertNull
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner

@RunWith(RobolectricTestRunner::class)
class PwaSessionCreatorTest {
    @Test
    fun `a shortcut installed before the extra existed asks for nothing`() {
        assertNull(PwaSessionCreator.desktopModeOf(Intent(Intent.ACTION_VIEW)))
        assertNull(PwaSessionCreator.desktopModeOf(null))
    }

    @Test
    fun `an explicit mobile install is not mistaken for a missing one`() {
        val intent = Intent(Intent.ACTION_VIEW)
            .putExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE, false)

        assertEquals(false, PwaSessionCreator.desktopModeOf(intent))
    }

    @Test
    fun `desktop mode survives the pending-launch round trip`() {
        // A profile-mismatch restart stores the shortcut as an intent URI and
        // replays it after relaunch.
        val original = Intent(Intent.ACTION_VIEW)
            .putExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE, true)

        val replayed = Intent.parseUri(
            original.toUri(Intent.URI_INTENT_SCHEME),
            Intent.URI_INTENT_SCHEME,
        )

        assertEquals(true, PwaSessionCreator.desktopModeOf(replayed))
    }
}
