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

export default class BackgroundMain {
  store: Store

  constructor({ store }: { store: Store }) {
    this.store = store
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
      // Until the app has handed over an authoritative snapshot, routing is
      // unknown rather than absent. Everything is blocked, because the store
      // cannot tell a container that is meant to be direct from one whose
      // proxy relation simply has not arrived yet.
      if (!this.store.isReady()) {
        return [emergencyBreak]
      }

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

      const proxies = this.store.getProxiesForContainer(contextId)
      if (proxies === null) {
        // The snapshot resolves this context to no proxy: an explicit direct
        // decision, which must override the startup proxy prefs.
        return directConnection
      }
      if (proxies.length === 0) {
        // A relation exists but none of its proxies resolve — the backend is
        // not running yet, or its endpoint is gone. Block rather than fall back.
        return [emergencyBreak]
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
