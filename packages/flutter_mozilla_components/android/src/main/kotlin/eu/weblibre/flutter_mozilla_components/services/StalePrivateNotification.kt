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
package eu.weblibre.flutter_mozilla_components.services

import android.app.NotificationManager
import android.content.Context
import android.util.Log
import mozilla.components.support.base.ids.SharedIdsHelper

/**
 * Clears a private-browsing notification left behind by a dead process.
 *
 * [PrivateTabsNotificationService] cannot defend its own cold dispatch:
 * `AbstractPrivateNotificationService` declares `onCreate` and `onStartCommand`
 * `final` and touches `store` synchronously, so components are resolved — and
 * throw — before any hook the subclass owns can run. Tapping the notification's
 * erase action after a process death therefore crashes rather than doing nothing.
 *
 * This is the half of the fix that needs no patch to Android Components. Private
 * tabs do not survive the process, so a private-browsing notification visible at
 * the start of a *new* process is always about tabs that no longer exist: it
 * describes nothing, and its only action is the one that crashes. Removing it
 * closes the window rather than handling what arrives through it.
 *
 * The two halves are independent on purpose. [PrivateTabsNotificationService] no
 * longer crashes on a cold dispatch — with no profile committed it resolves an
 * empty store, which is the truthful answer, and the base class stops it. This
 * removes the reason to dispatch it at all: a notification describing tabs that
 * no longer exist should not be sitting on the user's shade in the first place.
 */
object StalePrivateNotification {
    private const val TAG = "StalePrivateNotification"

    /**
     * Mirrors `AbstractPrivateNotificationService.NOTIFICATION_TAG`, which is
     * private. The service posts by id alone — [SharedIdsHelper] derives that id
     * from this tag — so reproducing the string is the only way to name the same
     * notification. If the upstream tag ever changes this stops matching and
     * falls back to today's behaviour rather than cancelling something else.
     */
    private const val NOTIFICATION_TAG =
        "mozilla.components.feature.privatemode.notification.AbstractPrivateNotificationService"

    /**
     * Call once per process, before anything can commit a profile.
     *
     * Deliberately tolerant: this runs on the startup path and a notification that
     * will not clear is not a reason to fail a launch.
     */
    fun clear(context: Context) {
        runCatching {
            val manager = context.getSystemService(NotificationManager::class.java) ?: return
            manager.cancel(SharedIdsHelper.getIdForTag(context, NOTIFICATION_TAG))
        }.onFailure { error ->
            Log.w(TAG, "Could not clear a stale private browsing notification", error)
        }
    }
}
