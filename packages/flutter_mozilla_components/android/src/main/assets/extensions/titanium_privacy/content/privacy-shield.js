// Titanium Privacy Shield - Content Script
// Ported from Titanium Browser's Chromium fingerprint resistance patches
// Runs at document_start to intercept before any site JS executes

(function() {
    'use strict';

    // === Canvas Noise Injection ===
    // Mirrors Titanium's CanvasRandomization patch
    const _toDataURL = HTMLCanvasElement.prototype.toDataURL;
    const _getImageData = CanvasRenderingContext2D.prototype.getImageData;
    const _toBlob = HTMLCanvasElement.prototype.toBlob;

    function addNoise(imageData) {
        const data = imageData.data;
        for (let i = 0; i < data.length; i += 4) {
            const noise = ((i * 2654435761) >>> 0) % 3 - 1;
            data[i] = Math.max(0, Math.min(255, data[i] + noise));
            data[i+1] = Math.max(0, Math.min(255, data[i+1] + noise));
            data[i+2] = Math.max(0, Math.min(255, data[i+2] + noise));
        }
        return imageData;
    }

    CanvasRenderingContext2D.prototype.getImageData = function(...args) {
        const result = _getImageData.apply(this, args);
        return addNoise(result);
    };

    HTMLCanvasElement.prototype.toDataURL = function(...args) {
        const ctx = this.getContext('2d');
        if (ctx) {
            const imageData = _getImageData.call(ctx, 0, 0, this.width, this.height);
            addNoise(imageData);
            ctx.putImageData(imageData, 0, 0);
        }
        return _toDataURL.apply(this, args);
    };

    // === WebGL Renderer Spoofing ===
    // Mirrors Titanium's WebGL render info masking
    const _getParameter = WebGLRenderingContext.prototype.getParameter;

    const SPOOFED_RENDERER = "ANGLE (Qualcomm, Adreno (TM) 730, OpenGL ES 3.2)";
    const SPOOFED_VENDOR = "Qualcomm";

    WebGLRenderingContext.prototype.getParameter = function(pname) {
        switch (pname) {
            case 0x1F01: return SPOOFED_VENDOR;
            case 0x9246: return SPOOFED_RENDERER;
            case 0x1F00: return "WebKit";
            case 0x1F02: return "WebKit WebGL";
            default: return _getParameter.apply(this, arguments);
        }
    };

    if (typeof WebGL2RenderingContext !== 'undefined') {
        WebGL2RenderingContext.prototype.getParameter = WebGLRenderingContext.prototype.getParameter;
    }

    // === Navigator Property Hardening ===
    Object.defineProperty(navigator, 'hardwareConcurrency', { value: 8, configurable: false });
    Object.defineProperty(navigator, 'deviceMemory', { value: 8, configurable: false });
    Object.defineProperty(navigator, 'platform', { value: 'Linux aarch64', configurable: false });
    Object.defineProperty(navigator, 'languages', { value: ['en-US', 'en'], configurable: false });

    if ('getBattery' in navigator) {
        Object.defineProperty(navigator, 'getBattery', {
            value: () => Promise.reject(new DOMException('Battery API disabled', 'NotAllowedError')),
            configurable: false
        });
    }

    // === AudioContext Fingerprint Protection ===
    const _createOscillator = AudioContext.prototype.createOscillator;
    AudioContext.prototype.createOscillator = function() {
        const osc = _createOscillator.apply(this, arguments);
        const _start = osc.start.bind(osc);
        osc.start = function(...args) {
            if (osc.frequency) {
                osc.frequency.value += (Math.random() - 0.5) * 0.01;
            }
            return _start(...args);
        };
        return osc;
    };
})();
