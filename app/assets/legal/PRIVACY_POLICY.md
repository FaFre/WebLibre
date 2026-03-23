# WebLibre Privacy Policy

**Version 1.3**
**Last Updated:** 2026-03-22

**Controller:**
OnDevice UG (haftungsbeschränkt)
Romerstrasse 21
D-71540 Murrhardt
Germany
info@ondevice.eu

---

## 1. Overview

This Privacy Policy explains how OnDevice UG handles personal data in connection with WebLibre.

WebLibre is designed so that browsing and app data are primarily processed on your device rather than sent to OnDevice UG. WebLibre may also connect you to third-party websites, services, networks, platform features, and content providers that process data under their own terms and privacy policies.

Unless otherwise stated, references to "we," "us," or "our" mean OnDevice UG.

---

## 2. Data Processed Locally on Your Device

Depending on the features you use, WebLibre may store or process data locally on your device, such as browsing history, bookmarks, cookies and site data, cached content, downloads, tab state, search history, settings, extension data, account-related data, feed content, and backup or export files.

Some files you create or export may be stored outside the app sandbox in locations you choose or that Android makes available for file access.

Local storage on your device is generally under your control. You can manage or delete certain data through Android and in-app settings, but some data may remain until you remove it manually, clear app storage, or uninstall the app.

---

## 3. Data That May Be Sent to Third Parties

When you use the web or optional features, your device may communicate directly with third parties. All such features are either user-initiated or can be disabled. OnDevice UG does not control third-party processing and is not responsible for third-party privacy or security practices.

### 3.1 Web Browsing

When you visit a website, your device connects directly to that website's servers. The website receives your IP address, browser user agent string, HTTP headers, cookies, and any data you submit. This is inherent to how the web works and is not controlled by WebLibre. WebLibre provides tools to mitigate tracking (see Section 7).

**Legal basis:** Contract performance (Art. 6(1)(b) GDPR) — fulfilling your request to access a website.

### 3.2 Search Suggestions (Optional)

When enabled, partial search queries are sent to the search suggestion provider you select (for example DuckDuckGo, Brave Search, Kagi, Qwant, or another provider you configure). Each provider's privacy policy governs their handling of this data. You can disable this feature entirely in settings.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enable this feature and select the provider.

### 3.3 Search Engines

When you perform a search, your full query is sent to your selected search engine (for example DuckDuckGo, Brave Search, Kagi, Qwant, or another provider you configure). This is a direct interaction between your device and the search engine provider. WebLibre does not intermediate or log these queries.

**Legal basis:** Contract performance (Art. 6(1)(b) GDPR) — fulfilling your request to perform a search.

### 3.4 Firefox Sync (Optional)

If you sign in with a Mozilla account, WebLibre can synchronize data (bookmarks, browsing history, open tabs, device information) with Mozilla's Firefox Sync servers. This feature is entirely opt-in. WebLibre also supports custom server overrides, in which case synchronization data is transmitted to the operator of the server endpoints you configure instead of Mozilla's default infrastructure.

**Data controller for Firefox Sync:** Mozilla Corporation for the default service, or the operator of the endpoints you configure if you override the defaults. Mozilla's privacy policy: https://www.mozilla.org/privacy/firefox/

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you actively sign in and choose to sync.

### 3.5 DNS-over-HTTPS (Optional)

If you enable DNS-over-HTTPS (DoH) or configure a custom DNS resolver, DNS queries are sent to the selected provider instead of your default network resolver.

**Data sent:** DNS lookup requests and related network metadata necessary for name resolution.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enable DoH or configure the provider.

### 3.6 Enhanced Tracking Protection and Safe Browsing

WebLibre uses GeckoView's built-in tracking protection and security features to block known trackers, fingerprinters, and malicious sites. When Google Safe Browsing or similar remote reputation features are active, URL-derived lookup data or other security-related request data may be transmitted to Google LLC or the relevant provider to detect dangerous websites or downloads.

**Data controller for Safe Browsing:** Google LLC. Google's privacy policy: https://policies.google.com/privacy

**Legal basis:** Legitimate interest (Art. 6(1)(f) GDPR) — protecting users from malicious websites.

### 3.7 Browser Extensions (User-Initiated)

When you install a browser extension, WebLibre may contact Mozilla Add-ons (addons.mozilla.org), a configured add-on collection, or another source to retrieve extension metadata or downloads. WebLibre also supports installation from local `.xpi` files, which does not require contact with a remote source.

**Data sent:** Extension identifiers and related request metadata required by the selected source.

Installed extensions may independently communicate with their own servers according to their own privacy policies.

**Legal basis:** Contract performance (Art. 6(1)(b) GDPR) — fulfilling your request to install an extension.

### 3.8 URL Unshortening (Optional)

When enabled, WebLibre can expand shortened URLs (e.g., bit.ly links) to reveal the actual destination before navigation.

**Data sent:** The shortened URL.
**Server:** `unshorten.me`. The service may cache redirect results. Avoid using this feature for private or sensitive URLs unless you accept third-party handling.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enable this feature.

### 3.9 Tor Network (Optional)

When Tor mode is enabled, your web traffic is routed through the Tor network via multiple relays for anonymity. OnDevice UG is not affiliated with The Tor Project.

**Data sent:** Encrypted traffic via the standard Tor protocol.

**Pluggable transports:** Depending on your settings, WebLibre may use pluggable transports (such as Snowflake, obfs4, meek, or webtunnel) to connect to the Tor network. When using these transports, your device may additionally communicate with transport brokers, CDN front domains, and STUN/TURN servers operated by third parties. **These connections may expose your IP address to the respective transport operators.**

Bridge configuration may be bundled with the app, manually entered by you, or fetched remotely (e.g., via the Tor Project's Moat API).

The Tor network's operation is governed by the Tor Project's policies: https://www.torproject.org/about/privacy/

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enable Tor mode.

### 3.10 RSS/Feed Fetching (User-Initiated)

When you subscribe to an RSS or Atom feed, WebLibre periodically fetches content from the feed URL. In release builds, feeds are automatically refreshed approximately every 15 minutes using Android's background fetch mechanism, including when the app is not actively running and after device restarts.

**Data sent:** HTTP requests to the feed URLs (your IP address is visible to the feed servers).

**Legal basis:** Contract performance (Art. 6(1)(b) GDPR) — fulfilling your request to subscribe to a feed.

### 3.11 URL Cleaner Catalog Updates (Optional)

WebLibre includes a locally cached URL-cleaning catalog (ClearURLs) to strip tracking parameters from URLs. Depending on your settings, the app may also fetch updated catalog data and related hash/check files from remote sources at runtime.

**Data sent:** Standard HTTP(S) requests to the configured catalog and hash URLs. URL cleaning itself is performed locally.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enable automatic catalog updates.

### 3.12 Speech Recognition / Voice Input (Optional)

If you use speech-to-text or voice-input features, WebLibre invokes Android's speech recognition facilities.

**Data sent:** Audio, recognized text, and related request metadata may be processed by your device vendor, OS provider, or configured speech-recognition service.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to invoke the feature.

### 3.13 Small Web Discovery (Optional)

When you use Small Web mode, WebLibre fetches content from third-party sources to help you discover independent websites and personal blogs.

**Kagi Small Web:** WebLibre fetches publicly available Atom feeds from Kagi (`kagi.com`) to retrieve curated lists of personal blog posts, indie videos, code projects, and web comics. Feed content is cached locally on your device.

**Wander:** WebLibre fetches small JavaScript files (`wander.js`) from independently operated personal websites that participate in the Wander network. These files contain lists of recommended pages and links to other participating sites. Your device connects directly to each console host.

**Data sent:** Standard HTTP(S) requests to Kagi's feed endpoints and to Wander console hosts. Your IP address is visible to these servers. Discovered content (URLs, titles, authors, summaries) is stored locally on your device. No account or personal data is sent beyond what is included in standard HTTP requests.

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to enter Small Web mode and initiate discovery.

### 3.14 QR Scanning and Camera-Based Pairing (Optional)

If you use QR scanning features (such as pairing a Firefox Sync account from a desktop browser), the app uses the device camera locally to scan the code.

QR image data is processed on-device. If you proceed with the action encoded in the QR code, related third-party communications may then occur as part of the chosen feature (e.g., Firefox Sync sign-in).

**Legal basis:** Consent (Art. 6(1)(a) GDPR) — you choose to invoke the feature.

---

## 4. Data We Receive

WebLibre is not designed to send your browsing history, page content, search queries, or app usage analytics to OnDevice UG by default. To be explicit, in the ordinary operation of the app as provided by OnDevice UG, OnDevice UG does **not**:

- operate telemetry, analytics, crash reporting, advertising, fingerprinting, or profiling services;
- intentionally collect browsing behavior, search queries, or app usage data;
- use advertising networks or ad identifiers;
- sell, rent, or share your personal data;
- intentionally operate servers that receive personal browsing data from WebLibre installations.

However, OnDevice UG may receive limited personal data in situations outside or around the app itself, for example if you contact us, submit a legal request, access our websites or code hosting pages, use a service we operate, or interact with a platform or distribution channel that shares operational information with us.

We may also process information where necessary to comply with law, protect rights and security, prevent abuse, or operate and improve our own services.

---

## 5. Purposes and Legal Bases

Where applicable under the GDPR, we process personal data on one or more of the following legal bases. The specific legal basis for each feature is stated in Section 3 alongside that feature's data flow description.

**Summary of legal bases:**

- **Consent** (Art. 6(1)(a) GDPR) — for optional features you choose to enable, such as search suggestions (3.2), Firefox Sync (3.4), DNS-over-HTTPS (3.5), URL unshortening (3.8), Tor routing (3.9), URL cleaner catalog updates (3.11), voice input (3.12), Small Web discovery (3.13), and QR scanning (3.14);
- **Contract performance** (Art. 6(1)(b) GDPR) — for features inherent to the service you requested, such as web browsing (3.1), search queries (3.3), extension installation (3.7), and feed fetching (3.10);
- **Legitimate interest** (Art. 6(1)(f) GDPR) — for security and protection features such as tracking protection and safe browsing (3.6);
- **Legal obligation** (Art. 6(1)(c) GDPR) — where required by applicable law;
- any other legal basis permitted under applicable law.

For optional third-party features you choose to enable or configure, the relevant third party may act as an independent controller or processor under its own privacy terms.

---

## 6. What We Do Not Intentionally Do Through the App

WebLibre is not intended to operate as a telemetry, advertising, or profiling product for OnDevice UG. We do not intentionally design the app to send us browsing content, browsing history, search terms, or app usage analytics for tracking or advertising purposes.

This section applies to the app's intended first-party behavior. It does not cover third-party services, modified builds, custom endpoints, user-configured services, platform-level processing, or data you provide to us separately.

---

## 7. Privacy Features and User Controls

WebLibre provides extensive privacy controls that you can configure through the app's privacy and security settings. Key controls include:

- **Enhanced Tracking Protection (ETP)** — blocks known trackers, fingerprinters, cryptominers, and social tracking content
- **Bounce Tracking Protection** — mitigates cross-site tracking via redirect chains
- **Query Parameter Stripping** — removes known tracking parameters from URLs
- **Fingerprinting Resistance** — reduces browser fingerprinting surface
- **Global Privacy Control (GPC)** — sends a signal to websites requesting they do not sell or share your data
- **Multi-Account Containers** — isolate browsing contexts to prevent cross-site tracking, with optional clear-on-exit per container
- **HTTPS-Only Mode** — upgrades connections to HTTPS where possible
- **DNS-over-HTTPS** — encrypts DNS queries to configured providers
- **Site Isolation** — isolates website processes for security
- **Local Network Blocking** — prevents websites from accessing local network resources
- **Tor Integration** — routes traffic through the Tor network for anonymity
- **URL Cleaning** — strips tracking parameters from URLs using locally cached catalogs

For a complete list of available controls and their current state, see the app's privacy and security settings.

---

## 8. Permissions and Device Features

WebLibre may request or use device permissions and platform features depending on the functionality you use, such as internet access, storage or media access, notifications, camera, microphone, location, biometric or local authentication, credential services, and interaction with other apps.

These permissions are used to provide requested functionality. Data obtained through those permissions may be processed locally on your device or sent to relevant third parties depending on the feature you use and your device or platform configuration.

---

## 9. Children

WebLibre is not directed to children, and we do not knowingly collect personal data from children through the app. Parents and guardians are responsible for supervising a child's use of the internet, apps, and connected services.

---

## 10. Retention

Data stored locally by the app generally remains on your device until you delete it, overwrite it, clear app storage, uninstall the app, or remove external files. Certain categories of local data may also be deleted earlier through in-app deletion features, clear-on-exit settings, or Android storage management.

If OnDevice UG receives personal data directly (for example through support requests or legal inquiries), we retain it only for as long as reasonably necessary for the purpose for which it was collected, including legal, operational, security, documentation, and dispute-resolution purposes, and no longer than required by applicable law.

---

## 11. Security

We use reasonable measures for personal data we control. Local app data is protected by Android's application sandboxing. WebLibre supports encrypted backups for profile data. The app's local-only storage model means that most user data never leaves your device unless you choose to use features that transmit data (as described in Section 3).

However, no software, device, network, or transmission method is completely secure. You are responsible for the security of your device, backups, exported files, credentials, accounts, and any third-party services or custom configurations you choose to use.

---

## 12. International Transfers

When you access websites or use optional features, third parties may process data in countries outside your own, including outside the European Economic Area. Those transfers are governed by the relevant third party's terms and privacy practices.

If OnDevice UG transfers personal data internationally, we will do so in accordance with applicable law.

---

## 13. Your Rights

Subject to applicable law, you may have rights including access, rectification, erasure, restriction, portability, objection, and the right to withdraw consent where processing is based on consent.

Because WebLibre is designed to store most data locally on your device, OnDevice UG may not be able to identify you from app use alone or respond to requests regarding data that we do not possess or control.

You also have the right to lodge a complaint with a competent data protection authority, in particular in the EU Member State of your habitual residence, place of work, or the place of the alleged infringement, subject to applicable law.

To exercise your rights regarding data controlled by OnDevice UG, contact: info@ondevice.eu

Supervisory authority:
Der Landesbeauftragte fur den Datenschutz und die Informationsfreiheit Baden-Wurttemberg (LfDI BW), https://www.baden-wuerttemberg.datenschutz.de/

---

## 14. Third-Party Services and Open Source

WebLibre includes or interoperates with third-party and open source components. Those components, services, and endpoints may change over time and may be governed by separate privacy notices, licenses, or terms.

WebLibre is open source. Its source code is publicly available to support transparency and independent review:

Source code: https://github.com/FaFre/WebLibre

---

## 15. Changes to This Privacy Policy

We may update this Privacy Policy from time to time. We will publish the updated version and revise the version number and last updated date. Material changes may also be communicated through app release notes, repositories, websites, or other appropriate channels.

---

## 16. Contact

If you have questions about this Privacy Policy, please contact:

OnDevice UG (haftungsbeschränkt)
Romerstrasse 21
D-71540 Murrhardt
Germany
Email: info@ondevice.eu

---

## 17. Governing Law

This Privacy Policy is governed by the laws of the Federal Republic of Germany, except where mandatory law requires otherwise.
