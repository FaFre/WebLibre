## 0.9.30
### GeckoView 146.0.1

**New Features**
- GitHub and Google Play releases are using libre Fennec-style Gecko builds from now on (on par with F-Droid)
- Added encrypted profile backup and restore system with password protection
- Added bookmark import/export functionality
  - Support for HTML (Netscape format, Firefox/Chrome compatible) and JSON formats
  - Option to merge with existing bookmarks or replace completely
- Added private tab tracking system
  - Visual indicator (private icon) in address bar for private tabs
  - "Close All Private Tabs" button in tab view
- Added page content export capabilities
  - Export current page as PDF file
  - Copy page content as Markdown to clipboard
  - Save page content as Markdown file
- Added multiple tab view modes
  - Grid view: Traditional grid layout
  - List view: Compact list showing more tabs at once
  - Tree view: Hierarchical display of tab relationships
  - View mode preference persists across app restarts
- Added quick tab switcher and contextual navigation bar
  - Contextual bottom toolbar showing recently used tabs or ordered container tabs (configurable)
  - Dismissible to maximize screen space
- Added container filter for tree view to show container-specific tab hierarchies
- Added ML model download progress reporting with real-time indicators
- Added isolated container data clearing
  - Clear cookies, cache, and browsing data for specific containers
  - Option to clear container data on exit
- Added quit button to profile selector for complete app exit
- Added address bar auto-focus option for improved navigation UX

**Improvements**
- Complete tab bar overhaul
  - Consolidated menu buttons for cleaner interface
  - Tab reordering now opt-in via settings (not always enabled)
  - Tab bar dismissible to maximize viewing space
- Enhanced container color system
  - Tab bar color now matches current container's color theme
  - Selected containers use border instead of background color (improved visibility)
- Redesigned search interface
  - Improved visual hierarchy and layout
  - Better organization of suggestions, history, and results
  - Enhanced container chip display
  - More efficient use of screen space
- Improved tab handling and state management
  - Better tab duplication logic
  - Enhanced tab parent handling and hierarchy management
  - Refined tab insertion process
  - Removed tab deletion cache for simplified architecture
- Enhanced bookmark management
  - Assignable folder parents (move bookmarks between folders)
  - Improved bookmark entry editing interface
  - Better folder management and organization
- UI/UX enhancements
  - Tab icons displayed when screenshots unavailable
  - Less intense chip background colors for better readability
  - Auto-hide "Add New Tab" button for cleaner interface
  - Automatic UI reset after 30+ minutes of inactivity
  - Updated addon/extension layouts
  - Various icon updates throughout the app

**Bug Fixes**
- Fixed search field focus issues preventing proper keyboard interaction
- Fixed disposed provider exceptions that could cause crashes
- Fixed unmounted widget exceptions
- Fixed browser floating action button animation glitches
- Fixed tab container provider lifecycle coordination
- Fixed widget/provider lifecycle timing issues
- Fixed incorrect tab hierarchy when adding multiple tabs (parent ID handling)
- Fixed tab menu incorrectly showing for history items
- Improved animation smoothness throughout the app

## 0.9.29
### GeckoView 145.0.2

**New Features**
- Added container site assignments to automatically open specific websites in designated containers
- Added multi-user profiles with complete separation of browsing data, extensions, and settings
- Added bookmarks feature
- Added support for custom search engines via user-defined bangs

**Improvements**
- Tor now uses built-in bridges as fallback
- Tor data storage migrated from file directory to cache
- Arti logging now outputs to logcat
- Tab overview now defaults to fullscreen mode (configurable in settings)
- Visual indicator added to tab bar for Tor-tunneled tabs
- Reorganized menu structure
- General UI improvements and bug fixes

## 0.9.28
### GeckoView 144.0.2

**New Features**
- Added support for requesting sites in Desktop Mode

**Improvements**
- Enhanced favicon caching
- Tor-related updates and improvements
- UI refinements

**Bug Fixes**
- Fixed URL launch intent issues

## 0.9.27
### GeckoView 144.0

**New Features**
- Added setting to disable internal PDF viewer (pdfjs)
- Added setting to define and select browser locales

**Improvements**
- Migrated from experimental API extension to new Gecko Preference API for most operations

**Bug Fixes**
- Fixed UI issues
- Fixed engine crash after prolonged background inactivity
- Fixed intent stream lifecycle issue

## 0.9.26
### GeckoView 144.0

**Bug Fixes**
- Ensure tab bar remains visible when bottom sheet is active
- Handle AI engine errors gracefully
- Fix container assignment when opening links
- Fix settings toggle not refreshing UI

## 0.9.25
### GeckoView 144.0

**New Features**
- Added AI feature to group related unassigned tabs into new containers
- Added setting to control how externally opened links are handled (now defaults to prompt)
- Added DoH (DNS over HTTPS) setting with predefined or custom DNS resolver options
- Added browser history view with options to view and delete history data
- Added tab bar swipe action setting with options: "Switch to last used Tab" and "Navigate Sequential Tabs"
- Added quick actions to open tabs via long press on home screen app icon
- Added developer setting to support third-party CA certificates
- Added support for custom addon collections
- Added developer setting to customize fingerprint protection measures

**Improvements**
- Rewrote large portions of the Tor Plugin with option to route all traffic and fixed potential IP leaks (through browser side effects like loading favicons)
- Increased Tor background service timeout from 15 minutes to 1 hour without interaction
- Localhost URLs now default to `http` instead of `https` for better compatibility
- Display scrollable breadcrumb representation of URLs wherever possible for improved visibility
- Updated built-in Bangs
- Large portions of UI rewritten and improved

**Breaking Changes**
- New database structure for bangs; saved bang frequency sorting has been reset

## 0.9.24
### GeckoView 143.0.0

* Upgraded GeckoView

## 0.9.23
### GeckoView 142.0.1

**New Features**
- Added Tor Bridge support with automatic configuration and bridge updates
- Added setting to display dialog for choosing external link handling behavior

**Bug Fixes**
- Fixed media upload issues on websites
- Fixed hardening settings UI display problems

**Improvements**
- Enhanced bottom sheet user interface
- Improved URI parsing and protocol detection for address bar input

## 0.9.22
### GeckoView 142.0

* Added setting to use third party CA certificates
* Added setting to control tab bar swipe behavior
* Downgraded AGP for F-Droid compatibility

## 0.9.21
### GeckoView 142.0

* Restore previous tab state on undo delete
* Fix Reader Mode issue on back arrow navigation
* Unhide tab bar on app resume

## 0.9.20
### GeckoView 142.0

* Added 'Undo' action for closed tabs
* Added swipe gesture to close tab
* Added compatibility for receiving intents of various MIME types
* Introduced Bounce Tracking Protection
* Introduced Query Parameter Stripping as setting
* Introduced setting to control default tab type for creating new tabs and opening links
* Upgraded Flutter to latest stable version
* Automatic hide tab bar on scroll
* Sort newly created tabs after parent instead of at front
* Set default fallback encoding for Web Feeds to UTF-8
* Take full screen size when in fullscreen mode
* Improved error logging
* Filter out sensitive logs
* Minor UI improvements
* Fix Reader Mode issue on back navigation
* Fix bottom sheet scrolling issues

## 0.9.17

* Reworked Tab UI into bottom sheet
* Adjusted Android permissions
* Improved Favicon handling

## 0.9.16-2

* Fix icon caching issue

## 0.9.16-1

* Fixed drop animation lag
* Allow drop into the unassigned container

## 0.9.16

* Integrated on-device ai for container naming and tab sugegstions
* Improved Tab and container UI

## 0.9.15-1

* Added certificate information title
* Fixed draggable tabs
* Open single tab in tree view automatically

## 0.9.15

* Improved intent handling
* Refactored tab grid
* Several UI improvements
* Optimized build

## 0.9.14

* Bundle bangs and disable auto fetch (sync from repo still possible via settings)
* Fix flickering after returning from home
* Fix UI website title overflow
* Optimize build

## 0.9.13

* Added option to show extensions in tab bar (through "Show Extension Shortcut" setting)
* Added tab menu action to assign tab to container
* Fixed QR code generation issues
* Switched to Mozilla stable builds
* Fixed issues with PiP and fullscreen mode

## 0.9.12

* Reorganized several settings into a new group: "Developer Settings"
* Added a "Get Extensions" menu entry
* Disabled the Cookie Banner Blocker option, as it is deprecated by Mozilla (consider using uBlock Origin instead)
* Updated hardening presets
* Mozilla Components upgraded

## 0.9.11

* Trigger automatic find-in-page when coming from local search results
* Upgraded gecko
* Upgraded GoRouter

## 0.9.10

* Initial public release