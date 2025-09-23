<p align="center">
  <img width="250" src="app/assets/icon/icon.png" alt="WebLibre Logo">
</p>

# WebLibre: The Privacy-Focused Browser

<p align="center">
  <a href='https://github.com/FaFre/WebLibre/releases'>
    <img alt="GitHub Release" src="https://img.shields.io/github/v/release/FaFre/WebLibre">
  </a>
  <a href='https://f-droid.org/en/packages/eu.weblibre.gecko/'>
    <img alt="F-Droid Version" src="https://img.shields.io/f-droid/v/eu.weblibre.gecko">
  </a>
  <a href="https://liberapay.com/FaFre/donate">
    <img alt="Liberapay receiving" src="https://img.shields.io/liberapay/receives/FaFre">
  </a>
</p>

WebLibre is an independent browser project built on the foundation of [Mozilla's Gecko Engine](https://en.wikipedia.org/wiki/Gecko_(software)) and [Mozilla Android Components](https://mozac.org/). It offers a fully featured web browser compatible with Firefox mobile add-ons, designed with privacy and usability at its core.

<p align="center">
  <a href="https://liberapay.com/FaFre/donate">
    <img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg">
  </a>
</p>

> **⚠️ Alpha Release Notice**  
> WebLibre is currently in the alpha phase. Expect frequent updates, potential bugs, and breaking changes. Please report issues on [GitHub](https://github.com/FaFre/WebLibre/issues).
> Currently only F-Droid builds are free from Google dependencies.

## Join the WebLibre Community

We'd love to see you over on [Matrix](https://matrix.to/#/#weblibre:unredacted.org) and [Discord](https://discord.gg/y5fjdCdJ) to share ideas, get support, and help shape the future of this project.

**Your voice matters.** Since WebLibre respects your privacy by design—no tracking, no telemetry—we depend on community feedback to improve. Whether you've discovered a bug, have a feature request, or want to share your experience, we'd love to hear from you!

## Privacy by Design

A core mission of WebLibre is to shield users from third-party surveillance—whether by ISPs, tracking companies, or other entities seeking to monitor or collect data on your browsing habits. WebLibre achieves this through a suite of optional privacy features, including:

- [**Web Engine Hardening:**](https://docs.weblibre.eu/Privacy--and--Security#hardening--advanced-controls) Strengthens the browser’s core to resist tracking and fingerprinting techniques.
- [**Cookie Isolation:**](https://docs.weblibre.eu/Tabs/Containers/Features/Container-Cookie-Contexts) Ensures cookies are separated by container or context, preventing cross-site tracking.
- [**Content Blocking:**](https://docs.weblibre.eu/Privacy--and--Security#content-blocking) Blocks ads, trackers, and other unwanted content by default.
- [**Tor Proxying:**](https://docs.weblibre.eu/Tabs/Containers/Features/Tor-Proxy) Allows you to selectively route browsing traffic through the Tor network for enhanced anonymity.
- [**Local Search Engine:**](https://docs.weblibre.eu/Personal-Local-Search-Engine) whenever possible, your device handles search and retrieval, minimizing the need to contact remote services.

By combining these tools, WebLibre empowers you to browse the web freely and privately, minimizing exposure to unwanted monitoring and giving you genuine control over your online experience.

## Features

### [Tab Management](https://docs.weblibre.eu/Tabs/Tab-Management)

- [**Tab Containers:**](https://docs.weblibre.eu/Tabs/Containers/Container) Organize tabs into isolated containers for enhanced privacy and workflow management with optional features:
    - [**Container Cookie Contexts:**](https://docs.weblibre.eu/Tabs/Containers/Features/Container-Cookie-Contexts) Separate “cookie jars” for each container.
    - [**Tor Proxy:**](https://docs.weblibre.eu/Tabs/Containers/Features/Tor-Proxy) Route container traffic through the Tor network for anonymous browsing.
    - [**Biometric Authentication:**](https://docs.weblibre.eu/Tabs/Containers/Features/Biometric-authentication) Restrict access to containers using fingerprint or face recognition.
- [**Tree View Navigation:**](https://docs.weblibre.eu/Tabs/Tree-View-Navigation) Visualize and manage complex tab hierarchies for better browsing context.
- [**Local AI Assistance:**](https://docs.weblibre.eu/Tabs/Containers/Features/On-Device-AI) Use on-device AI models to group tabs and manage containers effortlessly.

### [Personal Local Search Engine](https://docs.weblibre.eu/Personal-Local-Search-Engine)

- **Unified Search:** Instantly search across:
    - **Open Tabs:** By title, address, and full page content (no size limits).
    - **Web Feeds:** Aggregate and search your favorite news sites and blogs, with full content indexing.
    - **Browsing History:** Quickly find previously visited sites by title or address.
    - **Bangs:** Use custom shortcuts for direct on-site search.
- **Local-First Search:** All indexing and search operations happen on your device—your data never leaves your control.

### Privacy & Security

- **No Tracking:** WebLibre does not track or monitor your browsing.
- **Local Data Storage:** All your data stays on your device.
- **Tor Integration:** Route container or private tab traffic through the Tor network for greater anonymity.
- **Ad and Content Blocking:** Optional content blocker (uBlock Origin) installation during onboarding.
- **Web Engine Hardening:** Comprehensive and easy-to-use privacy and security presets for the Gecko Web-Engine.

### [Bangs](https://docs.weblibre.eu/Bangs)

- **Direct On-Site Search:** Use thousands of powerful shortcuts (“bangs”) to search directly on popular websites—no third-party search engine required.

---

## Getting Started

1. **Download & Install** WebLibre on your device.
2. **Organize Tabs:** Use containers for work, personal, or research contexts.
3. **Enable Tor Proxy:** Assign Tor to containers or private tabs for sensitive browsing.
4. **Add Web Feeds:** Aggregate your favorite sites for unified, private search.
5. **Try Bangs:** Search directly on your favorite websites with custom shortcuts.

<p align="center">
  <a href='https://github.com/FaFre/WebLibre/releases'>
    <img height="100" alt='Get it on GitHub' src='https://docs.weblibre.eu/static/images/badges/github.png'/>
  </a>
  <a href='https://f-droid.org/en/packages/eu.weblibre.gecko/'>
    <img height="100" alt='Get it on F-Droid' src='https://docs.weblibre.eu/static/images/badges/fdroid.png'/>
  </a>
  <a href='https://play.google.com/store/apps/details?id=eu.weblibre.gecko'>
    <img height="100" alt='Get it on Google Play' src='https://docs.weblibre.eu/static/images/badges/google_play.png'/>
  </a>
</p>

> **⚠️ F-Droid Updates Delayed**  
> Due to the complexity of compiling the browser from scratch and the ongoing issue of the F-Droid server not supporting up-to-date AGP >= 8.12 (https://gitlab.com/fdroid/admin/-/issues/593), it is very difficult to provide up-to-date F-Droid builds.
>
> A lot of effort has already been put into working on getting the F-Droid build up to date, and the progress can be tracked here: https://gitlab.com/fdroid/fdroiddata/-/merge_requests/26485
>
> For up-to-date releases, please consider using the GitHub Releases (ideally with Obtainium) or Google Play for now.

---

## Feedback & Contributions

WebLibre is in active development, and your feedback is greatly welcomed!  
Please share your ideas, report issues via [GitHub Issues](https://github.com/FaFre/WebLibre/issues).
