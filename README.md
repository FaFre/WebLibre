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

WebLibre is an independent privacy-focused browser for Android built on [Mozilla's Gecko Engine](https://en.wikipedia.org/wiki/Gecko_(software)) and [Mozilla Android Components](https://mozac.org/). It offers a fully-featured web browser with extension support, enhanced by powerful privacy features, local AI assistance (opt-in), and advanced tab organization tools.

<p align="center">
  <a href="https://liberapay.com/FaFre/donate">
    <img alt="Donate using Liberapay" src="https://docs.weblibre.eu/static/images/badges/liberapay.svg">
  </a>
  <a href="#donation">
    <img alt="Donate using Monero" src="https://docs.weblibre.eu/static/images/badges/monero.svg">
  </a>
</p>

> **📱 Early Access**
> WebLibre is under active development with frequent updates and new features. The browser is production-capable for early adopters who value privacy and are willing to help shape its future.

## Join the WebLibre Community

**Your voice matters.** Since WebLibre respects your privacy by design—no tracking, no telemetry—we depend on community feedback to improve. Here's how you can get involved:

- **[Feedback Platform](https://feedback.weblibre.eu/)** - Vote on features, share ideas, and help prioritize development
- **[Matrix Chat](https://matrix.to/#/#weblibre:unredacted.org)** - Get support, discuss ideas, and connect with other users
- **[GitHub Issues](https://github.com/FaFre/WebLibre/issues)** - Report bugs and track development

Whether you've discovered a bug, have a feature request, or want to share your experience, we'd love to hear from you!

## Privacy by Design

A core mission of WebLibre is to shield users from third-party surveillance—whether by ISPs, tracking companies, or other entities seeking to monitor or collect data on your browsing habits. WebLibre achieves this through a suite of optional privacy features, including:

- [**Web Engine Hardening:**](https://docs.weblibre.eu/Privacy--and--Security#hardening--advanced-controls) Strengthens the browser’s core to resist tracking and fingerprinting techniques.
- [**Cookie Isolation:**](https://docs.weblibre.eu/Tabs/Containers/Features/Container-Cookie-Contexts) Ensures cookies are separated by container or context, preventing cross-site tracking.
- [**Content Blocking:**](https://docs.weblibre.eu/Privacy--and--Security#content-blocking) Blocks ads, trackers, and other unwanted content by default.
- [**Tor Proxying:**](https://docs.weblibre.eu/Tabs/Containers/Features/Tor-Proxy) Allows you to selectively route browsing traffic through the Tor network for enhanced anonymity.
- [**Local Search Engine:**](https://docs.weblibre.eu/Personal-Local-Search-Engine) whenever possible, your device handles search and retrieval, minimizing the need to contact remote services.

By combining these tools, WebLibre empowers you to browse the web freely and privately, minimizing exposure to unwanted monitoring and giving you genuine control over your online experience.

## Features

### Multi-User Profiles

- **Complete Profile Isolation** - Separate browsing data, extensions, and settings per user
- **Profile Backups** - Export and restore individual user profiles with all associated data
- **Independent Configurations** - Each profile maintains its own containers, extensions, privacy settings, and preferences

### [Tab Management](https://docs.weblibre.eu/Tabs/Tab-Management)

- [**Tab Containers:**](https://docs.weblibre.eu/Tabs/Containers/Container) Organize tabs into isolated containers for enhanced privacy and workflow management:
    - [**Container Cookie Contexts:**](https://docs.weblibre.eu/Tabs/Containers/Features/Container-Cookie-Contexts) Separate "cookie jars" for each container
    - [**Tor Proxy:**](https://docs.weblibre.eu/Tabs/Containers/Features/Tor-Proxy) Route container traffic through the Tor network for anonymous browsing.
    - [**Biometric Authentication:**](https://docs.weblibre.eu/Tabs/Containers/Features/Biometric-authentication) Restrict access to containers using fingerprint or face recognition
    - **Site Assignments:** Automatically route specific domains to designated containers
- [**Tree View Navigation:**](https://docs.weblibre.eu/Tabs/Tree-View-Navigation) Visualize and manage complex tab hierarchies with parent-child relationships
- [**Local AI Assistance:**](https://docs.weblibre.eu/Tabs/Containers/Features/On-Device-AI) Use on-device AI models to intelligently group related tabs into new containers
- **Flexible Tab Views:** Choose between list view, grid view, or tree view with tab hierarchy

### [Personal Local Search Engine](https://docs.weblibre.eu/Personal-Local-Search-Engine)

- **Unified Search:** Instantly search across:
    - **Open Tabs:** By title, address, and full page content (no size limits)
    - **Bookmarks:** Search your saved bookmarks by title, URL, and folder
    - **Web Feeds:** Aggregate and search your favorite news sites and blogs with full content indexing
    - **Browsing History:** Quickly find previously visited sites by title or address
    - **[Bangs](https://docs.weblibre.eu/Bangs):** Use thousands of built-in shortcuts for direct on-site search
- **Custom Search Engines:** Create your own bang shortcuts for frequently used search engines and websites
- **Local-First Search:** All indexing and search operations happen on your device—your data never leaves your control

### Privacy & Security

- **No Tracking:** WebLibre does not track or monitor your browsing.
- **Local Data Storage:** All your data stays on your device.
- **Tor Integration:** Route container or private tab traffic through the Tor network for greater anonymity.
- **Ad and Content Blocking:** Optional content blocker (uBlock Origin) installation during onboarding.
- **Web Engine Hardening:** Comprehensive and easy-to-use privacy and security presets for the Gecko Web-Engine.
- **DNS over HTTPS (DoH):** Encrypted DNS with predefined or custom resolver options
- **Container Data Isolation:** Clear container data for isolated containers

### Productivity & Content Management

- **Bookmark Management** - Import/export bookmarks (JSON/HTML format)
- **Export Page Content** - Save web pages as PDF or Markdown

---

## Getting Started

1. **Download & Install** WebLibre on your Android device
2. **Set Up Your Profile:** Create your first user profile during onboarding
3. **Organize with Containers:** Create containers for different contexts (work, personal, shopping)
   - Assign specific websites to containers for automatic routing
   - Enable Tor proxy for sensitive containers
4. **Import Your Data:**
   - Import bookmarks from Firefox, Chrome, or other browsers (HTML format)
   - Organize bookmarks into folders
5. **Configure Privacy:**
   - Enable DNS over HTTPS
   - Configure web engine hardening presets
   - Set up content blocking (install uBlock Origin)
6. **Customize Your Experience:**
   - Add custom search engine bangs
   - Configure tab management preferences
   - Install extensions from custom addon collections

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

---

## Feedback & Contributions

WebLibre is in active development, and your feedback shapes its future!

- **Share Feedback:** [Feedback Platform](https://feedback.weblibre.eu/) - Request features, vote on ideas, and share your experience
- **Report Issues:** [GitHub Issues](https://github.com/FaFre/WebLibre/issues) - Report bugs and technical problems
- **Community Discussion:** [Matrix Chat](https://matrix.to/#/#weblibre:unredacted.org) - Get support and discuss ideas
- **Documentation:** [Documentation](https://docs.weblibre.eu/) - Learn more about features and configuration

Since WebLibre respects your privacy by design—**no tracking, no telemetry**—we rely entirely on community feedback to improve. Share your experience, request features, or report bugs!

---

## Donation

<a id="donation"></a>

If you find WebLibre useful and want to support its development, you can donate through any of the following platforms:

- **[GitHub Sponsors](https://github.com/sponsors/FaFre)** - Sponsor via GitHub
- **[Liberapay](https://liberapay.com/FaFre/donate)** - Recurring donations
- **[Ko-fi](https://ko-fi.com/FaFre)** - One-time donations

### Monero

```
89rpdkq1XJYJYUshjF23YZhJdNEpghrQTXnz7vxnrLVHGrrqXTZ6BdKbqgyQnNZCkxTDA4RfhDsUcF6eHAAqco4WDQR2cZF
```
