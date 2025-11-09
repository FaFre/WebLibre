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
const privateIdentifier = 'firefox-private'

type DoNotProxy = never[]
export const doNotProxy: DoNotProxy = []

const emergencyBreak: Socks5ProxyInfo = {
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

  async onRequest(requestDetails: Pick<_OnRequestDetails, 'cookieStoreId' | 'url' | 'tabId'>): Promise<DoNotProxy | ProxyInfo[]> {
    const tab = (requestDetails.tabId > -1) ? (await browser.tabs.get(requestDetails.tabId)) : null

    if (this.store.hasGeneralRelation() ||
      tab === null ||
      tab.cookieStoreId?.startsWith(containerIdentifier) === true ||
      tab.cookieStoreId === privateIdentifier
    ) {
      try {
        let cookieStoreId: string

        if (tab?.cookieStoreId?.startsWith(containerIdentifier) === true) {
          cookieStoreId = tab.cookieStoreId.substring(containerIdentifier.length)
        } else if (tab?.cookieStoreId === privateIdentifier) {
          // Handle private tabs - use 'private' as identifier
          cookieStoreId = 'private'
        } else {
          cookieStoreId = 'general'
        }

        let proxies = this.store.getProxiesForContainer(cookieStoreId)
        if ((proxies?.length ?? 0) == 0 && tab === null) {
          //When no tab is specified and general relation doesnt exist, we get all proxies to avoid leakage
          proxies = this.store.getAllProxies()

          if (proxies.length == 0) {
            return doNotProxy
          }
        } else if (proxies === null) {
          return doNotProxy
        }

        if (proxies.length > 0) {
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
            return [emergencyBreak]
          }
          return result
        }

        return [emergencyBreak]
      } catch (e: unknown) {
        console.error(`Error in onRequest listener: ${e as string}`)
        return [emergencyBreak]
      }
    }

    return doNotProxy
  }

  async onBeforeRequest(options: _OnBeforeRequestDetails, port: browser.runtime.Port): Promise<browser.webRequest.BlockingResponse> {
    const tab = (options.tabId > -1) ? (await browser.tabs.get(options.tabId)) : null

    if (options.frameId !== 0 || tab === null) {
      return {};
    }

    const url = URL.parse(options.url);
    if (url !== null && this.store.isSiteOriginAssigned(url)) {
      let cookieStoreId: string

      if (tab.cookieStoreId?.startsWith(containerIdentifier) === true) {
        cookieStoreId = tab.cookieStoreId.substring(containerIdentifier.length)
      } else if (tab.cookieStoreId === privateIdentifier) {
        // Handle private tabs - use 'private' as identifier
        cookieStoreId = 'private'
      } else {
        cookieStoreId = 'general'
      }

      if (this.store.isSiteOriginInSameContext(url, cookieStoreId)) {
        if (tab.highlighted) {
          port.postMessage({
            "type": "assignedSiteRequested",
            "id": options.requestId,
            "status": "success",
            "result": {
              "originUrl": options.originUrl,
              "url": options.url,
              "blocked": false
            }
          });

          return {};
        } else {
          //When tab not selected, block the request
          return {
            cancel: true,
          };
        }
      } else {
        //Only send events when tab is selected
        if (tab.highlighted) {
          port.postMessage({
            "type": "assignedSiteRequested",
            "id": options.requestId,
            "status": "success",
            "result": {
              "originUrl": options.originUrl,
              "url": options.url,
              "blocked": true
            }
          });
        }

        return {
          cancel: true,
        };
      }
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
