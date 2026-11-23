This alpha lets you lock tabs so they cannot be closed by accident, and adds sleeping tabs and freezable containers for people who want more control over memory and background activity. Tapping a website's notification now opens the site, and the Gecko engine moves from version 159 to 160.

**This is an alpha release. Back up important profiles before trying it.**

## Lock tabs so they stay open

Locking a tab keeps it from being closed until you unlock it. It is available to everyone, with no setting to turn on.

- **Lock and unlock from several places.** Use the **Lock** button in a tab's menu, **Lock Tab** under **More** in the browser menu, or the new **Lock / Unlock Tab** action, which you can assign to a gesture or keyboard shortcut. Private tabs cannot be locked.
- **A locked tab shows a padlock.** It appears in the tab tray, tab lists and the quick tab switcher. In the toolbar, the close button turns into a padlock for a locked tab.
- **Closing says why nothing happened.** Tapping close on a locked tab tells you it is locked and offers **Unlock**.
- **Bulk closing skips locked tabs.** Closing all tabs, closing other tabs, clearing browsing data for tabs, and automatically closing old unassigned tabs all leave locked tabs open, and tell you how many were kept.
- **Containers protect locked tabs too.** A container with locked tabs cannot be deleted until you unlock them, and a locked tab cannot be moved to a container with its own cookie storage, because that would close and recreate it.
- **Locks survive restarts.** A locked tab is still locked the next time you open WebLibre.

## Sleeping tabs and frozen containers

These features are meant for people who want to save memory or stop sites from working in the background. They are shown when **Expert settings** is turned on under **Settings > Feature Control**.

- **Put a tab to sleep.** Choose **Put Tab to Sleep** in the browser menu or the tab's menu. The page is unloaded to free memory. The tab stays in your list with a sleep icon, and **Wake** loads it again. **Sleep All Tabs** in a container's menu does it for the whole container.
- **WebLibre protects what matters.** The first time, it explains what sleeping keeps and loses. It asks before stopping playing media, discarding text typed into a form, or unloading a page that came from a form submission. It will not put a tab to sleep while the tab uses the camera, microphone or screen sharing, has a file chosen for upload, is being printed or saved as PDF, or has a download running.
- **Sleep tabs automatically.** Under **Settings > Browsing > Sleeping Tabs**, turn on **Sleep Tabs Automatically**. **Sleep After** sets how long a tab can be off screen, from 1 minute to 24 hours, and **Loaded Tabs Limit** sets how many tabs may stay loaded, from 1 to 20 or no limit. This is off by default and only counts time while WebLibre is open. A tab's **Keep awake** option exempts it.
- **Freeze a container.** **Freeze Container** in a container's menu unloads its tabs and stops what its sites do in the background, such as push messages and service workers, until you choose **Resume Container**. Cookies, sign-ins and site data are kept. Freezing needs a container with its own cookie storage (cookie isolation). Push messages sent to a frozen container are skipped.
- **Freeze automatically.** In a container's settings, **Freeze Automatically** freezes it after 15 minutes to 4 hours without use, counted while WebLibre is open. It waits while a tab plays media, is in a call, has a download running or is set to **Keep awake**.
- **Frozen containers are clear about it.** Their tabs show a pause icon, and new tabs opened in them wait until you resume the container. Tapping a notification from a frozen container asks whether to resume it. Downloads from a frozen container pause, and their notification says why. Web apps and custom tabs of a frozen container offer to open WebLibre to resume it.
- **Deleting containers.** Deleting a container with its own storage now offers **Also delete site data**, covering cookies, sign-ins, offline data and notification subscriptions. For a frozen container this is always included, so its background activity can never resume. If WebLibre cannot delete the data right away, it keeps the container's sites blocked and retries at every start, and the container list shows what is waiting.

## Notifications and push

- **Tapping a website's notification now opens the site.** Before, the tap did nothing. It now opens the page in the right profile and container, and goes through that container's proxy or Tor connection. If the container is frozen, WebLibre asks whether to resume it. If the connection is not ready yet, a message tells you to tap again in a moment. If the container or its site data was deleted, the notification is removed and you are told why.
- **Private tabs get no notifications and no push.** Sites in a private tab see the notification permission as denied and cannot subscribe to push, because a push subscription would outlive the private session and could link it to the next one. Push subscriptions that private tabs created earlier are removed when WebLibre starts.
- **Switching profiles keeps push subscriptions.** Before, switching away from a profile cancelled its subscriptions, so sites that do not subscribe again by themselves went quiet.
- **Cloned profiles and restored backups get their own push registrations.** They no longer copy the original's push keys, so a copy cannot read the original's messages. Backups no longer contain push registrations. A cloned profile registers its subscriptions again once you choose a push distributor for it.

## A locked profile no longer shows its pages

With a profile password or device lock, the browser could briefly show through when you came back to the app, and the app switcher thumbnail could show the page. Now a plain screen in the app's colour covers the window until the lock screen is drawn. The app switcher thumbnail is hidden on Android 13 and later; on older versions, turn on **Screenshot protection**.

## App updates

Android now asks you to confirm every WebLibre update, and WebLibre no longer asks for the permission to skip that confirmation. If you decline Android's confirmation, the update stays ready to install and WebLibre does not report an error.

## Everyday fixes and polish

- **Gecko engine 160.** WebLibre moves from Gecko 159 to Gecko 160, including its changes and security fixes.
- **No more grey wash over the app.** With a hardware keyboard or D-pad, a translucent grey layer could cover the whole window, for example after returning from the app switcher.
- **Slider settings look and behave alike.** UI zoom, font size, gesture distances and the quick tab switcher's title width now show the chosen value next to the title and move in fixed steps.
- **A rare startup problem is addressed.** In some starts, a built-in extension could fail to connect, which in one observed case left pages waiting about a minute before loading.
- **Component Versions in About** no longer lists Snowflake and Lyrebird.

## Upgrading from v0.50.0-alpha-6

- **Settings sync.** If you sync WebLibre settings between devices, update all of them to this alpha. Older versions cannot read the settings this version uploads, and they tell you so.
- **Web push with more than one profile.** If more than one of your profiles has web push set up, WebLibre resets their push registrations once on the first start. Some sites may need to subscribe again, so if a site stops sending notifications, open it once.
- **Sleeping tabs and frozen containers are hidden by default.** Turn on **Expert settings** under **Settings > Feature Control** to see them. Tab locking needs no setting.
