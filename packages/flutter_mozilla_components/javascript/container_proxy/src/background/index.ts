import { ProxySettings, Socks5ProxySettings } from 'src/domain/ProxySettings';
import { Store } from '../store/Store'
import BackgroundMain from './BackgroundMain'

console.log('Background script started')

const store = new Store()

interface Message {
    id: String | undefined;
    action: 'setProxyPort' |
    'addContainerProxy' |
    'removeContainerProxy' |
    'upsertProxy' |
    'removeProxy' |
    'setContainerProxy' |
    'setContainerDirectConnection' |
    'clearContainerProxy' |
    'removeContainerProxyRelation' |
    'healthcheck' |
    'setSiteAssignments' |
    'setStrictContexts';
    args: any;
}

const port = browser.runtime.connectNative("containerProxy");
port.onMessage.addListener((raw: unknown): void => {
    const message = raw as Message;
    switch (message.action) {
        case "setProxyPort":
            if (message.args > -1) {
                store.putProxy(new Socks5ProxySettings({
                    id: 'tor',
                    type: 'socks',
                    host: '127.0.0.1',
                    port: message.args,
                    doNotProxyLocal: true,
                    title: 'Tor',
                    proxyDNS: true,
                }))
                console.log('put tor port ' + message.args)
            } else {
                store.deleteProxyById('tor')
                console.log('remove tor port')
            }

            break
        case "addContainerProxy":
            store.setContainerProxyRelation(message.args, "tor")
            console.log('added container relation ' + message.args)
            break
        case "removeContainerProxy":
            store.removeContainerProxyRelation(message.args, "tor")
            console.log('removed container relation ' + message.args)
            break
        case "upsertProxy": {
            const proxy = ProxySettings.tryFromDao(message.args)
            if (proxy === undefined) {
                console.error('invalid proxy settings ' + JSON.stringify(message.args))
                break
            }
            store.putProxy(proxy)
            console.log('upsert proxy ' + message.args.id)
            break
        }
        case "removeProxy":
            store.deleteProxyById(message.args)
            console.log('removed proxy ' + message.args)
            break
        case "setContainerProxy":
            store.setContainerProxyRelation(message.args.contextId, message.args.proxyId)
            console.log('set container relation ' + message.args.contextId + ' -> ' + message.args.proxyId)
            break
        case "setContainerDirectConnection":
            if (typeof message.args === 'string') {
                store.setContainerDirectRelation(message.args)
                console.log('set container direct relation ' + message.args)
            } else {
                store.setContainerDirectRelation(message.args.contextId, message.args.scopeId)
                console.log('set container direct relation ' + message.args.contextId + ' scoped to ' + message.args.scopeId)
            }
            break
        case "clearContainerProxy":
            store.clearContainerProxyRelation(message.args)
            console.log('cleared container relation ' + message.args)
            break
        case "removeContainerProxyRelation":
            store.removeContainerProxyRelation(message.args.contextId, message.args.proxyId)
            console.log('removed container relation ' + message.args.contextId + ' -> ' + message.args.proxyId)
            break
        case "setSiteAssignments":
            const entries = new Map(Object.entries(message.args))
            console.log('set site assignments ' + JSON.stringify(message.args))
            store.setSiteAssignments(entries);
            break
        case "setStrictContexts":
            console.log('set strict contexts ' + JSON.stringify(message.args))
            store.setStrictContexts(new Map(Object.entries(message.args)) as Map<string, string[]>);
            break
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
