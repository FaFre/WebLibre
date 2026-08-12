/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.ContainerSiteAssignment
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import java.util.concurrent.atomic.AtomicLong
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import mozilla.components.concept.engine.webextension.MessageHandler
import mozilla.components.concept.engine.webextension.Port
import mozilla.components.concept.engine.webextension.WebExtensionRuntime
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.android.org.json.tryGetString
import mozilla.components.support.webextensions.BuiltInWebExtensionController
import org.json.JSONObject
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread

object ContainerProxyFeature {
    private val logger = Logger("container_proxy")

    private const val CONTAINER_PROXY_REPORTER_EXTENSION_ID = "container-proxy@weblibre.eu"
    private const val CONTAINER_PROXY_REPORTER_EXTENSION_URL =
        "resource://android/assets/extensions/container_proxy/"
    private const val CONTAINER_PROXY_REPORTER_MESSAGING_ID = "containerProxy"

    /**
     * How long a request may wait for a reply before it is failed and dropped.
     *
     * Every registered handler is answered by the extension or removed by a port
     * disconnect — except one whose reply is silently lost, which would sit in
     * [requestHandlers] for the life of the process. Comfortably above the app's
     * own timeouts, so this only ever fires as a backstop.
     */
    @VisibleForTesting
    internal var requestTimeoutMs = 60_000L

    private var nextRequestId: Int = 0
    private val requestHandlers = HashMap<Int, PendingRequest>()
    private val mutex = Mutex()

    private val replayScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    /**
     * Id of the extension's current native port connection.
     *
     * Bumped on every connect and disconnect, from the callbacks themselves —
     * which Gecko delivers in order — so it, and not the order in which their
     * coroutines happen to run, decides what is current. Without it a disconnect
     * that lands after the following connect wipes the state that connect just
     * established, and routing reports itself unready for the rest of the
     * session while the extension is in fact configured.
     */
    private val connectionEpoch = AtomicLong(0)

    /** A request waiting for a reply, tagged with the connection that carries it. */
    private class PendingRequest(
        val epoch: Long,
        val consumer: ResultConsumer<JSONObject>,
    )

    /** A snapshot the extension confirmed, and the connection it confirmed it on. */
    private class Acknowledgement(val generation: Long, val epoch: Long)

    /**
     * Last routing snapshot pushed from the app, kept so it can be replayed
     * when the extension's background script restarts.
     *
     * Without this, a restarted background script comes up with an empty store
     * while the app still believes its routing is installed — and an empty
     * store is what makes every request go direct.
     */
    @Volatile
    private var lastSnapshot: JSONObject? = null

    /**
     * Generation of [lastSnapshot]. Read and written only under [mutex], so a
     * replay can never observe a snapshot and a generation from different
     * pushes.
     */
    @Volatile
    private var lastSnapshotGeneration: Long? = null

    /**
     * What the extension has confirmed applying, or null when nothing is
     * confirmed. Reset on every port connect, because a reconnect means a fresh
     * background script that has lost whatever it was told before.
     */
    @Volatile
    private var acknowledged: Acknowledgement? = null

    fun acknowledgedSnapshotGeneration(): Long? = acknowledged?.generation

    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    @VisibleForTesting
    // This is an internal var to make it mutable for unit testing purposes only
    internal var extensionController = BuiltInWebExtensionController(
        CONTAINER_PROXY_REPORTER_EXTENSION_ID,
        CONTAINER_PROXY_REPORTER_EXTENSION_URL,
        CONTAINER_PROXY_REPORTER_MESSAGING_ID,
    )

    /**
     * How a message reaches the extension. Replaceable so tests can observe what
     * is sent without mocking Mozilla's (final) controller class.
     */
    @VisibleForTesting
    internal var sendToExtension: (JSONObject) -> Unit = { message ->
        extensionController.sendBackgroundMessage(message)
    }

    fun scheduleRequest(command: String, args: Any) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                sendToExtension(message)
            }
        }
    }

    fun scheduleRequestWithResponse(
        command: String,
        args: Any,
        callback: ResultConsumer<JSONObject>
    ) {
        val message = JSONObject()
        message.put("action", command);
        message.put("args", args)

        runBlocking {
            withContext(Dispatchers.Default) {
                mutex.withLock {
                    sendRequestWithResponseLocked(message, callback)
                }
            }
        }
    }

    /**
     * Registers [callback] and posts [message], assuming [mutex] is already
     * held.
     *
     * Split out so a caller can decide *what* to send and send it without
     * releasing the lock in between. Deliberately does not wait for the reply:
     * replies arrive through [onExtensionReply], which takes the same
     * (non-reentrant) mutex, so awaiting here would deadlock.
     */
    private fun sendRequestWithResponseLocked(
        message: JSONObject,
        callback: ResultConsumer<JSONObject>,
    ) {
        val requestId = nextRequestId
        message.put("id", requestId)

        requestHandlers[requestId] = PendingRequest(connectionEpoch.get(), callback)

        nextRequestId += 1

        expireRequest(requestId)

        sendToExtension(message)
    }

    /**
     * Fails and drops [requestId] if no reply has arrived by
     * [requestTimeoutMs].
     *
     * Removal is what matters: the reply path and this one both take the handler
     * out under [mutex], so exactly one of them ever answers the caller.
     */
    private fun expireRequest(requestId: Int) {
        val timeout = requestTimeoutMs
        replayScope.launch {
            delay(timeout)

            val expired = mutex.withLock { requestHandlers.remove(requestId) }
                ?: return@launch

            logger.warn("Container proxy request $requestId timed out")
            expired.consumer.error("Container Proxy", "Request timed out", null)
        }
    }

    private fun snapshotMessage(snapshot: JSONObject): JSONObject {
        return JSONObject().apply {
            put("action", "applySnapshot")
            put("args", snapshot)
        }
    }

    /**
     * Records [generation] as installed, but only if it is still the snapshot
     * we most recently sent.
     *
     * Called from the message handler, which already holds [mutex] — so this
     * must not take it again.
     */
    private fun onSnapshotAcknowledgedLocked(generation: Long, epoch: Long) {
        if (generation != lastSnapshotGeneration) {
            // A reply for a snapshot that has since been superseded. Treating it
            // as current would report routing as installed that is not.
            logger.debug(
                "Ignoring acknowledgement for superseded snapshot $generation"
            )
            return
        }

        if (epoch != connectionEpoch.get()) {
            // The connection that confirmed this is gone, and with it the
            // background script that was holding the snapshot.
            logger.debug(
                "Ignoring acknowledgement from stale connection $epoch"
            )
            return
        }

        acknowledged = Acknowledgement(generation, epoch)
    }

    /**
     * Pushes the authoritative routing state to the extension and reports the
     * generation it acknowledges.
     *
     * The snapshot is remembered so [replaySnapshot] can reinstall it after a
     * background-script restart.
     */
    fun applySnapshot(
        snapshot: JSONObject,
        generation: Long,
        callback: ResultConsumer<JSONObject>,
    ) {
        val message = snapshotMessage(snapshot)

        runBlocking {
            withContext(Dispatchers.Default) {
                // Caching and sending happen under one acquisition. Splitting
                // them would let a replay read the cache between the two and
                // send a snapshot that is already superseded.
                mutex.withLock {
                    lastSnapshot = snapshot
                    lastSnapshotGeneration = generation
                    // The extension drops its store when it restarts, so nothing
                    // is acknowledged again until it answers this push.
                    acknowledged = null

                    val epoch = connectionEpoch.get()

                    sendRequestWithResponseLocked(message, object :
                        ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch)
                            callback.success(result)
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            callback.error(errorCode, errorMessage, errorDetails)
                        }
                    })
                }
            }
        }
    }

    /**
     * Reinstalls the cached snapshot after the extension's port (re)connects.
     *
     * Reads the cache under the same lock that installs it, so what it sends is
     * by construction the newest snapshot — a replay racing an app-driven push
     * cannot resend an older one, and cannot leave the extension holding routing
     * the app believes it has replaced.
     *
     * Runs off the caller's thread, because [onPortConnected] is invoked on the
     * Gecko thread and this path blocks on a lock.
     *
     * [epoch] is the connection this replay was scheduled for; a replay whose
     * connection is already gone by the time it runs sends nothing.
     */
    @VisibleForTesting
    internal fun replaySnapshot(epoch: Long = connectionEpoch.get()) {
        replayScope.launch {
            mutex.withLock {
                if (epoch != connectionEpoch.get()) {
                    logger.debug("Skipping replay for stale connection $epoch")
                    return@withLock
                }

                val snapshot = lastSnapshot ?: return@withLock
                val generation = lastSnapshotGeneration ?: return@withLock

                logger.debug("Replaying routing snapshot generation $generation")
                acknowledged = null

                sendRequestWithResponseLocked(
                    snapshotMessage(snapshot),
                    object : ResultConsumer<JSONObject> {
                        override fun success(result: JSONObject) {
                            onSnapshotAcknowledgedLocked(generation, epoch)
                            logger.debug("Extension reapplied routing snapshot $generation")
                        }

                        override fun error(
                            errorCode: String,
                            errorMessage: String?,
                            errorDetails: Any?
                        ) {
                            logger.error(
                                "Failed to replay routing snapshot: $errorCode $errorMessage"
                            )
                        }
                    },
                )
            }
        }
    }

    /**
     * Fails every request still waiting for a reply.
     *
     * The extension answers over the port; once that is gone, no reply is ever
     * coming. Without this the app's snapshot push would await a future that
     * never completes, and — because the push is serialised — every later push
     * would queue behind it forever.
     *
     * Only what belongs to a connection older than [epoch] is dropped. A
     * reconnect that races this — the common case, since a background script
     * restart is a disconnect immediately followed by a connect — has already
     * registered its replay under a newer epoch, and clearing that would leave
     * the extension configured but permanently reported as unready.
     */
    @VisibleForTesting
    internal fun failPendingRequests(
        reason: String,
        epoch: Long = connectionEpoch.incrementAndGet(),
    ) {
        replayScope.launch {
            val pending = mutex.withLock {
                val dead = requestHandlers.filterValues { it.epoch < epoch }
                dead.keys.forEach(requestHandlers::remove)

                if ((acknowledged?.epoch ?: Long.MIN_VALUE) < epoch) {
                    acknowledged = null
                }

                dead.values.toList()
            }

            pending.forEach { handler ->
                handler.consumer.error("Container Proxy", reason, null)
            }
        }
    }

    /**
     * Takes the port connection this connect belongs to and reinstalls routing
     * on it.
     */
    @VisibleForTesting
    internal fun onPortConnected() {
        // Bumped here, on the ordered callback thread, so everything the
        // previous connection left behind is stale by construction.
        val epoch = connectionEpoch.incrementAndGet()

        // A connect means a background script that starts with an empty store —
        // it fails closed until it is told the routing again.
        acknowledged = null
        replaySnapshot(epoch)
    }

    /** Drains whatever the connection that just died was still carrying. */
    @VisibleForTesting
    internal fun onPortDisconnected() {
        failPendingRequests(
            "Container proxy port disconnected",
            connectionEpoch.incrementAndGet(),
        )
    }

    /**
     * Answers the request [message] replies to, if it is still waiting for one.
     *
     * Runs the consumer under [mutex]: a snapshot acknowledgement decides what
     * routing the app reports as installed, so it has to be recorded against a
     * cache no push can be halfway through replacing.
     */
    @VisibleForTesting
    internal fun onExtensionReply(message: JSONObject) {
        runBlocking {
            withContext(Dispatchers.Default) {
                mutex.withLock {
                    val requestId = message.getInt("id")
                    val status = message.getString("status")
                    val handler = requestHandlers.remove(requestId)?.consumer

                    if (status == "success") {
                        handler?.success(message)
                    } else {
                        handler?.error(
                            "Container Proxy",
                            "Failed to perform operation",
                            message.getString("error")
                        )
                    }
                }
            }
        }
    }

    /** Clears the singleton's state between unit tests. */
    @VisibleForTesting
    internal fun resetForTesting() {
        runBlocking {
            mutex.withLock {
                requestHandlers.clear()
                nextRequestId = 0
                lastSnapshot = null
                lastSnapshotGeneration = null
                acknowledged = null
                connectionEpoch.set(0)
                requestTimeoutMs = 60_000L
            }
        }
    }

    private class ContainerProxyBackgroundMessageHandler(
        private var events: GeckoStateEvents
    ) : MessageHandler {
        override fun onPortConnected(port: Port) {
            ContainerProxyFeature.onPortConnected()
        }

        override fun onPortDisconnected(port: Port) {
            ContainerProxyFeature.onPortDisconnected()
        }

        override fun onPortMessage(message: Any, port: Port) {
            val messageJSON = message as JSONObject;
            val type = messageJSON.getString("type")

            if (type == "healthcheck" || type == "snapshotApplied") {
                onExtensionReply(messageJSON)
            } else if (type == "assignedSiteRequested") {
                val requestId = messageJSON.getString("id")
                val status = messageJSON.getString("status")
                val details = messageJSON.getJSONObject("result")

                if (status == "success") {
                    runOnUiThread {
                        events.onContainerSiteAssignment(
                            EventSequence.next(),
                            ContainerSiteAssignment(
                                requestId = requestId,
                                tabId = components.core.store.state.selectedTabId,
                                originUrl = details.tryGetString("originUrl"),
                                url = details.getString("url"),
                                blocked = details.getBoolean("blocked"),
                                strict = details.optBoolean("strict", false)
                            )
                        ) { _ -> }
                    }
                }
            }
        }
    }

    /**
     * Installs the web extension in the runtime through the WebExtensionRuntime install method
     *
     * @param runtime a WebExtensionRuntime.
     * @param productName a custom product name used to automatically label reports. Defaults to
     * "android-components".
     */
    fun install(runtime: WebExtensionRuntime, events: GeckoStateEvents) {
        extensionController.registerBackgroundMessageHandler(
            ContainerProxyBackgroundMessageHandler(events)
        )
        extensionController.install(
            runtime,
            onSuccess = {
                logger.debug("Installed ContainerProxy webextension: ${it.id}")
            },
            onError = { throwable ->
                logger.error("Failed to install ContainerProxy webextension: ", throwable)
            },
        )
    }
}
