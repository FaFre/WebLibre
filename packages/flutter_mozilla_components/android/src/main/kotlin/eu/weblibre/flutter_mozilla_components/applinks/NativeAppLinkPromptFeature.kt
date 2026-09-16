/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.View
import androidx.appcompat.app.AlertDialog
import com.google.android.material.snackbar.BaseTransientBottomBar
import com.google.android.material.snackbar.Snackbar
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
 *
 * **Two surfaces, chosen by whether the navigation is actually stalled.** A banner-class
 * ([AppLinkUrlClass.BANNER]) request that is not holding its navigation was allowed to load, so the
 * page is on screen behind the prompt and a modal dialog would block a page the user can already
 * read — those get a [Snackbar]. Everything that really is waiting on an answer keeps the dialog:
 * an unsupported scheme, a marketplace offer, and any request holding a navigation under
 * `blockWhilePrompting`.
 *
 * The Snackbar carries one action, "Open". It has no "stay in the browser" affordance, so — unlike
 * the Flutter banner — swiping it away records no suppression and the same link may offer again.
 * That is the accepted cost of a surface that cannot grow a second button; a Custom Tab could never
 * remember a decision anyway (native creates no policy), so the only durable "stop asking" was
 * always the mode in Settings.
 */
class NativeAppLinkPromptFeature(
    private val context: Context,
    private val tabId: String,
    private val store: PendingAppLinkStore,
    private val browserStore: BrowserStore,
    private val launcher: AppLinkLauncher,
    private val sessionUseCases: SessionUseCases,
    private val rootView: View,
) : LifecycleAwareFeature {
    private var dialog: AlertDialog? = null
    private var banner: Snackbar? = null
    private var shownRequest: PendingAppLinkRequest? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    /** Whether a prompt is on screen; [showNext] must not stack a second one over it. */
    private val isShowing: Boolean get() = dialog != null || banner != null

    /**
     * Banner requests that lost the shared Snackbar surface to something else. They stay pending —
     * the user may still answer one from another surface, and they expire on their own deadline —
     * but this feature will not offer them again, because doing so means taking the surface back
     * from whatever is using it now. Cleared on [stop], so a fresh start offers them once more.
     */
    private val displacedBanners = mutableSetOf<Long>()

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
        // Clears the expiry tick and any pending banner retry alike.
        mainHandler.removeCallbacksAndMessages(null)
        // Dismissing on stop is not a user dismissal: the request stays pending and
        // is re-presented on the next start(). The Snackbar's own callback ignores the
        // programmatic dismiss for the same reason.
        dialog?.setOnDismissListener(null)
        dialog?.dismiss()
        dialog = null
        banner?.dismiss()
        banner = null
        shownRequest = null
        // A new start is a new chance at the surface.
        displacedBanners.clear()
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
     * Drop a prompt whose request has since been invalidated — otherwise it stays on screen as a
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
        banner?.dismiss()
        banner = null
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

    /**
     * Whether the tab is actually waiting on an answer to [request] — an unsupported scheme with no
     * page behind it, a marketplace offer, or a navigation held under `blockWhilePrompting`. The
     * opposite is a banner over a page that already loaded, which the user can ignore indefinitely.
     */
    private fun blocksNavigation(request: PendingAppLinkRequest): Boolean =
        request.heldNavigation || request.urlClass != AppLinkUrlClass.BANNER

    /** Take down the banner without treating it as an answer; the request stays pending. */
    private fun retireBanner() {
        val shown = banner ?: return
        // Cleared first: the dismissal callback checks identity and so ignores this one.
        banner = null
        shownRequest = null
        mainHandler.removeCallbacks(expiryTick)
        shown.dismiss()
    }

    private fun showNext() {
        val pending = store.getPending(AppLinkPromptOwner.NATIVE_EXTERNAL)
            .filter { it.tabId == tabId }
        // A blocking prompt is served first. A passive banner lets the user keep using the page,
        // and tapping a `tel:` or `mailto:` link there raises a request that genuinely stalls a
        // navigation — that must not sit behind an offer the user is free to ignore for 90 seconds.
        val request = pending.firstOrNull(::blocksNavigation)
            ?: pending.firstOrNull { it.requestId !in displacedBanners }
            ?: return

        if (shownRequest?.requestId == request.requestId) return

        if (isShowing) {
            // Only a blocking prompt may take the surface, and only from a banner: a dialog that is
            // up is itself waiting on an answer and is not interrupted.
            if (!blocksNavigation(request) || dialog != null) return
            retireBanner()
        }

        val title = request.appName?.let {
            context.getString(R.string.weblibre_app_link_prompt_title_named, it)
        } ?: context.getString(R.string.weblibre_app_link_prompt_title_generic)

        // The page loaded behind this offer, so nothing is waiting on the answer: don't take the
        // screen for it.
        if (!blocksNavigation(request)) {
            showBanner(request, title)
            return
        }

        val built = AlertDialog.Builder(context)
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
            .create()
        // Identity-checked for the same reason the Snackbar callback is: this dialog's dismissal
        // arrives after `afterResolve` has already put the next one up, and clearing the reference
        // then would leave that one on screen with nothing tracking it.
        built.setOnDismissListener { if (dialog === built) dialog = null }

        dialog = built
        shownRequest = request
        built.show()
        scheduleExpiryTick(request)
    }

    /**
     * The non-modal surface: an offer over a page that is already readable.
     *
     * [Snackbar.LENGTH_INDEFINITE] rather than a timeout of its own, so the offer lives exactly as
     * long as the request does — [scheduleExpiryTick] takes it down on the store's deadline, the
     * same 90 s the Flutter banner gets.
     *
     * **Every dismissal clears the reference; only a swipe answers the request.** The two are
     * separate, and conflating them was a deadlock: a Snackbar can go away for reasons that have
     * nothing to do with this feature — another Snackbar replaces it (`DISMISS_EVENT_CONSECUTIVE`,
     * which any unrelated confirmation raises), we dismissed it ourselves, or the action was
     * tapped. Ignoring those events wholesale left [banner] pointing at something invisible, and
     * [isShowing] then refused every later prompt until expiry or a lifecycle restart. Treating
     * them as a user dismissal would be worse still: it would consume a request nobody answered.
     */
    private fun showBanner(request: PendingAppLinkRequest, title: String) {
        val snackbar = Snackbar.make(rootView, title, Snackbar.LENGTH_INDEFINITE)
            .setAction(R.string.weblibre_app_link_prompt_open) { resolveOpen(request) }
            .addCallback(
                object : BaseTransientBottomBar.BaseCallback<Snackbar>() {
                    override fun onDismissed(transientBottomBar: Snackbar?, event: Int) {
                        // A dismissal for a Snackbar we have already moved past says nothing about
                        // the current one.
                        if (banner !== transientBottomBar) return
                        banner = null

                        if (event == DISMISS_EVENT_SWIPE) {
                            // The user swept the offer away: that is an answer.
                            resolveDismiss(request)
                            return
                        }
                        if (event == DISMISS_EVENT_ACTION) {
                            // `resolveOpen` already ran and called `afterResolve`.
                            return
                        }
                        // Something else took the shared surface. The request is untouched and
                        // still pending, but this offer does not get to take the surface back:
                        // re-showing displaces whatever replaced us, and two started Custom Tab
                        // features would trade it back and forth for as long as both offers live.
                        //
                        // A passive banner is an offer over a page the user can already read, so
                        // losing it costs them nothing they were waiting for. A prompt that is
                        // actually blocking a navigation is not recorded here and still takes the
                        // surface when one arrives.
                        displacedBanners.add(request.requestId)
                        shownRequest = null
                        mainHandler.removeCallbacks(expiryTick)
                    }
                },
            )
        banner = snackbar
        shownRequest = request
        snackbar.show()
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
                // Guard the fallback against bouncing straight back out to an app (§2.7): a
                // validated fallback can itself resolve externally. The re-entry map does that
                // without taking the load out of the navigation delegate, which still has to vet a
                // page-supplied URL — sandbox capture above all. See [FALLBACK_LOAD_FLAGS].
                store.recordFallbackReentry(consumed.tabId, fallback)
                sessionUseCases.loadUrl(
                    url = fallback,
                    sessionId = consumed.tabId,
                    flags = FALLBACK_LOAD_FLAGS,
                )
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
        store.recordSuppression(consumed.tabId, consumed.suppressionKey)
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
        // The action's own dismiss is already under way; clearing the reference here is what lets
        // [showNext] put the following request up without waiting for the animation to finish.
        banner?.dismiss()
        banner = null
        shownRequest = null
        showNext()
    }

    private companion object {
        /** Never schedule a zero-delay expiry tick; a lapsed request would reschedule in a spin. */
        const val MIN_EXPIRY_TICK_MS = 250L

    }
}
