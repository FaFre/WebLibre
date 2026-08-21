/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.services

import android.net.Uri
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsSessionToken
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.concept.engine.Engine
import mozilla.components.feature.customtabs.AbstractCustomTabsService
import mozilla.components.feature.customtabs.store.CustomTabsServiceStore
import mozilla.components.support.base.log.logger.Logger

/**
 * Custom Tabs entry point for other apps.
 *
 * Every request arrives on a binder thread from a process WebLibre does not
 * control, and any of them can be the first thing that touches this process. That
 * makes it one of the paths that can ask for components while the profile is
 * still being selected, or while maintenance owns the process — and there,
 * binding one is not allowed.
 *
 * Refusal is therefore a returned `false`, never a thrown exception. A throw here
 * crosses the binder as a dead-service error, which the client app reports as
 * WebLibre crashing; `false` is the documented way to say "not now", and clients
 * already handle it by opening the URL normally.
 */
class CustomTabsService : AbstractCustomTabsService() {

    override val customTabsServiceStore: CustomTabsServiceStore
        get() = requiredComponents().core.customTabsStore

    override val engine: Engine
        get() = requiredComponents().core.engine

    private fun requiredComponents() =
        requireNotNull(GlobalComponents.components) { "Components not initialized" }

    /**
     * Whether this process may serve a Custom Tabs client right now.
     *
     * Binding the candidate profile is legal from here: a Custom Tab has no
     * profile of its own to honour, so it runs in whichever profile the process
     * settles on. What is not legal is binding one while another owner is still
     * choosing, and that is exactly what the arbiter refuses.
     */
    private fun isServiceAvailable(): Boolean {
        if (GlobalComponents.components != null) return true

        return runCatching {
            GlobalComponents.bindCandidateAndEnsureExternalComponents(applicationContext)
            GlobalComponents.components != null
        }.getOrElse { error ->
            Logger.warn("Refusing a Custom Tabs request: no profile is available", error)
            false
        }
    }

    override fun warmup(flags: Long): Boolean =
        isServiceAvailable() && super.warmup(flags)

    override fun newSession(sessionToken: CustomTabsSessionToken): Boolean =
        isServiceAvailable() && super.newSession(sessionToken)

    override fun mayLaunchUrl(
        sessionToken: CustomTabsSessionToken,
        url: Uri?,
        extras: Bundle?,
        otherLikelyBundles: List<Bundle>?,
    ): Boolean =
        isServiceAvailable() &&
            super.mayLaunchUrl(sessionToken, url, extras, otherLikelyBundles)

    override fun validateRelationship(
        sessionToken: CustomTabsSessionToken,
        relation: Int,
        origin: Uri,
        extras: Bundle?,
    ): Boolean =
        isServiceAvailable() &&
            super.validateRelationship(sessionToken, relation, origin, extras)
}
