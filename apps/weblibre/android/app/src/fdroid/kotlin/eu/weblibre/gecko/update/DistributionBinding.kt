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

import android.content.Context

/**
 * F-Droid builds carry no updater: F-Droid delivers updates itself, its
 * inclusion policy rules out a self-updater and its scanner rules out Play
 * libraries. Every operation answers "unsupported".
 */
object DistributionBinding {
    @Suppress("UNUSED_PARAMETER")
    fun create(context: Context): DistributionOperations =
        object : DistributionOperations {}
}
