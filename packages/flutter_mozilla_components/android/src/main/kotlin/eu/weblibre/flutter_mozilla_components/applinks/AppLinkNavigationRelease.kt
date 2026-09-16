/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import androidx.annotation.MainThread
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.store.BrowserStore
import mozilla.components.concept.engine.EngineSession
import mozilla.components.feature.session.SessionUseCases
import mozilla.components.support.base.log.logger.Logger

private val logger = Logger("AppLinkNavigationRelease")

/**
 * The flags for re-issuing a navigation the user chose to keep in the browser.
 *
 * [EngineSession.LoadUrlFlags.LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE] is load-bearing, not decoration:
 * GeckoView skips the navigation delegate entirely for a load carrying it
 * (`GeckoSession.shouldLoadUri`), so the load never re-enters [WebLibreAppLinksInterceptor] and
 * cannot raise a second prompt for the answer the user just gave. Suppression alone would not do it
 * — [AppLinkNavigationMiddleware] clears a tab's suppression on every `LoadUrlAction`, so a plain
 * re-issue would wipe the very decision it is acting on and prompt again, forever. The middleware
 * exempts loads carrying this flag for the same reason.
 *
 * **Only a URL the structural guards have already vetted may carry this.** Skipping the delegate
 * skips all of `AppRequestInterceptor`, not just the app-links tail: sandbox capture, PWA/TWA and
 * `weblibre://` go with it. A released navigation qualifies because it is the very URL that reached
 * the app-links tail a moment ago, which means those guards already let it through. A
 * page-supplied `browser_fallback_url` does not — see [FALLBACK_LOAD_FLAGS].
 *
 * `EXTERNAL` is deliberately absent, and that is a departure from the AC default rather than an
 * oversight: `RequestInterceptor.InterceptionResponse.Url` and AC's `AppLinksFeature` both set it.
 * The load is not arriving from another app — it is the page the user asked to stay in the browser
 * for — and marking it external pushes Gecko through a content-process switch, which surfaces as a
 * transient `about:blank` location change before the real target commits. Anything watching the
 * tab's URL then reacts to a page that is not there yet.
 */
internal val SELF_ISSUED_LOAD_FLAGS: EngineSession.LoadUrlFlags = EngineSession.LoadUrlFlags.select(
    EngineSession.LoadUrlFlags.LOAD_FLAGS_BYPASS_LOAD_URI_DELEGATE,
)

/**
 * The flags for loading a `browser_fallback_url`, from the interceptor and from either prompt.
 *
 * Plain, and both omissions matter. `EXTERNAL` is dropped for the reason given above. The bypass
 * flag is dropped because a fallback URL comes from the page: nothing has checked it yet, and a
 * load that skips the navigation delegate skips every structural guard in
 * `AppRequestInterceptor` — a sandbox-capture tab could reach the live web simply by offering an
 * `intent:` link whose fallback points there. The fallback therefore arrives as an ordinary
 * navigation and is recognised on the way back in by
 * [PendingAppLinkStore.isFallbackReentry], which stops it being re-classified as a fresh app link
 * without stopping anything else from inspecting it.
 *
 * One consequence is deliberate: a fallback issued from a prompt goes through `SessionUseCases`, so
 * [AppLinkNavigationMiddleware] sees its `LoadUrlAction` and clears the tab's suppression and
 * fallback claims. That is the right reading — the user tapped "open", the app would not open, and
 * this is the page they get instead — and the re-entry map, not the claim budget, is what keeps the
 * load itself from being offered straight back to an app.
 */
internal val FALLBACK_LOAD_FLAGS: EngineSession.LoadUrlFlags = EngineSession.LoadUrlFlags.none()

/**
 * Load the navigation [request] was holding, if it was holding one and the tab is still where the
 * hold left it.
 *
 * Under `blockWhilePrompting` the interceptor answers a prompted engine-supported navigation with
 * `Deny`, so the tab stays on its previous page (or stays blank, for a link that opened a new tab)
 * while the prompt is up. An explicit "stay in browser" choice owes the tab that page, as does a
 * launch that failed with no fallback. Passive dismissal and expiry deliberately do nothing and do
 * not route here.
 *
 * A no-op when the request was not holding a navigation — the non-blocking path, where the page is
 * already on screen; every unsupported-scheme prompt, where there was never a loadable page; and
 * every subframe navigation, which is never held because this load is tab-level and would replace
 * the whole page rather than the frame.
 *
 * **The debt expires the moment the tab goes somewhere else.** A prompt outlives its page — that is
 * the deliberate design of [PendingAppLinkStore] — so by the time the user dismisses a banner, or
 * its 90 seconds run out, the tab may be showing something entirely unrelated. Loading the old
 * target over it is the one thing a prompt must never do, and it is not hypothetical: the request
 * survives Back, Forward, reload, an in-page link, and any number of direct loads.
 *
 * Deciding that here, rather than invalidating the hold when a navigation happens, is what makes it
 * safe under every ordering. There is no store action that reliably means "the user has moved on":
 * GeckoView short-circuits the navigation delegate for direct loads (`GeckoSession.load`), so the
 * interceptor runs *inside* `engineSession.loadUrl()` and any subsequent action would clear a hold
 * created microseconds earlier; while in-page links, Back/Forward and reload dispatch no load action
 * at all.
 *
 * [PendingAppLinkStore.claimRelease] makes the call against three things at once — the tab's
 * navigation generation, whether a newer hold has appeared, and the committed URL. The generation
 * catches a navigation that has *started* but not painted, which the URL alone cannot see; the
 * newer-hold check covers the window in which this request is already detached and nothing outside
 * could cancel it.
 *
 * Fragments are ignored, so an in-page anchor does not count as leaving. A same-document URL rewrite
 * (`history.pushState`) does count, and skips the release: the user keeps the page they are already
 * reading, which is the safe direction — they are left with a page either way, never a blank tab.
 *
 * The two checks disagree in one case, and the generation wins on purpose: moving through session
 * history between `page` and `page#section` advances the generation while leaving the anchor
 * matching, so the release is refused and the user's "stay in browser" does nothing that time. The
 * alternative — trusting the anchor whenever the generation has moved — would reopen the whole point
 * of the generation, which is to see a navigation that has *started* and not yet committed. A tap
 * that does nothing once is the better failure than a page replaced out from under the reader.
 *
 * One window remains, and it is not closable from here: a navigation may begin between the claim and
 * `loadUrl` below. The store's lock cannot be held across the load — see the [PendingAppLinkStore]
 * KDoc on never holding it across a side effect.
 *
 * **Callers must invoke this on the main thread**, which is what keeps that window to a few
 * instructions rather than a genuine race. Navigation runs on the UI thread, and so does the engine
 * work `loadUrl` reaches; claiming from a background dispatcher would let a navigation start and
 * commit in the gap, and would also hand the engine session a load from the wrong thread.
 */
@MainThread
internal fun releaseHeldNavigation(
    pendingStore: PendingAppLinkStore,
    browserStore: BrowserStore,
    sessionUseCases: SessionUseCases,
    request: PendingAppLinkRequest,
    reason: String,
) {
    if (!request.heldNavigation) return
    // Belt and braces: `heldNavigation` is only ever set for an engine-supported target, and
    // handing an unsupported scheme to the engine would strand the tab differently.
    if (!request.engineSupportsScheme) return

    val tab = browserStore.state.findTabOrCustomTab(request.tabId)
    if (tab == null) {
        logger.info("release skipped ($reason): tab ${request.tabId} is gone")
        return
    }

    // The store has the last word, under its own lock and against state it still owns: the tab's
    // navigation generation, any newer hold, and the committed URL. Everything up to here is a
    // prerequisite; this is the decision.
    if (!pendingStore.claimRelease(request, tab.content.url)) {
        logger.info(
            "release skipped ($reason): tab ${request.tabId} moved on " +
                "(anchor=${request.heldAnchorUrl} now=${tab.content.url} gen=${request.navGeneration})",
        )
        return
    }

    logger.info(
        "release LOADING ($reason) tab=${request.tabId} url=${request.url} flags=${SELF_ISSUED_LOAD_FLAGS.value}",
    )
    sessionUseCases.loadUrl(
        url = request.url,
        sessionId = request.tabId,
        flags = SELF_ISSUED_LOAD_FLAGS,
    )
}

/**
 * Whether [current] is still the page [anchor] named, ignoring the fragment.
 *
 * A null anchor is a request from before anchors were recorded; treat it as matching rather than
 * stranding a navigation that has no way to prove itself.
 */
internal fun isSameDocumentTarget(current: String, anchor: String?): Boolean {
    if (anchor == null) return true
    return current.substringBefore('#') == anchor.substringBefore('#')
}
