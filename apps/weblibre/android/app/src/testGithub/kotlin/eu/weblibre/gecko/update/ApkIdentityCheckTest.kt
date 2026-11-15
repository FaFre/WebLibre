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

import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Before
import org.junit.Test
import java.io.File
import java.nio.file.Files

/**
 * Check 7 of plan 7.4 on its own, plus the checks that run before any
 * signature work. Full byte-level verification with signed fixture APKs is
 * gate G4 and Phase 4's fixture script.
 */
class ApkIdentityCheckTest {
    private val installed = InstalledIdentity(
        packageName = "eu.weblibre.gecko",
        versionCode = 423,
        signers = listOf(ProductionSigner.CERT_SHA256),
        distribution = BuildDistribution.GITHUB,
        track = BuildTrack.STABLE,
        renderer = BuildRenderer.SKIA,
        logicalReleaseSequence = 42,
        abi = "arm64-v8a",
        sdkInt = 34,
    )

    private val expected = ExpectedArtifact(
        sha256 = "c".repeat(64),
        byteLength = 4,
        versionCode = 433,
        logicalReleaseSequence = 43,
        distribution = BuildDistribution.GITHUB,
        track = BuildTrack.STABLE,
        renderer = BuildRenderer.SKIA,
        abi = "arm64-v8a",
        authorizedUntilEpochMs = Long.MAX_VALUE,
    )

    private fun manifest(
        renderer: BuildRenderer = BuildRenderer.SKIA,
        distribution: BuildDistribution = BuildDistribution.GITHUB,
        track: BuildTrack = BuildTrack.STABLE,
        sequence: Int = 43,
    ) = BuildManifest(
        packageId = "eu.weblibre.gecko",
        distribution = distribution,
        track = track,
        renderer = renderer,
        logicalReleaseSequence = sequence,
        versionName = "0.43.0",
        buildTimeEpochMs = 0,
        abiVersionCodes = mapOf("x86_64" to 431L, "armeabi-v7a" to 432L, "arm64-v8a" to 433L),
        components = BuildManifest.unknownComponents(),
    )

    @Test
    fun matchingIdentityPasses() {
        assertNull(ApkInspector.identityMismatch(manifest(), installed, expected))
    }

    @Test
    fun sameSignerVersionAndAbiButTheOtherRendererIsRefused() {
        // F5: Skia and Impeller share package, version code and signer; only
        // the embedded identity tells them apart.
        assertNotNull(ApkInspector.identityMismatch(manifest(renderer = BuildRenderer.IMPELLER), installed, expected))
    }

    @Test
    fun theOtherDistributionOrTrackIsRefused() {
        assertNotNull(ApkInspector.identityMismatch(manifest(distribution = BuildDistribution.PLAY), installed, expected))
        assertNotNull(ApkInspector.identityMismatch(manifest(track = BuildTrack.ALPHA), installed, expected))
    }

    @Test
    fun aSequenceNotAboveTheInstalledOneIsRefused() {
        assertNotNull(ApkInspector.identityMismatch(manifest(sequence = 42), installed, expected))
    }

    @Test
    fun aCandidateThatDiffersFromTheExpectedArtifactIsRefused() {
        // The channel lock holds even if Dart or the catalogue were wrong.
        val mislabeled = expected.copy(renderer = BuildRenderer.IMPELLER)
        assertNotNull(ApkInspector.identityMismatch(manifest(), installed, mislabeled))
        assertNotNull(ApkInspector.identityMismatch(manifest(sequence = 44), installed, expected))
    }

    private lateinit var dir: File

    @Before
    fun setUp() {
        dir = Files.createTempDirectory("inspector").toFile()
    }

    @After
    fun tearDown() {
        dir.deleteRecursively()
    }

    @Test
    fun wrongLengthOrDigestFailsBeforeAnySignatureWork() {
        val inspector = ApkInspector({ installed })
        val file = File(dir, "x.part").apply { writeBytes(byteArrayOf(1, 2, 3)) }
        val short = inspector.inspect(file, expected)
        assertFalse(short.verified)
        assertEquals(NativeFailure.DOWNLOAD_MISMATCH, short.failure)

        file.writeBytes(byteArrayOf(1, 2, 3, 4))
        val digest = inspector.inspect(file, expected)
        assertEquals(NativeFailure.DOWNLOAD_MISMATCH, digest.failure)

        assertEquals(NativeFailure.DOWNLOAD_MISMATCH, inspector.inspect(File(dir, "missing"), expected).failure)
    }

    @Test
    fun bytesWithTheRightDigestThatAreNotAnApkAreInvalid() {
        val bytes = byteArrayOf(1, 2, 3, 4)
        val file = File(dir, "x.part").apply { writeBytes(bytes) }
        val inspector = ApkInspector({ installed })
        val result = inspector.inspect(
            file,
            expected.copy(sha256 = ProductionSigner.sha256Hex(bytes)),
        )
        assertEquals(NativeFailure.APK_INVALID, result.failure)
    }
}
