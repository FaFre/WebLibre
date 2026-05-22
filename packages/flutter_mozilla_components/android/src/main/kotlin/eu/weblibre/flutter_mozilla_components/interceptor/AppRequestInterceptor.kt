/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.interceptor

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.feature.InertExternalSchemes
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureBridge
import eu.weblibre.flutter_mozilla_components.feature.SandboxCaptureRegistry
import eu.weblibre.flutter_mozilla_components.pigeons.ProxyLoadError
import mozilla.components.browser.errorpages.ErrorPages
import mozilla.components.browser.errorpages.ErrorType
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.CustomTabSessionState
import mozilla.components.browser.state.state.ExternalAppType
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.request.RequestInterceptor

class AppRequestInterceptor(private val context: Context) : RequestInterceptor {
    private val components by lazy {
        requireNotNull(GlobalComponents.components) { "Components not initialized" }
    }

    override fun onLoadRequest(
        engineSession: EngineSession,
        uri: String,
        lastUri: String?,
        hasUserGesture: Boolean,
        isSameDomain: Boolean,
        isRedirect: Boolean,
        isDirectNavigation: Boolean,
        isSubframeRequest: Boolean,
    ): RequestInterceptor.InterceptionResponse? {
        // PWAs/TWAs should never trigger external app link interception —
        // they should behave as self-contained apps and load all URLs internally.
        val customTab = components.core.store.state.findTabOrCustomTab(engineSession)
        val externalAppType = (customTab as? CustomTabSessionState)
            ?.config?.externalAppType
        if (externalAppType == ExternalAppType.PROGRESSIVE_WEB_APP ||
            externalAppType == ExternalAppType.TRUSTED_WEB_ACTIVITY
        ) {
            return null
        }

        // Parsed once and reused by both the sandbox-capture handling and the
        // weblibre:// deep-link check below. `Uri.parse` never throws for
        // malformed input — it returns a Uri with empty fields — so callers
        // must check the scheme explicitly.
        val parsed = Uri.parse(uri)

        // Sandbox capture tabs: rewrite loads to loopback, deny links to live URLs.
        val sandboxEntry = (customTab?.id)?.let { SandboxCaptureRegistry.get(it) }
        if (sandboxEntry != null) {
            when {
                // Loopback redirects emitted by us — pass through.
                SandboxCaptureRegistry.isLoopbackRedirect(uri) -> {
                    // Fall through to existing accounts/applinks logic below —
                    // loopback URLs don't match any of them and the default
                    // "return null" at the bottom lets Gecko load normally.
                }
                // Canonical source URL — redirect to current loader/capture.
                uri == sandboxEntry.sourceUrl -> {
                    return RequestInterceptor.InterceptionResponse.Url(
                        sandboxEntry.redirectUrl,
                    )
                }
                // Inert external schemes — hand off to existing AppLinks logic.
                InertExternalSchemes.matches(parsed) -> {
                    // Fall through to AppLinks handling below.
                }
                // Any other URL — sandbox tab is trying to navigate to the live
                // web. Deny and ask Flutter to open a new sandbox tab instead.
                else -> {
                    customTab.id.let { parentId ->
                        SandboxCaptureBridge.dispatchLinkClick(parentId, uri)
                    }
                    return RequestInterceptor.InterceptionResponse.Deny
                }
            }
        }

        // Intercept weblibre:// deep links and dispatch them as Android intents
        // so the Flutter side can handle them (e.g. account callback handoff).
        if (parsed.scheme == "weblibre") {
            val intent = Intent(Intent.ACTION_VIEW, parsed).apply {
                setPackage(context.packageName)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }
            try {
                context.startActivity(intent)
                // No fallbackUrl — the intent targets our own package, so if
                // startActivity didn't throw we've handled the navigation
                // completely and there's no in-engine load to fall back to.
                // appName is null because there's no user-facing app picker
                // (the intent is package-scoped to us via setPackage above).
                return RequestInterceptor.InterceptionResponse.AppIntent(
                    appIntent = intent,
                    url = uri,
                    fallbackUrl = null,
                    appName = null,
                )
            } catch (e: ActivityNotFoundException) {
                // No activity is registered for this weblibre:// URI (cold-start
                // race, manifest mismatch, etc.). Let the load fall through so
                // Gecko shows a normal "can't load" page instead of crashing the
                // load flow on an unhandled exception.
                Log.w("AppRequestInterceptor", "No activity for $uri", e)
            }
        }

        components.services.accountsAuthFeature.interceptor.onLoadRequest(
            engineSession,
            uri,
            lastUri,
            hasUserGesture,
            isSameDomain,
            isRedirect,
            isDirectNavigation,
            isSubframeRequest,
        )?.let {
            return it
        }

        return components.services.appLinksInterceptor.onLoadRequest(
            engineSession,
            uri,
            lastUri,
            hasUserGesture,
            isSameDomain,
            isRedirect,
            isDirectNavigation,
            isSubframeRequest,
        )
    }

    override fun onErrorRequest(
        session: EngineSession,
        errorType: ErrorType,
        uri: String?,
    ): RequestInterceptor.ErrorResponse {
        if (errorType == ErrorType.ERROR_PROXY_CONNECTION_REFUSED ||
            errorType == ErrorType.ERROR_UNKNOWN_PROXY_HOST
        ) {
            val tab = components.core.store.state.findTabOrCustomTab(session)
            components.flutterEvents.onProxyLoadError(
                EventSequence.next(),
                ProxyLoadError(
                    tabId = tab?.id,
                    contextId = tab?.contextId,
                    url = uri,
                    errorType = errorType.name,
                )
            ) { _ -> }
        }

        val errorPage = ErrorPages.createUrlEncodedErrorPage(context, errorType, uri)
        return RequestInterceptor.ErrorResponse(errorPage)
    }

    override fun interceptsAppInitiatedRequests() = true
}
