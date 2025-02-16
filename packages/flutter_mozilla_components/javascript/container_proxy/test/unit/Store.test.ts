import { ProxyDao, Store } from '../../src/store/Store'
import webExtensionsApiFake from 'webextensions-api-fake'

import { expect } from 'chai'
import { ProxySettings } from '../../src/domain/ProxySettings'
const tryFromDao = ProxySettings.tryFromDao

/* eslint-disable @typescript-eslint/no-unused-expressions */

describe('Store', () => {
  const store = new Store()

  beforeEach(() => {
    (global as any).browser = webExtensionsApiFake()
  })

  afterEach(() => {
    delete (global as any).browser
  })

  function someProxyWith(id: string, props: Partial<ProxyDao> = {}): ProxySettings {
    const dao = {
      id: id,
      title: 'some title',
      type: 'socks',
      host: 'localhost',
      port: 1080,
      username: 'user',
      password: 'password',
      proxyDNS: true,
      failoverTimeout: 5,
      doNotProxyLocal: true
    }
    return tryFromDao({ ...dao, ...props }) as ProxySettings
  }

  describe('getAllProxies', function () {
    it('should return empty array if nothing is saved', async () => {
      const proxies = await store.getAllProxies()

      expect(proxies).to.be.an('array')
      expect(proxies).to.be.empty
    })
  })

  it('should put and get the proxy back', async () => {
    const id = 'someId'
    const proxy = someProxyWith(id)

    await store.putProxy(proxy)

    const gotProxy = await store.getProxyById(id)

    expect(gotProxy).to.be.deep.equal(proxy)
  })

  it('when get, returns doNotProxyLocal `true` if was not set when put', async () => {
    const id = 'someId'
    const proxy = someProxyWith(id)
    delete (proxy as any).doNotProxyLocal

    await store.putProxy(proxy)

    const gotProxy = await store.getProxyById(id)

    expect(gotProxy?.doNotProxyLocal).to.be.equal(true)
  })

  it('stores doNotProxyLocal value', async () => {
    const id = 'someId'
    const proxy = someProxyWith(id, { doNotProxyLocal: false })

    await store.putProxy(proxy)

    const gotProxy = await store.getProxyById(id)

    expect(gotProxy?.doNotProxyLocal).to.be.equal(false)
  })

  it('should be able to delete proxy', async () => {
    const id = 'someId'
    await store.putProxy(someProxyWith(id))
    await store.deleteProxyById(id)

    const result = await store.getProxyById(id)

    expect(result).to.be.null
  })

  // describe('getProxiesForContainer', () => {
  //   it('should find proxy by container id if one present', async () => {
  //     const cookieStoreId = 'container-1'
  //     const proxyId = 'proxy-1'
  //     // TODO Store should probably take care of this
  //     const relations = {
  //       [cookieStoreId]: [proxyId]
  //     }
  //     const givenProxy = someProxyWith(proxyId)
  //     await store.putProxy(givenProxy)

  //     await browser.storage.local.set({ relations: relations })

  //     const [gotProxy] = await store.getProxiesForContainer(cookieStoreId)

  //     expect(gotProxy).to.be.deep.equal(givenProxy)
  //   })

  //   it('doNotProxyLocal should be `true` if not set', async () => {
  //     const cookieStoreId = 'container-1'
  //     const proxyId = 'proxy-1'
  //     // TODO Store should probably take care of this
  //     const relations = {
  //       [cookieStoreId]: [proxyId]
  //     }
  //     const givenProxy = someProxyWith(proxyId)
  //     delete (givenProxy as any).doNotProxyLocal
  //     await store.putProxy(givenProxy)

  //     await browser.storage.local.set({ relations: relations })

  //     const [gotProxy] = await store.getProxiesForContainer(cookieStoreId)

  //     expect(gotProxy.doNotProxyLocal).to.be.equal(true)
  //   })

  //   it('should return empty array if proxy not set for the container', async () => {
  //     const cookieStoreId = 'container-1'

  //     const result = await store.getProxiesForContainer(cookieStoreId)

  //     expect(result).to.be.empty
  //   })

  //   it('should return empty array if proxy is set for the container but does not exist', async () => {
  //     const cookieStoreId = 'container-1'
  //     const proxyId = 'something-absent'
  //     const relations = {
  //       [cookieStoreId]: [proxyId]
  //     }
  //     await browser.storage.local.set({ relations: relations })

  //     const result = await store.getProxiesForContainer(cookieStoreId)

  //     expect(result).to.be.empty
  //   })
  // })

  describe('setContainerProxyRelation', function () {
    it('should set the relation', async () => {
      await store.setContainerProxyRelation('container1', 'proxy1')

      const relations = await store.getRelations()

      expect(relations.container1).to.be.deep.equal(['proxy1'])
    })

    it('should not remove existing relations', async () => {
      await store.setContainerProxyRelation('container1', 'proxy1')
      await store.setContainerProxyRelation('container2', 'proxy2')

      const relations = await store.getRelations()

      expect(relations.container1).to.be.deep.equal(['proxy1'])
      expect(relations.container2).to.be.deep.equal(['proxy2'])
    })
  })
})
