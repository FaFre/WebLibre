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

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertThrows
import org.junit.Test

class BuildManifestTest {
    private val sample = """
        {
          "schemaVersion": 1,
          "packageId": "eu.weblibre.gecko",
          "distribution": "github",
          "track": "stable",
          "renderer": "skia",
          "logicalReleaseSequence": 43,
          "versionName": "0.50.0",
          "buildTime": "2026-11-12T06:15:56Z",
          "abiVersionCodes": {"x86_64": 431, "armeabi-v7a": 432, "arm64-v8a": 433},
          "components": {
            "gecko": {"status": "known", "version": "160.0", "buildId": "20261124093000"},
            "applicationServices": {"status": "unknown"},
            "singbox": {"status": "known", "version": "1.14.4", "revision": "c005f353"}
          }
        }
    """.trimIndent()

    @Test
    fun parsesIdentityAndComponents() {
        val manifest = BuildManifest.parse(sample)
        assertEquals(BuildDistribution.GITHUB, manifest.distribution)
        assertEquals(43, manifest.logicalReleaseSequence)
        assertEquals("arm64-v8a", manifest.abiFor(433))
        assertNull(manifest.abiFor(43))
        val gecko = manifest.components.first { it.id == BuildComponent.GECKO }
        assertEquals("160.0", gecko.version)
        assertEquals("20261124093000", gecko.buildId)
        assertEquals(ComponentStatus.UNKNOWN, manifest.components.first { it.id == BuildComponent.APPLICATION_SERVICES }.status)
        // Absent from the manifest: unknown, never guessed.
        assertEquals(ComponentStatus.UNKNOWN, manifest.components.first { it.id == BuildComponent.TOR }.status)
        assertEquals(BuildComponent.entries, manifest.components.map { it.id })
    }

    @Test
    fun rejectsOtherSchemasAndIncompleteManifests() {
        assertThrows(Exception::class.java) {
            BuildManifest.parse(sample.replace("\"schemaVersion\": 1", "\"schemaVersion\": 2"))
        }
        assertThrows(Exception::class.java) {
            BuildManifest.parse(sample.replace("\"renderer\": \"skia\",", ""))
        }
        assertThrows(Exception::class.java) {
            BuildManifest.parse(sample.replace("\"renderer\": \"skia\"", "\"renderer\": \"vulkan\""))
        }
    }

    @Test
    fun wireSpellingsAreThePigeonDefinitions() {
        assertEquals("notBundled", ComponentStatus.NOT_BUNDLED.wire)
        assertEquals("androidComponents", BuildComponent.ANDROID_COMPONENTS.wire)
        assertEquals(InstallerPhase.ABANDON_REQUESTED, wireValue<InstallerPhase>("abandonRequested"))
        assertNull(wireValue<BuildRenderer>("vulkan"))
        assertNull(wireValue<BuildRenderer>(null))
    }
}
