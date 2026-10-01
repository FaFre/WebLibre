// WebLibre Fingerprint Shield — Consistency Tester.
//
// When loaded at test.weblibre.eu/fp-test (or any page with ?fp_test=1),
// this script runs a battery of fingerprint reads and compares each surface
// against the profile the shield assigned for the current origin. Mismatches
// are highlighted in red; matches in green.
//
// It is deliberately self-contained: no imports, no framework, runs in any
// page context. The results are written directly to the DOM so the user can
// see them immediately, including on a plain about:blank frame.
//
// Usage: open any page and append ?fp_test=1 to the URL, or visit
// https://test.weblibre.eu/fp-test in WebLibre with the shield enabled.

(function () {
  'use strict';

  if (!location.search.includes('fp_test=1') && location.hostname !== 'test.weblibre.eu') return;

  var profiles = (typeof WEBLIBRE_FP !== 'undefined' && WEBLIBRE_FP.PROFILES) ? WEBLIBRE_FP.PROFILES : [];
  var originFn = (typeof WEBLIBRE_FP !== 'undefined' && WEBLIBRE_FP.seedForOrigin) ? WEBLIBRE_FP.seedForOrigin : null;
  var origin = location.origin || 'null';
  var seed = originFn ? originFn(origin) : fnv1a('weblibre-fp-shield-v1|' + origin);
  var idx = seed % Math.max(1, profiles.length);
  var profile = profiles[idx] || { ua: '?', screenWidth: '?', screenHeight: '?', availWidth: '?', availHeight: '?', colorDepth: 24, dpr: '?', concurrency: '?', memory: '?', webglVendor: '?', webglRenderer: '?' };

  var results = [];

  // --- navigator ---
  results.push(test('navigator.userAgent', navigator.userAgent, profile.ua));
  results.push(test('navigator.platform', navigator.platform, 'Linux armv8l'));
  results.push(test('navigator.hardwareConcurrency', navigator.hardwareConcurrency, profile.concurrency));
  results.push(test('navigator.deviceMemory', navigator.deviceMemory, profile.memory));
  results.push(test('navigator.webdriver', navigator.webdriver, false));
  results.push(test('navigator.language', navigator.language, 'en-US'));
  results.push(test('navigator.languages', JSON.stringify(navigator.languages), '["en-US","en"]'));

  // --- window.chrome ---
  results.push(test('window.chrome exists', !!(window.chrome && window.chrome.runtime), true));

  // --- screen ---
  results.push(test('screen.width', screen.width, profile.screenWidth));
  results.push(test('screen.height', screen.height, profile.screenHeight));
  results.push(test('screen.availWidth', screen.availWidth, profile.availWidth));
  results.push(test('screen.availHeight', screen.availHeight, profile.availHeight));
  results.push(test('screen.colorDepth', screen.colorDepth, profile.colorDepth));
  results.push(test('window.devicePixelRatio', window.devicePixelRatio, profile.dpr));

  // --- WebGL ---
  try {
    var c = document.createElement('canvas');
    var gl = c.getContext('webgl') || c.getContext('experimental-webgl');
    if (gl) {
      var dbg = gl.getExtension('WEBGL_debug_renderer_info');
      if (dbg) {
        results.push(test('WebGL UNMASKED_VENDOR_WEBGL', gl.getParameter(dbg.UNMASKED_VENDOR_WEBGL), profile.webglVendor));
        results.push(test('WebGL UNMASKED_RENDERER_WEBGL', gl.getParameter(dbg.UNMASKED_RENDERER_WEBGL), profile.webglRenderer));
      }
    }
  } catch (e) {
    results.push({ label: 'WebGL', actual: 'error', expected: profile.webglRenderer, ok: false, note: e.message });
  }

  // --- timezone ---
  results.push(test('Date.getTimezoneOffset', new Date().getTimezoneOffset(), 0));
  try {
    var tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
    results.push(test('Intl.DateTimeFormat time zone', tz, 'UTC'));
  } catch (e) {
    results.push({ label: 'Intl zone', actual: 'error', expected: 'UTC', ok: false, note: e.message });
  }

  // --- UA Client Hints ---
  try {
    if (navigator.userAgentData && navigator.userAgentData.brands) {
      var brands = navigator.userAgentData.brands.map(function (b) { return b.brand + '/' + b.version; }).join(', ');
      results.push(test('userAgentData.brands', brands, 'Microsoft Edge/120, Chromium/120, Not_A Brand/99'));
      results.push(test('userAgentData.mobile', navigator.userAgentData.mobile, true));
    } else {
      results.push({ label: 'userAgentData', actual: 'not available', expected: 'present', ok: false, note: 'browser does not expose Client Hints' });
    }
  } catch (e) {
    results.push({ label: 'userAgentData', actual: 'error', expected: 'present', ok: false, note: e.message });
  }

  // --- doNotTrack / GPC ---
  results.push(test('navigator.doNotTrack', navigator.doNotTrack, '1'));
  if ('globalPrivacyControl' in navigator) {
    results.push(test('navigator.globalPrivacyControl', navigator.globalPrivacyControl, true));
  }

  // --- Battery (should be spoofed to constant) ---
  if (navigator.getBattery) {
    navigator.getBattery().then(function (b) {
      results.push({ label: 'battery.charging', actual: b.charging, expected: true, ok: b.charging === true, note: 'async' });
      results.push({ label: 'battery.level', actual: b.level, expected: 1, ok: b.level === 1, note: 'async' });
    }).catch(function (e) {
      results.push({ label: 'battery', actual: 'error', expected: 'spoi...', ok: false, note: e.message });
    });
  }

  // --- Font enumeration ---
  if (document.fonts && document.fonts.check) {
    try {
      var fontOk = document.fonts.check('1em sans-serif');
      results.push(test('document.fonts.check', fontOk, false));
    } catch (e) {
      results.push({ label: 'document.fonts.check', actual: 'error', expected: 'false', ok: false, note: e.message });
    }
  }

  // --- Performance.now precision ---
  var t0 = performance.now();
  while (performance.now() - t0 < 5) {}
  var now = performance.now();
  var digits = Math.floor(Math.log10(now)) + 1;
  // Chrome/Edge report ~3 decimal places; we clamp to 2.
  results.push({
    label: 'performance.now precision',
    actual: 'rounded to ' + digits + ' total digits',
    expected: 'rounded to 2 decimal places',
    ok: String(now).split('.')[1] && String(now).split('.')[1].length <= 2,
    note: ''
  });

  render(results);
})();

function fnv1a(str) {
  var h = 0x811c9dc5;
  for (var i = 0; i < str.length; i++) {
    h ^= str.charCodeAt(i);
    h = (h + ((h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24))) >>> 0;
  }
  return h;
}

function test(label, actual, expected) {
  var ok = (actual == expected) || (typeof actual === 'boolean' && actual === expected) ||
           (typeof actual === 'string' && actual === expected);
  return { label: label, actual: String(actual), expected: String(expected), ok: ok, note: '' };
}

function render(results) {
  var wrapper = document.createElement('div');
  wrapper.style.cssText = 'position:fixed;top:0;left:0;right:0;bottom:0;z-index:2147483647;background:#111;color:#eee;font:13px monospace;padding:16px;overflow:auto;box-sizing:border-box;';
  var heading = document.createElement('h1');
  heading.style.cssText = 'margin:0 0 8px;font-size:16px;color:#0f0;';
  heading.textContent = '🛡️ WebLibre Fingerprint Consistency Test';
  wrapper.appendChild(heading);

  var summary = document.createElement('div');
  summary.style.cssText = 'margin-bottom:12px;font-size:12px;color:#aaa;';
  var pass = results.filter(function (r) { return r.ok; }).length;
  var fail = results.length - pass;
  summary.textContent = 'Origin: ' + location.origin + ' | Passed: ' + pass + '/' + results.length + (fail > 0 ? ' | ❌ Failures below' : ' | ✅ All coherent');
  wrapper.appendChild(summary);

  var table = document.createElement('table');
  table.style.cssText = 'width:100%;border-collapse:collapse;';
  var thead = document.createElement('thead');
  thead.innerHTML = '<tr style="border-bottom:1px solid #333;"><th style="text-align:left;padding:4px 8px;">Surface</th><th style="text-align:left;padding:4px 8px;">Expected</th><th style="text-align:left;padding:4px 8px;">Actual</th><th style="text-align:center;padding:4px 8px;">Status</th></tr>';
  table.appendChild(thead);

  var tbody = document.createElement('tbody');
  for (var i = 0; i < results.length; i++) {
    var r = results[i];
    var tr = document.createElement('tr');
    tr.style.cssText = 'border-bottom:1px solid #222;' + (r.ok ? '' : 'background:rgba(255,0,0,0.08);');
    tr.innerHTML = [
      '<td style="padding:4px 8px;">' + esc(r.label) + '</td>',
      '<td style="padding:4px 8px;color:#8f8;">' + esc(r.expected) + '</td>',
      '<td style="padding:4px 8px;color:' + (r.ok ? '#eee' : '#f88') + ';">' + esc(r.actual) + (r.note ? ' <span style="color:#888;">(' + esc(r.note) + ')</span>' : '') + '</td>',
      '<td style="padding:4px 8px;text-align:center;font-size:16px;">' + (r.ok ? '✅' : '❌') + '</td>'
    ].join('');
    tbody.appendChild(tr);
  }
  table.appendChild(tbody);
  wrapper.appendChild(table);

  var tip = document.createElement('div');
  tip.style.cssText = 'margin-top:16px;font-size:11px;color:#888;';
  tip.innerHTML = 'Remove <code>?fp_test=1</code> from the URL to hide. ' +
    'If any mismatch is marked ❌, the fingerprint surfaces are inconsistent — ' +
    'that inconsistency itself is a unique signal a tracker can use.';
  wrapper.appendChild(tip);

  document.body.appendChild(wrapper);
}

function esc(s) {
  return String(s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
}
