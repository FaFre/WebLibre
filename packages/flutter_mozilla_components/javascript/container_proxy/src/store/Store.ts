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

interface WildcardAssignment {
  protocol: string
  hostSuffix: string
  contextId: string
}

export class Store {
  private proxies: ProxyDao[] = []
  private relations: { [key: string]: string[] } = {}

  private siteAssignments: Map<string, string> = new Map<string, string>()
  private wildcardAssignments: WildcardAssignment[] = []

  setSiteAssignments(sites: Map<string, unknown>): void {
    const exact = new Map<string, string>()
    const wildcard: WildcardAssignment[] = []

    // `*` is a forbidden host code point in WHATWG URL, so wildcard entries
    // must be detected by string match before any URL parser touches them.
    const wildcardRe = /^(https?):\/\/\*\.([^/?#]+)$/i

    for (const [key, value] of sites) {
      const contextId = value as string
      const wildcardMatch = wildcardRe.exec(key)

      if (wildcardMatch !== null) {
        const hostSuffix = wildcardMatch[2].toLowerCase()
        if (hostSuffix.length === 0) continue
        wildcard.push({
          protocol: wildcardMatch[1].toLowerCase() + ':',
          hostSuffix,
          contextId,
        })
        continue
      }

      const parsed = URL.parse(key)
      if (parsed === null) continue
      exact.set(parsed.origin, contextId)
    }

    this.siteAssignments = exact
    this.wildcardAssignments = wildcard
  }

  private matchWildcard(uri: URL): string | undefined {
    // Longest suffix wins, so e.g. *.sub.example.com beats *.example.com.
    let bestMatch: WildcardAssignment | undefined
    for (const entry of this.wildcardAssignments) {
      if (entry.protocol !== uri.protocol) continue
      const host = uri.hostname
      if (host !== entry.hostSuffix && !host.endsWith('.' + entry.hostSuffix)) {
        continue
      }
      if (
        bestMatch === undefined ||
        entry.hostSuffix.length > bestMatch.hostSuffix.length
      ) {
        bestMatch = entry
      }
    }
    return bestMatch?.contextId
  }

  private lookupAssignment(uri: URL): string | undefined {
    return this.siteAssignments.get(uri.origin) ?? this.matchWildcard(uri)
  }

  isSiteOriginAssigned(uri: URL): boolean {
    return this.lookupAssignment(uri) !== undefined
  }

  /**
   * Returns the effective proxy relation for a context ID, mirroring the
   * fallback logic in getProxiesForContainer: explicit relation first,
   * then 'general' for non-private contexts, then empty.
   */
  private getEffectiveRelation(contextId: string): string[] {
    return this.relations[contextId]
      ?? ((contextId !== 'private') ? this.relations['general'] : undefined)
      ?? [];
  }

  isSiteOriginInSameContext(uri: URL, contextId: string): boolean {
    const assignedContextId = this.lookupAssignment(uri);
    if (assignedContextId === undefined) return false;
    if (assignedContextId === contextId) return true;

    // Context equivalence: compare effective proxy relations (including
    // fallback to 'general') so that isolated tabs in non-proxied containers
    // or containers relying on the general relation are treated as compatible.
    const assignedRelation = this.getEffectiveRelation(assignedContextId);
    const currentRelation = this.getEffectiveRelation(contextId);

    // Only treat as equivalent if both have actual proxy relations —
    // empty relations mean no proxy, and different non-proxied contexts
    // should not be considered equivalent.
    if (assignedRelation.length > 0 &&
      assignedRelation.length === currentRelation.length &&
      assignedRelation.every((id, i) => id === currentRelation[i])) {
      return true;
    }

    return false;
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
