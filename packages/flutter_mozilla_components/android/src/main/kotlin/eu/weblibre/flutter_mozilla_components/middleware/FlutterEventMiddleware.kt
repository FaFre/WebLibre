/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */
package eu.weblibre.flutter_mozilla_components.middleware

import android.graphics.Bitmap
import android.util.Log
import eu.weblibre.flutter_mozilla_components.GlobalComponents
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
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.LastAccessAction
import mozilla.components.browser.state.action.ReaderAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.action.WebExtensionAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.concept.engine.HitResult
import mozilla.components.feature.addons.logger
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.MiddlewareContext
import org.mozilla.gecko.util.ThreadUtils.runOnUiThread
import java.io.ByteArrayOutputStream
import kotlin.reflect.typeOf


/**
 * [Middleware] implementation for handling [ContentAction.UpdateThumbnailAction] and storing
 * the thumbnail to the disk cache.
 */
class FlutterEventMiddleware(private val flutterEvents: GeckoStateEvents) : Middleware<BrowserState, BrowserAction> {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }
    
    @Suppress("ComplexMethod")
    override fun invoke(
        context: MiddlewareContext<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is ContentAction.UpdateThumbnailAction -> {
                val resized = action.thumbnail.resize(maxWidth = 1280, maxHeight = 800);
                val bytes = resized.toWebPBytes()

                runOnUiThread {
                    flutterEvents.onThumbnailChange(EventSequence.next(), action.sessionId, bytes) { _ -> }
                }
            }
            //UpdateReaderConnectRequiredAction seems to be the only event that is called predictable
            //after a hot reload
            is ReaderAction.UpdateReaderConnectRequiredAction -> {
                if(!components.engineReportedInitialized) {
                    runOnUiThread {
                        flutterEvents.onEngineReadyStateChange(
                            EventSequence.next(),
                            true
                        ) { _ -> }
                    }

                    components.engineReportedInitialized = true
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
                val bytes = action.icon.toWebPBytes()

                runOnUiThread {
                    flutterEvents.onIconUpdate(
                        EventSequence.next(),
                        action.pageUrl,
                        bytes
                    ) { _ -> }
                }
            }
            is ContentAction.UpdateHitResultAction -> {
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
                            is HitResult.UNKNOWN -> UnknownHitResult(result.src)
                            is HitResult.VIDEO -> VideoHitResult(result.src, result.title)
                        }
                    ) { _ -> }
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
}
