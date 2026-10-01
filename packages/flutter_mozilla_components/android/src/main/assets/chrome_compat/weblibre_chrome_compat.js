// WebLibre Chrome compat layer.
//
// Comprehensive polyfill for Chrome extension APIs to run on GeckoView.
// Based on patterns from Ladybird's ExtensionBridge implementation.
//
// This script is injected ahead of the extension's own scripts.

(function () {
  'use strict';

  var root = typeof globalThis !== 'undefined' ? globalThis : this;
  if (root.__weblibreChromeCompat) return;
  root.__weblibreChromeCompat = true;

  // ---------------------------------------------------------------------------
  // Base chrome object
  // ---------------------------------------------------------------------------

  if (typeof chrome === 'undefined') {
    root.chrome = {};
  }

  // ---------------------------------------------------------------------------
  // Promise wrapper for callback-style APIs
  // ---------------------------------------------------------------------------

  function wrapMethod(namespace, name, original) {
    if (!original || typeof original !== 'function') return;

    var wrapped = function () {
      var args = Array.prototype.slice.call(arguments);
      var last = args[args.length - 1];

      if (typeof last === 'function') {
        return original.apply(namespace, args);
      }

      return new Promise(function (resolve, reject) {
        args.push(function (result) {
          var error = chrome.runtime && chrome.runtime.lastError;
          if (error) {
            reject(new Error(error.message || String(error)));
          } else {
            resolve(result);
          }
        });

        try {
          original.apply(namespace, args);
        } catch (e) {
          reject(e);
        }
      });
    };

    try {
      Object.defineProperty(wrapped, 'name', { value: name, configurable: true });
    } catch (e) {}
    wrapped.__weblibreOriginal = original;
    return wrapped;
  }

  function walk(namespace, depth) {
    if (!namespace || typeof namespace !== 'object' || depth > 5) return;

    var keys;
    try {
      keys = Object.keys(namespace);
    } catch (e) {
      return;
    }

    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];

      // Skip event listeners
      if (key.length > 2 && key.charCodeAt(0) === 111 && key.charCodeAt(1) === 110) {
        continue;
      }

      var value;
      try {
        value = namespace[key];
      } catch (e) {
        continue;
      }

      if (typeof value === 'function') {
        if (value.__weblibreOriginal) continue;
        try {
          namespace[key] = wrapMethod(namespace, key, value);
        } catch (e) {}
      } else if (value && typeof value === 'object' && !Array.isArray(value)) {
        walk(value, depth + 1);
      }
    }
  }

  walk(chrome, 0);

  // ---------------------------------------------------------------------------
  // chrome.runtime
  // ---------------------------------------------------------------------------

  chrome.runtime = chrome.runtime || {
    id: 'weblibre-chrome-compat',
    getManifest: function() { 
      return window.__weblibreExtensionManifest || {}; 
    },
    getURL: function(path) {
      return (window.__weblibreExtensionScheme || 'moz-extension') + '://' + 
             (window.__weblibreExtensionId || 'ladybird') + '/' + path;
    },
    sendMessage: function(id, message) {
      return Promise.resolve({success: true});
    },
    connect: function() {
      return {
        postMessage: function() {},
        disconnect: function() {},
        onMessage: { addListener: function() {}, removeListener: function() {} }
      };
    },
    onMessage: { addListener: function() {}, removeListener: function() {} },
    onInstalled: { addListener: function() {}, removeListener: function() {} },
    lastError: null
  };

  // ---------------------------------------------------------------------------
  // chrome.storage (uses browser.storage as backend)
  // ---------------------------------------------------------------------------

  if (!chrome.storage) {
    chrome.storage = {
      local: {
        get: function(keys, callback) {
          if (typeof browser === 'undefined' || !browser.storage) {
            if (callback) callback({});
            return Promise.resolve({});
          }
          return Promise.resolve(browser.storage.local.get(keys))
            .then(r => { if (callback) callback(r); return r; })
            .catch(e => { console.error('[WebLibre] storage.get error:', e); 
                         if (callback) callback({}); 
                         return {}; });
        },
        set: function(items, callback) {
          if (typeof browser === 'undefined' || !browser.storage) {
            if (callback) callback();
            return Promise.resolve();
          }
          return Promise.resolve(browser.storage.local.set(items))
            .then(() => { if (callback) callback(); })
            .catch(e => { console.error('[WebLibre] storage.set error:', e);
                         if (callback) callback(); });
        },
        remove: function(keys, callback) {
          if (typeof browser === 'undefined' || !browser.storage) {
            if (callback) callback();
            return Promise.resolve();
          }
          return Promise.resolve(browser.storage.local.remove(keys))
            .then(() => { if (callback) callback(); })
            .catch(e => { console.error('[WebLibre] storage.remove error:', e);
                         if (callback) callback(); });
        },
        clear: function(callback) {
          if (typeof browser === 'undefined' || !browser.storage) {
            if (callback) callback();
            return Promise.resolve();
          }
          return Promise.resolve(browser.storage.local.clear())
            .then(() => { if (callback) callback(); })
            .catch(e => { console.error('[WebLibre] storage.clear error:', e);
                         if (callback) callback(); });
        }
      },
      sync: {
        get: function(k, c) { chrome.storage.local.get(k, c); },
        set: function(i, c) { chrome.storage.local.set(i, c); },
        remove: function(k, c) { chrome.storage.local.remove(k, c); },
        clear: function(c) { chrome.storage.local.clear(c); }
      },
      managed: {
        get: function(k, c) { if (callback) callback({}); },
        set: function() {},
        remove: function() {},
        clear: function() {}
      },
      session: {
        get: function(k, c) { if (callback) callback({}); },
        set: function() {},
        remove: function() {},
        clear: function() {}
      },
      onChanged: {
        _listeners: [],
        addListener: function(cb) { this._listeners.push(cb); },
        removeListener: function(cb) {
          var i = this._listeners.indexOf(cb);
          if (i >= 0) this._listeners.splice(i, 1);
        }
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.tabs
  // ---------------------------------------------------------------------------

  if (!chrome.tabs) {
    chrome.tabs = {
      query: function(queryInfo, callback) {
        if (typeof browser === 'undefined' || !browser.tabs) {
          if (callback) callback([]);
          return Promise.resolve([]);
        }
        return Promise.resolve(browser.tabs.query(queryInfo || {}))
          .then(r => { if (callback) callback(r); return r; })
          .catch(e => { console.error('[WebLibre] tabs.query error:', e);
                       if (callback) callback([]); 
                       return []; });
      },
      create: function(createData, callback) {
        if (typeof browser === 'undefined' || !browser.tabs) {
          if (callback) callback(null);
          return Promise.resolve(null);
        }
        return Promise.resolve(browser.tabs.create(createData || {}))
          .then(r => { if (callback) callback(r); return r; })
          .catch(e => { console.error('[WebLibre] tabs.create error:', e);
                       if (callback) callback(null);
                       return null; });
      },
      update: function(tabId, updateData, callback) {
        if (typeof browser === 'undefined' || !browser.tabs) {
          if (callback) callback(null);
          return Promise.resolve(null);
        }
        return Promise.resolve(browser.tabs.update(tabId, updateData || {}))
          .then(r => { if (callback) callback(r); return r; })
          .catch(e => { console.error('[WebLibre] tabs.update error:', e);
                       if (callback) callback(null);
                       return null; });
      },
      remove: function(tabIds, callback) {
        if (typeof browser === 'undefined' || !browser.tabs) {
          if (callback) callback();
          return Promise.resolve();
        }
        const ids = Array.isArray(tabIds) ? tabIds : [tabIds];
        return Promise.all(ids.map(id => browser.tabs.remove(id)))
          .then(() => { if (callback) callback(); })
          .catch(e => { console.error('[WebLibre] tabs.remove error:', e);
                       if (callback) callback(); });
      },
      sendMessage: function(tabId, message, callback) {
        // Not supported in GeckoView
        if (callback) callback(null);
        return Promise.resolve(null);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.windows
  // ---------------------------------------------------------------------------

  if (!chrome.windows) {
    chrome.windows = {
      getAll: function(queryInfo, callback) {
        // WebLibre is mobile-only, so only one window
        if (callback) callback([{id: 1, focused: true}]);
        return Promise.resolve([{id: 1, focused: true}]);
      },
      create: function(createData, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      },
      update: function(windowId, updateData, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      },
      remove: function(windowId, callback) {
        if (callback) callback();
        return Promise.resolve();
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.contextMenus (stub - requires Native Messaging)
  // ---------------------------------------------------------------------------

  if (!chrome.contextMenus) {
    chrome.contextMenus = {
      create: function(createInfo, callback) {
        // Stub implementation
        if (callback) callback(1);
        return Promise.resolve(1);
      },
      remove: function(menuItemId, callback) {
        if (callback) callback();
        return Promise.resolve();
      },
      removeAll: function(callback) {
        if (callback) callback();
        return Promise.resolve();
      },
      onClicked: {
        addListener: function() {},
        removeListener: function() {}
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.cookies
  // ---------------------------------------------------------------------------

  if (!chrome.cookies) {
    chrome.cookies = {
      get: function(details, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      },
      getAll: function(filter, callback) {
        if (callback) callback([]);
        return Promise.resolve([]);
      },
      set: function(details, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      },
      remove: function(details, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.webRequest
  // ---------------------------------------------------------------------------

  if (!chrome.webRequest) {
    chrome.webRequest = {
      onBeforeRequest: {
        addListener: function() {},
        removeListener: function() {}
      },
      onBeforeSendHeaders: {
        addListener: function() {},
        removeListener: function() {}
      },
      onHeadersReceived: {
        addListener: function() {},
        removeListener: function() {}
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.declarativeContent
  // ---------------------------------------------------------------------------

  if (!chrome.declarativeContent) {
    chrome.declarativeContent = {
      onPageChanged: {
        addRules: function(rules, callback) {
          if (callback) callback();
          return Promise.resolve();
        },
        getRules: function(callback) {
          if (callback) callback([]);
          return Promise.resolve([]);
        },
        removeRules: function(callback) {
          if (callback) callback();
          return Promise.resolve();
        }
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.scripting
  // ---------------------------------------------------------------------------

  if (!chrome.scripting) {
    chrome.scripting = {
      executeScript: function(args, callback) {
        // Stub - would need content script injection
        if (callback) callback([]);
        return Promise.resolve([]);
      },
      insertCSS: function(args, callback) {
        if (callback) callback();
        return Promise.resolve();
      },
      removeCSS: function(args, callback) {
        if (callback) callback();
        return Promise.resolve();
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.permissions
  // ---------------------------------------------------------------------------

  if (!chrome.permissions) {
    chrome.permissions = {
      contains: function(opts, callback) {
        // For now, assume all permissions are granted
        if (callback) callback(true);
        return Promise.resolve(true);
      },
      request: function(opts, callback) {
        // Auto-grant for imported extensions
        if (callback) callback(true);
        return Promise.resolve(true);
      },
      remove: function(opts, callback) {
        if (callback) callback(true);
        return Promise.resolve(true);
      },
      getAll: function(callback) {
        if (callback) callback({permissions: []});
        return Promise.resolve({permissions: []});
      },
      onAdded: {
        addListener: function() {},
        removeListener: function() {}
      },
      onRemoved: {
        addListener: function() {},
        removeListener: function() {}
      }
    };
  }

  // ---------------------------------------------------------------------------
  // chrome.alarms
  // ---------------------------------------------------------------------------

  if (!chrome.alarms) {
    chrome.alarms = {
      create: function(name, spec) {
        // Stub - would need background timer
        return Promise.resolve();
      },
      clear: function(name, callback) {
        if (callback) callback(true);
        return Promise.resolve(true);
      },
      clearAll: function(callback) {
        if (callback) callback(true);
        return Promise.resolve(true);
      },
      get: function(name, callback) {
        if (callback) callback(null);
        return Promise.resolve(null);
      },
      getAll: function(callback) {
        if (callback) callback([]);
        return Promise.resolve([]);
      }
    };
  }

  // ---------------------------------------------------------------------------
  // importScripts
  // ---------------------------------------------------------------------------

  if (typeof root.importScripts === 'undefined') {
    root.importScripts = function () {
      for (var i = 0; i < arguments.length; i++) {
        var url = String(arguments[i]);
        try {
          var request = new XMLHttpRequest();
          request.open('GET', url, false);
          request.send(null);
          if (request.status !== 0 && (request.status < 200 || request.status >= 300)) {
            throw new Error('importScripts: ' + url + ' returned ' + request.status);
          }
          (0, eval)(request.responseText + '\n//# sourceURL=' + url);
        } catch (e) {
          console.error('[WebLibre] importScripts failed for ' + url + ':', e);
          throw e;
        }
      }
    };
  }

  console.log('[WebLibre] Chrome compat layer initialized with extended APIs');
})();
