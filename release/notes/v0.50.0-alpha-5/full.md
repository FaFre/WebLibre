This alpha brings **built-in app updates**: WebLibre can now check for new versions, download them and install them from inside the app, without visiting GitHub.

**This is an alpha release. Back up important profiles before trying it.**

## Update WebLibre from inside the app

Find the new **App updates** screen under **Settings > General > Updates**, or open it from the About dialog.

- **Automatic checks once a day.** When a new version is out, WebLibre shows a short notice, a dot appears on the menu button, and an update row sits at the top of the browser menu. Checks can be turned off with **Check for updates automatically**, and **Check now** checks at any time.
- **Nothing happens without a tap.** WebLibre only checks on its own. Downloading and installing always wait for you to start them.
- **See what you are getting first.** The App updates screen shows the size of the download, a short summary of what's new, a link to the full release notes, whether the version includes security fixes, and which bundled parts change, such as the Gecko engine, Tor and sing-box.
- **Interrupted downloads pick up where they left off.** If a download is cancelled or the connection drops, **Continue download** carries on from what was already downloaded.
- **Every update is verified before it is installed.** WebLibre checks that the update information is signed by the WebLibre project and that the downloaded file is a genuine WebLibre build for your device. Anything that doesn't match is deleted, and the screen explains what went wrong.
- **Respects your connection settings.** Update checks and downloads go through the same proxy or Tor connection your tabs use. If that connection isn't available, WebLibre doesn't fall back to a direct connection.
- **Installing closes WebLibre.** Android needs WebLibre to close while the update installs; open it again afterwards. Private tabs are closed, and WebLibre warns you about this before it starts. Recent tab changes are saved before the app closes.
- The first time, Android asks you to allow WebLibre to **install unknown apps**. This permission is only used for WebLibre's own verified updates.

## Everyday fixes and polish

- The bridges used to connect to Tor (Snowflake and Lyrebird) have been updated.
- Tab changes made just before quitting WebLibre with Quit are no longer lost.

## Upgrading from v0.50.0-alpha-2

This version has to be installed by hand one last time. From this alpha on, WebLibre can update itself: the next alpha will show up on the App updates screen.

Alphas 3 and 4 were never published, so everything they would have brought is part of this release.
