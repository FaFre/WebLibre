/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components

import io.flutter.plugin.common.BinaryMessenger
import java.nio.ByteBuffer

class NoopBinaryMessenger : BinaryMessenger {
    override fun send(channel: String, message: ByteBuffer?) {
        // No-op
    }

    override fun send(
        channel: String,
        message: ByteBuffer?,
        callback: BinaryMessenger.BinaryReply?
    ) {
        callback?.reply(null)
    }

    override fun setMessageHandler(
        channel: String,
        handler: BinaryMessenger.BinaryMessageHandler?
    ) {
        // No-op
    }
}
