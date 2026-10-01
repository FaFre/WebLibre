/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import java.io.ByteArrayOutputStream

/**
 * Locates the ZIP payload inside a Chrome extension package.
 *
 * A `.crx` is a ZIP with a header in front of it. There are two shapes:
 *
 * - CRX2: `Cr24`, a little-endian version `2`, a little-endian public-key
 *   length, a little-endian signature length, then the key, the signature, and
 *   the ZIP.
 * - CRX3: `Cr24`, a little-endian version `3`, a little-endian header length,
 *   then that many bytes of protobuf header, then the ZIP.
 *
 * Neither header needs to be understood to get at the archive — only its
 * length does — so this returns the ZIP bytes and leaves the signature
 * unverified. That is deliberate: the signature proves the package came from
 * the Chrome Web Store, which is a claim this app has no key material to check
 * anyway. What matters here is that the payload is a ZIP the normal archive
 * reader can open.
 *
 * A bare ZIP is also accepted, so an unpacked-then-rezipped extension works
 * without a round trip through Chrome.
 */
object CrxArchive {

    private val MAGIC = byteArrayOf('C'.code.toByte(), 'r'.code.toByte(), '2'.code.toByte(), '4'.code.toByte())
    private val ZIP_LOCAL_HEADER = byteArrayOf(0x50, 0x4B, 0x03, 0x04) // "PK\u0003\u0004"

    sealed interface Result {
        /** The bytes are a usable ZIP. */
        data class Zip(val bytes: ByteArray) : Result

        /** The bytes are not a CRX or a ZIP, or are truncated. */
        data class Malformed(val reason: String) : Result
    }

    /** True when the bytes start with the CRX magic rather than a ZIP header. */
    fun isCrx(bytes: ByteArray): Boolean = startsWith(bytes, MAGIC)

    /** True when the bytes start with a ZIP local file header. */
    fun isZip(bytes: ByteArray): Boolean = startsWith(bytes, ZIP_LOCAL_HEADER)

    /**
     * Return the ZIP payload of [bytes], whether they are a CRX or a plain ZIP.
     */
    fun open(bytes: ByteArray): Result {
        if (isZip(bytes)) return Result.Zip(bytes)
        if (!isCrx(bytes)) {
            return Result.Malformed("not a CRX or ZIP: unexpected magic")
        }
        if (bytes.size < 12) {
            return Result.Malformed("truncated CRX header")
        }

        val version = readUInt32(bytes, 4)
        val zipOffset = when (version) {
            2L -> {
                if (bytes.size < 16) return Result.Malformed("truncated CRX2 header")
                val keyLength = readUInt32(bytes, 8)
                val signatureLength = readUInt32(bytes, 12)
                // Checked as Longs before adding: a hostile header can name
                // lengths that overflow an Int and land back at a small offset.
                16L + keyLength + signatureLength
            }

            3L -> {
                val headerLength = readUInt32(bytes, 8)
                12L + headerLength
            }

            else -> return Result.Malformed("unsupported CRX version $version")
        }

        if (zipOffset >= bytes.size) {
            return Result.Malformed("CRX header claims ${zipOffset} bytes but the file is ${bytes.size}")
        }

        val payload = bytes.copyOfRange(zipOffset.toInt(), bytes.size)
        if (!isZip(payload)) {
            return Result.Malformed("CRX payload does not start with a ZIP header")
        }
        return Result.Zip(payload)
    }

    private fun startsWith(bytes: ByteArray, prefix: ByteArray): Boolean {
        if (bytes.size < prefix.size) return false
        for (i in prefix.indices) {
            if (bytes[i] != prefix[i]) return false
        }
        return true
    }

    /** Little-endian unsigned 32-bit read, widened so callers cannot overflow. */
    private fun readUInt32(bytes: ByteArray, offset: Int): Long {
        return (bytes[offset].toLong() and 0xFF) or
            ((bytes[offset + 1].toLong() and 0xFF) shl 8) or
            ((bytes[offset + 2].toLong() and 0xFF) shl 16) or
            ((bytes[offset + 3].toLong() and 0xFF) shl 24)
    }

    /** Build a CRX2 container around [zip], for tests and for round-tripping. */
    fun wrapAsCrx2(zip: ByteArray, publicKey: ByteArray = ByteArray(8), signature: ByteArray = ByteArray(8)): ByteArray {
        val out = ByteArrayOutputStream()
        out.write(MAGIC)
        out.write(uint32(2))
        out.write(uint32(publicKey.size.toLong()))
        out.write(uint32(signature.size.toLong()))
        out.write(publicKey)
        out.write(signature)
        out.write(zip)
        return out.toByteArray()
    }

    /** Build a CRX3 container around [zip]. */
    fun wrapAsCrx3(zip: ByteArray, header: ByteArray = ByteArray(4)): ByteArray {
        val out = ByteArrayOutputStream()
        out.write(MAGIC)
        out.write(uint32(3))
        out.write(uint32(header.size.toLong()))
        out.write(header)
        out.write(zip)
        return out.toByteArray()
    }

    private fun uint32(value: Long): ByteArray = byteArrayOf(
        (value and 0xFF).toByte(),
        ((value shr 8) and 0xFF).toByte(),
        ((value shr 16) and 0xFF).toByte(),
        ((value shr 24) and 0xFF).toByte(),
    )
}
