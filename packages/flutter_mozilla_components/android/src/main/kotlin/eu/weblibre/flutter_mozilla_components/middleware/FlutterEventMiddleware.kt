/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package eu.weblibre.flutter_mozilla_components.middleware

import android.graphics.Bitmap
import android.util.Log
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.ext.resize
import eu.weblibre.flutter_mozilla_components.ext.toWebPBytes
import eu.weblibre.flutter_mozilla_components.pigeons.AudioHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.EmailHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.FindResultState
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoStateEvents
import eu.weblibre.flutter_mozilla_components.pigeons.GeoHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.ImageHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.ImageSrcHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.PhoneHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.UnknownHitResult
import eu.weblibre.flutter_mozilla_components.pigeons.VideoHitResult
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.LastAccessAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.HitResult
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import java.io.ByteArrayOutputStream
import kotlin.reflect.typeOf


/**
 * [Middleware] implementation for handling [ContentAction.UpdateThumbnailAction] and storing
 * the thumbnail to the disk cache.
 */
class FlutterEventMiddleware(private val flutterEvents: GeckoStateEvents) : Middleware<BrowserState, BrowserAction> {
    // Bitmap resize + WebP encoding is CPU-bound (measured 12-50ms for a single
    // thumbnail/icon) and Gecko dispatches BrowserActions on the main thread —
    // doing this work inline here was stealing that thread from GeckoView's own
    // navigation work often enough to lose the back/forward-cache restore race
    // on back navigation. mozilla-components' own ThumbnailsMiddleware defers
    // its own Bitmap handling to a coroutine the same way (see
    // ThumbnailStorage.saveThumbnail), so holding onto the Bitmap across the
    // async boundary here follows the same precedent.
    private val encodingScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

    /**
     * Cancels any in-flight encode.
     *
     * Each components set builds its own [FlutterEventMiddleware], so without
     * this an encode started before a profile switch would outlive the profile
     * it belongs to and still call [GeckoStateEvents.onIconUpdate] /
     * [GeckoStateEvents.onThumbnailChange] into the *next* profile's Dart
     * state. [EventSequence] is process-global and strictly increasing, so
     * those stale events would not be filtered out by Dart's
     * `addWhenMoreRecent` gate either — they would land as entries for tab ids
     * the new profile does not have. Called from `GlobalComponents.tearDown`.
     */
    fun close() {
        encodingScope.cancel()
    }

    @Suppress("ComplexMethod")
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdateThumbnailAction -> {
                val sessionId = action.sessionId
                val thumbnail = action.thumbnail
                // Captured synchronously, in dispatch order, before the async
                // encode: Dispatchers.Default gives no ordering guarantee
                // between concurrent encodes, so an older thumbnail that takes
                // longer to encode than a newer one for the same tab must not
                // be allowed to claim a higher sequence number — Dart's
                // addWhenMoreRecent trusts this value to reflect native order.
                val sequence = EventSequence.next()
                encodingScope.launch {
                    // Resizing and encoding can fail on input the store is happy
                    // to hold (an extreme aspect ratio makes `resize` compute a
                    // zero dimension, and `createScaledBitmap`/`compress` can go
                    // OOM). Inline, that threw back at whoever dispatched the
                    // action — `GeckoSessionApiImpl.requestScreenshot` catches it
                    // and returns a failed Result. From a coroutine it would
                    // instead reach the thread's default uncaught handler and
                    // take the process down, so it has to be caught here.
                    try {
                        val bytes = thumbnail.resize(maxWidth = 1280, maxHeight = 800).toWebPBytes()

                        ensureActive()
                        runOnUiThread {
                            flutterEvents.onThumbnailChange(sequence, sessionId, bytes) { _ -> }
                        }
                    } catch (e: CancellationException) {
                        throw e
                    } catch (e: Exception) {
                        logger.error("$TAG: Failed to encode thumbnail for tab $sessionId", e)
                    } catch (e: OutOfMemoryError) {
                        logger.error("$TAG: Out of memory encoding thumbnail for tab $sessionId", e)
                    }
                }
            }
            is TabListAction.AddTabAction -> {
                runOnUiThread {
                    flutterEvents.onTabAdded(
                        EventSequence.next(),
                        action.tab.id
                    ) { _ -> }
                }
            }
            is ContentAction.UpdateIconAction -> {
                val pageUrl = action.pageUrl
                val icon = action.icon
                // See the matching comment in UpdateThumbnailAction above.
                val sequence = EventSequence.next()
                encodingScope.launch {
                    // See the matching try/catch in UpdateThumbnailAction above.
                    try {
                        val bytes = icon.toWebPBytes()

                        ensureActive()
                        runOnUiThread {
                            flutterEvents.onIconUpdate(
                                sequence,
                                pageUrl,
                                bytes
                            ) { _ -> }
                        }
                    } catch (e: CancellationException) {
                        throw e
                    } catch (e: Exception) {
                        logger.error("$TAG: Failed to encode icon for $pageUrl", e)
                    } catch (e: OutOfMemoryError) {
                        logger.error("$TAG: Out of memory encoding icon for $pageUrl", e)
                    }
                }
            }
            is ContentAction.UpdateHitResultAction -> {
                // Skip forwarding to Flutter for custom tab sessions (PWAs, TWAs),
                // as they handle context menus natively via ContextMenuFeature
                if (store.state.findCustomTab(action.sessionId) == null) {
                    runOnUiThread {
                        flutterEvents.onLongPress(
                            EventSequence.next(),
                            action.sessionId,
                            when(val result = action.hitResult) {
                                is HitResult.AUDIO -> AudioHitResult(result.src, result.title)
                                is HitResult.EMAIL -> EmailHitResult(result.src)
                                is HitResult.GEO -> GeoHitResult(result.src)
                                is HitResult.IMAGE -> ImageHitResult(result.src, result.title)
                                is HitResult.IMAGE_SRC -> ImageSrcHitResult(result.src, result.uri)
                                is HitResult.PHONE -> PhoneHitResult(result.src)
                                is HitResult.UNKNOWN -> UnknownHitResult(result.src, result.linkText)
                                is HitResult.VIDEO -> VideoHitResult(result.src, result.title)
                            }
                        ) { _ -> }
                    }
                }
            }
            is ContentAction.AddFindResultAction -> {
                runOnUiThread {
                    flutterEvents.onFindResults(
                        EventSequence.next(),
                        action.sessionId,
                        listOf(
                            FindResultState(
                                activeMatchOrdinal = action.findResult.activeMatchOrdinal.toLong(),
                                numberOfMatches = action.findResult.numberOfMatches.toLong(),
                                isDoneCounting = action.findResult.isDoneCounting,
                            )
                        )
                    ) { _ -> }
                }
            }
            is ContentAction.ClearFindResultsAction -> {
                runOnUiThread {
                    flutterEvents.onFindResults(
                        EventSequence.next(),
                        action.sessionId,
                        listOf()
                    ) { _ -> }
                }
            }
//            is ReaderAction.UpdateReaderScrollYAction -> {
//                runOnUiThread {
//                    flutterEvents.onScrollChange(
//                        EventSequence.next(),
//                        action.tabId,
//                        action.scrollY.toLong()
//                    ) { _ -> }
//                }
//            }
            else -> {
                //logger.debug("Event fired: " + action.javaClass.name)
            }
        }
        next(action)
    }

    companion object {
        private const val TAG = "FlutterEventMiddleware"
    }
}
