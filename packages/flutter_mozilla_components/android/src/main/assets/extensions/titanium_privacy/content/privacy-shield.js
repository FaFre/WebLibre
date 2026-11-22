// Titanium Privacy Shield — content script.
//
// This file is only the injector. The spoofing code below it must run in the
// page's own JavaScript context to be able to shadow HTMLCanvasElement,
// WebGLRenderingContext, AudioContext and navigator: a content script runs in
// an isolated sandbox whose globals the page never sees, so patching
// prototypes here would have no effect on any site. We inject an inline
// <script> as the first child of documentElement, which executes synchronously
// before any author script.

(function () {
    'use strict';

    if (window.__titaniumShieldInjected) return;
    window.__titaniumShieldInjected = true;

    function shieldEngine() {
        'use strict';

        if (window.__titaniumPrivacyShield) return;
        window.__titaniumPrivacyShield = true;

        // === Canvas Noise Injection ===
        // Mirrors Titanium's CanvasRandomization patch. Noise is applied to a
        // single pixel rather than the whole surface: reading and rewriting the
        // full canvas on every export is itself a main-thread stall, and one
        // perturbed pixel already changes the hash a fingerprinter computes.
        var _toDataURL = HTMLCanvasElement.prototype.toDataURL;
        var _getImageData = CanvasRenderingContext2D.prototype.getImageData;
        var _toBlob = HTMLCanvasElement.prototype.toBlob;

        function addNoise(ctx, width, height) {
            if (!width || !height) return;
            try {
                var imageData = _getImageData.call(ctx, 0, 0, 1, 1);
                var data = imageData.data;
                data[0] = (data[0] + 1) & 0xff;
                data[1] = (data[1] + 1) & 0xff;
                data[2] = (data[2] + 1) & 0xff;
                ctx.putImageData(imageData, 0, 0);
            } catch (e) {
                // Tainted canvas or no 2d context — nothing to perturb.
            }
        }

        CanvasRenderingContext2D.prototype.getImageData = function () {
            var result = _getImageData.apply(this, arguments);
            try {
                if (result && result.data && result.data.length >= 3) {
                    result.data[0] = (result.data[0] + 1) & 0xff;
                }
            } catch (e) {}
            return result;
        };

        HTMLCanvasElement.prototype.toDataURL = function () {
            var ctx = this.getContext && this.getContext('2d');
            if (ctx) addNoise(ctx, this.width, this.height);
            return _toDataURL.apply(this, arguments);
        };

        HTMLCanvasElement.prototype.toBlob = function () {
            var ctx = this.getContext && this.getContext('2d');
            if (ctx) addNoise(ctx, this.width, this.height);
            return _toBlob.apply(this, arguments);
        };

        // === WebGL Renderer Spoofing ===
        // Mirrors Titanium's WebGL render-info masking.
        var SPOOFED_RENDERER = 'ANGLE (Qualcomm, Adreno (TM) 730, OpenGL ES 3.2)';
        var SPOOFED_VENDOR = 'Qualcomm';

        function patchGetParameter(proto) {
            if (!proto) return;
            var _getParameter = proto.getParameter;
            if (!_getParameter) return;
            proto.getParameter = function (pname) {
                switch (pname) {
                    case 0x1F01: return SPOOFED_VENDOR;
                    case 0x9246: return SPOOFED_RENDERER;
                    case 0x1F00: return 'WebKit';
                    case 0x1F02: return 'WebKit WebGL';
                    default: return _getParameter.apply(this, arguments);
                }
            };
        }

        patchGetParameter(window.WebGLRenderingContext && WebGLRenderingContext.prototype);
        patchGetParameter(window.WebGL2RenderingContext && WebGL2RenderingContext.prototype);

        // === Navigator Property Hardening ===
        function define(target, prop, value) {
            try {
                Object.defineProperty(target, prop, { get: function () { return value; }, configurable: true });
            } catch (e) {}
        }

        define(navigator, 'hardwareConcurrency', 8);
        define(navigator, 'deviceMemory', 8);
        define(navigator, 'platform', 'Linux aarch64');
        define(navigator, 'languages', ['en-US', 'en']);

        if ('getBattery' in navigator) {
            define(navigator, 'getBattery', function () {
                return Promise.reject(new DOMException('Battery API disabled', 'NotAllowedError'));
            });
        }

        // === AudioContext Fingerprint Protection ===
        function patchOscillator(proto) {
            if (!proto) return;
            var _createOscillator = proto.createOscillator;
            if (!_createOscillator) return;
            proto.createOscillator = function () {
                var osc = _createOscillator.apply(this, arguments);
                var _start = osc.start.bind(osc);
                osc.start = function () {
                    try {
                        if (osc.frequency) {
                            osc.frequency.value += (Math.random() - 0.5) * 0.01;
                        }
                    } catch (e) {}
                    return _start.apply(null, arguments);
                };
                return osc;
            };
        }

        patchOscillator(window.AudioContext && AudioContext.prototype);
        patchOscillator(window.OfflineAudioContext && OfflineAudioContext.prototype);
    }

    var code = '(' + shieldEngine.toString() + ')();';

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
