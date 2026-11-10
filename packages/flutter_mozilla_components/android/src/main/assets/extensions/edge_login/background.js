// WebLibre Edge Account Login — background script.
//
// Microsoft's identity endpoints answer a Gecko User-Agent with the
// "Browser not supported" page, so the header is rewritten before it leaves.
// The manifest already restricts this listener to Microsoft's domains, so
// nothing outside them is touched.
//
// The Client Hints headers are set alongside it: a request that claims to be
// Edge in User-Agent but carries Firefox's hints (or none) is inconsistent in
// exactly the way the extension exists to avoid.

const EDGE_VERSION = '120';

const EDGE_UA =
  'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) ' +
  'Chrome/' + EDGE_VERSION + '.0.0.0 Mobile Safari/537.36 EdgA/' + EDGE_VERSION + '.0.0.0';

const EDGE_HINTS = {
  'Sec-CH-UA': '"Microsoft Edge";v="' + EDGE_VERSION + '", "Chromium";v="' + EDGE_VERSION + '", "Not_A Brand";v="99"',
  'Sec-CH-UA-Mobile': '?1',
  'Sec-CH-UA-Platform': '"Android"'
};

function rewrite(headers, name, value) {
  const lower = name.toLowerCase();
  for (const header of headers) {
    if (header.name.toLowerCase() === lower) {
      header.value = value;
      return;
    }
  }
  headers.push({ name: name, value: value });
}

browser.webRequest.onBeforeSendHeaders.addListener(
  function (details) {
    const headers = details.requestHeaders || [];
    rewrite(headers, 'User-Agent', EDGE_UA);
    for (const name of Object.keys(EDGE_HINTS)) {
      rewrite(headers, name, EDGE_HINTS[name]);
    }
    return { requestHeaders: headers };
  },
  { urls: [
      '*://*.live.com/*',
      '*://*.microsoft.com/*',
      '*://*.microsoftonline.com/*',
      '*://*.microsoft365.com/*',
      '*://*.office.com/*',
      '*://*.office365.com/*',
      '*://*.sharepoint.com/*',
      '*://login.windows.net/*',
      '*://*.bing.com/*'
    ] },
  ['blocking', 'requestHeaders']
);
