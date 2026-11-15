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

import com.android.apksig.ApkVerifier
import com.android.apksig.apk.ApkUtils
import com.android.apksig.util.DataSources
import java.io.File
import java.io.RandomAccessFile
import java.security.MessageDigest
import java.util.zip.ZipFile

/** The installed build, as native code knows it. Never from Dart. */
data class InstalledIdentity(
    val packageName: String,
    val versionCode: Long,
    val signers: List<String>,
    val distribution: BuildDistribution?,
    val track: BuildTrack?,
    val renderer: BuildRenderer?,
    val logicalReleaseSequence: Int,
    val abi: String?,
    val sdkInt: Int,
)

/**
 * Byte-level verification of a staged APK (plan 7.4). Runs on the `.part`
 * file before it is promoted and again on the `.apk` right before a session is
 * created. In order, first failure wins.
 */
class ApkInspector(
    private val installed: () -> InstalledIdentity,
    private val productionSigner: String = ProductionSigner.CERT_SHA256,
) {
    /**
     * [checkDigest] false skips hashing the file, for a caller that hashes
     * the same bytes while it copies them and rejects a mismatch itself.
     */
    fun inspect(file: File, expected: ExpectedArtifact, checkDigest: Boolean = true): ApkVerificationResult {
        if (!file.isFile) return fail(NativeFailure.DOWNLOAD_MISMATCH, "missing")

        // 1. The bytes are the authenticated ones.
        if (file.length() != expected.byteLength) {
            return fail(NativeFailure.DOWNLOAD_MISMATCH, "length ${file.length()} != ${expected.byteLength}")
        }
        if (checkDigest) {
            val digest = sha256(file)
            if (digest != expected.sha256) return fail(NativeFailure.DOWNLOAD_MISMATCH, "sha256 $digest")
        }

        val identity = installed()

        return try {
            RandomAccessFile(file, "r").use { raf ->
                val source = DataSources.asDataSource(raf)

                // 2. apksig accepts the signatures for every platform from the
                // APK's own minSdk to this device.
                val result = ApkVerifier.Builder(source)
                    .setMaxCheckedPlatformVersion(identity.sdkInt)
                    .build()
                    .verify()
                if (!result.isVerified) {
                    return fail(NativeFailure.APK_INVALID, result.allErrors.take(3).joinToString { it.toString() })
                }

                // 3. Exactly the production certificate, and exactly the
                // installed app's current signer. No lineage in v1 (5.4).
                val signers = result.signerCertificates.map { ProductionSigner.sha256Hex(it.encoded) }
                if (signers != listOf(productionSigner) || identity.signers != signers) {
                    return fail(NativeFailure.SIGNER_UNTRUSTED, signers.joinToString())
                }

                val manifest = ApkUtils.getAndroidManifest(source)

                // 4. Our package.
                val packageName = ApkUtils.getPackageNameFromBinaryAndroidManifest(manifest.duplicate())
                if (packageName != identity.packageName) {
                    return fail(NativeFailure.APK_IDENTITY_MISMATCH, "package $packageName")
                }

                // 5. The expected version code, and newer than what is
                // installed now (read now, not at check time).
                val versionCode = ApkUtils.getLongVersionCodeFromBinaryAndroidManifest(manifest.duplicate())
                if (versionCode != expected.versionCode || versionCode <= identity.versionCode) {
                    return fail(NativeFailure.APK_IDENTITY_MISMATCH, "versionCode $versionCode")
                }
            }

            ZipFile(file).use { zip ->
                // 6. Native libraries for exactly the installed ABI.
                val abis = ApkNativeAbis.of(zip)
                if (identity.abi == null || abis != setOf(identity.abi) || expected.abi != identity.abi) {
                    return fail(NativeFailure.APK_IDENTITY_MISMATCH, "abis $abis")
                }

                // 7. The embedded build identity, against the installed build
                // (the channel lock) and against the expected artifact.
                val entry = zip.getEntry(BuildManifest.APK_ENTRY)
                    ?: return fail(NativeFailure.APK_IDENTITY_MISMATCH, "no build manifest")
                if (entry.size > BuildManifest.MAX_BYTES) return fail(NativeFailure.APK_IDENTITY_MISMATCH, "manifest size")
                val candidate = zip.getInputStream(entry).use {
                    BuildManifest.parse(it.readBytes().decodeToString())
                }
                identityMismatch(candidate, identity, expected)?.let { return fail(NativeFailure.APK_IDENTITY_MISMATCH, it) }
            }

            ApkVerificationResult(verified = true)
        } catch (e: Exception) {
            fail(NativeFailure.APK_INVALID, e.toString())
        }
    }

    private fun fail(kind: NativeFailure, detail: String) =
        ApkVerificationResult(verified = false, failure = kind, detail = detail)

    companion object {
        fun sha256(file: File): String {
            val md = MessageDigest.getInstance("SHA-256")
            file.inputStream().use { input ->
                val buffer = ByteArray(1 shl 16)
                while (true) {
                    val read = input.read(buffer)
                    if (read < 0) break
                    md.update(buffer, 0, read)
                }
            }
            return md.digest().toHexString()
        }

        /** Check 7 on its own, so it can be tested without a signed APK. */
        fun identityMismatch(
            candidate: BuildManifest,
            installed: InstalledIdentity,
            expected: ExpectedArtifact,
        ): String? {
            if (candidate.distribution != installed.distribution ||
                candidate.track != installed.track ||
                candidate.renderer != installed.renderer
            ) {
                return "installed ${installed.distribution}/${installed.track}/${installed.renderer}, " +
                    "candidate ${candidate.distribution}/${candidate.track}/${candidate.renderer}"
            }
            if (candidate.logicalReleaseSequence <= installed.logicalReleaseSequence) {
                return "sequence ${candidate.logicalReleaseSequence} <= ${installed.logicalReleaseSequence}"
            }
            if (candidate.distribution != expected.distribution ||
                candidate.track != expected.track ||
                candidate.renderer != expected.renderer ||
                candidate.logicalReleaseSequence.toLong() != expected.logicalReleaseSequence ||
                candidate.abiFor(expected.versionCode) != expected.abi
            ) {
                return "candidate does not match the expected artifact"
            }
            return null
        }
    }
}
