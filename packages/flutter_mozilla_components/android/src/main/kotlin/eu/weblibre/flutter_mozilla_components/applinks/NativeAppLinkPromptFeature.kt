/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import android.os.Handler
import android.os.Looper
import androidx.appcompat.app.AlertDialog
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.support.base.feature.LifecycleAwareFeature
import java.util.concurrent.ConcurrentHashMap

/**
 * Process-level registry of the *started* [NativeAppLinkPromptFeature] instances, keyed by tabId.
 * The [WebLibreAppLinksInterceptor] runs on an engine thread and creates prompt requests
 * asynchronously; a Custom Tab feature only queries the store at lifecycle start, so without this a
 * request created after start would sit unshown (its navigation already denied) until a rotation or
 * restart. The interceptor pings [notifyPromptAvailable] so the feature re-queries immediately.
 */
object NativeAppLinkPromptNotifier {
    private val features = ConcurrentHashMap<String, NativeAppLinkPromptFeature>()

    fun register(tabId: String, feature: NativeAppLinkPromptFeature) {
        features[tabId] = feature
    }

    fun unregister(tabId: String, feature: NativeAppLinkPromptFeature) {
        features.remove(tabId, feature)
    }

    fun notifyPromptAvailable(tabId: String) {
        features[tabId]?.onPromptAvailable()
    }
}

/**
 * Presents the minimal native app-link prompt for Custom Tab sessions that have no
 * Flutter engine (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.6). Title, message,
 * open/cancel — **no remember checkbox**, so native never creates policy.
 *
 * Queries [PendingAppLinkStore] for its own tab on start (and re-queries after each
 * resolution); a request that is rotated/backgrounded away stays pending and is
 * re-presented on the next start. Owner is fixed to [AppLinkPromptOwner.NATIVE_EXTERNAL].
 */
class NativeAppLinkPromptFeature(
    private val context: Context,
    private val tabId: String,
    private val store: PendingAppLinkStore,
    private val browserStore: BrowserStore,
    private val launcher: AppLinkLauncher,
    private val sessionUseCases: SessionUseCases,
) : LifecycleAwareFeature {
    private var dialog: AlertDialog? = null
    private var shownRequest: PendingAppLinkRequest? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    /**
     * The lapse tick for the dialog currently on screen. Held as a single instance so it can be
     * cancelled: the delay is up to [PendingAppLinkStore.REQUEST_EXPIRY_MS] (10 minutes) and the
     * runnable retains this feature — and through it the Activity-derived [context] — for its whole
     * duration, so it must never outlive [stop].
     */
    private val expiryTick = Runnable {
        dismissStaleDialog()
        // A tick can land a millisecond early and dismiss nothing. Re-arm in that case rather than
        // leave the dialog with no deadline at all; [MIN_EXPIRY_TICK_MS] keeps that from spinning.
        shownRequest?.let(::scheduleExpiryTick)
        // A dialog retired by its own deadline still has to make way for whatever else pends.
        showNext()
    }

    override fun start() {
        NativeAppLinkPromptNotifier.register(tabId, this)
        showNext()
    }

    override fun stop() {
        NativeAppLinkPromptNotifier.unregister(tabId, this)
        mainHandler.removeCallbacksAndMessages(null)
        // Dismissing on stop is not a user dismissal: the request stays pending and
        // is re-presented on the next start().
        dialog?.setOnDismissListener(null)
        dialog?.dismiss()
        dialog = null
        shownRequest = null
    }

    /**
     * The tab's pending requests changed (interceptor created one on an engine thread after [start]
     * already queried, or the navigation middleware invalidated one). Re-check on the main thread;
     * [showNext] is idempotent (a no-op while a live dialog is up or when nothing pends).
     */
    fun onPromptAvailable() {
        mainHandler.post {
            dismissStaleDialog()
            showNext()
        }
    }

    /**
     * Drop a dialog whose request has since been invalidated — otherwise it stays on screen as a
     * dud whose Open button consumes nothing. Not a user dismissal: nothing is suppressed.
     */
    private fun dismissStaleDialog() {
        val shown = shownRequest ?: return
        if (store.peek(shown.requestId) != null) return
        mainHandler.removeCallbacks(expiryTick)
        dialog?.setOnCancelListener(null)
        dialog?.setOnDismissListener(null)
        dialog?.dismiss()
        dialog = null
        shownRequest = null
    }

    /**
     * Expiry in the store is lazy, so nothing would take a dialog down when its request lapses —
     * its buttons would consume nothing. Retire it on its own deadline instead.
     */
    private fun scheduleExpiryTick(request: PendingAppLinkRequest) {
        mainHandler.removeCallbacks(expiryTick)
        mainHandler.postDelayed(
            expiryTick,
            store.expiresInMs(request).coerceAtLeast(MIN_EXPIRY_TICK_MS),
        )
    }

    private fun showNext() {
        if (dialog != null) return

        val request = store.getPending(AppLinkPromptOwner.NATIVE_EXTERNAL)
            .firstOrNull { it.tabId == tabId }
            ?: return

        val title = request.appName?.let {
            context.getString(R.string.weblibre_app_link_prompt_title_named, it)
        } ?: context.getString(R.string.weblibre_app_link_prompt_title_generic)

        dialog = AlertDialog.Builder(context)
            .setTitle(title)
            .setMessage(context.getString(R.string.weblibre_app_link_prompt_message))
            .setPositiveButton(R.string.weblibre_app_link_prompt_open) { _, _ ->
                resolveOpen(request)
            }
            .setNegativeButton(R.string.weblibre_app_link_prompt_cancel) { _, _ ->
                resolveCancel(request)
            }
            .setOnCancelListener {
                // Back / touch-outside is an explicit passive dismissal (§2.6).
                resolveDismiss(request)
            }
            .setOnDismissListener { dialog = null }
            .show()
        shownRequest = request
        scheduleExpiryTick(request)
    }

    private fun resolveOpen(request: PendingAppLinkRequest) {
        val consumed = store.consume(request.requestId) ?: return afterResolve()
        val mode = if (consumed.isMarketplace) {
            AppLinkLaunchMode.MARKETPLACE
        } else {
            AppLinkLaunchMode.MANUAL
        }
        // Fresh prompt-open: no remembered package binding to enforce (§2.5); the
        // launcher's pre-launch re-resolution still validates the handler.
        // Honour the package captured when the prompt was created for a *named*
        // (non-ambiguous) target, so a change in handlers before the user taps Open
        // can't launch a different app (§2.5/§2.7). Ambiguous/chooser prompts store a
        // null expectedPackage, so this stays null and the chooser still opens.
        val result = launcher.launch(consumed.url, mode, expectedPackage = consumed.expectedPackage)
        if (result != AppLinkLaunchResult.LAUNCHED) {
            val fallback = consumed.fallbackUrl
            if (fallback != null) {
                // Guard the fallback load against immediately bouncing back out to an
                // app (§2.7): a validated fallback can itself resolve externally.
                store.recordFallbackReentry(fallback)
                sessionUseCases.loadUrl(url = fallback, sessionId = consumed.tabId)
            } else {
                // Under `blockWhilePrompting` this tab is showing nothing at all, so "the app
                // wouldn't open" must not also mean "and the page never arrives".
                releaseHeldNavigation(store, browserStore, sessionUseCases, consumed, reason = "launch_failed")
            }
        }
        afterResolve()
    }

    private fun resolveCancel(request: PendingAppLinkRequest) {
        val consumed = store.consume(request.requestId) ?: return afterResolve()
        store.recordSuppression(consumed.tabId, consumed.targetFingerprint)
        // Under `blockWhilePrompting` this Custom Tab is sitting on nothing; declining is the user
        // asking for the page here rather than in the app.
        releaseHeldNavigation(store, browserStore, sessionUseCases, consumed, reason = "cancel")
        afterResolve()
    }

    private fun resolveDismiss(request: PendingAppLinkRequest) {
        // Passive dismissal is not "stay in browser": retire the prompt without loading the held
        // URL or suppressing a future prompt for the same target.
        store.consume(request.requestId)
        afterResolve()
    }

    private fun afterResolve() {
        mainHandler.removeCallbacks(expiryTick)
        dialog = null
        shownRequest = null
        showNext()
    }

    private companion object {
        /** Never schedule a zero-delay expiry tick; a lapsed request would reschedule in a spin. */
        const val MIN_EXPIRY_TICK_MS = 250L
    }
}
