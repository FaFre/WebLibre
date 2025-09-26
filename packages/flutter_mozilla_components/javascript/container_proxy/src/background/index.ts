import { Socks5ProxySettings } from 'src/domain/ProxySettings';
import { Store } from '../store/Store'
import BackgroundMain from './BackgroundMain'

console.log('Background script started')

const store = new Store()

interface Message {
    id: String | undefined;
    action: 'setProxyPort' | 'addContainerProxy' | 'removeContainerProxy' | 'healthcheck';
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
backgroundListener.run(browser)
