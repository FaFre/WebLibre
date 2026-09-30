/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.bridge

import mozilla.components.support.base.log.logger.Logger

/**
 * WebExtensions API compatibility bridge inspired by Ladybird's LibGeckoShim.
 *
 * Ladybird lacks native WebExtensions support, so LibGeckoShim injects a JS
 * shim that translates browser.* calls into IPC messages to a native host.
 * GeckoView supports WebExtensions natively — so this bridge serves a different
 * purpose: it provides a JS-side API shim for extensions that target Chrome's
 * promise-based `chrome.*` API surface (rather than Firefox's callback-based
 * `browser.*` API), smoothing over API shape differences without native patches.
 *
 * The shim is injected as a content script into extension pages when needed.
 *
 * Reference: qwerzxcva/ladybird Libraries/LibGeckoShim/ExtensionBridge.cpp
 */
object LadybirdExtensionBridge {

    private val logger = Logger("LadybirdExtensionBridge")

    /** Extension APIs exposed by the shim (mirrors C++ ExtensionAPI enum). */
    enum class ExtensionAPI {
        RuntimeSendMessage,
        RuntimeGetURL,
        StorageLocalGet,
        StorageLocalSet,
        TabsQuery,
        TabsCreate,
        WebRequestOnBeforeRequest,
        CookiesGetAll,
        CookiesSet
    }

    private val contentScripts = mutableMapOf<String, String>()

    /**
     * Register a content script to be injected for a given origin.
     * Mirrors ExtensionBridge::register_content_script.
     */
    fun registerContentScript(origin: String, scriptSource: String) {
        contentScripts[origin] = scriptSource
        logger.debug("Registered content script for origin: $origin")
    }

    /**
     * Unregister a content script for a given origin.
     */
    fun unregisterContentScript(origin: String) {
        contentScripts.remove(origin)
        logger.debug("Unregistered content script for origin: $origin")
    }

    /** Returns the shim JavaScript to inject into extension pages. */
    fun getShimJavascript(): String {
        return SHIM_JS
    }

    /**
     * Stub response for an API call, mirroring ExtensionBridge::handle_api_call.
     *
     * GeckoView handles real extension API calls natively; this helper exists
     * for the JS shim's fallback path when the native message port is absent
     * (for example, in sandboxed content scripts without extension permissions).
     */
    fun stubResponse(api: ExtensionAPI): String {
        return when (api) {
            ExtensionAPI.RuntimeSendMessage -> """{"success":true}"""
            ExtensionAPI.StorageLocalGet -> """{}"""
            ExtensionAPI.TabsQuery -> """[{"id":1,"url":"about:blank","active":true}]"""
            else -> """{"error":"not_implemented"}"""
        }
    }

    private val SHIM_JS = """
(function() {
    if (window.__ladybird_ext_shim_loaded) return;
    window.__ladybird_ext_shim_loaded = true;

    var callbacks = {};
    var nextId = 1;

    function sendMessage(apiName, payload) {
        return new Promise(function(resolve, reject) {
            var id = nextId++;
            callbacks[id] = { resolve: resolve, reject: reject };
            window.postMessage({
                type: 'LADYBIRD_EXT_IPC',
                id: id,
                api: apiName,
                payload: payload
            }, '*');
        });
    }

    window.addEventListener('message', function(event) {
        if (event.data && event.data.type === 'LADYBIRD_EXT_RESPONSE') {
            var cb = callbacks[event.data.id];
            if (cb) {
                delete callbacks[event.data.id];
                try {
                    cb.resolve(JSON.parse(event.data.response));
                } catch (e) {
                    cb.resolve(event.data.response);
                }
            }
        }
    });

    // Chrome-style promise API. If the page already has a native browser.*
    // (from GeckoView), we do NOT override it — only fill in missing pieces.
    if (!window.browser) {
        window.browser = {};
    }

    window.browser.runtime = window.browser.runtime || {
        sendMessage: function(msg) { return sendMessage('runtime.sendMessage', JSON.stringify(msg)); },
        getURL: function(path) { return 'moz-extension://shim/' + path; },
        onMessage: { addListener: function() {}, removeListener: function() {} }
    };

    window.browser.storage = window.browser.storage || {
        local: {
            get: function(keys) { return sendMessage('storage.local.get', JSON.stringify(keys)); },
            set: function(items) { return sendMessage('storage.local.set', JSON.stringify(items)); }
        }
    };

    window.browser.tabs = window.browser.tabs || {
        query: function(queryInfo) { return sendMessage('tabs.query', JSON.stringify(queryInfo)); },
        create: function(props) { return sendMessage('tabs.create', JSON.stringify(props)); }
    };

    window.browser.webRequest = window.browser.webRequest || {
        onBeforeRequest: { addListener: function() {}, removeListener: function() {} }
    };

    window.browser.cookies = window.browser.cookies || {
        getAll: function(details) { return sendMessage('cookies.getAll', JSON.stringify(details)); },
        set: function(details) { return sendMessage('cookies.set', JSON.stringify(details)); }
    };

    // Chrome namespace alias for compatibility with Chrome-targeted extensions.
    if (!window.chrome) window.chrome = {};
    window.chrome.runtime = window.chrome.runtime || window.browser.runtime;
    window.chrome.storage = window.chrome.storage || window.browser.storage;
    window.chrome.tabs = window.chrome.tabs || window.browser.tabs;
})();
""".trimIndent()
}