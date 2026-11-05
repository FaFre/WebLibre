<p align="center">
  <img width="250" src="apps/weblibre/assets/icon/icon.png" alt="WebLibre logo">
</p>

# WebLibre

<p align="center"><strong>A private, personal web environment for Android.</strong></p>

<p align="center">
  <a href="https://github.com/FaFre/WebLibre/releases">
    <img alt="Latest GitHub release" src="https://img.shields.io/github/v/release/FaFre/WebLibre">
  </a>
  <a href="https://f-droid.org/en/packages/eu.weblibre.gecko/">
    <img alt="F-Droid version" src="https://img.shields.io/f-droid/v/eu.weblibre.gecko">
  </a>
  <a href="COPYING">
    <img alt="License: AGPL-3.0" src="https://img.shields.io/badge/license-AGPL--3.0-blue">
  </a>
  <a href="https://hosted.weblate.org/engage/weblibre/">
    <img src="https://hosted.weblate.org/widget/weblibre/language-badge.svg?threshold=0" alt="Translation status">
  </a>
  <a href="https://liberapay.com/FaFre/donate">
    <img alt="Liberapay patrons" src="https://img.shields.io/liberapay/patrons/FaFre">
  </a>
</p>

<p align="center">
  <a href="https://matrix.to/#/#weblibre:unredacted.org">
    <img alt="Chat on Matrix" src="https://img.shields.io/badge/Matrix-%23weblibre-0DBD8B?logo=matrix&logoColor=white">
  </a>
  <a href="https://fosstodon.org/@WebLibre">
    <img alt="Follow on Mastodon" src="https://img.shields.io/badge/Mastodon-%40WebLibre-6364FF?logo=mastodon&logoColor=white">
  </a>
  <a href="https://feedback.weblibre.eu/">
    <img alt="Suggest and vote on features" src="https://img.shields.io/badge/Feedback-Suggest%20%26%20vote-F59E0B">
  </a>
</p>

WebLibre is an independent, privacy-focused Android browser built on [Mozilla's Gecko engine](https://wiki.mozilla.org/Gecko), the engine used by Firefox. It brings browsing and web apps together in one place, with separate spaces for different accounts and activities, built-in Tor, WireGuard VPN, and proxy support, and full-text search of the pages you've visited that never leaves your device.

Give a website its own app window and login, or let it share logins with related tabs. Shape the same environment for one-handed browsing on a phone or a keyboard and mouse on a larger Android screen.

[Explore](#your-web-environment) · [Install](#install-weblibre) · [Documentation](#documentation) · [Community](#community)

> [!IMPORTANT]
> **Early Access** - WebLibre is under active development. Features and settings can change, and updates may introduce bugs.

## Your Web Environment

Profiles hold your data and settings, containers group your activities, and tabs and web apps open the sites. Which logins a tab or web app shares, and whether it goes through Tor, a VPN, or a proxy, are separate choices.

[How WebLibre is organized](https://docs.weblibre.eu/how-weblibre-is-organized.html)

### Spaces with Their Own Rules

Keep accounts and activities apart without treating every visit the same way:

- **[Isolated tabs](https://docs.weblibre.eu/tabs/tab-management.html)** each keep their own cookies and logins, separate from every other tab. Unlike private tabs, they survive quitting and reopening WebLibre.
- **[Containers](https://docs.weblibre.eu/tabs/containers.html)** group recurring activities, open assigned sites automatically, and can exclude pages from history and search. Cookie-isolated containers can also go through Tor, a VPN, or a proxy, and clear their cookies and site data on exit.
- **[Profiles](https://docs.weblibre.eu/profiles.html)** separate the whole setup: tabs, bookmarks, history, logins, extensions, feeds, and settings. Switching profiles requires a restart.

Containers **share cookies by default**. Choose **Cookie Isolation** when creating a container if you need separate logins and site data, or want the container to use Tor, a VPN, or a proxy; that choice cannot be changed later.

Optional [on-device AI](https://docs.weblibre.eu/on-device-ai.html) can suggest containers and names for open tabs based on their titles, and asks before changing anything. This may require downloading a model first.

### A Searchable Local Library

Everything you visit, save, and follow becomes one library you can search from the address bar, on your device:

- **Page text** - WebLibre keeps a full-text index of the pages you visit. Type a word you remember from an article, recipe, or forum thread, and it finds the page even if that word never appeared in its title or address. Opening the result highlights the match.
- **Feed articles** - Follow sites through [RSS/Atom feeds](https://docs.weblibre.eu/web-feeds.html) without a separate feed reader. Saved articles are searchable by title, summary, and text, so your feeds work as a personal reading archive. [Small Web](https://docs.weblibre.eu/small-web.html) helps you discover independent sites to follow.
- **Tabs, bookmarks, and history** - Matches appear alongside page text and articles, before you choose a web search.

Pages are indexed on your device without sending their content anywhere. Private tabs are left out by default, and you can exclude individual containers or clear the index at any time. When you do want the web, [bang shortcuts](https://docs.weblibre.eu/search/bangs.html) such as `!w privacy` send your search straight to a specific site.

[Reader Mode](https://docs.weblibre.eu/reader-mode.html), [PDF/Markdown/full-page image export](https://docs.weblibre.eu/page-export.html), and [on-device translation](https://docs.weblibre.eu/page-translation.html) help you read and reuse what you find.

[Local search & page index](https://docs.weblibre.eu/search/local-search.html) · [Web feeds](https://docs.weblibre.eu/web-feeds.html)

### Websites as Apps

Install sites you use often on your home screen, where they open in their own window like an app. Choose whether each one shares logins with your browser or a container, or keeps its own. The same service can become **Personal Mail** and **Work Mail**, each signed in to a different account. Web apps installed from a container also use its Tor, VPN, or proxy setting.

[Web apps & PWA](https://docs.weblibre.eu/web-apps.html) · [Website notifications via UnifiedPush](https://docs.weblibre.eu/website-notifications.html) (requires a separate delivery app)

### Built-in Tor, VPN, and Proxies

Use **Tor** without a separate app to help hide your IP address from the sites you visit. Import a **WireGuard VPN** configuration from your VPN provider or your own server, so sites see that server's address instead of yours. You can also connect through SOCKS, HTTP, Shadowsocks, and other supported proxy protocols. These connections apply only to WebLibre, not to other apps on your device.

Keep everyday browsing on your normal internet connection while private tabs, isolated tabs, or cookie-isolated containers use Tor, a VPN, or a proxy. Or send all regular browsing through one.

[Tor](https://docs.weblibre.eu/tor.html) · [Proxy connections](https://docs.weblibre.eu/proxy.html)

### An Interface You Can Shape

WebLibre adapts from one-handed browsing on a phone to a keyboard and mouse on a larger screen. Automatic layout uses bottom controls on phones and side panels on large screens, from foldables to Chromebooks and desktop windows.

Follow relationships between pages in a [tree of tabs](https://docs.weblibre.eu/tabs/tree-view.html), or use list and grid views with grouping, pinning, and filtering.

Customize menus, toolbar buttons, long-press actions, and search sections. Assign browser actions to [gestures](https://docs.weblibre.eu/gestures.html), [keyboard shortcuts](https://docs.weblibre.eu/keyboard-shortcuts.html), or toolbar long presses.

[Larger screens & input](https://docs.weblibre.eu/customization/toolbar.html#larger-screens) · [Toolbar & layout](https://docs.weblibre.eu/customization/toolbar.html) · [Tab management](https://docs.weblibre.eu/tabs/tab-management.html)

### A Setup You Can Keep and Move

- **[Profile backups](https://docs.weblibre.eu/profiles.html#_back_up_a_profile)** save a whole profile as an encrypted file you can restore later or on another device.
- **[Export & Import Settings](https://docs.weblibre.eu/settings-transfer.html)** moves selected settings between profiles or devices without a full backup.
- **[Firefox Sync](https://docs.weblibre.eu/firefox-sync.html)** keeps tabs, bookmarks, and history up to date across your devices. [WebLibre Supporters](https://docs.weblibre.eu/supporter-subscription.html#encrypted-account-sync) can also sync WebLibre's own settings, encrypted on the device before upload.
- **[Profile locks](https://docs.weblibre.eu/app-lock.html)** protect individual profiles with a password or Android device authentication.

## Gecko, Extensions, and Privacy Defaults

WebLibre has its own browser interface, with support for [Firefox-compatible extensions](https://docs.weblibre.eu/extensions.html). **Quick Start** installs uBlock Origin automatically. More add-ons are available through the in-app store, custom collections, or local `.xpi` files; not every desktop add-on works on Android.

Strict tracking protection, DNS over HTTPS, HTTPS-only protection, tracking-parameter removal, Global Privacy Control, and site isolation are enabled by default. [Per-site controls](https://docs.weblibre.eu/site-controls.html) let you handle exceptions without changing settings for the whole browser.

WebLibre has no telemetry or crash reporting of its own, and Gecko's telemetry, studies, and experiments are switched off and locked so engine updates can't turn them back on. Optional services such as Firefox Sync, WebLibre Search, and encrypted settings sync connect only when you use them.

## Install WebLibre

WebLibre requires Android 8.0 or newer. Android 13 or newer is recommended. On Android 12 and older, you may notice visual glitches.

<p align="center">
  <a href="https://github.com/FaFre/WebLibre/releases">
    <img height="90" alt="Get WebLibre from GitHub" src="https://docs.weblibre.eu/_images/badges/github.png">
  </a>
  <a href="https://f-droid.org/en/packages/eu.weblibre.gecko/">
    <img height="90" alt="Get WebLibre on F-Droid" src="https://docs.weblibre.eu/_images/badges/fdroid.png">
  </a>
  <a href="https://play.google.com/store/apps/details?id=eu.weblibre.gecko">
    <img height="90" alt="Get WebLibre on Google Play" src="https://docs.weblibre.eu/_images/badges/google_play.png">
  </a>
</p>

- **[GitHub Releases](https://github.com/FaFre/WebLibre/releases)** - Direct downloads; [Obtainium](https://obtainium.imranr.dev/) can manage updates. Most current devices use the `arm64-v8a` APK; `armeabi-v7a` is for older 32-bit devices, and `x86_64` is for emulators, ChromeOS, and x86 tablets.
- **[Google Play](https://play.google.com/store/apps/details?id=eu.weblibre.gecko)** - Automatic updates through Google Play.
- **[F-Droid](https://f-droid.org/en/packages/eu.weblibre.gecko/)** - Independently built and signed by F-Droid. Build and review requirements mean updates may arrive considerably later than on GitHub or Google Play.

> [!WARNING]
> Switching between F-Droid and GitHub or Google Play builds requires uninstalling WebLibre first, because they use different signing keys. Uninstalling deletes **all profiles and their data**.
>
> Before you uninstall, create an encrypted [backup of every profile you want to keep](https://docs.weblibre.eu/profiles.html#_back_up_a_profile). Save the backups outside WebLibre's app storage, leave **Verify backup integrity** enabled, and keep the backup passwords safe.

<details>
<summary>Verify your download</summary>

Check an APK's signing certificate with `apksigner verify --print-certs path/to/weblibre.apk`. The SHA-256 certificate fingerprints are:

- **GitHub Releases / Google Play:**

  ```text
  8F:52:6E:1E:53:D6:BD:4D:FB:F4:F4:B9:3C:2A:91:EC:B5:CB:8D:A5:E1:4A:D9:4C:25:70:E1:E3:C7:13:52:7F
  ```

- **F-Droid** (signed by F-Droid with its own key):

  ```text
  BB:2A:97:F5:61:53:35:C9:E5:7C:86:6F:1C:30:ED:4F:D7:D7:BD:DC:BC:BC:06:68:FE:93:A5:79:17:3D:3D:2D
  ```

</details>

On first launch, choose **Quick Start**, **Custom Setup**, or **Restore from Backup**. The [First Launch Guide](https://docs.weblibre.eu/getting-started.html) explains each option.

## Documentation

Full user documentation is available at **[docs.weblibre.eu](https://docs.weblibre.eu/)**.

- **[First Launch Guide](https://docs.weblibre.eu/getting-started.html)** - Setup options and recommended defaults.
- **[Privacy Setup](https://docs.weblibre.eu/quick-start.html)** - Review the main protections and their tradeoffs.
- **[Switching Browsers](https://docs.weblibre.eu/migration.html)** - Import bookmarks or use [Firefox Sync](https://docs.weblibre.eu/firefox-sync.html) for tabs, bookmarks, and history.
- **[Common Workflows](https://docs.weblibre.eu/workflows.html)** - Everyday tasks and advanced features.
- **[Troubleshooting](https://docs.weblibre.eu/troubleshooting.html)** - Fix common problems and learn what to include in a bug report.

## Community

Have an idea, a question, or want to follow along? Join us:

| | Where | What for |
|---|---|---|
| 💡 | **[Feedback Platform](https://feedback.weblibre.eu/)** | Suggest and vote on features. |
| 💬 | **[Matrix Chat](https://matrix.to/#/#weblibre:unredacted.org)** | Ask questions and talk with the community. |
| 🐘 | **[Mastodon](https://fosstodon.org/@WebLibre)** | Follow release announcements and project news. |
| 🐛 | **[GitHub Issues](https://github.com/FaFre/WebLibre/issues)** | Report reproducible bugs and follow development. |

## Support the Project

- **[WebLibre Supporter](https://docs.weblibre.eu/supporter-subscription.html)** - Fund development and get access to WebLibre Search and encrypted sync for WebLibre settings. The browser and its built-in privacy controls remain free.
- **[GitHub Sponsors](https://github.com/sponsors/FaFre)** - Sponsor development through GitHub.
- **[Liberapay](https://liberapay.com/FaFre/donate)** - Make a recurring donation.
- **[Ko-fi](https://ko-fi.com/FaFre)** - Make a one-time donation.

<p align="center">
  <a href="https://liberapay.com/FaFre/donate"><img alt="Donate with Liberapay" src="https://docs.weblibre.eu/_images/badges/liberapay.svg"></a>
  <a href="https://ko-fi.com/FaFre"><img alt="Donate with Ko-fi" src="https://docs.weblibre.eu/_images/badges/kofi.svg"></a>
  <a href="https://github.com/sponsors/FaFre"><img alt="Donate with GitHub Sponsors" src="https://docs.weblibre.eu/_images/badges/github_sponsors.svg"></a>
  <a href="#monero"><img alt="Donate with Monero" src="https://docs.weblibre.eu/_images/badges/monero.svg"></a>
  <a href="#litecoin"><img alt="Donate with Litecoin" src="https://docs.weblibre.eu/_images/badges/litecoin.svg"></a>
</p>

### Monero

```text
89rpdkq1XJYJYUshjF23YZhJdNEpghrQTXnz7vxnrLVHGrrqXTZ6BdKbqgyQnNZCkxTDA4RfhDsUcF6eHAAqco4WDQR2cZF
```

### Litecoin

```text
ltc1q0dtutc9zgkvffevwsz7s87379puk37hwn4un94
```

## License

WebLibre is free software licensed under the [GNU Affero General Public License v3.0](COPYING).
