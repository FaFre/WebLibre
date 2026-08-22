/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.feature

import android.os.Handler
import android.os.Looper
import androidx.lifecycle.DefaultLifecycleObserver
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.ProcessLifecycleOwner
import java.lang.ref.WeakReference
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import mozilla.components.browser.state.action.AppLifecycleAction
import mozilla.components.browser.state.selector.findTabOrCustomTabOrSelectedTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession.SessionPriority
import mozilla.components.support.base.log.logger.Logger

/**
 * Mirrors the process lifecycle into the [BrowserStore], and keeps the visible
 * session's content process bindable at foreground importance across it.
 *
 * Two things happen when the app is backgrounded. GeckoView destroys the
 * surface, which makes that session's `BrowsingContext` inactive, and three
 * seconds later (`dom.ipc.processPriorityManager.backgroundGracePeriodMS`)
 * Gecko recomputes that process' priority. From then on the only thing keeping
 * it bound with `BIND_IMPORTANT` instead of as a plain — and readily reaped —
 * background service is `BrowserParent::mPriorityHint`.
 *
 * That hint does not survive a process switch. It lives on the `BrowserParent`,
 * is initialised to `false`, and nothing carries it over when a cross-process
 * navigation builds a successor. Android Components sets it once, from
 * `SessionPrioritizationMiddleware`, on tab selection and engine-session
 * linking — neither of which a fission process switch produces. So a tab that
 * has navigated across origins since it was selected silently loses the only
 * protection it had, and is the first thing the OS takes under memory pressure.
 *
 * Re-applying on pause is what closes that: it is the moment the hint starts to
 * matter, and one call covers however many process switches happened while the
 * tab was in the foreground.
 *
 * See https://github.com/FaFre/WebLibre/issues/495.
 */
object AppLifecycleFeature : DefaultLifecycleObserver {
    private val logger = Logger("AppLifecycleFeature")

    private var installed = false

    private val store: BrowserStore?
        get() = GlobalComponents.components?.core?.store

    /**
     * Session id of the browser fragment currently on screen, or `null` when
     * that is the main browser fragment (which follows the tab selection).
     *
     * The store has no notion of a "visible" custom tab: `selectedTabId` only
     * ever names a regular tab, so with a custom tab or PWA in front of the user
     * it points at something that is not on screen — or, in external mode, at
     * nothing at all. Prioritising by selection would then hold the wrong
     * process, or none.
     */
    @Volatile
    private var visibleSessionId: String? = null

    private var visibleSessionOwner: WeakReference<Any>? = null

    /**
     * Records which session the given fragment is showing.
     *
     * Called from `onResume` rather than on creation, so the fragment that is
     * actually in front wins when several exist (a custom tab over the main
     * browser).
     */
    @Synchronized
    fun setVisibleSession(owner: Any, sessionId: String?) {
        visibleSessionOwner = WeakReference(owner)
        visibleSessionId = sessionId
    }

    /**
     * Forgets [owner]'s session, if it is still the one on record.
     *
     * Deliberately *not* called from a fragment's `onPause`: the process
     * lifecycle dispatches its own pause after the activity's, so clearing there
     * would erase the very thing [onPause] is about to read. Fragment teardown is
     * the correct point.
     */
    @Synchronized
    fun clearVisibleSession(owner: Any) {
        if (visibleSessionOwner?.get() === owner) {
            visibleSessionOwner = null
            visibleSessionId = null
        }
    }

    /**
     * Observes the process lifecycle for as long as the process lives.
     *
     * Registration is deliberately not tied to a [BrowserStore] instance:
     * components are rebuilt when the process is promoted from external to full
     * mode, and an observer captured against the outgoing store would keep
     * prioritising tabs nothing renders any more. The current store is resolved
     * on each callback instead, and installing again is a no-op.
     *
     * Also installed for external-mode setups. Those still front an Activity for
     * custom tabs and PWAs, so the process lifecycle runs and their session is
     * prioritised exactly like a regular tab's; a genuinely headless setup (push
     * delivery) never advances past CREATED and simply never calls back.
     */
    fun install() {
        // Components can be built from a background thread on the headless
        // paths, and ProcessLifecycleOwner is main-thread only.
        Handler(Looper.getMainLooper()).post {
            if (installed) {
                return@post
            }

            installed = true
            ProcessLifecycleOwner.get().lifecycle.addObserver(this)
        }
    }

    override fun onPause(owner: LifecycleOwner) {
        val store = store ?: return

        store.dispatch(AppLifecycleAction.PauseAction)

        // Only the visible session is worth holding: it is the one the user comes
        // back to, and every other engine session is already at DEFAULT.
        // Resolves a custom tab / PWA by id, and falls back to the tab selection
        // for the main browser.
        val visible = store.state.findTabOrCustomTabOrSelectedTab(visibleSessionId)
        val engineSession = visible?.engineState?.engineSession
        if (engineSession == null) {
            return
        }

        engineSession.updateSessionPriority(SessionPriority.HIGH)
        logger.debug("Re-applied HIGH session priority to ${visible.id} for background")
    }

    override fun onResume(owner: LifecycleOwner) {
        store?.dispatch(AppLifecycleAction.ResumeAction)
    }
}
