/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

private const val PROFILE_A = "0199a0b1-1111-7111-8111-111111111111"

class LaunchClassifierTest {
    private fun classify(
        action: String? = LaunchClassifier.ACTION_VIEW,
        dataUri: String? = "https://example.com/",
        categories: Set<String> = emptySet(),
        hasCustomTabSession: Boolean = false,
        pwaProfileId: String? = null,
        pwaTrusted: Boolean = false,
        shortcutType: String? = null,
        shareUrl: String? = null,
        customTabsEnabled: Boolean = true,
    ) = LaunchClassifier.classify(
        LaunchFacts(
            action = action,
            dataUri = dataUri,
            categories = categories,
            hasCustomTabSession = hasCustomTabSession,
            pwaProfileId = pwaProfileId,
            pwaTrusted = pwaTrusted,
            shortcutType = shortcutType,
            shareUrl = shareUrl,
            customTabsEnabled = customTabsEnabled,
        ),
    )

    @Test
    fun aPlainViewIsRegularAndNeedsNothing() {
        val descriptor = classify()

        assertEquals(LaunchClassification.REGULAR, descriptor.classification)
        assertFalse(descriptor.requiresComponents)
        assertFalse(descriptor.bindsTrustedProfile)
    }

    @Test
    fun aValidatedPwaNamesItsProfileAndNeedsComponents() {
        val descriptor = classify(
            pwaProfileId = PROFILE_A,
            pwaTrusted = true,
            shortcutType = "pwa",
        )

        assertEquals(LaunchClassification.TRUSTED_PWA, descriptor.classification)
        assertEquals(PROFILE_A, descriptor.trustedProfileId)
        assertTrue(descriptor.requiresComponents)
    }

    @Test
    fun aValidatedBasicShortcutNamesItsProfileButNeedsNoComponents() {
        // It opens in the ordinary browser, so there is nothing to build here —
        // but the profile it was pinned under still has to win the commit.
        val descriptor = classify(
            pwaProfileId = PROFILE_A,
            pwaTrusted = true,
            shortcutType = LaunchClassifier.SHORTCUT_TYPE_BASIC,
        )

        assertEquals(LaunchClassification.TRUSTED_SHORTCUT, descriptor.classification)
        assertEquals(PROFILE_A, descriptor.trustedProfileId)
        assertFalse(descriptor.requiresComponents)
        assertTrue(descriptor.bindsTrustedProfile)
    }

    @Test
    fun anUnvalidatedProfileExtraSelectsNothing() {
        // The whole point of the trust check: any app can put this extra on an
        // intent, so an unvalidated claim must not reach the arbiter.
        val descriptor = classify(pwaProfileId = PROFILE_A, pwaTrusted = false)

        assertEquals(LaunchClassification.REGULAR, descriptor.classification)
        assertNull(descriptor.trustedProfileId)
        assertFalse(descriptor.bindsTrustedProfile)
        assertFalse(descriptor.requiresComponents)
    }

    @Test
    fun anUnvalidatedProfileExtraDoesNotPromoteACustomTab() {
        val descriptor = classify(
            hasCustomTabSession = true,
            pwaProfileId = PROFILE_A,
            pwaTrusted = false,
        )

        assertEquals(LaunchClassification.CUSTOM_TAB, descriptor.classification)
        assertNull(descriptor.trustedProfileId)
    }

    @Test
    fun aCustomTabNeedsComponentsButNamesNoProfile() {
        val descriptor = classify(hasCustomTabSession = true)

        assertEquals(LaunchClassification.CUSTOM_TAB, descriptor.classification)
        assertTrue(descriptor.requiresComponents)
        assertNull(descriptor.trustedProfileId)
    }

    @Test
    fun aCustomTabWithTheFeatureOffIsAnOrdinaryLink() {
        // Nothing to open as a custom tab, so building an engine to find that out
        // would bind the process profile for no reason at all.
        val descriptor = classify(hasCustomTabSession = true, customTabsEnabled = false)

        assertEquals(LaunchClassification.REGULAR, descriptor.classification)
        assertFalse(descriptor.requiresComponents)
    }

    @Test
    fun aLegacyPwaActionNeedsComponents() {
        val descriptor = classify(action = LaunchClassifier.ACTION_VIEW_PWA)

        assertEquals(LaunchClassification.LEGACY_PWA, descriptor.classification)
        assertTrue(descriptor.requiresComponents)
        assertNull(descriptor.trustedProfileId)
    }

    @Test
    fun theLegacyShortcutCategoryAlsoCounts() {
        val descriptor = classify(
            categories = setOf(LaunchClassifier.CATEGORY_PWA_SHORTCUT),
        )

        assertEquals(LaunchClassification.LEGACY_PWA, descriptor.classification)
    }

    @Test
    fun aShareWithAUrlBecomesACustomTab() {
        val descriptor = classify(
            action = LaunchClassifier.ACTION_SEND,
            dataUri = null,
            shareUrl = "https://example.com/shared",
        )

        assertEquals(LaunchClassification.SHARE_URL, descriptor.classification)
        assertEquals("https://example.com/shared", descriptor.shareUrl)
        assertTrue(descriptor.requiresComponents)
    }

    @Test
    fun aShareWithoutAUrlIsRegular() {
        val descriptor = classify(
            action = LaunchClassifier.ACTION_SEND,
            dataUri = null,
            shareUrl = null,
        )

        assertEquals(LaunchClassification.REGULAR, descriptor.classification)
        assertFalse(descriptor.requiresComponents)
    }

    @Test
    fun aShareWithCustomTabsOffIsRegular() {
        val descriptor = classify(
            action = LaunchClassifier.ACTION_SEND,
            dataUri = null,
            shareUrl = "https://example.com/shared",
            customTabsEnabled = false,
        )

        assertEquals(LaunchClassification.REGULAR, descriptor.classification)
        assertFalse(descriptor.requiresComponents)
    }

    @Test
    fun aTrustedPwaOutranksACustomTabSession() {
        // A forged custom tab session on a genuinely trusted PWA launch must not
        // be able to downgrade it into a session that names no profile.
        val descriptor = classify(
            hasCustomTabSession = true,
            pwaProfileId = PROFILE_A,
            pwaTrusted = true,
        )

        assertEquals(LaunchClassification.TRUSTED_PWA, descriptor.classification)
        assertEquals(PROFILE_A, descriptor.trustedProfileId)
    }

    @Test
    fun aShareOutranksEverythingElseOnTheIntent() {
        val descriptor = classify(
            action = LaunchClassifier.ACTION_SEND,
            dataUri = null,
            hasCustomTabSession = true,
            shareUrl = "https://example.com/shared",
        )

        assertEquals(LaunchClassification.SHARE_URL, descriptor.classification)
    }

    @Test
    fun everyClassificationThatBindsAProfileIsATrustedOne() {
        // Guards the invariant the arbiter depends on: `trustedProfileId` is only
        // ever populated for a classification that `isTrusted` agrees with.
        val cases = listOf(
            classify(pwaProfileId = PROFILE_A, pwaTrusted = true),
            classify(
                pwaProfileId = PROFILE_A,
                pwaTrusted = true,
                shortcutType = LaunchClassifier.SHORTCUT_TYPE_BASIC,
            ),
            classify(hasCustomTabSession = true),
            classify(action = LaunchClassifier.ACTION_VIEW_PWA),
            classify(),
        )

        for (descriptor in cases) {
            if (descriptor.bindsTrustedProfile) {
                assertTrue(
                    descriptor.classification.isTrusted,
                    "${descriptor.classification} named a profile but is not trusted",
                )
            }
        }
    }
}
