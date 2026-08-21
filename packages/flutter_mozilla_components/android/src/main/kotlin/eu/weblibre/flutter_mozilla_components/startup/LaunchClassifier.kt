/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.startup

import eu.weblibre.flutter_mozilla_components.PwaConstants

/**
 * Everything about a launch that the classification depends on.
 *
 * A plain data snapshot rather than the `Intent` itself, for two reasons. It is
 * what the durable intent queue persists, so the classification of a replayed
 * launch is by construction the classification of the original. And it keeps the
 * decision testable without an Android framework: an `Intent` cannot be
 * meaningfully constructed in a JVM unit test, and this decision is far too
 * consequential to leave uncovered.
 *
 * [pwaTrusted] is a *result*, not an input to trust: whoever builds these facts
 * has already validated the launch token against the pinned shortcut list. The
 * raw [pwaProfileId] is carried alongside so an untrusted claim can be seen and
 * discarded rather than silently missing.
 */
data class LaunchFacts(
    val action: String? = null,
    val dataUri: String? = null,
    val categories: Set<String> = emptySet(),
    val hasCustomTabSession: Boolean = false,
    val pwaProfileId: String? = null,
    val pwaTrusted: Boolean = false,
    val shortcutType: String? = null,
    val shareUrl: String? = null,
    val customTabsEnabled: Boolean = true,
)

/**
 * What a launch is, and what it needs, decided before anything is built.
 *
 * [requiresComponents] is the point of the whole exercise. Creating components
 * means creating the Gecko engine, which binds the process profile for good, so
 * a launch that only forwards to `MainActivity` must be recognised as such
 * *before* that happens — otherwise every plain link tap would settle the profile
 * question before the user could be asked.
 */
data class LaunchDescriptor(
    val classification: LaunchClassification,
    val trustedProfileId: String? = null,
    val shareUrl: String? = null,
) {
    /** Whether this launch may name the profile the process commits to. */
    val bindsTrustedProfile: Boolean
        get() = trustedProfileId != null

    /** See [LaunchClassification.requiresComponents], which decides this. */
    val requiresComponents: Boolean
        get() = classification.requiresComponents
}

/**
 * Turns a launch into a decision, with no side effects and no Android types.
 *
 * The order of the rules is the contract:
 *
 * 1. A share is a share regardless of what else it carries.
 * 2. A validated PWA or pinned shortcut outranks everything below it, because it
 *    is the only kind of launch that knows which profile it belongs to.
 * 3. A Custom Tab session is next; it has no profile of its own.
 * 4. A legacy PWA launch, which also has no validated profile.
 * 5. Everything else is a regular launch and gets no components.
 */
object LaunchClassifier {
    const val ACTION_SEND = "android.intent.action.SEND"
    const val ACTION_VIEW = "android.intent.action.VIEW"
    const val ACTION_VIEW_PWA = "mozilla.components.feature.pwa.VIEW_PWA"
    const val CATEGORY_PWA_SHORTCUT = "mozilla.components.pwa.category.SHORTCUT"
    const val SHORTCUT_TYPE_BASIC = PwaConstants.SHORTCUT_TYPE_BASIC

    fun classify(facts: LaunchFacts): LaunchDescriptor {
        if (facts.action == ACTION_SEND) {
            // A share without a URL is text, a file, or something only the Flutter
            // side knows what to do with; it goes to the browser like any other
            // regular launch.
            val shareUrl = facts.shareUrl
            return if (shareUrl != null && facts.customTabsEnabled) {
                LaunchDescriptor(
                    classification = LaunchClassification.SHARE_URL,
                    shareUrl = shareUrl,
                )
            } else {
                LaunchDescriptor(LaunchClassification.REGULAR)
            }
        }

        if (facts.pwaTrusted && facts.pwaProfileId != null) {
            // A basic pinned shortcut opens in the ordinary browser, so it needs no
            // components — but it still names a profile, and that has to be honoured
            // before the process settles on the candidate instead.
            return if (facts.shortcutType == SHORTCUT_TYPE_BASIC) {
                LaunchDescriptor(
                    classification = LaunchClassification.TRUSTED_SHORTCUT,
                    trustedProfileId = facts.pwaProfileId,
                )
            } else {
                LaunchDescriptor(
                    classification = LaunchClassification.TRUSTED_PWA,
                    trustedProfileId = facts.pwaProfileId,
                )
            }
        }

        if (facts.hasCustomTabSession) {
            // With the feature off there is no custom tab to open, so this is an
            // ordinary link and must not build an engine to discover that.
            return if (facts.customTabsEnabled) {
                LaunchDescriptor(LaunchClassification.CUSTOM_TAB)
            } else {
                LaunchDescriptor(LaunchClassification.REGULAR)
            }
        }

        val isLegacyPwa = facts.action == ACTION_VIEW_PWA ||
            facts.categories.contains(CATEGORY_PWA_SHORTCUT)
        if (isLegacyPwa) {
            return LaunchDescriptor(LaunchClassification.LEGACY_PWA)
        }

        return LaunchDescriptor(LaunchClassification.REGULAR)
    }
}
