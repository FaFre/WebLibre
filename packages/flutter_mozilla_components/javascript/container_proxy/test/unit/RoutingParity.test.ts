import { RoutingSnapshot, Store } from '../../src/store/Store'

import { expect } from 'chai'
import * as fs from 'fs'
import * as path from 'path'

/**
 * The verdicts native's `RoutingResolution` answers with, expressed in terms of
 * what this store actually does.
 *
 * `getProxiesForContainer` already draws the two distinctions that matter:
 * `null` is "no proxy carries this context", which is a direct connection and
 * covers both an absent relation and an explicit empty one; a non-empty array
 * is a live route. What is left — a relation naming proxies none of which
 * resolve — is a block, and only the app saying the backend is still coming up
 * turns it into a wait.
 *
 * `UNKNOWN` has no expression here: it means "no snapshot", which this store
 * reports through `isReady()` rather than through a resolution. Each side
 * covers that on its own.
 */
function verdictFor (store: Store, contextId: string): string {
  const proxies = store.getProxiesForContainer(contextId)
  if (proxies === null) return 'DIRECT'
  if (proxies.length > 0) return 'LIVE'

  return store.isContextAwaitingProxy(contextId) ? 'STARTING' : 'BLOCKED'
}

interface VerdictCase {
  name: string
  contextId: string
  expected: string
  snapshot: RoutingSnapshot
}

const fixturePath = path.join(
  __dirname, '..', '..', '..', '..', 'shared', 'routing', 'routing_verdicts.json'
)

/**
 * The same cases native's `RoutingResolutionTest` is held to.
 *
 * There are two implementations of these rules because neither side can ask the
 * other — see `shared/routing/README.md`. This is what stops them drifting: a
 * launch native decides can PROCEED for a context this store still blocks is a
 * Custom Tab window that opens onto a proxy error page and cannot be recovered.
 */
describe('routing resolution parity with the native reader', function () {
  const fixture = JSON.parse(fs.readFileSync(fixturePath, 'utf8')) as { cases: VerdictCase[] }

  it('carries cases', () => {
    expect(fixture.cases).to.not.be.empty // eslint-disable-line @typescript-eslint/no-unused-expressions
  })

  fixture.cases.forEach((verdictCase) => {
    it(verdictCase.name, () => {
      const store = new Store()
      store.applySnapshot(verdictCase.snapshot)

      expect(verdictFor(store, verdictCase.contextId)).to.equal(verdictCase.expected)
    })
  })
})
