/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.ext

import android.graphics.Bitmap
import android.os.Build
import java.io.ByteArrayOutputStream

fun Bitmap.resize(maxWidth: Int, maxHeight: Int): Bitmap {
    var width = this.width
    var height = this.height

    val aspectRatio: Float = width.toFloat() / height.toFloat()

    if (width > height) {
        width = maxWidth
        height = (width / aspectRatio).toInt()
    } else {
        height = maxHeight
        width = (height * aspectRatio).toInt()
    }

    return Bitmap.createScaledBitmap(this, width, height, true)
}

/**
 * For [Bitmap.CompressFormat.WEBP_LOSSLESS] the quality argument is not a
 * quality at all but the encoder's effort, and 100 is its slowest setting.
 * Encoding a 1080x2400 page-like image with libwebp on a desktop, 75 took 1.7
 * to 6 times less time than 100 (depending on the encoder method) for a file
 * at most 9% larger — and lossless means the pixels are identical either way.
 */
private const val LOSSLESS_EFFORT = 75

fun Bitmap.toWebPBytes(): ByteArray {
    val stream = ByteArrayOutputStream()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
        compress(Bitmap.CompressFormat.WEBP_LOSSLESS, LOSSLESS_EFFORT, stream)
    } else {
        @Suppress("DEPRECATION")
        compress(Bitmap.CompressFormat.WEBP, 100, stream)
    }
    return stream.toByteArray()
}

fun Bitmap.toPngBytes(): ByteArray {
    val stream = ByteArrayOutputStream()
    // PNG ignores the quality argument.
    compress(Bitmap.CompressFormat.PNG, 100, stream)
    return stream.toByteArray()
}
