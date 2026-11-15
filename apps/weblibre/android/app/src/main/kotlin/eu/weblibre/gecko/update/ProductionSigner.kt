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
import android.content.pm.PackageManager
import android.content.pm.Signature
import android.os.Build
import java.security.MessageDigest

/**
 * The APK signing certificate of GitHub and Google Play releases (plan 5.4).
 *
 * The README publishes the same fingerprint. v1 accepts an exact match only:
 * no lineage, no shared ancestor. Remote metadata never names a signer, and
 * nothing at runtime can change this value.
 */
object ProductionSigner {
    /** SHA-256 of the certificate, lower-case hex, no separators. */
    const val CERT_SHA256 =
        "8f526e1e53d6bd4dfbf4f4b93c2a91ecb5cb8da5e14ad94c2570e1e3c713527f"

    fun sha256Hex(bytes: ByteArray): String =
        MessageDigest.getInstance("SHA-256").digest(bytes).toHexString()

    /** The installed app's *current* signing certificates. */
    @Suppress("DEPRECATION")
    fun installedSigners(context: Context): List<String> {
        val pm = context.packageManager
        val signatures: Array<Signature> = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val info = pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNING_CERTIFICATES)
            val signing = info.signingInfo ?: return emptyList()
            if (signing.hasMultipleSigners()) signing.apkContentsSigners else signing.signingCertificateHistory.takeLast(1).toTypedArray()
        } else {
            pm.getPackageInfo(context.packageName, PackageManager.GET_SIGNATURES).signatures ?: emptyArray()
        }
        return signatures.map { sha256Hex(it.toByteArray()) }
    }

    /** Exactly one signer, and it is the production certificate. */
    fun isTrusted(signers: List<String>): Boolean = signers == listOf(CERT_SHA256)
}
