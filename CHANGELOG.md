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