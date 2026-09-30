// WebLibre Fingerprint Shield — content script.
//
// Runs at document_start in every frame, after common.js. It derives a single
// deterministic seed from the document origin, picks a consistent device
// profile from that seed, then injects the shield engine into the page's own
// JavaScript context.
//
// The engine must run in the page context (not the content-script sandbox) to
// be able to shadow the page's navigator/screen/canvas/WebGL/audio surfaces.
// We inject an inline <script> as the very first child of documentElement,
// which executes synchronously before any author script.
//
// The background script derives the same profile for the same origin and pins
// the outgoing User-Agent header to it, so the header and the JS surface agree.

(function () {
  'use strict';

  if (window.__weblibreFingerprintShield) return;

  var origin = 'null';
  try {
    origin = location.origin || (location.protocol + '//' + location.host) || 'null';
  } catch (e) {}

  var seed = WEBLIBRE_FP.seedForOrigin(origin);
  var profile = WEBLIBRE_FP.profileForOrigin(origin);

  // ---------------------------------------------------------------------------
  // Engine
  //
  // Serialized with Function.prototype.toString and evaluated in the page
  // context, so it cannot close over anything above. Everything it needs is
  // passed as the config argument.
  // ---------------------------------------------------------------------------

  function shieldEngine(config) {
    'use strict';
    if (window.__weblibreFingerprintShield) return;
    window.__weblibreFingerprintShield = true;

    var profile = config.profile;
    var seed = config.seed;

    // Seeded PRNG (mulberry32) for all stochastic noise. Deterministic per
    // origin, so canvas/audio fingerprints are stable within a site yet differ
    // between sites.
    var _s = seed >>> 0;
    function rand() {
      _s = (_s + 0x6d2b79f5) | 0;
      var t = Math.imul(_s ^ (_s >>> 15), 1 | _s);
      t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
      return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
    }

    function define(obj, prop, getter) {
      try {
        Object.defineProperty(obj, prop, { get: getter, configurable: true, enumerable: true });
      } catch (e) {}
    }

    // =========================================================================
    // navigator
    // =========================================================================

    try {
      var nav = window.navigator;

      define(nav, 'userAgent', function () { return profile.ua; });
      define(nav, 'appVersion', function () { return profile.appVersion; });
      define(nav, 'platform', function () { return profile.platform; });
      define(nav, 'vendor', function () { return profile.vendor; });
      define(nav, 'product', function () { return 'Gecko'; });
      define(nav, 'productSub', function () { return '20100101'; });
      define(nav, 'hardwareConcurrency', function () { return profile.hardwareConcurrency; });
      define(nav, 'deviceMemory', function () { return profile.deviceMemory; });
      define(nav, 'maxTouchPoints', function () { return profile.maxTouchPoints; });
      define(nav, 'webdriver', function () { return false; });
      define(nav, 'language', function () { return 'en-US'; });
      define(nav, 'languages', function () { return ['en-US', 'en']; });
      define(nav, 'doNotTrack', function () { return '1'; });
      define(nav, 'globalPrivacyControl', function () { return true; });

      // plugins / mimeTypes — empty, matching a clean profile.
      try {
        var PluginArrayProto = Object.getPrototypeOf(nav.plugins);
        var MimeTypeArrayProto = Object.getPrototypeOf(nav.mimeTypes);
        var emptyPlugins = Object.create(PluginArrayProto);
        Object.defineProperty(emptyPlugins, 'length', { get: function () { return 0; } });
        Object.defineProperty(emptyPlugins, 'item', { value: function () { return null; } });
        Object.defineProperty(emptyPlugins, 'namedItem', { value: function () { return null; } });
        Object.defineProperty(emptyPlugins, 'refresh', { value: function () {} });
        define(nav, 'plugins', function () { return emptyPlugins; });

        var emptyMimeTypes = Object.create(MimeTypeArrayProto);
        Object.defineProperty(emptyMimeTypes, 'length', { get: function () { return 0; } });
        Object.defineProperty(emptyMimeTypes, 'item', { value: function () { return null; } });
        Object.defineProperty(emptyMimeTypes, 'namedItem', { value: function () { return null; } });
        define(nav, 'mimeTypes', function () { return emptyMimeTypes; });
      } catch (e) {}

      // Client Hints (userAgentData) — must agree with the UA string.
      try {
        if (nav.userAgentData) {
          var uad = nav.userAgentData;
          define(uad, 'brands', function () {
            return [
              { brand: 'Chromium', version: '120' },
              { brand: 'Google Chrome', version: '120' },
              { brand: 'Not-A.Brand', version: '99' }
            ];
          });
          define(uad, 'mobile', function () { return true; });
          define(uad, 'platform', function () { return 'Android'; });
        }
      } catch (e) {}

      // Battery Status API — a stable fingerprinting vector with no legitimate
      // use case; report a plausible constant instead of the real values.
      try {
        define(nav, 'getBattery', function () {
          return function () {
            return Promise.resolve({
              charging: true,
              chargingTime: 0,
              dischargingTime: Infinity,
              level: 1,
              onchargingchange: null,
              onchargingtimechange: null,
              ondischargingtimechange: null,
              onlevelchange: null,
              addEventListener: function () {},
              removeEventListener: function () {}
            });
          };
        });
      } catch (e) {}

      // Connection API
      try {
        if (nav.connection) {
          define(nav.connection, 'rtt', function () { return 100; });
          define(nav.connection, 'downlink', function () { return 10; });
          define(nav.connection, 'effectiveType', function () { return '4g'; });
        }
      } catch (e) {}
    } catch (e) {}

    // =========================================================================
    // screen / window metrics
    // =========================================================================

    try {
      var screen = window.screen;
      var sp = profile.screen;
      define(screen, 'width', function () { return sp.width; });
      define(screen, 'height', function () { return sp.height; });
      define(screen, 'availWidth', function () { return sp.availWidth; });
      define(screen, 'availHeight', function () { return sp.availHeight; });
      define(screen, 'colorDepth', function () { return sp.colorDepth; });
      define(screen, 'pixelDepth', function () { return sp.pixelDepth; });

      define(window, 'devicePixelRatio', function () { return profile.dpr; });
    } catch (e) {}

    // =========================================================================
    // Timezone
    // =========================================================================

    try {
      var origResolved = Intl.DateTimeFormat.prototype.resolvedOptions;
      Intl.DateTimeFormat.prototype.resolvedOptions = function () {
        var opts = origResolved.call(this);
        try {
          opts.timeZone = 'UTC';
        } catch (e) {}
        return opts;
      };

      Date.prototype.getTimezoneOffset = function () {
        return 0;
      };
    } catch (e) {}

    // =========================================================================
    // Canvas 2D — deterministic per-origin pixel noise
    // =========================================================================

    try {
      var CH = window.HTMLCanvasElement;
      var CR = window.CanvasRenderingContext2D;

      function addCanvasNoise(canvas) {
        try {
          var ctx = canvas.getContext('2d');
          if (!ctx) return;
          var w = canvas.width, h = canvas.height;
          if (!w || !h) return;
          var x = Math.floor(rand() * w);
          var y = Math.floor(rand() * h);
          var img = ctx.getImageData(x, y, 1, 1);
          var d = img.data;
          d[0] = (d[0] + Math.floor(rand() * 8) + 1) & 0xff;
          d[1] = (d[1] + Math.floor(rand() * 8) + 1) & 0xff;
          d[2] = (d[2] + Math.floor(rand() * 8) + 1) & 0xff;
          ctx.putImageData(img, x, y);
        } catch (e) {}
      }

      var origToDataURL = CH.prototype.toDataURL;
      CH.prototype.toDataURL = function () {
        addCanvasNoise(this);
        return origToDataURL.apply(this, arguments);
      };

      var origToBlob = CH.prototype.toBlob;
      CH.prototype.toBlob = function () {
        addCanvasNoise(this);
        return origToBlob.apply(this, arguments);
      };

      var origGetImageData = CR.prototype.getImageData;
      CR.prototype.getImageData = function (x, y, w, h) {
        var result = origGetImageData.apply(this, arguments);
        try {
          if (w > 0 && h > 0 && result.data.length >= 4) {
            var i = Math.floor(rand() * (result.data.length / 4)) * 4;
            result.data[i] = (result.data[i] + Math.floor(rand() * 8) + 1) & 0xff;
          }
        } catch (e) {}
        return result;
      };
    } catch (e) {}

    // =========================================================================
    // WebGL / WebGL2 — spoof GPU vendor and renderer
    // =========================================================================

    try {
      var UNMASKED_VENDOR = 0x9245;
      var UNMASKED_RENDERER = 0x9246;

      function patchGetParameter(proto) {
        if (!proto) return;
        var orig = proto.getParameter;
        if (!orig) return;
        proto.getParameter = function (pname) {
          if (pname === UNMASKED_VENDOR) return profile.webgl.vendor;
          if (pname === UNMASKED_RENDERER) return profile.webgl.renderer;
          return orig.apply(this, arguments);
        };
      }

      patchGetParameter(window.WebGLRenderingContext && window.WebGLRenderingContext.prototype);
      patchGetParameter(window.WebGL2RenderingContext && window.WebGL2RenderingContext.prototype);
    } catch (e) {}

    // =========================================================================
    // WebAudio — deterministic frequency-domain noise
    // =========================================================================

    try {
      function noisyFloat(arr) {
        for (var i = 0; i < arr.length; i++) {
          arr[i] = arr[i] + (rand() - 0.5) * 1e-7;
        }
      }
      function noisyByte(arr) {
        for (var i = 0; i < arr.length; i++) {
          arr[i] = (arr[i] + Math.floor(rand() * 3) - 1) & 0xff;
        }
      }

      if (window.AnalyserNode) {
        var origFloat = AnalyserNode.prototype.getFloatFrequencyData;
        if (origFloat) {
          AnalyserNode.prototype.getFloatFrequencyData = function (arr) {
            origFloat.call(this, arr);
            noisyFloat(arr);
          };
        }
        var origByte = AnalyserNode.prototype.getByteFrequencyData;
        if (origByte) {
          AnalyserNode.prototype.getByteFrequencyData = function (arr) {
            origByte.call(this, arr);
            noisyByte(arr);
          };
        }
      }

      if (window.AudioBuffer) {
        var origChannel = AudioBuffer.prototype.getChannelData;
        if (origChannel) {
          AudioBuffer.prototype.getChannelData = function () {
            var data = origChannel.apply(this, arguments);
            try {
              if (data && data.length) {
                data[0] = data[0] + (rand() - 0.5) * 1e-7;
              }
            } catch (e) {}
            return data;
          };
        }
      }
    } catch (e) {}

    // =========================================================================
    // WebRTC — restrict ICE candidates so local/private addresses never leak
    // =========================================================================

    try {
      var RTC = window.RTCPeerConnection || window.webkitRTCPeerConnection;
      if (RTC) {
        var origSetLocal = RTC.prototype.setLocalDescription;
        if (origSetLocal) {
          RTC.prototype.setLocalDescription = function () {
            var self = this;
            var args = arguments;
            return origSetLocal.apply(self, args).then(function (desc) {
              try {
                if (desc && desc.sdp) {
                  desc.sdp = desc.sdp.replace(/^(a=candidate:.*? )(?:\d+\.\d+\.\d+\.\d+)( .*)$/gm, function (m, a, b) {
                    return a + '0.0.0.0' + b;
                  });
                }
              } catch (e) {}
              return desc;
            });
          };
        }
      }
    } catch (e) {}

    // =========================================================================
    // MediaDevices — hide device labels and non-essential kinds
    // =========================================================================

    try {
      if (navigator.mediaDevices && navigator.mediaDevices.enumerateDevices) {
        var origEnum = navigator.mediaDevices.enumerateDevices.bind(navigator.mediaDevices);
        navigator.mediaDevices.enumerateDevices = function () {
          return origEnum().then(function (devices) {
            return devices.map(function (d) {
              try {
                return { deviceId: '', groupId: '', kind: d.kind, label: '' };
              } catch (e) {
                return d;
              }
            });
          });
        };
      }
    } catch (e) {}

    // =========================================================================
    // Fonts — restrict enumeration via document.fonts.check
    // =========================================================================

    try {
      if (document.fonts && document.fonts.check) {
        document.fonts.check = function () {
          return false;
        };
      }
    } catch (e) {}

    // =========================================================================
    // Timing — clamp high-resolution clocks to reduce side-channel precision
    // =========================================================================

    try {
      if (window.performance && performance.now) {
        var origNow = performance.now.bind(performance);
        performance.now = function () {
          return Math.round(origNow() * 100) / 100;
        };
      }
    } catch (e) {}
  }

  // ---------------------------------------------------------------------------
  // Injection
  // ---------------------------------------------------------------------------

  var code =
    '(' + shieldEngine.toString() + ')(' +
    JSON.stringify({ profile: profile, seed: seed }) +
    ');';

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
    // documentElement can be missing for a brief moment at document_start in
    // some frames; wait for the root element and inject as early as possible.
    var observer = new MutationObserver(function () {
      if (inject()) observer.disconnect();
    });
    observer.observe(document, { childList: true, subtree: true });
    // Hard fallback: give up waiting after the first task turn.
    Promise.resolve().then(function () {
      if (inject()) observer.disconnect();
    });
  }
})();
