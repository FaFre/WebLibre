// WebLibre Edge Account Login — content script.
//
// Microsoft's identity pages decide whether to serve the sign-in form or the
// "Browser not supported" page (account.live.com/error.aspx?errcode=1047)
// before any of this runs, from the User-Agent header. background.js rewrites
// that header. This file handles the other half: a page that is told it is
// Edge by the header and then reads navigator.userAgent, or the User-Agent
// Client Hints, and finds Firefox instead has been given a reason to abort the
// flow or to show a compatibility warning.
//
// Like the rest of WebLibre's extension code, the spoofing has to happen in the
// page's own JavaScript context — a content script's globals are not the ones
// the page reads — so the engine is serialized and injected as the first child
// of documentElement, before any author script.

(function () {
  'use strict';

  if (window.__edgeLoginInjected) return;
  window.__edgeLoginInjected = true;

  function edgeIdentity() {
    'use strict';

    if (window.__edgeLoginApplied) return;
    window.__edgeLoginApplied = true;

    // Microsoft Edge on Android. Edge uses the EdgA/ token on Android (Edg/ is
    // desktop Edge, EdgiOS/ is iOS), and reports Google Inc. as the vendor
    // because it is Chromium underneath.
    var EDGE_VERSION = '120';
    var EDGE_UA =
      'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) ' +
      'Chrome/' + EDGE_VERSION + '.0.0.0 Mobile Safari/537.36 EdgA/' + EDGE_VERSION + '.0.0.0';

    function define(obj, prop, getter) {
      try {
        Object.defineProperty(obj, prop, { get: getter, configurable: true, enumerable: true });
      } catch (e) {}
    }

    // --- navigator -----------------------------------------------------------

    define(navigator, 'userAgent', function () { return EDGE_UA; });
    define(navigator, 'appVersion', function () {
      return '5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) ' +
        'Chrome/' + EDGE_VERSION + '.0.0.0 Mobile Safari/537.36 EdgA/' + EDGE_VERSION + '.0.0.0';
    });
    define(navigator, 'vendor', function () { return 'Google Inc.'; });
    define(navigator, 'productSub', function () { return '20030107'; });

    // --- User-Agent Client Hints ---------------------------------------------
    //
    // Chromium-derived pages read the brand list rather than the UA string, so
    // a page that sees Chromium in the header and no "Microsoft Edge" brand in
    // the hints has the same inconsistency in the other direction.

    var EDGE_BRANDS = [
      { brand: 'Microsoft Edge', version: EDGE_VERSION },
      { brand: 'Chromium', version: EDGE_VERSION },
      { brand: 'Not_A Brand', version: '99' }
    ];

    try {
      if (navigator.userAgentData) {
        define(navigator.userAgentData, 'brands', function () { return EDGE_BRANDS; });
        define(navigator.userAgentData, 'mobile', function () { return true; });
        define(navigator.userAgentData, 'platform', function () { return 'Android'; });

        // getHighEntropyValues resolves from the same underlying data, so it has
        // to be wrapped or it would hand back the real brands.
        var originalGetHighEntropyValues = navigator.userAgentData.getHighEntropyValues;
        if (originalGetHighEntropyValues) {
          navigator.userAgentData.getHighEntropyValues = function (hints) {
            return originalGetHighEntropyValues.call(navigator.userAgentData, hints).then(function (values) {
              try {
                values.brands = EDGE_BRANDS;
                values.mobile = true;
                values.platform = 'Android';
              } catch (e) {}
              return values;
            });
          };
        }
      }
    } catch (e) {}

    // --- window.chrome -------------------------------------------------------
    //
    // Chromium exposes this object; a page that reads a Chromium UA and finds
    // no window.chrome can tell the difference.

    try {
      if (!window.chrome) {
        Object.defineProperty(window, 'chrome', {
          value: { runtime: {}, app: {}, csi: function () { return {}; }, loadTimes: function () { return {}; } },
          configurable: true,
          enumerable: true
        });
      }
    } catch (e) {}
  }

  var code = '(' + edgeIdentity.toString() + ')();';

  function inject() {
    try {
      var parent = document.documentElement || document.head;
      if (!parent) return false;
      var script = document.createElement('script');
      script.textContent = code;
      parent.insertBefore(script, parent.firstChild);
      script.remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  if (!inject()) {
    var observer = new MutationObserver(function () {
      if (inject()) observer.disconnect();
    });
    observer.observe(document, { childList: true, subtree: true });
    Promise.resolve().then(function () {
      if (inject()) observer.disconnect();
    });
  }
})();
