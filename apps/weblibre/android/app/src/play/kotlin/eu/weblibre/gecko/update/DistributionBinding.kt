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
package eu.weblibre.gecko.update

import android.app.Activity
import android.content.Context

/**
 * Play builds: Google Play's in-app update, flexible flow only (plan 8.7).
 * There is no installer, no install permission and no apksig here, and no
 * path from any Play state into the GitHub backend.
 */
object DistributionBinding {
    fun create(context: Context): DistributionOperations =
        PlayOperations(PlayUpdateClient(context.applicationContext))
}

private class PlayOperations(private val client: PlayUpdateClient) : DistributionOperations {
    override fun attachActivity(activity: Activity?) = client.attach(activity)

    override suspend fun playCheck(): PlayUpdateInfo = client.check()

    override suspend fun playStartFlexible(activity: Activity?) = client.startFlexible(activity)

    override suspend fun playCompleteFlexible() = client.completeFlexible()
}
