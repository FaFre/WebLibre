import { Store } from '../store/Store'
import { HttpProxySettings, HttpsProxySettings, ProxySettings } from '../domain/ProxySettings'
import { ProxyInfo, Socks5ProxyInfo } from '../domain/ProxyInfo'
import { ProxyType } from '../domain/ProxyType'
import BlockingResponse = browser.webRequest.BlockingResponse
import _OnAuthRequiredDetails = browser.webRequest._OnAuthRequiredDetails
import _OnRequestDetails = browser.proxy._OnRequestDetails
import _OnBeforeRequestDetails = browser.webRequest._OnBeforeRequestDetails

const localhosts = new Set(['localhost', '127.0.0.1', '[::1]'])

const containerIdentifier = 'firefox-container-'
const defaultIdentifier = 'firefox-default'
const privateIdentifier = 'firefox-private'

/**
 * Result of the proxy listener meaning "connect directly", as distinct from
 * "no opinion".
 *
 * Mozilla's ProxyChannelFilter treats the two differently, and the difference
 * is what makes a fail-closed startup possible: an empty array resolves to
 * `defaultProxyInfo` (whatever the proxy prefs say, which during startup is a
 * deliberately dead proxy), whereas `null` overrides the prefs and connects
 * directly. Only a context the snapshot explicitly allows direct may return
 * this.
 */
export type DirectConnection = null
export const directConnection: DirectConnection = null

/**
 * Result meaning "no opinion — apply the configured proxy prefs". Returned by
 * nothing in the request path today; kept because it names the empty-array
 * semantics that the direct/blocked distinction is defined against.
 */
type InheritProxyPrefs = never[]
export const inheritProxyPrefs: InheritProxyPrefs = []

/**
 * A proxy that cannot connect, returned wherever routing must not go out.
 *
 * Not a hard block on its own, and cannot be made into one from here: Firefox
 * builds the returned array into a failover chain and terminates it with the
 * prefs-derived `defaultProxyInfo` (`ProxyInfoData.createProxyInfoFromData`
 * recurses past the end of the list and returns it). So a request that fails
 * against this proxy falls through to whatever the proxy prefs resolve to.
 *
 * What makes the fall-through safe is the app-side pref baseline
 * (`proxy_pref_baseline.dart`): while any context routes through a proxy it
 * pins the user branch to a dead SOCKS endpoint, so the end of the chain is
 * blocked too. The two are one mechanism — removing the baseline turns every
 * `emergencyBreak` here into a direct connection after the first failure.
 *
 * `failoverTimeout` is the blocklist duration after a failure, not a delay
 * before failing over (see nsIProxyInfo). Keep it at the minimum: a larger
 * value means this proxy is skipped for longer and requests reach the chain's
 * terminal sooner, which is the opposite of what is wanted here.
 */
export const emergencyBreak: Socks5ProxyInfo = {
  type: ProxyType.Socks5,
  host: 'emergency-break-proxy.localhost',
  port: 1,
  failoverTimeout: 1,
  username: 'nonexistent user',
  password: 'dummy password',
  proxyDNS: true
}

/**
 * How long a request may be held while no routing at all is known.
 *
 * Blocking is the right answer to "this context must not connect directly";
 * it is the wrong answer to "nobody has told us yet". The two are the same
 * state in a cold process — the store is empty until the native side seeds it
 * or the app pushes — and answering the second one with [emergencyBreak]
 * produces a proxy error page on whatever happened to load first, which for a
 * Custom Tab or a PWA is the page the user just opened and nothing in the
 * process is left to retry it.
 *
 * So requests that land in that window wait for routing instead of failing on
 * it. Nothing is decided while they wait, so nothing leaks. The budget covers
 * the app's own push path end to end — 30s to reach the extension plus 20s for
 * the acknowledgement (`container_proxy.dart`) — because a request failed at
 * 15s would be failed while the push that answers it is still legitimately in
 * flight. A wait that runs out means routing is not coming, and then the
 * emergency break is the answer after all.
 *
 * A provisional snapshot spends this same budget rather than the proxy-start
 * one below: it is routing that has not arrived yet, wearing last run's
 * answers.
 */
const ROUTING_WAIT_MS = 50_000

/**
 * How long a request routed through a proxy that has not published an endpoint
 * may be held while the app says that proxy is still starting.
 *
 * Counted from the first *live* snapshot that names this context's proxy as
 * starting, never from a provisional one. A provisional snapshot predates the
 * app's own startup — the seed is installed while components are built, and
 * autostart runs near the end of the Dart sequence — so a deadline opened there
 * would have spent an unknown part of itself on app initialization before the
 * proxy it is timing was even asked to come up.
 *
 * Normally left long before the budget: the app pushes again the moment the
 * start settles, and that push — endpoint or not — is what decides the request.
 * The budget is therefore a backstop against a start that neither succeeds nor
 * reports failing, and is sized for the slowest legitimate one, a Tor
 * bootstrap, which the app itself waits 90s for elsewhere
 * (`search_controller.dart`).
 */
const PROXY_START_WAIT_MS = 90_000

export default class BackgroundMain {
  store: Store

  /** Overridable so tests do not have to sit out the real budgets. */
  private readonly routingWaitMs: number
  private readonly proxyStartWaitMs: number

  constructor (
    { store, routingWaitMs, proxyStartWaitMs }:
    { store: Store, routingWaitMs?: number, proxyStartWaitMs?: number }
  ) {
    this.store = store
    this.routingWaitMs = routingWaitMs ?? ROUTING_WAIT_MS
    this.proxyStartWaitMs = proxyStartWaitMs ?? PROXY_START_WAIT_MS
  }

  /**
   * Re-checks `isSatisfied` on every snapshot the store applies, and reports
   * whether it ever held before `deadlineMs`.
   *
   * Both waits in the request path are this shape — "keep looking at the store
   * until it says something usable, then give up" — and both are deadlines
   * rather than durations, because a request that has already spent time
   * waiting may not spend the whole budget again on the next turn.
   */
  private async awaitSnapshotUntil(
    deadlineMs: number,
    isSatisfied: () => boolean
  ): Promise<boolean> {
    while (!isSatisfied()) {
      if (!await this.store.awaitSnapshot(deadlineMs - Date.now())) {
        return false
      }
    }

    return true
  }

  private async tabForRequest(tabId?: number): Promise<browser.tabs.Tab | null> {
    if (tabId === undefined || tabId <= -1) {
      return null
    }

    try {
      return await browser.tabs.get(tabId)
    } catch (e) {
      return null
    }
  }

  private contextIdFromCookieStoreId(cookieStoreId?: string): string | null {
    if (cookieStoreId === undefined || cookieStoreId.length === 0) {
      return null
    }
    if (cookieStoreId.startsWith(containerIdentifier)) {
      return cookieStoreId.substring(containerIdentifier.length)
    }
    if (cookieStoreId === privateIdentifier) {
      return 'private'
    }
    if (cookieStoreId === defaultIdentifier) {
      return 'general'
    }

    return cookieStoreId
  }

  /*
  initializeAuthListener(cookieStoreId: string, proxy: HttpProxySettings | HttpsProxySettings): void {
    const listener: (details: _OnAuthRequiredDetails) => BlockingResponse = (details) => {
      if (!details.isProxy) return {}

      if (details.cookieStoreId !== cookieStoreId) return {}

      // TODO: Fix in @types/firefox-webext-browser
      // @ts-expect-error
      const info = details.proxyInfo
      if (info.host !== proxy.host || info.port !== proxy.port || info.type !== proxy.type) return {}

      const result = { authCredentials: { username: proxy.username, password: proxy.password } }

      browser.webRequest.onAuthRequired.removeListener(listener)

      return result
    }

    browser.webRequest.onAuthRequired.addListener(
      listener,
      { urls: ['<all_urls>'] },
      ['blocking']
    )
  }
*/

  async onRequest(requestDetails: Pick<_OnRequestDetails, 'cookieStoreId' | 'url' | 'tabId'>): Promise<DirectConnection | ProxyInfo[]> {
    try {
      const unknownRoutingDeadline = Date.now() + this.routingWaitMs

      // Until the app has handed over an authoritative snapshot, routing is
      // unknown rather than absent. Nothing may be decided here, because the
      // store cannot tell a container that is meant to be direct from one whose
      // proxy relation simply has not arrived yet — so the request waits for
      // the answer instead of being refused one.
      //
      // A provisional snapshot is that same unknown state, and is waited out
      // the same way. It is last run's routing minus its endpoints, and the
      // app has not yet said whether it still holds: a container the user
      // moved onto Tor since reads as direct in it, and answering from it
      // would send the first request of the process out unproxied on routing
      // nobody has confirmed. Its site assignments are stale for the same
      // reason. So nothing at all is resolved until the live snapshot lands —
      // what the seed buys is not a faster answer but a *fail-closed* one, and
      // that it already provides by making the store ready.
      if (!await this.awaitSnapshotUntil(
        unknownRoutingDeadline,
        () => this.store.isReady() && !this.store.isProvisional(),
      )) {
        return [emergencyBreak]
      }

      // Opened by the first live snapshot that says this context's start is in
      // flight, not at the top: the two waits answer different questions, and a
      // request that spent its patience waiting for routing to exist has not
      // yet spent any waiting for a backend to come up.
      let proxyStartDeadline: number | undefined

      const tab = await this.tabForRequest(requestDetails.tabId)
      // `||` (not `??`) so an empty-string cookieStoreId on the tab falls
      // back to the request's cookieStoreId. Some extension code paths
      // surface `''` for tabs without an explicit container assignment,
      // which `??` would treat as a real value and stop the fallback.
      const cookieStoreId = (tab?.cookieStoreId || requestDetails.cookieStoreId)
      // Requests that belong to no tab and carry no cookie store — Gecko's own
      // background traffic — follow the general routing policy. Exempting them
      // would quietly punch a hole through a global proxy.
      const contextId = this.contextIdFromCookieStoreId(cookieStoreId) ?? 'general'

      for (;;) {
        const proxies = this.store.getProxiesForContainer(contextId)
        if (proxies === null) {
          // The snapshot resolves this context to no proxy: an explicit direct
          // decision, which must override the startup proxy prefs.
          return directConnection
        }

        if (proxies.length === 0) {
          // A relation exists but none of its proxies resolve — the backend is
          // not running yet, or its endpoint is gone. Never fall back to a
          // direct connection; the only question is whether to block now or to
          // wait for the snapshot that is already on its way.
          // Only this context's own backend still starting buys that wait; the
          // snapshot is live by now, so anything else is a decision, and a
          // decision is answered at once — the user gets the error page and the
          // "start this proxy?" prompt that goes with it.
          if (!this.store.isContextAwaitingProxy(contextId)) {
            return [emergencyBreak]
          }
          proxyStartDeadline ??= Date.now() + this.proxyStartWaitMs
          if (!await this.store.awaitSnapshot(proxyStartDeadline - Date.now())) {
            return [emergencyBreak]
          }
          // Re-resolve against the snapshot that just landed: it may carry the
          // endpoint this relation was missing, or route the context somewhere
          // else entirely.
          continue
        }

        // proxies.forEach(p => {
        //   if (p.type === ProxyType.Http || p.type === ProxyType.Https) {
        //     this.initializeAuthListener(cookieStoreId, p)
        //   }
        // })

        const result: ProxyInfo[] = proxies.filter((p: ProxySettings) => {
          try {
            const documentUrl = new URL(requestDetails.url)
            const isLocalhost = localhosts.has(documentUrl.hostname)
            if (isLocalhost && p.doNotProxyLocal) {
              return false
            }
          } catch (e) {
            console.error(e)
          }

          return true
        }).map(p => p.asProxyInfo())

        if (result.length === 0) {
          // Every proxy for this context declined the address (localhost with
          // doNotProxyLocal). That is a deliberate direct connection.
          return directConnection
        }
        return result
      }
    } catch (e: unknown) {
      console.error(`Error in onRequest listener: ${e as string}`)
      return [emergencyBreak]
    }
  }

  async onBeforeRequest(options: _OnBeforeRequestDetails, port: browser.runtime.Port): Promise<browser.webRequest.BlockingResponse> {
    const tab = (options.tabId > -1) ? (await browser.tabs.get(options.tabId)) : null

    if (options.frameId !== 0 || tab === null) {
      return {};
    }

    const url = URL.parse(options.url);
    if (url === null) {
      return {};
    }

    let cookieStoreId: string

    if (tab.cookieStoreId?.startsWith(containerIdentifier) === true) {
      cookieStoreId = tab.cookieStoreId.substring(containerIdentifier.length)
    } else if (tab.cookieStoreId === privateIdentifier) {
      // Handle private tabs - use 'private' as identifier
      cookieStoreId = 'private'
    } else {
      cookieStoreId = 'general'
    }

    // Private tabs are never strict. For other tabs, strict enforcement is
    // keyed on the tab's cookie-store context (base container context, or an
    // isolation context of a strict container's isolated tab).
    const isStrict = cookieStoreId !== 'private' &&
      this.store.isContextStrict(cookieStoreId)

    if (this.store.isSiteOriginAssigned(url)) {
      // In a strict context the site must be assigned to *this* container's own
      // base context (exact match, no proxy equivalence). Non-strict contexts
      // keep the looser proxy/direct-equivalence matching used for routing.
      const allowed = isStrict
        ? this.store.isSiteOriginStrictlyAllowed(url, cookieStoreId)
        : (cookieStoreId == 'private' || this.store.isSiteOriginInSameContext(url, cookieStoreId))

      if (allowed) {
        if (tab.highlighted) {
          port.postMessage({
            "type": "assignedSiteRequested",
            "id": options.requestId,
            "status": "success",
            "result": {
              "originUrl": options.originUrl,
              "url": options.url,
              "tabId": options.tabId,
              "blocked": false,
              "strict": false
            }
          });
        }

        // Allow requests when the assigned site already matches the current context,
        // even if the tab is not highlighted.
        return {};
      } else {
        // Assigned to a different container: cancel here and let the app re-open
        // it in its assigned container. This applies to strict contexts too —
        // the site still doesn't load here, it just routes to where it belongs.
        //Only send events when tab is selected
        if (tab.highlighted) {
          port.postMessage({
            "type": "assignedSiteRequested",
            "id": options.requestId,
            "status": "success",
            "result": {
              "originUrl": options.originUrl,
              "url": options.url,
              "tabId": options.tabId,
              "blocked": true,
              "strict": false
            }
          });
        }

        return {
          cancel: true,
        };
      }
    } else if (isStrict) {
      // Strict mode: this container may only load origins assigned to it. The
      // origin is not assigned to any container, so cancel the navigation and
      // report it as a strict block (no destination container).
      if (tab.highlighted) {
        port.postMessage({
          "type": "assignedSiteRequested",
          "id": options.requestId,
          "status": "success",
          "result": {
            "originUrl": options.originUrl,
            "url": options.url,
            "tabId": options.tabId,
            "blocked": true,
            "strict": true
          }
        });
      }

      return {
        cancel: true,
      };
    }

    return {};
  }

  run(browser: { proxy: any, webRequest: any }, port: browser.runtime.Port): void {
    browser.proxy.onRequest.addListener(this.onRequest.bind(this), { urls: ['<all_urls>'] })

    browser.proxy.onError.addListener((e: Error) => {
      console.error('Proxy error', e)
    })

    browser.webRequest.onBeforeRequest.addListener((options: _OnBeforeRequestDetails) => {
      return this.onBeforeRequest(options, port);
    }, { urls: ["<all_urls>"], types: ["main_frame"] }, ["blocking"])
  }
}
