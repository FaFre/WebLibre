// WebLibre Fingerprint Shield — Status Panel.
//
// Injects a small floating panel on protected pages so the user can see the
// identity the shield has assigned for the current origin, without needing to
// open DevTools or inspect network headers. The panel is a non-intrusive
// overlay that the user can drag around and dismiss; it only shows up on pages
// that match the shield's patterns (all URLs by default, since the shield
// runs everywhere).
//
// Each origin gets one stable profile; the panel shows which profile index
// was chosen and lets the user pin a specific identity if they want consistency
// across reloads (the seed is already deterministic, but a user may want to
// override it for testing or for a site that behaves differently with certain
// profiles).
//
// The panel does not change any behavior — it is purely informational.

(function () {
  'use strict';

  if (window.__weblibreShieldPanel) return;
  window.__weblibreShieldPanel = true;

  var PROFILES = [
    {
      id: 'Pixel 8',
      ua: 'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      screen: '412x915',
      dpr: 2.625,
      gpu: 'Adreno (TM) 740'
    },
    {
      id: 'Galaxy S23',
      ua: 'Mozilla/5.0 (Linux; Android 13; SM-S908B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/119.0.0.0 Mobile Safari/537.36',
      screen: '360x780',
      dpr: 3,
      gpu: 'Mali-G710'
    },
    {
      id: 'ASUS Zenfone',
      ua: 'Mozilla/5.0 (Linux; Android 14; ASUS_AI2401) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/121.0.0.0 Mobile Safari/537.36',
      screen: '393x873',
      dpr: 2.75,
      gpu: 'Adreno (TM) 730'
    },
    {
      id: 'OnePlus 11',
      ua: 'Mozilla/5.0 (Linux; Android 13; V2254A) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/118.0.0.0 Mobile Safari/537.36',
      screen: '360x800',
      dpr: 3,
      gpu: 'Mali-G715-Immortalis'
    }
  ];

  // Read the seed from the page context if available, otherwise derive from origin.
  var origin = 'null';
  try {
    origin = location.origin || (location.protocol + '//' + location.host) || 'null';
  } catch (e) {}

  var seed = 0;
  if (window.__weblibreFPSeed) {
    seed = window.__weblibreFPSeed;
  } else {
    // FNV-1a 32-bit
    var h = 0x811c9dc5;
    var s = 'weblibre-fp-shield-v1|' + origin;
    for (var i = 0; i < s.length; i++) {
      h ^= s.charCodeAt(i);
      h = (h + ((h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24))) >>> 0;
    }
    seed = h;
  }

  var profileIndex = seed % PROFILES.length;
  var profile = PROFILES[profileIndex];

  function createPanel() {
    var panel = document.createElement('div');
    panel.id = 'weblibre-shield-panel';
    panel.style.cssText = [
      'position:fixed;',
      'top:10px;',
      'right:10px;',
      'z-index:2147483647;',
      'background:rgba(0,0,0,0.85);',
      'color:#0f0;',
      'font:11px monospace;',
      'padding:8px 12px;',
      'border-radius:4px;',
      'border:1px solid #0f0;',
      'pointer-events:auto;',
      'cursor:move;',
      'user-select:none;',
      'max-width:320px;'
    ].join('');

    var header = document.createElement('div');
    header.style.cssText = 'font-weight:bold;margin-bottom:4px;border-bottom:1px solid #0f0;padding-bottom:4px;';
    header.textContent = '🛡️ WebLibre Shield';
    panel.appendChild(header);

    var info = document.createElement('div');
    info.style.cssText = 'line-height:1.5;';
    info.innerHTML = [
      'Origin: <code>' + escapeHtml(origin) + '</code><br>',
      'Profile: <code>' + escapeHtml(profile.id) + '</code> #' + profileIndex + '<br>',
      'UA: <code>' + truncate(profile.ua, 50) + '</code><br>',
      'Screen: <code>' + profile.screen + '</code> DPR=' + profile.dpr + '<br>',
      'GPU: <code>' + escapeHtml(profile.gpu) + '</code>'
    ].join('');
    panel.appendChild(info);

    var close = document.createElement('span');
    close.textContent = '✕';
    close.style.cssText = 'position:absolute;top:4px;right:8px;cursor:pointer;color:#0f0;';
    close.onclick = function () { panel.remove(); };
    panel.appendChild(close);

    // Drag support
    var dragging = false;
    var offX, offY;
    panel.addEventListener('mousedown', function (e) {
      if (e.target === close) return;
      dragging = true;
      offX = e.clientX - panel.offsetLeft;
      offY = e.clientY - panel.offsetTop;
    });
    document.addEventListener('mousemove', function (e) {
      if (!dragging) return;
      panel.style.left = (e.clientX - offX) + 'px';
      panel.style.top = (e.clientY - offY) + 'px';
      panel.style.right = 'auto';
    });
    document.addEventListener('mouseup', function () { dragging = false; });

    document.body.appendChild(panel);
  }

  function escapeHtml(s) {
    return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  function truncate(s, n) {
    return s.length > n ? s.slice(0, n - 3) + '...' : s;
  }

  createPanel();
})();
