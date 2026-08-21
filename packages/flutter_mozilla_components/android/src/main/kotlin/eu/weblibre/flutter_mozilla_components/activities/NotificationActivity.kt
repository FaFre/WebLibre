/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import eu.weblibre.flutter_mozilla_components.GlobalComponents

/**
 * Trampoline that exists only to give the notifications delegate an Activity.
 *
 * A notification outlives the process that posted it, so this can be started
 * long after that process died — and in the new one nothing is committed yet.
 * It cannot bind a profile to fix that: the tap says nothing about which profile
 * the notification belonged to. So it finishes, which is what it does on the
 * happy path too; the only loss is the delegate binding that had nothing to bind.
 */
class NotificationActivity: AppCompatActivity() {
    private val components get() = GlobalComponents.components

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        components?.notificationsDelegate?.bindToActivity(this)

        finish()
    }

    override fun onDestroy() {
        super.onDestroy()
        components?.notificationsDelegate?.unBindActivity(this)
    }
}