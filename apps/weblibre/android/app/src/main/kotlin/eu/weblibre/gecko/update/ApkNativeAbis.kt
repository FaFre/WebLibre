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
import java.util.zip.ZipFile

/**
 * The ABIs an APK carries native libraries for: its `lib/<abi>/` directories.
 * One reading for a candidate APK ([ApkInspector] check 6) and for the
 * installed app (plan 7.1 step 4).
 */
object ApkNativeAbis {
    fun of(zip: ZipFile): Set<String> = zip.entries().asSequence()
        .map { it.name }
        .filter { it.startsWith("lib/") && it.count { c -> c == '/' } >= 2 }
        .map { it.split('/')[1] }
        .toSet()

    /** The installed app's own, across its base and split APKs. */
    fun installed(context: Context): Set<String> {
        val info = context.applicationInfo
        val paths = listOfNotNull(info.sourceDir) + info.splitSourceDirs.orEmpty()
        return paths.flatMapTo(mutableSetOf()) { path -> ZipFile(path).use(::of) }
    }

    /**
     * [declared], the build manifest's ABI for the installed version code,
     * only when the installed APK's native libraries are exactly that ABI. A
     * disagreement (a repackaged or universal APK, a manifest that drifted)
     * is unknown, so no update is selected for it.
     */
    fun crossChecked(declared: String?, packaged: Set<String>): String? =
        declared?.takeIf { packaged == setOf(it) }
}
