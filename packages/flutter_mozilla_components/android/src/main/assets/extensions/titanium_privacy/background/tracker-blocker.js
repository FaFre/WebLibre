// Titanium Privacy Shield - Background Tracker Blocker
// Ported from Titanium Browser's host-based tracker blocking architecture

const TRACKER_PATTERNS = [
    "*://*.doubleclick.net/*",
    "*://*.googlesyndication.com/*",
    "*://*.google-analytics.com/*",
    "*://*.facebook.com/tr*",
    "*://*.fbcdn.net/*/tracking*",
    "*://*.analytics.google.com/*",
    "*://*.hotjar.com/*",
    "*://*.mixpanel.com/*",
    "*://*.amplitude.com/*",
    "*://*.segment.io/*",
    "*://*.branch.io/*",
    "*://*.adjust.com/*",
    "*://*.appsflyer.com/*",
    "*://*.kochava.com/*",
    "*://*.singular.net/*"
];

browser.webRequest.onBeforeRequest.addListener(
    function(details) { return { cancel: true }; },
    { urls: TRACKER_PATTERNS },
    ["blocking"]
);
