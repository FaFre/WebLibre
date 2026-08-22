/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import mozilla.components.concept.engine.EngineSession
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

/**
 * The guard that decides whether a held navigation may still be loaded. Getting this wrong in either
 * direction is a visible bug: too strict strands a declined prompt, too loose overwrites the page
 * the user moved on to.
 */
class AppLinkNavigationReleaseTest {
    @Test
    fun theTabStandingStillMayBeReleased() {
        assertTrue(
            isSameDocumentTarget("https://news.example/article", "https://news.example/article"),
        )
    }

    @Test
    fun aTabThatNavigatedElsewhereMayNot() {
        assertFalse(
            isSameDocumentTarget("https://other.example/", "https://news.example/article"),
        )
    }

    @Test
    fun anInPageAnchorIsNotLeaving() {
        // Clicking a table-of-contents link must not cost the user their "Stay in browser".
        assertTrue(
            isSameDocumentTarget(
                "https://news.example/article#section-3",
                "https://news.example/article",
            ),
        )
        assertTrue(
            isSameDocumentTarget(
                "https://news.example/article",
                "https://news.example/article#section-3",
            ),
        )
    }

    @Test
    fun aTabOpenedForTheLinkStartsAndStaysEmpty() {
        // A link that opened its own tab anchors on "", and nothing has loaded since.
        assertTrue(isSameDocumentTarget("", ""))
    }

    @Test
    fun aTabOpenedForTheLinkThatSinceLoadedSomethingMayNot() {
        assertFalse(isSameDocumentTarget("https://elsewhere.example/", ""))
    }

    @Test
    fun aRequestWithoutAnAnchorIsAllowed() {
        // No anchor recorded (never held, or an older request): nothing to contradict.
        assertTrue(isSameDocumentTarget("https://anything.example/", null))
    }

    @Test
    fun releaseLoadsBypassTheNavigationDelegate() {
        // Without this the release re-enters the interceptor and prompts for the answer just given.
        assertTrue(
            RELEASE_LOAD_FLAGS.contains(
                EngineSession.LoadUrlFlags.LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE,
            ),
        )
        // Explicitly *not* EXTERNAL: it sends Gecko through a process switch whose transient
        // `about:blank` location change makes URL watchers act on a page that has not arrived.
        assertFalse(RELEASE_LOAD_FLAGS.contains(EngineSession.LoadUrlFlags.EXTERNAL))
    }
}
