/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Dialog
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.activity.addCallback
import androidx.annotation.VisibleForTesting
import androidx.appcompat.app.AppCompatActivity
import androidx.core.view.WindowCompat
import androidx.lifecycle.Lifecycle
import com.google.android.material.button.MaterialButton
import eu.weblibre.flutter_mozilla_components.AppLocalePreference
import eu.weblibre.flutter_mozilla_components.ColorSchemePreference
import eu.weblibre.flutter_mozilla_components.ExternalAppBrowserFragment
import eu.weblibre.flutter_mozilla_components.FlutterEngineCoordinator
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.HomePressDispatcher
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.PwaSessionCreator
import eu.weblibre.flutter_mozilla_components.addons.WebExtensionPromptHost
import eu.weblibre.flutter_mozilla_components.lock.ExternalWindowLock
import eu.weblibre.flutter_mozilla_components.lock.LockedWindowCurtain
import eu.weblibre.flutter_mozilla_components.lock.ProfileLockedWindow
import eu.weblibre.flutter_mozilla_components.lock.ProfileUnlockRegistry
import eu.weblibre.flutter_mozilla_components.startup.AppHalfBootstrap
import eu.weblibre.flutter_mozilla_components.startup.BootstrapFailure
import eu.weblibre.flutter_mozilla_components.startup.BootstrapStage
import eu.weblibre.flutter_mozilla_components.startup.LaunchRouting
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.R
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.support.base.feature.UserInteractionHandler
import mozilla.components.support.base.log.logger.Logger

/**
 * Native activity that hosts [ExternalAppBrowserFragment] for Custom Tab and PWA sessions.
 * This is a non-Flutter activity — it renders GeckoView directly in a native layout.
 *
 * Uses an empty taskAffinity so Custom Tabs appear as a separate task from the main app.
 */
open class ExternalAppBrowserActivity : AppCompatActivity(), ProfileLockedWindow {
    companion object {
        private const val TAG = "ExternalAppBrowserActivity"

        const val EXTRA_CUSTOM_TAB_SESSION_ID = "custom_tab_session_id"
        const val EXTRA_WEB_APP_MANIFEST_URL = "web_app_manifest_url"

        /** How [recoverPwaSession] creates a lost PWA session again. */
        @VisibleForTesting
        internal var createPwaSession: suspend (
            url: String,
            contextId: String?,
            desktopMode: Boolean?,
        ) -> String = PwaSessionCreator::create

        /**
         * Whether this window's session is a private one, in the shape the
         * intent processors already carry it.
         *
         * Set by whoever created the session, because the one place that needs
         * it here — the routing decision taken when the system hands the task
         * back to a process that has since been killed — runs before there is a
         * session to ask. A plan made in the general context for a private
         * launch is a plan about someone else's routing: `private` inherits
         * nothing from `general`, so a direct general relation would wave a
         * blocked launch straight onto a proxy error page, and a blocked one
         * would bounce a perfectly serviceable launch to the browser.
         */
        private const val PRIVATE_BROWSING_MODE = "private_browsing_mode"

        /**
         * Marks a window opened *before* its session exists, to wait here for
         * routing the app half has yet to install.
         *
         * The wait used to happen in `IntentReceiverActivity`, which is
         * translucent — so a PWA cold start into a proxied container showed the
         * launcher, unchanged, for as long as the bootstrap took, and then a
         * browser window if it did not finish. Neither half of that is something
         * the user can act on. Opening this window first gives the wait somewhere
         * to be seen and the failure somewhere to offer a choice, and costs
         * nothing: no components are built and no session created until routing
         * says the launch can actually be served.
         */
        const val EXTRA_AWAITING_ROUTING = "awaiting_routing"

        /**
         * A PWA window that opens straight into the wait.
         *
         * Carries everything [recoverPwaSession] needs to create the session once
         * routing lands — which is the same path a PWA task whose session went
         * missing already takes, so there is one way to create a PWA session here
         * rather than two.
         */
        fun createAwaitingRoutingIntent(
            context: Context,
            launchUrl: String,
            pwaProfileUuid: String? = null,
            pwaContextId: String? = null,
            pwaToken: String? = null,
            pwaInstallStartUrl: String? = null,
            pwaDesktopMode: Boolean? = null,
        ): Intent {
            return Intent(context, ExternalAppBrowserActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_DOCUMENT or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
                putExtra(EXTRA_AWAITING_ROUTING, true)
                putExtra(EXTRA_WEB_APP_MANIFEST_URL, launchUrl)
                pwaProfileUuid?.let { putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, it) }
                pwaContextId?.let { putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, it) }
                pwaToken?.let { putExtra(PwaConstants.EXTRA_PWA_TOKEN, it) }
                putExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL, pwaInstallStartUrl ?: launchUrl)
                pwaDesktopMode?.let { putExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE, it) }
            }
        }

        fun createIntent(
            context: Context,
            customTabSessionId: String,
            webAppManifestUrl: String? = null,
            pwaProfileUuid: String? = null,
            pwaContextId: String? = null,
            pwaToken: String? = null,
            pwaInstallStartUrl: String? = null,
            pwaDesktopMode: Boolean? = null,
            isPrivate: Boolean = false,
        ): Intent {
            return Intent(context, ExternalAppBrowserActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_DOCUMENT or Intent.FLAG_ACTIVITY_MULTIPLE_TASK
                putExtra(EXTRA_CUSTOM_TAB_SESSION_ID, customTabSessionId)
                putExtra(PRIVATE_BROWSING_MODE, isPrivate)
                webAppManifestUrl?.let { putExtra(EXTRA_WEB_APP_MANIFEST_URL, it) }
                pwaProfileUuid?.let { putExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID, it) }
                pwaContextId?.let { putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, it) }
                pwaToken?.let { putExtra(PwaConstants.EXTRA_PWA_TOKEN, it) }
                pwaInstallStartUrl?.let {
                    putExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL, it)
                }
                pwaDesktopMode?.let { putExtra(PwaConstants.EXTRA_PWA_DESKTOP_MODE, it) }
            }
        }
    }

    private val logger = Logger("ExternalAppBrowserActivity")
    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var isRecoveringPwaSession = false

    /**
     * Whether this window is only ever opened by the browser, from a screen
     * that is itself behind the profile lock.
     *
     * Such a window opens unlocked, as a continuation of what the person was
     * doing, and locks like any other once they leave it. Only a fresh launch
     * counts: reopening it from recents is a new visit.
     */
    protected open val opensFromUnlockedBrowser: Boolean = false

    /** Null only before `setContentView`, which it needs. */
    private var windowLock: ExternalWindowLock? = null

    /** Null only before `onCreate`. */
    private var curtain: LockedWindowCurtain? = null

    /** Whether [start] ran: the profile was open when this window began. */
    private var started = false

    /**
     * Custom tabs moving to new components while this window is open; see
     * [onCustomTabsHandedOver]. Acts only while a fragment transaction is
     * allowed, and keeps the rest for [onResume].
     */
    private val handover = HandoverWait(
        timeoutMs = PwaConstants.COMPONENT_INIT_TIMEOUT_MS,
        schedule = { delayMs, block ->
            val job = coroutineScope.launch {
                delay(delayMs)
                block()
            }
            ({ job.cancel() })
        },
        mayAct = {
            !supportFragmentManager.isStateSaved &&
                lifecycle.currentState.isAtLeast(Lifecycle.State.STARTED)
        },
    )

    private val customTabsHandoverListener: () -> Unit = { onCustomTabsHandedOver() }

    /**
     * What [showFragment] was asked to show while fragment transactions were
     * not allowed, for [onResume]. The latest request wins.
     */
    private var deferredShow: (() -> Unit)? = null

    /** Paused into picture-in-picture, which is not leaving yet. */
    private var pausedIntoPictureInPicture = false

    /** This window in [ProfileUnlockRegistry]'s pending departures. */
    private val departureToken = Any()

    private val customTabSessionId: String?
        get() = intent?.getStringExtra(EXTRA_CUSTOM_TAB_SESSION_ID)

    private val webAppManifestUrl: String?
        get() = intent?.getStringExtra(EXTRA_WEB_APP_MANIFEST_URL)

    // The app's language for this window's own UI; see AppLocalePreference.
    override fun attachBaseContext(newBase: Context) {
        super.attachBaseContext(AppLocalePreference.wrap(newBase))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        // Match the window chrome (status/nav bar + pre-paint background) to the
        // user's WebLibre color scheme rather than just the system mode, so a
        // cold-started Custom Tab / PWA doesn't flash dark when WebLibre is light.
        // Set before super.onCreate so the correct mode is applied without a recreate.
        delegate.localNightMode = ColorSchemePreference.nightMode(this)

        super.onCreate(savedInstanceState)

        // This window's traffic may be routed through a proxy the Flutter
        // isolate runs, so the engine has to outlive `MainActivity` going away
        // for as long as this task exists — see
        // [FlutterEngineCoordinator.retainForExternalTask].
        FlutterEngineCoordinator.retainForExternalTask()

        onBackPressedDispatcher.addCallback(this) {
            // Not the page's back history: that belongs to whoever unlocks it.
            if (windowLock?.isShowing == true) {
                finishAndRemoveTask()
                return@addCallback
            }

            val fragment = supportFragmentManager.findFragmentById(R.id.container)
            if (fragment is UserInteractionHandler && fragment.onBackPressed()) {
                return@addCallback
            }

            finishAndRemoveTask()
        }

        WindowCompat.setDecorFitsSystemWindows(window, false)
        setContentView(R.layout.activity_external_app_browser)

        // Before the lock, which reports to it, and before `onStart`, which
        // shows the dialogs `super.onCreate` restored.
        curtain = LockedWindowCurtain(supportFragmentManager)

        // Before anything of the profile is shown or started: a Custom Tab or
        // PWA never passes through the browser's lock screen, so a locked
        // profile is locked here as well (issue #658).
        val lock = ExternalWindowLock(
            activity = this,
            scope = coroutineScope,
            onClose = { finishAndRemoveTask() },
            onLockChanged = ::onLockChanged,
        )
        windowLock = lock

        val freshLaunch = savedInstanceState == null &&
            ((intent?.flags ?: 0) and Intent.FLAG_ACTIVITY_LAUNCHED_FROM_HISTORY) == 0
        if (opensFromUnlockedBrowser && freshLaunch) {
            lock.grantForLaunch()
        }

        GlobalComponents.addCustomTabsHandoverListener(customTabsHandoverListener)

        lock.guard(autoPrompt = false) { start() }
    }

    override val isProfileLocked: Boolean
        get() = windowLock?.isShowing == true

    override fun coverWhileLocked(dialog: Dialog) {
        curtain?.cover(dialog)
    }

    /**
     * Hides everything above the lock panel that the panel cannot cover:
     * windows of their own, which a page or the window's own controls put up.
     */
    private fun onLockChanged(locked: Boolean) {
        if (locked) {
            curtain?.lock()
            (supportFragmentManager.findFragmentById(R.id.container) as? ExternalAppBrowserFragment)
                ?.onWindowLocked()
        } else {
            curtain?.unlock()
        }

        // Install prompts wait in the store while the window is locked.
        WebExtensionPromptHost.onWindowLockChanged(this)
    }

    /** What the window does once its profile is open. */
    private fun start() {
        started = true

        if (intent?.getBooleanExtra(EXTRA_AWAITING_ROUTING, false) == true) {
            // Opened deliberately without a session: this window *is* where the
            // wait for the app half happens, and the session is created on the
            // other side of it. See [beginAwaitingRouting].
            beginAwaitingRouting()
            return
        }

        val sessionId = customTabSessionId
        if (sessionId == null) {
            Log.e(TAG, "No custom tab session ID provided")
            logger.error("No custom tab session ID provided, finishing.")
            if (!recoverPwaSession(null, "missing session ID")) {
                fallbackToMainActivity()
            }
            return
        }

        val components = GlobalComponents.components
        if (components == null) {
            // The process this task belonged to is gone — the system handed the
            // task back and nothing has been built in the new one yet. That makes
            // this a cold start like any other, including the part where a
            // proxied context cannot be served without the app half: building
            // external components here first is exactly what would strand it.
            startWithRouting(sessionId)
            return
        }

        showFragment(sessionId)
    }

    /**
     * Brings up whatever this launch's routing needs, then shows it.
     *
     * The context comes off the intent because there is no session to read it
     * from yet: a PWA carries its container, and everything else runs in the
     * general context.
     */
    private fun startWithRouting(sessionId: String) {
        if (StartupArbiter.committedProfileId() == null) {
            // Nothing has decided which profile this process serves, so there is
            // no routing to read and no profile to start the app half under.
            // Leave that to the path below, which refuses for the same reason and
            // ends at the browser, where the profile question has an owner.
            logger.debug("No committed profile; not starting the app half here")
            startWithExistingComponents(sessionId)
            return
        }

        awaitRoutingThenServe { startWithExistingComponents(sessionId) }
    }

    /**
     * Runs the wait this window was opened for, then creates the session on the
     * other side of it.
     *
     * The session is deliberately not created first. A window with no routing has
     * nothing to show but a proxy error page, and a session created into one is a
     * session that has to be thrown away or reloaded when routing finally lands.
     */
    private fun beginAwaitingRouting() {
        val launchUrl = webAppManifestUrl
        if (launchUrl == null) {
            Log.e(TAG, "Awaiting-routing launch carries no URL")
            logger.error("Awaiting-routing launch carries no URL, using the browser.")
            fallbackToMainActivity()
            return
        }

        if (StartupArbiter.committedProfileId() == null) {
            // Same refusal, same reason as [startWithRouting]. There is nothing to
            // wait for: no routing to read, and no profile to start the app half
            // under.
            logger.debug("No committed profile; not starting the app half here")
            fallbackToMainActivity()
            return
        }

        awaitRoutingThenServe {
            // The wait is over for this window: a later recreation with the
            // session already in hand must show it, not queue behind a second
            // one. A task the system restores from its base intent still arrives
            // with the flag set, and still needs to wait — which is correct,
            // because that process has no session either.
            intent?.removeExtra(EXTRA_AWAITING_ROUTING)

            if (!recoverPwaSession(null, "routing installed")) {
                fallbackToMainActivity()
            }
        }
    }

    /**
     * Waits for the app half in this window rather than behind it, and ends the
     * wait in something the user can act on either way.
     *
     * [onReady] is not required to be synchronous — creating a session is not —
     * so the progress it replaces is left up until [showFragment] takes the
     * window over.
     */
    private fun awaitRoutingThenServe(onReady: () -> Unit) {
        showLaunchProgress()

        coroutineScope.launch {
            val contextId = LaunchRouting.contextIdFor(
                pwaContextId = intent?.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID),
                isPrivate = intent?.getBooleanExtra(PRIVATE_BROWSING_MODE, false) == true,
            )

            val outcome = AppHalfBootstrap.ensure(
                applicationContext,
                contextId,
                onStage = ::showLaunchStep,
            )

            if (isFinishing || isDestroyed) return@launch

            if (outcome.canProceed) {
                onReady()
                return@launch
            }

            // Blocked for good, or the app half never came up. Either way this
            // window can only show a proxy error page — but which of those
            // happened, and what to do about it, is the user's to decide here
            // rather than something to be answered by silently becoming a
            // browser.
            logger.debug("Routing cannot serve this launch: ${outcome.failure}")
            showLaunchFailure(
                failure = outcome.failure ?: BootstrapFailure.STILL_STARTING,
                onTryAgain = { awaitRoutingThenServe(onReady) },
            )
        }
    }

    /**
     * The URL this window is for, for as long as it has no session to ask.
     *
     * Named apart from [recoverPwaSession]'s own local: that one is the URL a
     * session is about to be created for and must exist, this one is only what
     * the window says it is showing.
     */
    private val windowLaunchUrl: String?
        get() = webAppManifestUrl
            ?: intent?.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)
            ?: intent?.dataString

    /**
     * The wait, with a way out of it from the first frame.
     *
     * "Open in browser" is offered before anything has gone wrong on purpose: a
     * wait the user cannot leave is the thing this window was added to stop
     * being, and someone who knows their proxy is off should not have to sit out
     * fifty seconds to be told so. "Cancel" is the third answer — closing the
     * window they opened by mistake, without being handed a browser for it.
     */
    private fun showLaunchProgress() {
        val status = findViewById<View>(R.id.launch_status) ?: return
        status.visibility = View.VISIBLE
        status.findViewById<View>(R.id.launch_status_progress).visibility = View.VISIBLE
        status.findViewById<ImageView>(R.id.launch_status_icon).visibility = View.GONE
        status.findViewById<TextView>(R.id.launch_status_title).text =
            RoutingUnavailableCopy.waitingTitle(this)
        status.findViewById<TextView>(R.id.launch_status_message).text =
            RoutingUnavailableCopy.waitingMessage(this, windowLaunchUrl)

        // Filled in by the first [showLaunchStep]; until then the spinner and
        // the explanation are the whole of it, rather than a step this window
        // has not actually observed yet.
        status.findViewById<TextView>(R.id.launch_status_step).visibility = View.GONE

        status.findViewById<MaterialButton>(R.id.launch_status_primary).visibility = View.GONE
        status.findViewById<MaterialButton>(R.id.launch_status_secondary).apply {
            setText(R.string.weblibre_launch_action_open_in_browser)
            visibility = View.VISIBLE
            setOnClickListener { fallbackToMainActivity() }
        }
        status.findViewById<MaterialButton>(R.id.launch_status_tertiary).apply {
            setText(R.string.weblibre_launch_action_cancel)
            visibility = View.VISIBLE
            setOnClickListener { finishAndRemoveTask() }
        }
    }

    /** Names the step the app half is on, so a working wait looks like one. */
    private fun showLaunchStep(stage: BootstrapStage) {
        val status = findViewById<View>(R.id.launch_status) ?: return
        if (status.visibility != View.VISIBLE) return

        status.findViewById<TextView>(R.id.launch_status_step).apply {
            text = RoutingUnavailableCopy.stepMessage(this@ExternalAppBrowserActivity, stage)
            visibility = View.VISIBLE
        }
    }

    /**
     * The end of the wait, as a choice.
     *
     * The emphasised button is whichever one gets the user what they asked for:
     * another attempt when the app half was merely slow, the browser when the
     * proxy is not running and only the browser can offer to start it. Both are
     * always present — a user who knows better than this classification should
     * not have to take its word for which one to want.
     */
    private fun showLaunchFailure(failure: BootstrapFailure, onTryAgain: () -> Unit) {
        val status = findViewById<View>(R.id.launch_status) ?: return
        status.visibility = View.VISIBLE
        status.findViewById<View>(R.id.launch_status_progress).visibility = View.GONE
        status.findViewById<ImageView>(R.id.launch_status_icon).visibility = View.VISIBLE
        status.findViewById<TextView>(R.id.launch_status_step).visibility = View.GONE
        status.findViewById<TextView>(R.id.launch_status_title).text =
            RoutingUnavailableCopy.title(this, failure)
        status.findViewById<TextView>(R.id.launch_status_message).text =
            RoutingUnavailableCopy.message(
                this,
                failure,
                RoutingUnavailableCopy.subject(
                    windowLaunchUrl,
                    isStandaloneApp = webAppManifestUrl != null,
                ),
            )

        val canTryAgain = failure.canKeepWaiting
        status.findViewById<MaterialButton>(R.id.launch_status_primary).apply {
            if (canTryAgain) {
                setText(R.string.weblibre_launch_action_try_again)
                visibility = View.VISIBLE
                setOnClickListener { onTryAgain() }
            } else {
                visibility = View.GONE
            }
        }
        status.findViewById<MaterialButton>(R.id.launch_status_secondary).apply {
            setText(R.string.weblibre_launch_action_open_in_browser)
            visibility = View.VISIBLE
            setOnClickListener { fallbackToMainActivity() }
        }
        status.findViewById<MaterialButton>(R.id.launch_status_tertiary).apply {
            setText(R.string.weblibre_launch_action_close)
            visibility = View.VISIBLE
            setOnClickListener { finishAndRemoveTask() }
        }
    }

    private fun hideLaunchStatus() {
        findViewById<View>(R.id.launch_status)?.visibility = View.GONE
    }

    /** The original path: whatever components this process has, or none. */
    private fun startWithExistingComponents(sessionId: String) {
        if (GlobalComponents.components != null) {
            showFragment(sessionId)
            return
        }

        // Requires a committed profile rather than binding one: this Activity is
        // launched by IntentReceiverActivity, which has already classified the
        // launch and bound the right profile. Binding again here could only pick
        // a different one.
        if (GlobalComponents.ensureExternalComponents(applicationContext)) {
            showFragment(sessionId)
            return
        }

        logger.debug("Components not yet initialized, waiting...")
        waitForComponents(sessionId)
    }

    override fun onPause() {
        super.onPause()

        // A rotation is not leaving.
        if (isChangingConfigurations) return

        // Neither is picture-in-picture: the video is still on screen, and
        // covering it would end what the person asked for. Leaving happens
        // when that window goes away without coming back, see [onStop].
        if (isInPictureInPictureMode) {
            pausedIntoPictureInPicture = true
            return
        }

        // Not leaving yet: a dialog may only be drawing over the window. See
        // [ProfileUnlockRegistry.windowPaused].
        ProfileUnlockRegistry.windowPaused(departureToken, ::coverAfterLeaving)
    }

    override fun onStop() {
        super.onStop()

        if (isChangingConfigurations) return

        if (pausedIntoPictureInPicture) {
            pausedIntoPictureInPicture = false
            ProfileUnlockRegistry.windowLeft(::coverAfterLeaving)
            return
        }

        ProfileUnlockRegistry.windowStopped(departureToken)
    }

    /**
     * Leaving ended a background-mode unlock, for this window and every other
     * one. Covered as soon as that is settled, so the page is not what the
     * next person to look at this window sees first.
     */
    private fun coverAfterLeaving() {
        if (started && !isDestroyed) {
            windowLock?.guard(autoPrompt = false)
        }
    }

    override fun onUserLeaveHint() {
        if (HomePressDispatcher.onUserLeaveHint(this)) {
            return
        }

        super.onUserLeaveHint()
    }

    private fun waitForComponents(sessionId: String) {
        coroutineScope.launch {
            var elapsedMs = 0L

            while (isActive && elapsedMs < PwaConstants.COMPONENT_INIT_TIMEOUT_MS) {
                if (GlobalComponents.components != null) {
                    showFragment(sessionId)
                    return@launch
                }

                delay(PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS)
                elapsedMs += PwaConstants.COMPONENT_INIT_CHECK_INTERVAL_MS
            }

            // Timeout reached
            if (isActive) {
                Log.e(TAG, "Timeout waiting for components")
                logger.error("Timeout waiting for components after ${PwaConstants.COMPONENT_INIT_TIMEOUT_MS}ms")
                fallbackToMainActivity()
            }
        }
    }

    /**
     * [mayAwaitHandover] is false once a wait for the handover gave up: the
     * session is then decided on as lost, rather than waited for again.
     */
    private fun showFragment(sessionId: String, mayAwaitHandover: Boolean = true) {
        // Asked for by continuations (a recovered PWA session, the waits for
        // components, routing or the handover) that can finish after the
        // window went to the background. A commit after `onSaveInstanceState`
        // throws, so the request waits for the window, with the session it
        // names; so does every decision below, starting activities included.
        if (supportFragmentManager.isStateSaved) {
            deferredShow = { showFragment(sessionId, mayAwaitHandover) }
            return
        }

        hideLaunchStatus()

        val components = GlobalComponents.components ?: run {
            logger.error("Components still null after waiting, finishing.")
            finish()
            return
        }

        // Verify session exists
        if (components.core.store.state.findCustomTab(sessionId) == null) {
            if (mayAwaitHandover && GlobalComponents.isHandingOverCustomTabs) {
                // The app half started (a password check starts it) and its
                // components take this window's session over only once they
                // have restored the browser's tabs. Missing for that long is
                // not gone. A handover that never finishes must not leave a
                // blank window, though: past the components timeout, this
                // decides again without waiting.
                handover.await { showFragment(sessionId, mayAwaitHandover = false) }
                return
            }

            Log.e(TAG, "Custom tab session $sessionId not found in store")
            logger.error("Custom tab session $sessionId not found in store, finishing.")
            if (!recoverPwaSession(sessionId, "session not found in store")) {
                fallbackToMainActivity()
            }
            return
        }

        val fragment = ExternalAppBrowserFragment.create(
            customTabSessionId = sessionId,
            webAppManifestUrl = webAppManifestUrl,
        )

        supportFragmentManager.beginTransaction()
            .replace(R.id.container, fragment)
            .commit()
    }

    /**
     * Custom tabs moved to new components: the app half started while this
     * window was open and replaced the external set (issue #658: a password
     * check starts it).
     */
    private fun onCustomTabsHandedOver() {
        if (!started || isFinishing || isDestroyed) return
        handover.arrived(::applyHandover)
    }

    private fun applyHandover(endedWait: Boolean) {
        val sessionId = customTabSessionId ?: return

        if (endedWait) {
            showFragment(sessionId)
            return
        }

        // A fragment built before the handover keeps the outgoing components:
        // its features watch a store the page no longer reports to, so its
        // URL, back state and prompts would go stale. One built since is fine.
        val fragment =
            supportFragmentManager.findFragmentById(R.id.container) as? ExternalAppBrowserFragment
                ?: return
        val bound = fragment.boundComponents ?: return
        if (bound === GlobalComponents.components) return

        fragment.releaseSession()
        showFragment(sessionId)
    }

    override fun onResume() {
        super.onResume()

        // Back from picture-in-picture, or through it: either way, here again.
        pausedIntoPictureInPicture = false

        // Before the guard: settles whether this window left, and whether the
        // one it took the front from did.
        ProfileUnlockRegistry.windowResumed(departureToken)

        // A window this very guard starts has just checked its session.
        val wasStarted = started
        windowLock?.guard(autoPrompt = true)
        if (!wasStarted) return

        // What could not be shown, or done for the handover, while the window
        // was away. The handover second: it leaves a fragment that is already
        // on the current components alone.
        val shown = deferredShow?.let { show ->
            deferredShow = null
            show()
            true
        } ?: false
        val handedOver = handover.runDeferred()
        if (shown || handedOver) return

        // Mid-handover the session is missing from the new components without
        // being gone; [onCustomTabsHandedOver] picks it up.
        if (GlobalComponents.isHandingOverCustomTabs) return

        // If the session was removed while we were in the background, finish
        val sessionId = customTabSessionId ?: return
        val components = GlobalComponents.components ?: return
        if (components.core.store.state.findCustomTab(sessionId) == null) {
            Log.w(TAG, "Custom tab session $sessionId gone on resume")
            logger.debug("Custom tab session $sessionId gone, finishing activity.")
            if (!recoverPwaSession(sessionId, "session gone on resume")) {
                fallbackToMainActivity()
            }
        }
    }

    private fun recoverPwaSession(missingSessionId: String?, reason: String): Boolean {
        if (isRecoveringPwaSession) {
            return true
        }

        val launchUrl = webAppManifestUrl
            ?: intent?.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)
            ?: return false

        val isPwaTask = webAppManifestUrl != null ||
            intent?.hasExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == true
        if (!isPwaTask) {
            return false
        }

        val contextId = intent?.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID)
        isRecoveringPwaSession = true
        Log.w(TAG, "Creating PWA session for $launchUrl: $reason")

        coroutineScope.launch {
            // Only the creation can fail the recovery. Showing the session
            // is not part of it: a failure there must not remove a task
            // whose session exists.
            val sessionId = try {
                createPwaSession(
                    launchUrl,
                    contextId,
                    PwaSessionCreator.desktopModeOf(intent),
                )
            } catch (e: Exception) {
                Log.e(TAG, "Failed to recover PWA session", e)
                logger.error("Failed to recover PWA session, removing stale task.", e)
                if (!isFinishing && !isDestroyed) {
                    finishAndRemoveTask()
                }
                return@launch
            } finally {
                isRecoveringPwaSession = false
            }

            Log.d(
                TAG,
                "Recovered PWA session: old=$missingSessionId, new=$sessionId, url=$launchUrl",
            )

            intent.putExtra(EXTRA_CUSTOM_TAB_SESSION_ID, sessionId)
            if (webAppManifestUrl == null) {
                intent.putExtra(EXTRA_WEB_APP_MANIFEST_URL, launchUrl)
            }

            if (!isFinishing && !isDestroyed) {
                // Deferred to `onResume` if the window went away meanwhile.
                showFragment(sessionId)
            }
        }

        return true
    }

    /**
     * Same fallback, reachable from the window's fragment when it gives up
     * waiting for components (see `BaseBrowserFragment.onComponentsUnavailable`).
     */
    internal fun fallbackToMainActivityFromWindow() = fallbackToMainActivity()

    /**
     * Hands this launch to the ordinary browser.
     *
     * The container goes with it. A PWA belongs to one, and a URL opened in the
     * browser without it is a URL opened under different routing and different
     * cookies than the app it came from — the very thing the launch was being
     * careful about. Dart reads `pwa_context_id` off a VIEW intent and opens the
     * tab in that container (see `IntentContainerMode.fromWireValue`), which is
     * also what puts the user in front of the prompt to start its proxy.
     */
    private fun fallbackToMainActivity() {
        val url = windowLaunchUrl
        val contextId = intent?.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID)

        val mainIntent = Intent().apply {
            setClassName(this@ExternalAppBrowserActivity, "eu.weblibre.gecko.MainActivity")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            if (url != null) {
                action = Intent.ACTION_VIEW
                data = android.net.Uri.parse(url)
                if (contextId != null) {
                    putExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID, contextId)
                }
            }
        }
        startActivity(mainIntent)
        finish()
    }

    override fun onDestroy() {
        super.onDestroy()

        // Normally settled by `onStop` already; this only drops a pause that
        // never got that far.
        ProfileUnlockRegistry.windowStopped(departureToken)
        GlobalComponents.removeCustomTabsHandoverListener(customTabsHandoverListener)
        handover.cancel()

        FlutterEngineCoordinator.releaseForExternalTask()

        // Cancel any pending coroutines
        coroutineScope.cancel()

        // Only clean up when the activity is actually finishing (user closed it),
        // not when the system temporarily destroys it (e.g. switching to main app).
        if (isFinishing) {
            // Mid-handover too, where it is still in the outgoing store.
            customTabSessionId?.let(GlobalComponents::removeCustomTab)
        }
    }

}
