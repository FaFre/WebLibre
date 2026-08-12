import { RoutingSnapshot, Store } from '../store/Store'
import BackgroundMain from './BackgroundMain'

console.log('Background script started')

const store = new Store()

interface Message {
    id: String | undefined;
    action: 'applySnapshot' | 'healthcheck';
    args: any;
}

/**
 * Coerces the snapshot as it arrives over the native port. Everything is
 * validated before it is applied: a malformed snapshot must leave the store in
 * its previous state (unready on a cold start) rather than half-applied.
 */
function parseSnapshot(args: any): RoutingSnapshot | undefined {
    if (args === null || typeof args !== 'object') return undefined
    if (typeof args.generation !== 'number') return undefined
    if (!Array.isArray(args.proxies)) return undefined

    const relations: { [key: string]: string[] } = {}
    for (const [contextId, proxyIds] of Object.entries(args.relations ?? {})) {
        if (!Array.isArray(proxyIds)) return undefined
        relations[contextId] = proxyIds as string[]
    }

    const strictContexts: { [key: string]: string[] } = {}
    for (const [contextId, baseContexts] of Object.entries(args.strictContexts ?? {})) {
        if (!Array.isArray(baseContexts)) return undefined
        strictContexts[contextId] = baseContexts as string[]
    }

    return {
        generation: args.generation,
        proxies: args.proxies,
        relations,
        directScopes: args.directScopes ?? {},
        siteAssignments: args.siteAssignments ?? {},
        strictContexts,
    }
}

const port = browser.runtime.connectNative("containerProxy");
port.onMessage.addListener((raw: unknown): void => {
    const message = raw as Message;
    switch (message.action) {
        case "applySnapshot": {
            const snapshot = parseSnapshot(message.args)
            if (snapshot === undefined) {
                console.error('invalid routing snapshot ' + JSON.stringify(message.args))
                port.postMessage({
                    "type": "snapshotApplied",
                    "id": message.id,
                    "status": "error",
                    "error": "invalid routing snapshot"
                });
                break
            }

            store.applySnapshot(snapshot)
            console.log('applied routing snapshot generation ' + snapshot.generation)
            port.postMessage({
                "type": "snapshotApplied",
                "id": message.id,
                "status": "success",
                "result": snapshot.generation
            });
            break
        }
        case "healthcheck":
            port.postMessage({
                "type": "healthcheck",
                "id": message.id,
                "status": "success",
                "result": true
            });
            break
    }
});

const backgroundListener = new BackgroundMain({ store })
backgroundListener.run(browser, port)
