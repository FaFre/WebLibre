/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureBridge
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureRegistry
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware

// Stops _blank / window.open / middle-click from leaking the first request
// when the originating tab is a sandbox capture tab.
//
// WindowFeature creates new app tabs via TabListAction.AddTabAction with the
// target URL already populated. AppRequestInterceptor.onLoadRequest would fire
// on the first load, but by that point Gecko has already issued the request.
// This middleware runs synchronously before that: it rewrites the new tab's
// URL to about:blank and dispatches the capture flow to Dart.
val SandboxCaptureMiddleware: Middleware<BrowserState, BrowserAction> =
    { _, next, action ->
        if (action !is TabListAction.AddTabAction) {
            next(action)
        } else {
            val parentId = action.tab.parentId
            val parentEntry = parentId?.let { SandboxCaptureRegistry.get(it) }
            val targetUrl = action.tab.content.url
            when {
                parentEntry == null -> {
                    next(action)
                }
                SandboxCaptureRegistry.isLoopbackRedirect(targetUrl) -> {
                    // We initiated this AddTab for a sandbox capture.
                    next(action)
                }
                else -> {
                    val rewrittenTab = action.tab.copy(
                        content = action.tab.content.copy(url = "about:blank"),
                    )
                    next(TabListAction.AddTabAction(rewrittenTab, action.select))
                    SandboxCaptureBridge.dispatchNewTab(
                        parentTabId = parentId,
                        newTabId = action.tab.id,
                        targetUrl = targetUrl,
                    )
                }
            }
        }
    }
