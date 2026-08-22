/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.api

import android.content.Context
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.applinks.AppLinkLaunchMode
import eu.weblibre.flutter_mozilla_components.applinks.AppLinkLaunchResult
import eu.weblibre.flutter_mozilla_components.applinks.AppLinkPolicyStores
import eu.weblibre.flutter_mozilla_components.applinks.AppLinkRuntime
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkRequest
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStore
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStores
import eu.weblibre.flutter_mozilla_components.applinks.releaseHeldNavigation
import eu.weblibre.flutter_mozilla_components.applinks.toAppLinkPolicy
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkDecision
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPolicySnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptRequest
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkResolutionResult
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkTarget
import eu.weblibre.flutter_mozilla_components.pigeons.GeckoAppLinksApi
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.support.base.log.logger.Logger
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import androidx.annotation.MainThread
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.util.Locale

/**
 * WebLibre-owned implementation of [GeckoAppLinksApi] backed by [ExternalAppResolver] and
 * [AppLinkLauncher] (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md Phase 1). Policy lives in Dart; this
 * surface owns PackageManager resolution and Intent launch for the manual entry points.
 */
class GeckoAppLinksApiImpl(
    private val context: Context,
) : GeckoAppLinksApi {
    companion object {
        private val coroutineScope = CoroutineScope(Dispatchers.Default + SupervisorJob())
        private val logger = Logger("GeckoAppLinksApi")
    }

    // Shared process-level resolver/launcher (§2.7): the 2 s auto-launch cooldown and 30 s
    // resolution cache are observed across the interceptor tail, the manual entry points, and
    // prompt resolution alike.
    private val resolver get() = AppLinkRuntime.get(context).resolver
    private val launcher get() = AppLinkRuntime.get(context).launcher

    override fun setAppLinkPolicy(
        snapshot: AppLinkPolicySnapshot,
        callback: (Result<Unit>) -> Unit,
    ) {
        coroutineScope.launch {
            try {
                // A profile must be bound before policy can be applied. The Dart
                // replicator retries after initialisation (§2.8, §2.10).
                val profileContext = GlobalComponents.components?.profileApplicationContext
                    ?: throw IllegalStateException("No profile bound for app-link policy")
                val store = AppLinkPolicyStores.forProfile(profileContext)
                val persisted = store.setPolicy(snapshot.toAppLinkPolicy())
                if (persisted) {
                    callback(Result.success(Unit))
                } else {
                    callback(Result.failure(IllegalStateException("Failed to persist app-link policy")))
                }
            } catch (e: Exception) {
                callback(Result.failure(e))
            }
        }
    }

    override fun resolveAppLink(
        url: String,
        includeHttpAppLinks: Boolean,
        callback: (Result<AppLinkTarget?>) -> Unit,
    ) {
        coroutineScope.launch {
            try {
                val resolved = resolver.resolve(url, includeHttpAppLinks = includeHttpAppLinks)
                if (!resolved.hasExternalApp) {
                    callback(Result.success(null))
                    return@launch
                }
                callback(
                    Result.success(
                        AppLinkTarget(
                            url = url,
                            appName = resolved.appName,
                            packageName = resolved.packageName,
                            fallbackUrl = resolved.fallbackUrl,
                            isMarketplace = false,
                            isAmbiguous = resolved.isAmbiguous,
                            engineSupportsScheme = resolved.engineSupportsScheme,
                            scopeKey = resolved.scopeKey,
                        ),
                    ),
                )
            } catch (e: Exception) {
                // Uniform failure semantics (§2.8): callers cannot distinguish "nothing installed"
                // from "resolution failed".
                callback(Result.success(null))
            }
        }
    }

    override fun launchAppLink(url: String, callback: (Result<Boolean>) -> Unit) {
        coroutineScope.launch {
            try {
                val result = launcher.launch(url, mode = AppLinkLaunchMode.MANUAL)
                logger.info("launchAppLink($url) -> $result")
                callback(Result.success(result == AppLinkLaunchResult.LAUNCHED))
            } catch (e: Exception) {
                logger.error("launchAppLink($url) failed", e)
                callback(Result.success(false))
            }
        }
    }

    private fun pendingStoreFor(components: Components): PendingAppLinkStore {
        return PendingAppLinkStores.forProfile(
            components.profileApplicationContext.relativePath,
        )
    }

    override fun getPendingAppLinkPrompts(
        owner: AppLinkPromptOwner,
        callback: (Result<List<AppLinkPromptRequest>>) -> Unit,
    ) {
        coroutineScope.launch {
            try {
                val components = GlobalComponents.components
                val list = components
                    ?.let {
                        val store = pendingStoreFor(it)
                        val pending = store.getPending(owner).map { request ->
                            request.toPigeon(store.expiresInMs(request))
                        }
                        pending
                    }
                    ?: emptyList()

                // The surface re-queries on the soonest deadline in order to retire lapsed prompts,
                // which makes this the natural place to settle what those prompts were holding: a
                // banner the user simply ignored must still end with the page on screen, not with a
                // navigation that silently died. Released on the main thread for the same reason as
                // the resolution path.
                components?.let {
                    val store = pendingStoreFor(it)
                    val expired = store.drainExpiredHeldNavigations()
                    if (expired.isNotEmpty()) {
                        withContext(Dispatchers.Main) {
                            expired.forEach { request ->
                                releaseHeldNavigation(
                                    store,
                                    it.core.store,
                                    it.useCases.sessionUseCases,
                                    request,
                                    reason = "expired",
                                )
                            }
                        }
                    }
                }
                callback(Result.success(list))
            } catch (e: Exception) {
                callback(Result.success(emptyList()))
            }
        }
    }

    override fun resolvePendingAppLink(
        requestId: Long,
        decision: AppLinkDecision,
        callback: (Result<AppLinkResolutionResult>) -> Unit,
    ) {
        coroutineScope.launch {
            try {
                val components = GlobalComponents.components
                    ?: return@launch callback(Result.success(stale()))
                val store = pendingStoreFor(components)

                // Consume atomically; the store lock is released before any side effect.
                val request = store.consume(requestId)
                if (request == null) {
                    // The request was invalidated (navigation/tab close/expiry) before the user
                    // resolved it — the prompt shown was stale. No launch, no page change.
                    logger.info("resolvePendingAppLink($requestId, $decision) -> stale (no pending request)")
                    return@launch callback(Result.success(stale()))
                }

                // Never launch into a session that no longer exists.
                val tabAlive = components.core.store.state
                    .findTabOrCustomTab(request.tabId) != null
                if (!tabAlive) {
                    logger.info("resolvePendingAppLink($requestId) -> dead_session (${request.tabId})")
                    return@launch callback(
                        Result.success(AppLinkResolutionResult(false, false, "dead_session")),
                    )
                }

                // This scope is `Dispatchers.Default`, and everything below reaches the engine:
                // launching, loading a fallback, and claiming a held navigation. Navigation itself
                // runs on the UI thread, so claiming from here would race it — and would hand the
                // engine session a load from the wrong thread besides.
                val result = withContext(Dispatchers.Main) {
                    when (decision) {
                        AppLinkDecision.OPEN -> handleOpen(components, request)
                        AppLinkDecision.CANCEL, AppLinkDecision.DISMISS -> {
                            store.recordSuppression(request.tabId, request.targetFingerprint)
                            // Under `blockWhilePrompting` the page never loaded; declining is the
                            // user asking for it in the browser, so it is owed to them now. A no-op
                            // on the non-blocking path, where the page is already on screen.
                            releaseHeldNavigation(
                                store,
                                components.core.store,
                                components.useCases.sessionUseCases,
                                request,
                                reason = decision.name.lowercase(Locale.ROOT),
                            )
                            AppLinkResolutionResult(false, false, null)
                        }
                    }
                }
                logger.info("resolvePendingAppLink id=$requestId -> $result")
                callback(Result.success(result))
            } catch (e: Exception) {
                callback(Result.success(AppLinkResolutionResult(false, false, "launch_failed")))
            }
        }
    }

    @MainThread
    private fun handleOpen(
        components: Components,
        request: PendingAppLinkRequest,
    ): AppLinkResolutionResult {
        val mode = if (request.isMarketplace) {
            AppLinkLaunchMode.MARKETPLACE
        } else {
            // Prompt-resolved opens are user gestures (bypass the cooldown).
            AppLinkLaunchMode.MANUAL
        }
        // Honour the package captured when the prompt was created for a *named*
        // (non-ambiguous) target, so a change in handlers before the user taps Open
        // can't launch a different app (§2.5/§2.7). Ambiguous/chooser prompts store a
        // null expectedPackage, so this stays null and the chooser still opens.
        val result = launcher.launch(request.url, mode, expectedPackage = request.expectedPackage)
        logger.info("resolvePendingAppLink open: launch(${request.url}, $mode) -> $result")
        if (result == AppLinkLaunchResult.LAUNCHED) {
            return AppLinkResolutionResult(true, false, null)
        }

        // Launch failed: load a validated fallback if present, else leave the page.
        val fallback = request.fallbackUrl
        if (fallback != null) {
            // Guard the fallback load against immediately bouncing back out to an app
            // (§2.7): a validated http(s) fallback can itself resolve to an external
            // handler, which would re-prompt/auto-launch. The interceptor records the
            // same for fallbacks it issues.
            pendingStoreFor(components).recordFallbackReentry(fallback)
            components.useCases.sessionUseCases.loadUrl(
                url = fallback,
                sessionId = request.tabId,
            )
            return AppLinkResolutionResult(false, true, "launch_failed")
        }
        // No fallback to fall back to. Under `blockWhilePrompting` the tab is showing nothing at
        // all, so "the app wouldn't open" must not also mean "and the page never arrives".
        releaseHeldNavigation(
            pendingStoreFor(components),
            components.core.store,
            components.useCases.sessionUseCases,
            request,
            reason = "launch_failed",
        )
        return AppLinkResolutionResult(false, false, "launch_failed")
    }

    private fun stale() = AppLinkResolutionResult(false, false, "stale")
}
