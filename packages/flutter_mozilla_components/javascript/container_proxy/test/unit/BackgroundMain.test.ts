import BackgroundMain, { directConnection, emergencyBreak } from '../../src/background/BackgroundMain'
import { RoutingSnapshot, Store } from '../../src/store/Store'

import { expect } from 'chai'
import { ProxySettings } from '../../src/domain/ProxySettings'
const tryFromDao = ProxySettings.tryFromDao

/* eslint-disable @typescript-eslint/no-unused-expressions */

const chrome = require('sinon-chrome/extensions');

let store: Store
let backgroundMain: BackgroundMain

function emptySnapshot (overrides: Partial<RoutingSnapshot> = {}): RoutingSnapshot {
  return {
    generation: 1,
    proxies: [],
    relations: {},
    directScopes: {},
    siteAssignments: {},
    strictContexts: {},
    ...overrides
  }
}

// Short enough that the "routing never arrives" tests do not sit out a real
// cold-start budget, long enough that a snapshot applied in a later turn still
// lands inside it.
const routingWaitMs = 50
const proxyStartWaitMs = 50

describe('BackgroundMain', function () {
  beforeEach(() => {
    global.browser = chrome
    store = new Store()
    backgroundMain = new BackgroundMain({ store, routingWaitMs, proxyStartWaitMs })
  })

  afterEach(() => {
    // @ts-expect-error
    delete global.browser
  })

  describe('onRequest', function () {
    it('should block every request when no snapshot ever arrives', async () => {
      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      expect(result).to.be.deep.equal([emergencyBreak])
    })

    it('should block a container request when no snapshot ever arrives', async () => {
      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
    })

    it('should block tabless requests when no snapshot ever arrives', async () => {
      const result = await backgroundMain.onRequest({ url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
    })

    it('should hold a request until the first snapshot arrives instead of blocking it', async () => {
      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      // The store is still empty at this point: the request is waiting, not
      // being answered with the emergency break.
      store.applySnapshot(emptySnapshot())

      expect(await pending).to.be.equal(directConnection)
    })

    it('should route a held request through the proxy the late snapshot names', async () => {
      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    it('should hold a request routed by a provisional snapshot until the endpoint arrives', async () => {
      // What a native seed looks like: relations restored from the last run,
      // endpoints deliberately left out because they die with their backend.
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: { container1: ['proxy1'] },
        provisional: true
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    // The sequence a cold start actually produces: the native seed, then the
    // app's first push — which carries relations but not yet the endpoints of
    // the backends it is still starting. Answering that push as final is what
    // released held requests straight into the error page they were waiting to
    // avoid; the app marks it provisional too, and only the snapshot that
    // reports the start settled ends the wait.
    it('should keep holding across a provisional push that still has no endpoint', async () => {
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: { container1: ['proxy1'] },
        provisional: true
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      // The app's first push: routing is known, the backend is not up yet and
      // the app says so by naming it.
      store.applySnapshot(emptySnapshot({
        generation: 1,
        relations: { container1: ['proxy1'] },
        awaitingProxies: ['proxy1']
      }))

      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    it('should block once a push reports the start settled without an endpoint', async () => {
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: { container1: ['proxy1'] },
        provisional: true
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      // The start failed or was never made: nothing is coming, so the user gets
      // the error page and the "start this proxy?" prompt without sitting out
      // the rest of the budget.
      const started = Date.now()
      store.applySnapshot(emptySnapshot({
        generation: 2,
        relations: { container1: ['proxy1'] }
      }))

      expect(await pending).to.be.deep.equal([emergencyBreak])
      expect(Date.now() - started).to.be.lessThan(proxyStartWaitMs)
    })

    it('should hold a request whose own backend is still starting', async () => {
      store.applySnapshot(emptySnapshot({
        relations: { container1: ['proxy1'] },
        awaitingProxies: ['proxy1']
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    it('should not hold a request behind an unrelated backend that is starting', async () => {
      // Tor is coming up for some other container; this one routes through a
      // sing-box profile nobody is starting, and must fail at once.
      store.applySnapshot(emptySnapshot({
        relations: { container1: ['proxy1'], container2: ['tor'] },
        awaitingProxies: ['tor']
      }))

      const started = Date.now()
      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
      expect(Date.now() - started).to.be.lessThan(proxyStartWaitMs)
    })

    it('should hold a context that inherits a general relation still starting', async () => {
      store.applySnapshot(emptySnapshot({
        relations: { general: ['proxy1'] },
        awaitingProxies: ['proxy1']
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      givenSomeProxyIsSetUpForContainer({ containerId: 'general', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    // The seed is last run's routing, and "direct" in it is not a decision —
    // it is what this context happened to resolve to before the user moved it
    // onto a proxy. Releasing the first request of the process on it is a leak
    // that no later snapshot can take back.
    it('should not connect directly on a provisional snapshot that says so', async () => {
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: {},
        provisional: true
      }))

      const pending = backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      // The live push: this container routes through Tor after all.
      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: 'proxyX.example.com', doNotProxyLocal: undefined })

      const result = await pending
      expect(result).to.be.an('array')
      expect(result![0].host).to.be.equal('proxyX.example.com')
    })

    // The provisional wait is the routing wait, not the proxy-start one: the
    // seed is installed while components are built, long before Dart gets round
    // to starting anything, so a proxy-start deadline opened there would have
    // spent itself on app startup rather than on the proxy.
    it('should not spend the proxy-start budget waiting out a provisional seed', async () => {
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: { container1: ['proxy1'] },
        provisional: true
      }))

      const started = Date.now()
      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
      // Both budgets are 50ms here, so what this pins is that the two are not
      // spent one after the other.
      expect(Date.now() - started).to.be.lessThan(routingWaitMs + proxyStartWaitMs)
    })

    it('should block a provisionally routed request when no push follows', async () => {
      store.applySnapshot(emptySnapshot({
        generation: 0,
        relations: { container1: ['proxy1'] },
        provisional: true
      }))

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
    })

    it('should not wait for a successor when a seed is the final routing', async () => {
      store.applySnapshot(emptySnapshot({ generation: 0, relations: { container1: ['proxy1'] } }))

      const started = Date.now()
      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.deep.equal([emergencyBreak])
      expect(Date.now() - started).to.be.lessThan(routingWaitMs)
    })

    it('should connect directly once an empty snapshot says so', async () => {
      store.applySnapshot(emptySnapshot())

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      expect(result).to.be.equal(directConnection)
    })

    it('should return proxy if proxy is set up', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'general', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      expect(result).to.be.an('array')
      expect(result).to.be.not.empty
    })

    it('should not use an unrelated container proxy for default tabs', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.equal(directConnection)
    })

    it('should use request cookieStoreId when no tab is available', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect(result).to.be.an('array')
      expect(result).to.be.not.empty
    })

    it('should route tabless requests without a cookie store through the general relation', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'general', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ url: 'https://google.com', tabId: -1 })

      expect(result).to.be.an('array')
      expect(result).to.be.not.empty
    })

    it('should connect tabless requests directly when the general relation is direct', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ url: 'https://google.com', tabId: -1 })

      expect(result).to.be.equal(directConnection)
    })

    it('should block if an assigned proxy no longer exists', async () => {
      store.applySnapshot(emptySnapshot({ relations: { general: ['missing-proxy'] } }))

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      expect(result).to.be.deep.equal([emergencyBreak])
    })

    it('should remove doNotProxyLocal flag from proxy settings if proxy is set up', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'general', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'https://google.com', tabId: 0 })

      expect((result![0] as any).doNotProxyLocal).to.be.undefined
    })

    it('should preserve proxyDNS on SOCKS proxy settings', async () => {
      givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url: 'https://google.com', tabId: -1 })

      expect((result![0] as any).proxyDNS).to.be.true
    })

    it('should return proxy for the container if url is invalid', async () => {
      // To be more on a safe side
      givenSomeProxyIsSetUpForContainer({ containerId: 'general', host: undefined, doNotProxyLocal: undefined })

      const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-default', url: 'np-protocol-url.com', tabId: 0 })

      expect(result).to.be.an('array')
      expect(result).to.be.not.empty
    })

    // Connections to localhost, 127.0.0.1, and ::1 are never proxied. (From FF settings)
    const localAddresses = [
      'http://localhost/index.html',
      'https://localhost/index.html',
      'http://127.0.0.1/',
      'https://127.0.0.1/',
      'http://[::1]/test',
      'https://[::1]/test',
      'http://[0:0:0:0:0:0:0:1]/test',
      'https://[0:0:0:0:0:0:0:1]/test',
      'https://user:password@127.0.0.1:123/',
      'http://[::1]:123/test'
    ]

    describe('proxying of local addresses is disabled', () => {
      localAddresses.forEach(url => {
        it(`should connect directly if the address is local: ${url}`, async () => {
          givenSomeProxyIsSetUpForContainer({ containerId: 'container1', host: undefined, doNotProxyLocal: true })

          const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url, tabId: -1 })

          expect(result).to.be.equal(directConnection)
        })
      })
    })

    describe('proxying of local addresses is enabled', () => {
      localAddresses.forEach(url => {
        it(`should return array with proxy: ${url}`, async () => {
          const host = 'proxyX.example.com'
          givenSomeProxyIsSetUpForContainer({ host, containerId: 'container1', doNotProxyLocal: false })

          const result = await backgroundMain.onRequest({ cookieStoreId: 'firefox-container-container1', url, tabId: -1 })

          expect(result![0].host).to.be.equal(host)
        })
      })
    })
  })
})

function givenSomeProxyIsSetUpForContainer ({ host, containerId, doNotProxyLocal }: any): void {
  const proxyId = 'proxy1'
  const proxy: any = {
    id: proxyId,
    type: 'socks',
    host: (host as string) ?? 'example.com',
    port: 1080
  }
  if (typeof doNotProxyLocal !== 'undefined') {
    proxy.doNotProxyLocal = doNotProxyLocal
  }

  store.applySnapshot(emptySnapshot({
    proxies: [(tryFromDao(proxy) as ProxySettings).asDao()],
    relations: { [containerId as string]: [proxyId] }
  }))
}
