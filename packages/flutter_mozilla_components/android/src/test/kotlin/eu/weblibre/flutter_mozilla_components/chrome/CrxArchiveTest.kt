/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.chrome

import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * The CRX header is the only thing between a downloaded extension and a ZIP
 * reader, and it is the part an attacker controls first. These tests pin the
 * offsets for both header shapes and, more importantly, that a header claiming
 * an impossible length is rejected rather than turned into a slice.
 */
class CrxArchiveTest {

    /** A stand-in archive: CrxArchive only ever inspects the four magic bytes. */
    private val zip = byteArrayOf(0x50, 0x4B, 0x03, 0x04, 1, 2, 3, 4, 5, 6, 7, 8)

    // -------------------------------------------------------------------------
    // Detection
    // -------------------------------------------------------------------------

    @Test
    fun `isCrx recognises the magic`() {
        assertTrue(CrxArchive.isCrx(CrxArchive.wrapAsCrx3(zip)))
        assertFalse(CrxArchive.isCrx(zip))
    }

    @Test
    fun `isZip recognises the local file header`() {
        assertTrue(CrxArchive.isZip(zip))
        assertFalse(CrxArchive.isZip(CrxArchive.wrapAsCrx3(zip)))
    }

    // -------------------------------------------------------------------------
    // Happy paths
    // -------------------------------------------------------------------------

    @Test
    fun `a plain zip is returned untouched`() {
        val result = CrxArchive.open(zip)
        assertTrue(result is CrxArchive.Result.Zip)
        assertArrayEquals(zip, (result as CrxArchive.Result.Zip).bytes)
    }

    @Test
    fun `a CRX2 header is skipped`() {
        val publicKey = ByteArray(32) { it.toByte() }
        val signature = ByteArray(64) { (it * 2).toByte() }
        val bytes = CrxArchive.wrapAsCrx2(zip, publicKey, signature)

        val result = CrxArchive.open(bytes)
        assertTrue("expected Zip, got $result", result is CrxArchive.Result.Zip)
        assertArrayEquals(zip, (result as CrxArchive.Result.Zip).bytes)
    }

    @Test
    fun `a CRX3 header is skipped`() {
        val header = ByteArray(128) { 0x42 }
        val bytes = CrxArchive.wrapAsCrx3(zip, header)

        val result = CrxArchive.open(bytes)
        assertTrue("expected Zip, got $result", result is CrxArchive.Result.Zip)
        assertArrayEquals(zip, (result as CrxArchive.Result.Zip).bytes)
    }

    @Test
    fun `a CRX2 header with empty key and signature is skipped`() {
        val bytes = CrxArchive.wrapAsCrx2(zip, ByteArray(0), ByteArray(0))
        val result = CrxArchive.open(bytes)
        assertTrue(result is CrxArchive.Result.Zip)
        assertArrayEquals(zip, (result as CrxArchive.Result.Zip).bytes)
    }

    // -------------------------------------------------------------------------
    // Rejections
    // -------------------------------------------------------------------------

    @Test
    fun `an empty file is rejected`() {
        val result = CrxArchive.open(ByteArray(0))
        assertTrue(result is CrxArchive.Result.Malformed)
    }

    @Test
    fun `bytes with neither magic are rejected`() {
        val result = CrxArchive.open("not an extension at all".toByteArray())
        assertTrue(result is CrxArchive.Result.Malformed)
        assertTrue((result as CrxArchive.Result.Malformed).reason.contains("unexpected magic"))
    }

    @Test
    fun `a truncated CRX header is rejected`() {
        val bytes = byteArrayOf('C'.code.toByte(), 'r'.code.toByte(), '2'.code.toByte(), '4'.code.toByte(), 3, 0)
        val result = CrxArchive.open(bytes)
        assertTrue(result is CrxArchive.Result.Malformed)
    }

    @Test
    fun `an unsupported CRX version is rejected`() {
        val bytes = byteArrayOf('C'.code.toByte(), 'r'.code.toByte(), '2'.code.toByte(), '4'.code.toByte(), 9, 0, 0, 0, 0, 0, 0, 0)
        val result = CrxArchive.open(bytes)
        assertTrue(result is CrxArchive.Result.Malformed)
        assertTrue((result as CrxArchive.Result.Malformed).reason.contains("version 9"))
    }

    @Test
    fun `a header naming more bytes than the file has is rejected`() {
        // 16 + key + signature runs past the end of the file.
        val bytes = CrxArchive.wrapAsCrx2(zip, ByteArray(4), ByteArray(4))
        val truncated = bytes.copyOfRange(0, 20) // keeps the header, loses most of the payload

        val result = CrxArchive.open(truncated)
        assertTrue("expected Malformed, got $result", result is CrxArchive.Result.Malformed)
    }

    @Test
    fun `a CRX2 length that would overflow an Int is rejected rather than wrapped`() {
        // keyLength = 0xFFFFFFFF, signatureLength = 0xFFFFFFFF. Added as Ints
        // this wraps to a small positive offset and would slice into the
        // middle of the buffer; added as Longs it is far past the end.
        val bytes = byteArrayOf(
            'C'.code.toByte(), 'r'.code.toByte(), '2'.code.toByte(), '4'.code.toByte(),
            2, 0, 0, 0,
            -1, -1, -1, -1,
            -1, -1, -1, -1,
        ) + zip

        val result = CrxArchive.open(bytes)
        assertTrue("expected Malformed, got $result", result is CrxArchive.Result.Malformed)
    }

    @Test
    fun `a payload that is not a zip is rejected`() {
        val bytes = CrxArchive.wrapAsCrx3("garbage following the header".toByteArray())
        val result = CrxArchive.open(bytes)
        assertTrue(result is CrxArchive.Result.Malformed)
        assertTrue((result as CrxArchive.Result.Malformed).reason.contains("ZIP header"))
    }

    // -------------------------------------------------------------------------
    // Round trip
    // -------------------------------------------------------------------------

    @Test
    fun `wrapping and reopening preserves the payload for both versions`() {
        for (bytes in listOf(CrxArchive.wrapAsCrx2(zip), CrxArchive.wrapAsCrx3(zip))) {
            val result = CrxArchive.open(bytes)
            assertTrue(result is CrxArchive.Result.Zip)
            assertEquals(zip.size, (result as CrxArchive.Result.Zip).bytes.size)
            assertArrayEquals(zip, result.bytes)
        }
    }
}
