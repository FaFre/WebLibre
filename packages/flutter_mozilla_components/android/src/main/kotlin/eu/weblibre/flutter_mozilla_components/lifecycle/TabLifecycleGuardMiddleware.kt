/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.lifecycle

import mozilla.components.browser.state.action.BrowserAction
import mozilla.components.browser.state.action.ContentAction
import mozilla.components.browser.state.action.CustomTabListAction
import mozilla.components.browser.state.action.EngineAction
import mozilla.components.browser.state.action.RestoreCompleteAction
import mozilla.components.browser.state.action.TabListAction
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.BrowserState
import mozilla.components.lib.state.Middleware
import mozilla.components.lib.state.Store
import mozilla.components.support.base.log.logger.Logger

/**
 * Keeps a tab held asleep ([TabLifecycleRegistry]) without an engine session
 * (boundary B1 in section 3.6 of `plans/TAB_LOCK_AND_FREEZE_IMPLEMENTATION_PLAN.md`).
 *
 * - [EngineAction.CreateEngineSessionAction] for a held tab, or a tab whose
 *   context is restricted (a frozen container, or recovery), is dropped, and with
 *   it the action that was to follow the creation (a load, a reload, going back).
 *   Nothing is queued: a background or add-on load leaves the tab asleep, and the
 *   app wakes a tab before it navigates it on the user's behalf (5.2.1). A
 *   creation accepted before the hold is stopped by AC's creation gate (B2).
 *   A desktop mode toggle is the one follow-up kept, as the tab's own mode.
 * - [EngineAction.LinkEngineSessionAction] into a held tab means a creation path
 *   got past both (B3). Reported, and an assertion failure in debug builds; the
 *   session is still linked, because a dropped link would leak it.
 * - A session linked while its tab's context is restricted ([RestrictedSessions])
 *   only ever holds an empty page, because Gecko refuses its restore: its state
 *   updates are dropped, so the tab's saved state survives (spike S1).
 * - A removal forgets the holds of the tabs it removed, after it went through.
 * - The end of the session restore drops holds of tabs that did not come back.
 *
 * Only drops actions and records, so it sits before everything that reacts to
 * sessions being created.
 */
class TabLifecycleGuardMiddleware(
    private val registry: TabLifecycleRegistry = TabLifecycleRegistry,
    private val assertInvariants: Boolean = false,
    private val restricted: RestrictedSessions = RestrictedSessions,
) : Middleware<BrowserState, BrowserAction> {
    private val logger = Logger("TabLifecycleGuard")

    override fun invoke(
        store: Store<BrowserState, BrowserAction>,
        next: (BrowserAction) -> Unit,
        action: BrowserAction,
    ) {
        when (action) {
            is EngineAction.CreateEngineSessionAction -> {
                val contextId = store.state.findTabOrCustomTab(action.tabId)?.contextId
                if (!registry.maySessionBeCreated(action.tabId, contextId)) {
                    logger.debug("Tab ${action.tabId} is asleep or its context frozen; not creating its session")
                    // A desktop mode asked for meanwhile (a site rule) is kept
                    // in the tab's state, which the session takes when it is
                    // created: dropped, the tab would wake in the other mode
                    // than the one the app shows.
                    (action.followupAction as? EngineAction.ToggleDesktopModeAction)?.let { toggle ->
                        next(ContentAction.UpdateTabDesktopMode(toggle.tabId, toggle.enable))
                    }
                    return
                }
            }

            is EngineAction.LinkEngineSessionAction -> {
                if (registry.isHeld(action.tabId)) {
                    val message = "A session was linked into tab ${action.tabId}, which is asleep"
                    logger.error(message)
                    check(!assertInvariants) { message }
                }
                val contextId = store.state.findTabOrCustomTab(action.tabId)?.contextId
                if (restricted.onLinked(action.tabId, contextId, action.engineSession)) {
                    logger.warn("Tab ${action.tabId} got a session while its context is restricted; its state is not saved")
                }
            }

            is EngineAction.UnlinkEngineSessionAction -> {
                next(action)
                restricted.onUnlinked(listOf(action.tabId))
                return
            }

            is EngineAction.UpdateEngineSessionStateAction -> {
                val linkedWhileRestricted = restricted.wasLinkedWhileRestricted(action.tabId) {
                    store.state.findTabOrCustomTab(action.tabId)?.engineState?.engineSession
                }
                if (linkedWhileRestricted) {
                    // An empty about:blank (E8 refused its restore): it would
                    // replace the tab's history with nothing.
                    logger.debug("Not saving the state of tab ${action.tabId}: its session was linked while restricted")
                    return
                }
            }

            is TabListAction.RemoveTabAction,
            is TabListAction.RemoveTabsAction,
            is TabListAction.RemoveAllTabsAction,
            is TabListAction.RemoveAllNormalTabsAction,
            is TabListAction.RemoveAllPrivateTabsAction,
            is CustomTabListAction.RemoveCustomTabAction,
            is CustomTabListAction.RemoveAllCustomTabsAction,
            -> {
                // Ask the reducer which went rather than mirroring its rules.
                // Custom tabs too: their sessions can be linked while
                // restricted, and closed ones must not stay tracked.
                val before = store.state.tabs.map { it.id } + store.state.customTabs.map { it.id }
                next(action)
                val after = store.state.tabs.mapTo(mutableSetOf()) { it.id }
                store.state.customTabs.mapTo(after) { it.id }
                val removed = before.filterNot { it in after }
                registry.forget(removed)
                restricted.onUnlinked(removed)
                return
            }

            is RestoreCompleteAction -> {
                next(action)
                registry.retainOnly(store.state.tabs.mapTo(mutableSetOf()) { it.id })
                return
            }

            else -> Unit
        }

        next(action)
    }
}
