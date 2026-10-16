/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.security

import mozilla.components.feature.sitepermissions.SitePermissionsRules
import mozilla.components.feature.sitepermissions.SitePermissionsRules.Action
import mozilla.components.feature.sitepermissions.SitePermissionsRules.AutoplayAction

/**
 * Decides what a site is allowed to ask for, before the prompt is shown.
 *
 * Titanium's approach is to move the secure choice into the default rather than
 * into the user's answer: the permissions that exist mostly to track or to
 * reach the local network are denied outright, while the ones a site needs to
 * function (camera, microphone, location, DRM) still prompt. The difference
 * from the stock rules is that a site which never prompts cannot silently
 * acquire the denied capability through a permission the user granted once.
 *
 * The rules object is built here rather than inline at the fragment so the
 * policy is a single, testable value instead of a literal spread across the
 * browser setup.
 */
object TitaniumPermissionGate {

    enum class Policy { Standard, Hardened }

    @Volatile
    private var policy: Policy = Policy.Hardened

    fun currentPolicy(): Policy = policy

    fun setPolicy(value: Policy) {
        policy = value
    }

    fun rules(): SitePermissionsRules = when (policy) {
        Policy.Standard -> standard()
        Policy.Hardened -> hardened()
    }

    /** Stock behaviour: every capability prompts. */
    private fun standard() = SitePermissionsRules(
        autoplayAudible = AutoplayAction.BLOCKED,
        autoplayInaudible = AutoplayAction.BLOCKED,
        camera = Action.ASK_TO_ALLOW,
        location = Action.ASK_TO_ALLOW,
        notification = Action.ASK_TO_ALLOW,
        microphone = Action.ASK_TO_ALLOW,
        persistentStorage = Action.ASK_TO_ALLOW,
        mediaKeySystemAccess = Action.ASK_TO_ALLOW,
        crossOriginStorageAccess = Action.ASK_TO_ALLOW,
        localDeviceAccess = Action.ASK_TO_ALLOW,
        localNetworkAccess = Action.ASK_TO_ALLOW,
    )

    /**
     * Hardened: deny the capabilities whose main purpose is tracking or local
     * network reach; keep prompting for the ones a site legitimately needs.
     *
     * - notification is a re-engagement/tracking channel and is denied.
     * - localDeviceAccess and localNetworkAccess expose nearby devices and the
     *   LAN; there is no browsing use case that needs them without a prompt the
     *   user can reason about, so they are denied.
     * - camera, microphone, location, DRM and third-party storage still prompt:
     *   denying them outright would break sites the user deliberately visits.
     */
    private fun hardened() = SitePermissionsRules(
        autoplayAudible = AutoplayAction.BLOCKED,
        autoplayInaudible = AutoplayAction.BLOCKED,
        camera = Action.ASK_TO_ALLOW,
        location = Action.ASK_TO_ALLOW,
        notification = Action.BLOCKED,
        microphone = Action.ASK_TO_ALLOW,
        persistentStorage = Action.ASK_TO_ALLOW,
        mediaKeySystemAccess = Action.ASK_TO_ALLOW,
        crossOriginStorageAccess = Action.ASK_TO_ALLOW,
        localDeviceAccess = Action.BLOCKED,
        localNetworkAccess = Action.BLOCKED,
    )
}
