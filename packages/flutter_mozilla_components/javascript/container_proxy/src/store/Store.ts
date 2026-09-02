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

/**
 * The complete routing state, as owned by the app. The extension's store is
 * memory-only and dies with the background script, so routing can never be
 * reconstructed from the incremental mutation messages alone — a restarted
 * background script would sit with an empty store while believing itself
 * configured, and an empty store means "direct" for every request.
 *
 * A snapshot is therefore the only way the store becomes usable: it replaces
 * every field at once and stamps a generation, and until one arrives the store
 * reports itself unready so requests wait — and, if none ever comes, fail
 * closed instead of leaking.
 */
export interface RoutingSnapshot {
  generation: number
  proxies: ProxyDao[]
  relations: { [key: string]: string[] }
  directScopes: { [key: string]: string }
  siteAssignments: { [key: string]: string }
  strictContexts: { [key: string]: string[] }

  /**
   * Whether a further snapshot is expected to replace this one.
   *
   * Set by the native side when it seeds the store from the routing this
   * profile had last time it ran, in a process that also runs the app half and
   * will therefore push the live routing shortly. The seed is deliberately
   * stripped of proxy endpoints (an address is only valid while its backend
   * runs), so every context it routes through a proxy resolves to "no endpoint"
   * until that push lands — which is a startup window, not a decision.
   *
   * Absent on an app push (the routing *is* the decision) and on a seed
   * installed in a process with no app half, where nothing will ever follow it.
   */
  provisional?: boolean

  /**
   * Proxy ids named by [relations], missing from [proxies], and still being
   * brought up by the app.
   *
   * The narrow form of [provisional]: it does not say the snapshot is about to
   * be replaced, only that these particular relations are blocked by a backend
   * that has not finished starting. Everything else in the snapshot is a
   * decision, including relations naming a proxy that is *not* in this list.
   */
  awaitingProxies?: string[]
}

export class Store {
  private proxies: ProxyDao[] = []
  private relations: { [key: string]: string[] } = {}
  private directRelationScopes: { [key: string]: string } = {}

  /**
   * Generation of the last applied snapshot, or null while no snapshot has
   * been applied. Null is the fail-closed state: it is not "no proxies
   * configured", it is "routing is unknown".
   */
  private generation: number | null = null

  /** See [RoutingSnapshot.provisional]. */
  private provisional: boolean = false

  /** See [RoutingSnapshot.awaitingProxies]. */
  private awaitingProxies: Set<string> = new Set<string>()

  /**
   * Resolvers waiting for the next snapshot, see [awaitSnapshot].
   *
   * Held rather than polled so a request blocked on routing resumes in the same
   * turn the snapshot is applied.
   */
  private snapshotWaiters: Array<() => void> = []

  /**
   * Whether an authoritative snapshot has been applied. Callers must treat a
   * false answer as "wait, then block", never as "direct" — see
   * [awaitSnapshot].
   */
  isReady(): boolean {
    return this.generation !== null
  }

  /**
   * Whether the applied snapshot announces a successor, i.e. whether routing
   * this store currently resolves to "blocked" may still resolve to a live
   * proxy without anything else changing.
   */
  isProvisional(): boolean {
    return this.provisional
  }

  /**
   * Whether [contextId]'s route is blocked by a backend that is still starting,
   * rather than by one that is not running.
   *
   * Asked of the context rather than of a proxy id, so the caller does not have
   * to reimplement how a context resolves to a relation — the inheritance rules
   * are the store's, and answering the wrong context is how a wait ends up on
   * a request that should have failed at once.
   */
  isContextAwaitingProxy(contextId: string): boolean {
    if (this.awaitingProxies.size === 0) return false

    const relation = this.getEffectiveRelation(contextId)
    if (relation === undefined) return false

    return relation.some(proxyId => this.awaitingProxies.has(proxyId))
  }

  getGeneration(): number | null {
    return this.generation
  }

  /**
   * Resolves true when a snapshot is applied, false when [timeoutMs] passes
   * first.
   *
   * This is what lets the request path treat "routing is not known yet" as a
   * wait rather than a failure: on a cold start the store is empty for as long
   * as it takes the seed or the app's first push to arrive, and everything that
   * loads inside that window would otherwise be answered with the emergency
   * break — an error page on a page the user just opened, with nothing left to
   * retry it in a process that has no app half.
   *
   * A non-positive timeout resolves false without waiting, so a caller working
   * to a deadline never has to special-case having reached it.
   */
  async awaitSnapshot(timeoutMs: number): Promise<boolean> {
    if (timeoutMs <= 0) return false

    return await new Promise<boolean>(resolve => {
      const waiter = (): void => {
        clearTimeout(timer)
        resolve(true)
      }

      const timer = setTimeout(() => {
        this.snapshotWaiters = this.snapshotWaiters.filter(w => w !== waiter)
        resolve(false)
      }, timeoutMs)

      this.snapshotWaiters.push(waiter)
    })
  }

  private wakeSnapshotWaiters(): void {
    const waiters = this.snapshotWaiters
    this.snapshotWaiters = []
    for (const waiter of waiters) {
      waiter()
    }
  }

  /**
   * Atomically replaces the whole routing state and marks the store ready.
   * Every field is overwritten, so state left over from a previous generation
   * cannot survive into the new one.
   */
  applySnapshot(snapshot: RoutingSnapshot): void {
    this.proxies = snapshot.proxies.map(p => ({ ...p }))

    const relations: { [key: string]: string[] } = {}
    for (const [contextId, proxyIds] of Object.entries(snapshot.relations)) {
      relations[contextId] = [...proxyIds]
    }
    this.relations = relations
    this.directRelationScopes = { ...snapshot.directScopes }

    this.setSiteAssignments(new Map(Object.entries(snapshot.siteAssignments)))
    this.setStrictContexts(new Map(Object.entries(snapshot.strictContexts)))

    this.generation = snapshot.generation
    this.provisional = snapshot.provisional === true
    this.awaitingProxies = new Set(snapshot.awaitingProxies ?? [])

    // Last, so a waiter that resumes here reads the whole new state.
    this.wakeSnapshotWaiters()
  }

  private siteAssignments: Map<string, string> = new Map<string, string>()
  private wildcardAssignments: WildcardAssignment[] = []

  // Maps an enforced cookie-store context (a strict container's base context,
  // or an isolation context of one of its isolated tabs) to the base contexts
  // its site assignments are keyed on.
  private strictContexts: Map<string, Set<string>> = new Map<string, Set<string>>()

  setStrictContexts(contexts: Map<string, string[]>): void {
    const next = new Map<string, Set<string>>()
    for (const [contextId, assignmentContexts] of contexts) {
      next.set(contextId, new Set(assignmentContexts))
    }
    this.strictContexts = next
  }

  isContextStrict(contextId: string): boolean {
    return this.strictContexts.has(contextId)
  }

  /**
   * True when [uri]'s origin is assigned to a base context that [contextId]
   * enforces. Strict mode requires an exact assignment match (via
   * [lookupAssignment], which handles exact + wildcard entries) against the
   * container's base contexts — proxy/direct equivalence is deliberately NOT
   * consulted, so a site assigned only to a different (even proxy-equivalent)
   * container does not load here.
   */
  isSiteOriginStrictlyAllowed(uri: URL, contextId: string): boolean {
    const assignmentContexts = this.strictContexts.get(contextId)
    const assignedContext = this.lookupAssignment(uri)
    return assignedContext !== undefined &&
      assignmentContexts !== undefined &&
      assignmentContexts.has(assignedContext)
  }

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

  private hasRelation(contextId: string): boolean {
    return Object.prototype.hasOwnProperty.call(this.relations, contextId)
  }

  /**
   * Returns the effective proxy relation for a context ID, preserving the
   * difference between "no explicit relation" (undefined, may inherit) and
   * "explicit direct connection" ([]).
   */
  private getEffectiveRelation(contextId: string): string[] | undefined {
    if (this.hasRelation(contextId)) {
      return this.relations[contextId]
    }
    if (contextId !== 'private' && this.hasRelation('general')) {
      return this.relations['general']
    }
    return undefined
  }

  private getEffectiveDirectScope(contextId: string): string | undefined {
    if (this.hasRelation(contextId) && this.relations[contextId].length === 0) {
      return this.directRelationScopes[contextId] ?? contextId
    }
    if (contextId !== 'private' &&
      this.hasRelation('general') &&
      this.relations['general'].length === 0) {
      return this.directRelationScopes['general'] ?? 'general'
    }
    return undefined
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

    const assignedDirectScope = this.getEffectiveDirectScope(assignedContextId)
    const currentDirectScope = this.getEffectiveDirectScope(contextId)
    if (assignedDirectScope !== undefined || currentDirectScope !== undefined) {
      return assignedDirectScope !== undefined &&
        assignedDirectScope === currentDirectScope
    }

    // Treat proxy-routed contexts as equivalent only when both resolve to an
    // explicit non-direct relation. Direct relations are scoped above so two
    // unrelated bypassed containers do not collapse into the same context.
    if (assignedRelation !== undefined &&
      currentRelation !== undefined &&
      assignedRelation.length > 0 &&
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
    delete this.directRelationScopes[cookieStoreId]
  }

  setContainerDirectRelation(cookieStoreId: string, scopeId: string = cookieStoreId): void {
    this.relations[cookieStoreId] = []
    this.directRelationScopes[cookieStoreId] = scopeId
  }

  clearContainerProxyRelation(cookieStoreId: string): void {
    delete this.relations[cookieStoreId]
    delete this.directRelationScopes[cookieStoreId]
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
