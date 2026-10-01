// WebLibre Chrome compat layer.
//
// Gecko exposes `chrome.*` as a callback-style alias of `browser.*`, which is
// what Manifest V2 Chrome extensions use and what they expect. Manifest V3
// changed the contract: `chrome.*` methods return a Promise when no callback is
// given. An MV3 extension written against that contract does
//
//     const tabs = await chrome.tabs.query({});
//
// and on Gecko gets `undefined` back, because the call returns nothing until
// the callback fires. This layer restores the promise form while leaving the
// callback form exactly as it was, so MV2 and MV3 extensions both work.
//
// It is injected ahead of the extension's own scripts — in the background event
// page and in every content script — so it runs before any of them.

(function () {
  'use strict';

  var root = typeof globalThis !== 'undefined' ? globalThis : this;
  if (root.__weblibreChromeCompat) return;
  root.__weblibreChromeCompat = true;

  // ---------------------------------------------------------------------------
  // Promise form of chrome.*
  // ---------------------------------------------------------------------------

  if (typeof chrome === 'undefined') return;

  /**
   * Wrap one API method so that it returns a Promise when called without a
   * callback, and behaves exactly as before when called with one.
   */
  function wrapMethod(namespace, name, original) {
    var wrapped = function () {
      var args = Array.prototype.slice.call(arguments);
      var last = args[args.length - 1];

      if (typeof last === 'function') {
        // Callback form: hand the call straight through. Nothing about an MV2
        // extension's expectations should change.
        return original.apply(namespace, args);
      }

      return new Promise(function (resolve, reject) {
        args.push(function (result) {
          // Gecko reports failures through runtime.lastError during the
          // callback; that is the only place the promise form can learn about
          // them, so it has to be read here rather than later.
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

    // Keep the original reachable, and keep the function's name so stack
    // traces still say which API threw.
    try {
      Object.defineProperty(wrapped, 'name', { value: name, configurable: true });
    } catch (e) {}
    wrapped.__weblibreOriginal = original;
    return wrapped;
  }

  function isWrappable(owner, key) {
    var descriptor;
    try {
      descriptor = Object.getOwnPropertyDescriptor(owner, key);
    } catch (e) {
      // Some chrome.* members are exotic objects that refuse introspection.
      return false;
    }
    if (!descriptor) return true;
    return descriptor.writable !== false || descriptor.configurable !== false;
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

      // Events (onMessage, onInstalled, onBeforeRequest, …) are objects whose
      // addListener must stay the same function identity, and whose listeners
      // are not API calls. Walking into them would break every extension that
      // registers a listener.
      if (key.length > 2 && key.charCodeAt(0) === 111 /* o */ && key.charCodeAt(1) === 110 /* n */) {
        continue;
      }

      var value;
      try {
        value = namespace[key];
      } catch (e) {
        continue;
      }

      if (typeof value === 'function') {
        if (value.__weblibreOriginal) continue; // already wrapped
        if (!isWrappable(namespace, key)) continue;
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
  // importScripts
  // ---------------------------------------------------------------------------
  //
  // An MV3 service worker that is not a module loads its dependencies with
  // importScripts, which does not exist on an event page. A synchronous
  // fetch-and-evaluate is the closest available behaviour.
  //
  // Note the limitation: extension pages run under a content security policy
  // that blocks eval by default, so this only works when the extension's own
  // policy allows it. It is provided because failing with a clear error from a
  // defined function is better than failing with "importScripts is not defined"
  // from nowhere, not because it is guaranteed to work.

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
})();
