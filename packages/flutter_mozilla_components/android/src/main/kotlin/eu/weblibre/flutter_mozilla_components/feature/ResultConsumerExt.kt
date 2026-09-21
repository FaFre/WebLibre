/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import kotlinx.coroutines.suspendCancellableCoroutine
import org.json.JSONObject
import kotlin.coroutines.resumeWithException

/**
 * Runs a [ResultConsumer]-based extension request as a suspend call.
 *
 * [schedule] receives the consumer to hand to the feature's `scheduleRequest`. The call resumes
 * with [transform] applied to the reply, or fails with the error the extension reported.
 */
suspend fun <T> awaitResult(
    schedule: (ResultConsumer<JSONObject>) -> Unit,
    transform: (JSONObject) -> T,
): T = suspendCancellableCoroutine { continuation ->
    schedule(object : ResultConsumer<JSONObject> {
        override fun success(result: JSONObject) {
            continuation.resumeWith(runCatching { transform(result) })
        }

        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            continuation.resumeWithException(Exception("$errorCode $errorMessage $errorDetails"))
        }
    })
}
