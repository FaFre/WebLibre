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
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store

/**
 * Observes the [BrowserStore] and drives [PendingAppLinkStore] tab teardown and suppression
 * clearing (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.6):
 *
 * - tab close / Custom Tab removal invalidates the tab's pending requests and suppression, and
 *   tells the owning surface to re-query so no dead prompt is left on screen;
 * - a new user-initiated/direct navigation (omnibar, bookmark, typed URL — which dispatch a
 *   `LoadUrlAction`) clears the tab's suppression and its fallback-issue claims. In-page
 *   redirects do not dispatch these actions — nor does the interceptor's own
 *   `InterceptionResponse.Url`, which the engine session loads directly — so the redirect-loop
 *   defences stay intact and the user keeps a way to ask for the fallback again.
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
                this.store.clearSuppressionForTab(action.tabId)
                this.store.clearFallbackIssuedForTab(action.tabId)
            }

            is EngineAction.OptimizedLoadUrlTriggeredAction -> {
                this.store.clearSuppressionForTab(action.tabId)
                this.store.clearFallbackIssuedForTab(action.tabId)
            }

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

            else -> {}
        }

        next(action)
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
