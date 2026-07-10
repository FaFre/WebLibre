/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentActivity
import mozilla.components.support.base.feature.UserInteractionHandler

/**
 * Dispatches "the user is leaving the app" to the browser fragments so they can enter
 * picture-in-picture.
 *
 * Lives in this package because Mozilla Components is an `implementation` dependency, so
 * [UserInteractionHandler] is not on the app module's compile classpath.
 */
object HomePressDispatcher {
    /**
     * Returns true if a fragment handled the home press (i.e. entered picture-in-picture),
     * in which case the caller must not run the default `onUserLeaveHint` behaviour.
     */
    fun onUserLeaveHint(activity: FragmentActivity): Boolean {
        // Runtime permission prompts trigger onUserLeaveHint too. That is not the user
        // leaving, so it must not put a playing fullscreen video into picture-in-picture.
        if (GlobalComponents.components?.notificationsDelegate?.isRequestingPermission == true) {
            return false
        }

        return activity.supportFragmentManager.fragments.any(::dispatch)
    }

    private fun dispatch(fragment: Fragment): Boolean {
        // A hidden or paused fragment must not be able to grab picture-in-picture.
        if (!fragment.isResumed) {
            return false
        }

        if (fragment is UserInteractionHandler && fragment.onHomePressed()) {
            return true
        }

        return fragment.childFragmentManager.fragments.any(::dispatch)
    }
}
