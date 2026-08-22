/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.middleware

import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.applinks.NativeAppLinkPromptNotifier
import eu.weblibre.flutter_mozilla_components.applinks.PendingAppLinkStore
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.concept.engine.EngineSession
import mozilla.components.lib.state.Store

/**
 * Observes the [BrowserStore] and drives [PendingAppLinkStore] tab teardown and suppression
 * clearing (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.6):
 *
 * - tab close / Custom Tab removal invalidates the tab's pending requests and suppression, and
 *   tells the owning surface to re-query so no dead prompt is left on screen. Bulk closes name no
 *   tab, so they reconcile against the surviving tabs after the reducer ([retainLiveTabs]);
 * - a new user-initiated/direct navigation (omnibar, bookmark, typed URL — which dispatch a
 *   `LoadUrlAction`) clears the tab's suppression and its fallback-issue claims. In-page
 *   redirects do not dispatch these actions — nor does the interceptor's own
 *   `InterceptionResponse.Url`, which the engine session loads directly — so the redirect-loop
 *   defences stay intact and the user keeps a way to ask for the fallback again. A load we issued
 *   ourselves to release a held prompt is exempt; see [clearForUserNavigation].
 *
 * It deliberately does **not** invalidate prompts on navigation: see the [PendingAppLinkStore]
 * KDoc for the three per-document signals that were tried and why none of them can express
 * "the user left this page".
 */
class AppLinkNavigationMiddleware(
    private val store: PendingAppLinkStore,
) : Middleware<BrowserState, BrowserAction> {
    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is EngineAction.LoadUrlAction -> {
                clearForUserNavigation(action.tabId, action.flags)
            }

            is EngineAction.OptimizedLoadUrlTriggeredAction -> {
                clearForUserNavigation(action.tabId, action.flags)
            }

            // Engine-delegated navigations that never reach the interceptor, so nothing else
            // advances the generation for them (`EngineDelegateMiddleware` hands each straight to
            // the engine session). Unlike the load actions, these carry no ordering hazard: they are
            // commands dispatched *before* the engine acts, not the trailing half of a call that
            // already ran the interceptor inline, so bumping here cannot cancel a hold that this
            // same navigation raised.
            //
            // Back and forward are gated on the tab actually having somewhere to go. AC dispatches
            // them to the engine unconditionally, so at a history boundary Gecko does nothing —
            // and an ungated bump would then refuse a release the tab never moved away from,
            // turning "stay in browser" into a tap that does nothing.
            is EngineAction.GoBackAction ->
                bumpIf(store, action.tabId, "goBack") { it.content.canGoBack }

            is EngineAction.GoForwardAction ->
                bumpIf(store, action.tabId, "goForward") { it.content.canGoForward }

            is EngineAction.GoToHistoryIndexAction ->
                bumpIf(store, action.tabId, "historyIndex") {
                    it.content.history.currentIndex != action.index
                }

            is EngineAction.ReloadAction ->
                this.store.beginNavigation(action.tabId, reason = "reload")

            is EngineAction.LoadDataAction ->
                this.store.beginNavigation(action.tabId, reason = "loadData")

            // `EngineDelegateMiddleware` always passes `reload = true`, so this is always a
            // navigation even though it reads like a setting change.
            is EngineAction.ToggleDesktopModeAction ->
                this.store.beginNavigation(action.tabId, reason = "desktopMode")

            is TabListAction.RemoveTabAction -> {
                notifyInvalidated(action.tabId, this.store.invalidateTab(action.tabId))
            }

            is TabListAction.RemoveTabsAction -> {
                action.tabIds.forEach { tabId ->
                    notifyInvalidated(tabId, this.store.invalidateTab(tabId))
                }
            }

            is CustomTabListAction.RemoveCustomTabAction -> {
                notifyInvalidated(action.tabId, this.store.invalidateTab(action.tabId))
            }

            // Bulk closes name no tab, so there is nothing to invalidate up front. Let the reducer
            // run and reconcile against what survived instead of mirroring its rules here.
            is TabListAction.RemoveAllTabsAction,
            is TabListAction.RemoveAllNormalTabsAction,
            is TabListAction.RemoveAllPrivateTabsAction,
            is CustomTabListAction.RemoveAllCustomTabsAction,
            -> {
                next(action)
                retainLiveTabs(store)
                return
            }

            else -> {}
        }

        next(action)
    }

    /**
     * Advance the tab's navigation generation only when the action will really move it.
     *
     * A bump that no navigation follows is not harmless: the held prompt then answers for a
     * navigation the store thinks is over, and the release is refused even though the tab never left
     * the page. Erring the other way would overwrite a page the user is reading, so the guard is
     * kept tight rather than dropped.
     */
    private inline fun bumpIf(
        store: Store<BrowserState, BrowserAction>,
        tabId: String,
        reason: String,
        predicate: (mozilla.components.browser.state.state.SessionState) -> Boolean,
    ) {
        val tab = store.state.findTabOrCustomTab(tabId) ?: return
        if (predicate(tab)) {
            this.store.beginNavigation(tabId, reason = reason)
        }
    }

    /**
     * Drop prompts and held debt belonging to tabs a bulk close removed.
     *
     * Without this a close-all leaves a prompt pending against a tab id that no longer exists — and
     * under blocking mode, a debt that would load its page into that id. "Undo close" restores the
     * tab under the same id, so the stale prompt would come back with it and could rewrite the
     * restored page.
     */
    private fun retainLiveTabs(store: Store<BrowserState, BrowserAction>) {
        val live = store.state.tabs.mapTo(mutableSetOf()) { it.id }
        store.state.customTabs.mapTo(live) { it.id }
        for ((tabId, owners) in this.store.retainTabs(live)) {
            notifyInvalidated(tabId, owners)
        }
    }

    /**
     * A new user-initiated/direct navigation releases the tab's suppression and fallback claims —
     * unless it is a navigation *we* re-issued to release a held prompt
     * ([RELEASE_LOAD_FLAGS]), which is the opposite of a fresh user intent: it is the tab finally
     * loading the page the user chose the browser for.
     *
     * Without the exemption blocking mode is an infinite prompt loop. Declining records suppression
     * and then loads the page; that load lands here, clears the suppression it was issued under, and
     * the site's next attempt at the same target prompts all over again. It also throws away the
     * 10-minute quiet period the user earned by answering.
     */
    private fun clearForUserNavigation(tabId: String, flags: EngineSession.LoadUrlFlags) {
        if (flags.contains(EngineSession.LoadUrlFlags.LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE)) return
        this.store.clearSuppressionForTab(tabId)
        this.store.clearFallbackIssuedForTab(tabId)
        // Deliberately does *not* touch held navigations. GeckoView short-circuits the navigation
        // delegate for direct loads, running the interceptor inline inside `engineSession.loadUrl()`
        // before `SessionUseCases` dispatches the action that lands here — so a hold taken by an
        // omnibar or bookmark navigation would be cleared by its own load. Whether releasing is
        // still safe is decided at release time instead; see [releaseHeldNavigation].
    }

    /**
     * Nudge each affected surface to re-query the pending store. The event is the same
     * "prompts changed" signal the interceptor sends on creation — the query is authoritative, so
     * a lost event only delays the cleanup to the next resume.
     */
    private fun notifyInvalidated(tabId: String, owners: Set<AppLinkPromptOwner>) {
        for (owner in owners) {
            when (owner) {
                AppLinkPromptOwner.NATIVE_EXTERNAL ->
                    NativeAppLinkPromptNotifier.notifyPromptAvailable(tabId)

                AppLinkPromptOwner.FLUTTER_BROWSER ->
                    GlobalComponents.appLinkEvents
                        ?.onAppLinkPromptAvailable(EventSequence.next(), owner) { _ -> }
            }
        }
    }
}
