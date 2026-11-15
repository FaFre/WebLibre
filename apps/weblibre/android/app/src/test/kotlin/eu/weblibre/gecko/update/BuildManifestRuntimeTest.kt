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

import eu.weblibre.gecko.update.BuildManifestRuntimeCheck.Reported
import java.io.File
import java.util.zip.ZipEntry
import java.util.zip.ZipFile
import java.util.zip.ZipOutputStream
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Rule
import org.junit.Test
import org.junit.rules.TemporaryFolder

/** Plan 4.2 (manifest against runtime) and 7.1 step 4 (installed ABI). */
class BuildManifestRuntimeTest {
    @get:Rule
    val temp = TemporaryFolder()

    private val manifest = BuildManifest.parse(
        """
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
            "gecko": {"status": "known", "version": "159.0", "buildId": "20261030161337"},
            "androidComponents": {"status": "known", "version": "159.0"},
            "lyrebird": {"status": "unknown"},
            "singbox": {"status": "known", "version": "1.14.4", "revision": "c005f353"}
          }
        }
        """.trimIndent(),
    )

    @Test
    fun agreeingLibrariesAreNoMismatch() {
        val reported = mapOf(
            BuildComponent.GECKO to Reported("159.0", "20261030161337"),
            BuildComponent.ANDROID_COMPONENTS to Reported("159.0"),
            BuildComponent.SINGBOX to Reported("1.14.4"),
        )
        assertEquals(emptyList<String>(), BuildManifestRuntimeCheck.mismatches(manifest, reported))
    }

    @Test
    fun aDifferentVersionOrBuildIdIsReported() {
        val reported = mapOf(
            BuildComponent.GECKO to Reported("159.0", "20261031000000"),
            BuildComponent.SINGBOX to Reported("1.14.3"),
        )
        val wrong = BuildManifestRuntimeCheck.mismatches(manifest, reported)
        assertEquals(2, wrong.size)
        assertTrue(wrong[0], wrong[0].startsWith("gecko:"))
        assertTrue(wrong[1], wrong[1].contains("1.14.3"))
    }

    @Test
    fun whatNeitherSideClaimsIsNotCompared() {
        // Lyrebird is unknown in the manifest; Tor is reported by nothing.
        val reported = mapOf(BuildComponent.LYREBIRD to Reported("0.6.1"))
        assertEquals(emptyList<String>(), BuildManifestRuntimeCheck.mismatches(manifest, reported))
    }

    /**
     * The manifest Gradle wrote for this variant against the libraries on the
     * test classpath. Gradle passes its path; outside Gradle there is none.
     */
    @Test
    fun theGeneratedManifestMatchesTheLibrariesOnTheClasspath() {
        val path = System.getProperty("weblibre.buildManifest")
        assumeTrue("run through Gradle", path != null)
        val generated = BuildManifest.parse(File(path!!).readText())
        val reported = BuildManifestRuntimeCheck.jvmReported()
        // Otherwise the comparison below would pass by comparing nothing.
        assertEquals(
            setOf(BuildComponent.GECKO, BuildComponent.ANDROID_COMPONENTS, BuildComponent.APPLICATION_SERVICES),
            reported.keys,
        )
        assertEquals(emptyList<String>(), BuildManifestRuntimeCheck.mismatches(generated, reported))
    }

    @Test
    fun nativeAbisAreTheLibDirectories() {
        val apk = zip("lib/arm64-v8a/libgecko.so", "lib/arm64-v8a/libflutter.so", "lib/README", "assets/lib/x86/a.so")
        assertEquals(setOf("arm64-v8a"), ZipFile(apk).use(ApkNativeAbis::of))
    }

    @Test
    fun theInstalledAbiNeedsTheManifestAndTheLibrariesToAgree() {
        assertEquals("arm64-v8a", ApkNativeAbis.crossChecked("arm64-v8a", setOf("arm64-v8a")))
        assertNull(ApkNativeAbis.crossChecked("arm64-v8a", setOf("x86_64")))
        // A universal APK is no single ABI.
        assertNull(ApkNativeAbis.crossChecked("arm64-v8a", setOf("arm64-v8a", "armeabi-v7a")))
        assertNull(ApkNativeAbis.crossChecked("arm64-v8a", emptySet()))
        assertNull(ApkNativeAbis.crossChecked(null, setOf("arm64-v8a")))
    }

    private fun zip(vararg entries: String): File {
        val file = temp.newFile("test.apk")
        ZipOutputStream(file.outputStream()).use { out ->
            for (name in entries) {
                out.putNextEntry(ZipEntry(name))
                out.write(1)
                out.closeEntry()
            }
        }
        return file
    }
}
