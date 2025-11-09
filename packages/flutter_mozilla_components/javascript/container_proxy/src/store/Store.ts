import { ProxyInfo } from '../domain/ProxyInfo'
import { ProxyType } from '../domain/ProxyType'
import { ProxySettings } from '../domain/ProxySettings'
const tryFromDao = ProxySettings.tryFromDao

/* eslint-disable @typescript-eslint/no-namespace,no-redeclare,import/export */

export interface ProxyDao {
  id: string
  title: string
  type: string
  host: string
  port: number
  username?: string
  password?: string
  proxyDNS?: boolean
  doNotProxyLocal: boolean
}

export namespace ProxyDao {
  export function toProxyInfo(proxy: Pick<ProxyDao, 'type' | 'host' | 'port' | 'username' | 'password' | 'proxyDNS'>): ProxyInfo | undefined {
    const type = ProxyType.tryFromString(proxy.type)
    if (type === undefined) {
      return
    }

    const base = {
      host: proxy.host,
      port: proxy.port,
      failoverTimeout: 5
    }

    switch (type) {
      case ProxyType.Socks5:
        return {
          type,
          ...base,
          username: proxy.username ?? '',
          password: proxy.password ?? '',
          proxyDNS: proxy.proxyDNS ?? true
        }
      case ProxyType.Socks4:
        return {
          type,
          ...base,
          proxyDNS: proxy.proxyDNS ?? true
        }
      case ProxyType.Http:
        return {
          type,
          ...base
        }
      case ProxyType.Https:
        return {
          type,
          ...base,
          proxyAuthorizationHeader: '' //generateAuthorizationHeader(proxy.username ?? '', proxy.password ?? '')
        }
    }
  }
}

function fillInDefaults(proxy: Partial<ProxyDao>): ProxyDao {
  if (proxy.title === undefined) {
    proxy.title = ''
  }
  if (typeof proxy.doNotProxyLocal === 'undefined') {
    proxy.doNotProxyLocal = true
  }
  if (typeof proxy.proxyDNS === 'undefined') {
    if (proxy.type === 'socks' || proxy.type === 'socks4') {
      proxy.proxyDNS = true
    }
  }
  return proxy as ProxyDao
}

export class Store {
  private proxies: ProxyDao[] = []
  private relations: { [key: string]: string[] } = {}

  private siteAssignments: Map<string, string> = new Map<string, string>()

  setSiteAssignments(sites: Map<string, unknown>): void {
    this.siteAssignments = new Map(
      Array.from(sites, ([key, value]) => {
        return [URL.parse(key)!.origin, value as string]
      })
    );
  }

  isSiteOriginAssigned(uri: URL): boolean {
    return this.siteAssignments.has(uri.origin)
  }

  isSiteOriginInSameContext(uri: URL, contextId: string): boolean {
    return this.siteAssignments.get(uri.origin) === contextId;
  }

  getAllProxies(): ProxySettings[] {
    const proxyDaos = this.getAllProxyDaos()
    return proxyDaos.map(tryFromDao).filter(p => p !== undefined) as ProxySettings[]
  }

  getProxyById(id: string): ProxySettings | null {
    const proxies = this.getAllProxies()
    const proxy = proxies.find(p => p.id === id)
    return proxy ?? null
  }

  putProxy(proxy: ProxySettings): void {
    const proxies = this.getAllProxyDaos()
    const index = proxies.findIndex(p => p.id === proxy.id)
    if (index !== -1) {
      proxies[index] = proxy.asDao()
    } else {
      proxies.push(proxy.asDao())
    }
    this.saveProxyDaos(proxies)
  }

  deleteProxyById(id: string): void {
    const proxies = this.getAllProxyDaos()
    const index = proxies.findIndex(p => p.id === id)
    if (index !== -1) {
      proxies.splice(index, 1)
      this.saveProxyDaos(proxies)
    }
  }

  getRelations(): { [key: string]: string[] } {
    return this.relations
  }

  hasGeneralRelation(): boolean {
    return this.relations['general'] != null;
  }

  setContainerProxyRelation(cookieStoreId: string, proxyId: string): void {
    this.relations[cookieStoreId] = [proxyId]
  }

  removeContainerProxyRelation(cookieStoreId: string, proxyId: string): void {
    const currentRelations = this.relations[cookieStoreId] ?? []
    this.relations[cookieStoreId] = currentRelations.filter(id => id !== proxyId)

    if (this.relations[cookieStoreId].length === 0) {
      delete this.relations[cookieStoreId]
    }
  }

  getProxiesForContainer(cookieStoreId: string): ProxySettings[] | null {
    const relations = this.getRelations()
    const proxyIds: string[] = relations[cookieStoreId]
      ?? ((cookieStoreId != 'private') ? relations['general'] : null)
      ?? []

    if (proxyIds.length === 0) {
      return null
    }

    const proxies = this.getAllProxies()
    const proxyById: { [key: string]: ProxySettings } = {}
    proxies.forEach(p => { proxyById[p.id] = p })

    return proxyIds.map(pId => proxyById[pId])
      .filter(p => p !== undefined)
      .map(fillInDefaults)
      .map(tryFromDao)
      .filter(p => p !== undefined) as ProxySettings[]
  }

  private saveProxyDaos(p: ProxyDao[]): void {
    this.proxies = p
  }

  private getAllProxyDaos(): ProxyDao[] {
    return this.proxies.map(fillInDefaults)
  }
}
