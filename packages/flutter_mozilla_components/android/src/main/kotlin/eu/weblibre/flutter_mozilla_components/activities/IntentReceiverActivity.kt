/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.app.ActivityManager
import android.content.DialogInterface
import android.content.Intent
import android.os.Bundle
import android.util.Log
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.PwaConstants
import eu.weblibre.flutter_mozilla_components.PwaSessionCreator
import eu.weblibre.flutter_mozilla_components.gatekeeper.IntentBlockNotifier
import eu.weblibre.flutter_mozilla_components.gatekeeper.IntentGatekeeperPreferences
import eu.weblibre.flutter_mozilla_components.gatekeeper.GatekeeperNotificationActionReceiver
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import mozilla.components.browser.state.selector.findCustomTab
import mozilla.components.feature.customtabs.CustomTabIntentProcessor
import mozilla.components.feature.intent.ext.getSessionId
import mozilla.components.feature.pwa.intent.WebAppIntentProcessor
import androidx.browser.customtabs.CustomTabsIntent
import eu.weblibre.flutter_mozilla_components.startup.ExternalCommitResult
import eu.weblibre.flutter_mozilla_components.startup.LaunchClassification
import eu.weblibre.flutter_mozilla_components.startup.LaunchTrust
import eu.weblibre.flutter_mozilla_components.startup.LaunchDescriptor
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.PENDING_LAUNCH_TTL_MS
import eu.weblibre.flutter_mozilla_components.startup.PendingLaunch
import eu.weblibre.flutter_mozilla_components.startup.PendingLaunchStore
import eu.weblibre.flutter_mozilla_components.startup.ProfileDiscovery
import eu.weblibre.flutter_mozilla_components.startup.RestartAuthorizationStore
import eu.weblibre.flutter_mozilla_components.startup.ProfileInspection
import eu.weblibre.flutter_mozilla_components.startup.StartupConfig
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import mozilla.components.browser.state.state.ExternalAppType

/**
 * Lightweight transparent activity that receives all external intents and routes them
 * to the appropriate activity:
 * - Custom Tab intents → [ExternalAppBrowserActivity]
 * - PWA launch intents → [ExternalAppBrowserActivity] (with profile/context tracking)
 * - SHARE intents with a URL → [ExternalAppBrowserActivity] (separate recents entry)
 * - Regular VIEW / SEND / PROCESS_TEXT / WEB_SEARCH intents → MainActivity (Flutter)
 *
 * For PWA intents created by our custom installer, checks profile match and shows dialog
 * if the current profile differs from the installation profile.
 */
class IntentReceiverActivity : Activity() {
    companion object {
        private const val TAG = "IntentReceiverActivity"
        private const val PRIVATE_BROWSING_MODE = "private_browsing_mode"

        const val MAIN_ACTIVITY_CLASS = "eu.weblibre.gecko.MainActivity"

        /**
         * Asks the running browser to restart onto another profile.
         *
         * Delivered to the main activity and forwarded to Flutter, which owns the
         * teardown. Nothing native acts on it directly.
         *
         * The main activity is exported, so this action is one any app on the
         * device can send. It authorises nothing on its own: Flutter honours a
         * request only when it carries the [EXTRA_RESTART_AUTHORIZATION] token
         * matching the record written below, which lives in app-private storage
         * and so cannot be read or forged from outside.
         */
        const val ACTION_RESTART_INTO_PROFILE =
            "eu.weblibre.action.RESTART_INTO_PROFILE"

        const val EXTRA_RESTART_PROFILE_ID = "eu.weblibre.extra.RESTART_PROFILE_ID"

        /** One-shot proof that this app issued the request. */
        const val EXTRA_RESTART_AUTHORIZATION =
            "eu.weblibre.extra.RESTART_AUTHORIZATION"
    }

    private val coroutineScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val intent = intent?.let { Intent(it) } ?: Intent()

        Log.d(TAG, "onCreate: action=${intent.action} data=${intent.dataString}")

        // Strip flags that could interfere with task management
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_NEW_TASK.inv()
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_CLEAR_TASK.inv()
        intent.flags = intent.flags and Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS.inv()

        // Classification comes first, and everything after it is a consequence.
        // The gatekeeper needs it (a trusted internal launch is exempt, a forged
        // extra is not), and the profile decision needs it, and both have to
        // happen before a single component exists.
        val descriptor = classifyLaunch(intent)
        Log.d(TAG, "Classified launch as ${descriptor.classification.id}")

        if (shouldBlockIntent(intent, descriptor)) {
            finish()
            return
        }

        processIntent(intent, descriptor)
    }

    /**
     * Builds the launch facts and classifies them.
     *
     * Trust validation happens here, before the result is used for anything: it
     * reads only global preferences and the pinned shortcut list, so it is legal
     * without a committed profile, and running it this early is what lets an
     * unvalidated `pwa_profile_uuid` be discarded rather than acted on.
     *
     * The rule itself lives in [LaunchTrust] because `MainActivity` needs the
     * same answer when it queues an undeliverable launch, and two copies of a
     * trust check are two copies that can disagree.
     */
    private fun classifyLaunch(intent: Intent): LaunchDescriptor =
        LaunchTrust.classify(applicationContext, intent)

    /**
     * Fast native block-check. Only rejects packages explicitly on the blocked
     * list; allowed and unknown packages fall through to the Flutter-side
     * gatekeeper which can still prompt the user.
     *
     * Launches whose PWA/shortcut token validated are never blocked here — those
     * are internal launches regardless of which app delivered them. An unvalidated
     * claim gets no exemption.
     */
    private fun shouldBlockIntent(intent: Intent, descriptor: LaunchDescriptor): Boolean {
        if (!IntentGatekeeperPreferences.isEnabled(applicationContext)) return false

        // Only a launch whose token actually validated is exempt. Keying this on
        // the mere presence of `pwa_profile_uuid` let any app opt out of the
        // gatekeeper by adding one extra to its intent.
        if (descriptor.bindsTrustedProfile) return false
        intent.getStringExtra(
            GatekeeperNotificationActionReceiver.EXTRA_NOTIFICATION_APPROVAL_TOKEN,
        )?.let { token ->
            if (IntentGatekeeperPreferences.hasNotificationApproval(applicationContext, token)) {
                return false
            }
        }

        val caller = resolveExternalCallerPackage(intent) ?: return false
        if (caller == packageName) return false
        if (!IntentGatekeeperPreferences.isBlocked(applicationContext, caller)) return false

        Log.i(TAG, "Blocking intent from $caller (native gatekeeper)")
        IntentBlockNotifier.notifyBlocked(applicationContext, caller, intent)
        return true
    }

    override fun onDestroy() {
        super.onDestroy()
        coroutineScope.cancel()
    }

    private fun processIntent(intent: Intent, descriptor: LaunchDescriptor) {
        // Must run before any intent processor: CustomTabIntentProcessor reads the caller off the
        // intent when it builds the session source, and the app-links authentication carve-out
        // needs that caller to recognise a sign-in callback.
        addExternalCallerInformation(intent)

        // A trusted PWA or pinned shortcut names the profile it was installed
        // under, and that has to win before any component exists — the process
        // profile is immutable, so a candidate bound first could never be replaced
        // by the right one.
        // A regular launch binds nothing at all. It has no profile of its own to
        // honour and needs no engine, so leaving the decision open is what allows
        // MainActivity's Dart engine to arbitrate — and, once the picker exists,
        // to ask.
        if (descriptor.bindsTrustedProfile || descriptor.requiresComponents) {
            bindProcessProfile(descriptor)
        }

        if (!descriptor.requiresComponents) {
            // A regular launch is forwarded unbound. Building an engine here would
            // settle the profile question for the whole process just to discover
            // that this intent only needed MainActivity — and it is MainActivity's
            // Dart engine that runs the picker.
            Log.d(TAG, "Launch needs no components, forwarding to MainActivity")
            routeIntent(intent, descriptor)
            return
        }

        if (GlobalComponents.components == null &&
            !GlobalComponents.ensureExternalComponents(applicationContext)
        ) {
            Log.w(TAG, "Components unavailable, routing directly to MainActivity")
            handleRegularIntent(intent)
            return
        }

        routeIntent(intent, descriptor)
    }

    /**
     * Binds the process to the profile this launch belongs to.
     *
     * Only a validated trusted launch may name one; everything else falls back to
     * the ordinary candidate. A launch that needs no components still binds,
     * because a trusted pinned shortcut opens in the ordinary browser and its
     * profile must still be the one the process settles on.
     */
    private fun bindProcessProfile(descriptor: LaunchDescriptor) {
        val honorShortcutProfile = runCatching {
            StartupConfig.read(StartupPaths(applicationContext)).honorShortcutProfile
        }.getOrDefault(true)

        val result = StartupArbiter.tryCommitExternal(
            requestedProfileId = descriptor.trustedProfileId,
            trusted = descriptor.bindsTrustedProfile,
            honorShortcutProfile = honorShortcutProfile,
        )

        when (result) {
            is ExternalCommitResult.AlreadyCommittedDifferent ->
                // The process already serves another profile and cannot change
                // without dying first. Continue under the committed one; the
                // mismatch dialog and restart flow are not built yet.
                Log.w(
                    TAG,
                    "Trusted launch wants ${descriptor.trustedProfileId} but the process " +
                        "is committed to ${result.profileId}; continuing under the " +
                        "committed profile",
                )

            ExternalCommitResult.MaintenanceRefused,
            ExternalCommitResult.SelectionInProgress,
            ExternalCommitResult.Terminating,
            ExternalCommitResult.NoValidProfile,
            -> Log.w(TAG, "Process refused to bind a profile for this launch ($result)")

            else -> Unit
        }
    }

    private fun routeIntent(intent: Intent, descriptor: LaunchDescriptor) {
        val privateBrowsingMode = intent.getBooleanExtra(PRIVATE_BROWSING_MODE, false)
        intent.putExtra(PRIVATE_BROWSING_MODE, privateBrowsingMode)

        when (descriptor.classification) {
            // SHARE intents with a URL open as a separate recents entry ("share as
            // new task"), matching what users expect when sharing into a browser.
            // A share without a URL was classified REGULAR and never gets here.
            LaunchClassification.SHARE_URL -> {
                val shareUrl = descriptor.shareUrl
                if (shareUrl == null) {
                    handleRegularIntent(intent)
                } else {
                    Log.d(TAG, "SHARE intent with URL, routing to custom tab: $shareUrl")
                    handleShareUrlAsCustomTab(intent, shareUrl, privateBrowsingMode)
                }
                return
            }

            // A basic pinned shortcut opens in the ordinary browser rather than as
            // a standalone PWA.
            LaunchClassification.TRUSTED_SHORTCUT -> {
                val profileUuid = descriptor.trustedProfileId
                if (profileUuid == null) {
                    handleRegularIntent(intent)
                } else {
                    Log.d(TAG, "Trusted basic shortcut, routing to regular browser")
                    handleBasicShortcutIntent(intent, profileUuid)
                }
                return
            }

            LaunchClassification.TRUSTED_PWA -> {
                val profileUuid = descriptor.trustedProfileId
                if (profileUuid == null) {
                    handleRegularIntent(intent)
                } else {
                    val contextId = intent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID)
                    val token = intent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)
                    Log.d(TAG, "Trusted PWA launch under $profileUuid (context=$contextId)")
                    handlePwaIntent(intent, profileUuid, contextId, token)
                }
                return
            }

            LaunchClassification.CUSTOM_TAB,
            LaunchClassification.LEGACY_PWA,
            -> Unit

            else -> {
                handleRegularIntent(intent)
                return
            }
        }

        val components = GlobalComponents.components
            ?: run {
                Log.e(TAG, "Components became null during routing")
                handleRegularIntent(intent)
                return
            }

        // One processor, not both. The classification already decided which kind of
        // launch this is, and the two processors' own `matches` conditions are
        // disjoint anyway — trying the other one could only ever fail.
        val (name, processor) = when (descriptor.classification) {
            LaunchClassification.CUSTOM_TAB -> "CustomTab" to CustomTabIntentProcessor(
                components.useCases.customTabsUseCases.add,
                resources,
                isPrivate = privateBrowsingMode,
            )

            else -> "PWA" to WebAppIntentProcessor(
                components.core.store,
                components.useCases.customTabsUseCases.addWebApp,
                components.useCases.sessionUseCases.loadUrl,
                components.core.webAppManifestStorage,
            )
        }

        Log.d(TAG, "Trying $name processor...")
        try {
            if (processor.process(intent)) {
                val sessionId = intent.getSessionId()
                    ?: resolveSessionIdFromStore(name, intent, components)
                Log.d(TAG, "$name session ID from intent: $sessionId")
                if (sessionId != null) {
                    startActivity(
                        ExternalAppBrowserActivity.createIntent(
                            context = this,
                            customTabSessionId = sessionId,
                            webAppManifestUrl = if (name == "PWA") intent.dataString else null,
                        ),
                    )
                    finish()
                    return
                }

                Log.w(TAG, "$name processor succeeded but no session ID in intent!")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in $name processor", e)
        }

        Log.d(TAG, "$name processor did not match, routing to MainActivity")
        handleRegularIntent(intent)
    }

    private fun resolveSessionIdFromStore(
        processorName: String,
        intent: Intent,
        components: Components,
    ): String? {
        val customTabs = components.core.store.state.customTabs
        if (customTabs.isEmpty()) {
            return null
        }

        return when (processorName) {
            "PWA" -> {
                val targetUrl = intent.dataString
                val pwaTab = customTabs.lastOrNull { tab ->
                    val appType = tab.config.externalAppType
                    val isPwa = appType == ExternalAppType.PROGRESSIVE_WEB_APP ||
                        appType == ExternalAppType.TRUSTED_WEB_ACTIVITY
                    if (!isPwa) {
                        return@lastOrNull false
                    }

                    if (targetUrl == null) {
                        true
                    } else {
                        tab.content.url == targetUrl || tab.content.webAppManifest?.startUrl == targetUrl
                    }
                } ?: customTabs.lastOrNull { tab ->
                    val appType = tab.config.externalAppType
                    appType == ExternalAppType.PROGRESSIVE_WEB_APP ||
                        appType == ExternalAppType.TRUSTED_WEB_ACTIVITY
                }

                pwaTab?.id
            }

            else -> customTabs.lastOrNull()?.id
        }
    }

    /**
     * Handles PWA intents with profile and context metadata.
     * Checks if current profile matches and shows dialog if different.
     */
    private fun handlePwaIntent(
        intent: Intent,
        profileUuid: String,
        contextId: String?,
        token: String?,
    ) {
        val url = intent.dataString
        if (url == null) {
            Log.e(TAG, "PWA intent has no URL")
            handleRegularIntent(intent)
            return
        }

        val installStartUrl = intent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL)

        val currentProfileUuid = getCurrentProfileUuid()

        if (currentProfileUuid != null && currentProfileUuid != profileUuid) {
            Log.d(TAG, "Profile mismatch: current=$currentProfileUuid, expected=$profileUuid")
            showProfileMismatchDialog(
                intent = intent,
                onProceed = {
                    launchPwaWithContext(
                        url = url,
                        contextId = contextId,
                        profileUuid = profileUuid,
                        token = token,
                        installStartUrl = installStartUrl,
                        allowTaskReuse = false,
                    )
                },
                isPwa = true,
                expectedProfileUuid = profileUuid,
                currentProfileUuid = currentProfileUuid,
            )
        } else {
            Log.d(TAG, "Profile match or indeterminate, launching PWA with contextId=$contextId")
            launchPwaWithContext(
                url = url,
                contextId = contextId,
                profileUuid = profileUuid,
                token = token,
                installStartUrl = installStartUrl,
                allowTaskReuse = true,
            )
        }
    }

    /**
     * Reads the current profile UUID from the filesystem.
     * The Flutter side persists this as a plain text file at:
     *   <filesDir>/weblibre_profiles/current_profile
     */
    /**
     * The profile this process actually runs, or null if it has not committed one.
     *
     * Deliberately not `current_profile`: that file says which profile the *next*
     * process will start on, so comparing a shortcut against it would report a
     * mismatch the user cannot see and miss one they can. A mismatch dialog is
     * only meaningful against the profile already bound here.
     */
    private fun getCurrentProfileUuid(): String? = StartupArbiter.committedProfileId()

    /**
     * Handles basic shortcut intents with profile validation.
     * Checks profile match and shows dialog if different, then forwards to regular browser.
     */
    private fun handleBasicShortcutIntent(intent: Intent, profileUuid: String) {
        val currentProfileUuid = getCurrentProfileUuid()

        if (currentProfileUuid != null && currentProfileUuid != profileUuid) {
            Log.d(TAG, "Basic shortcut profile mismatch: current=$currentProfileUuid, expected=$profileUuid")
            showProfileMismatchDialog(
                intent = intent,
                onProceed = { handleRegularIntent(it) },
                isPwa = false,
                expectedProfileUuid = profileUuid,
                currentProfileUuid = currentProfileUuid,
            )
        } else {
            Log.d(TAG, "Basic shortcut profile match or indeterminate, routing to browser")
            handleRegularIntent(intent)
        }
    }

    /**
     * Shows a dialog when the current profile doesn't match the shortcut's installation profile.
     */
    private fun showProfileMismatchDialog(
        intent: Intent,
        onProceed: (Intent) -> Unit,
        isPwa: Boolean,
        expectedProfileUuid: String,
        currentProfileUuid: String,
    ) {
        val typeLabel = if (isPwa) "PWA" else "shortcut"
        val paths = StartupPaths(applicationContext)
        val expectedName = profileNameOf(paths, expectedProfileUuid)
        val currentName = profileNameOf(paths, currentProfileUuid)

        // Both profiles are named. "A different profile" leaves the user deciding
        // between two options whose consequences they cannot see, which is the one
        // thing this dialog exists to prevent.
        // Offered only for a profile that still validates. A restart onto a damaged
        // profile would commit to something Flutter then refuses, and the process
        // profile cannot be re-pointed once bound.
        val canRestart = ProfileDiscovery.validate(paths.profilesDir, expectedProfileUuid)

        // Both consequences, because both buttons have one. The restart line is
        // not optional politeness: restarting is the emphasised action, and an
        // emphasised button that closes the browser without saying so is a
        // surprise the first time and a reason not to trust the dialog after
        // that.
        val message = "This $typeLabel belongs to the profile \u201C$expectedName\u201D, " +
            "but WebLibre is currently running \u201C$currentName\u201D.\n\n" +
            "Opening it here uses only \u201C$currentName\u201D\u2019s data and settings. " +
            "The original profile\u2019s app state and saved data will not be used." +
            if (canRestart) {
                "\n\nRestarting closes WebLibre and reopens it as " +
                    "\u201C$expectedName\u201D, with this $typeLabel."
            } else {
                ""
            }

        val openHere = DialogInterface.OnClickListener { _, _ ->
            Log.d(TAG, "User chose to open $typeLabel despite profile mismatch")
            onProceed(intent)
        }

        val builder = MaterialAlertDialogBuilder(this)
            .setTitle("Profile mismatch")
            .setMessage(message)
            .setNegativeButton("Cancel") { _, _ ->
                Log.d(TAG, "User cancelled $typeLabel launch due to profile mismatch")
                finish()
            }
            .setOnCancelListener {
                finish()
            }

        // Which action is *emphasised* is the decision this dialog is making for
        // the user, and it used to be the wrong one: the positive button — the
        // filled one, the one a returning user taps without reading — was "Open
        // in <current>", which is the option that quietly uses the wrong
        // profile's data. Restarting is what the shortcut actually asked for, so
        // it takes the positive slot whenever it is possible, and opening here
        // moves to the neutral slot as the deliberate alternative it is.
        //
        // With no valid profile to restart into there is no alternative, and
        // opening here is the only way forward — so it becomes the positive
        // action rather than a neutral one beside an empty slot.
        if (canRestart) {
            builder
                .setPositiveButton("Restart in \u201C$expectedName\u201D") { _, _ ->
                    requestRestartInto(intent, expectedProfileUuid, expectedName)
                }
                .setNeutralButton("Open in \u201C$currentName\u201D", openHere)
        } else {
            builder.setPositiveButton("Open in \u201C$currentName\u201D", openHere)
        }

        builder.show()
    }

    private fun profileNameOf(paths: StartupPaths, profileId: String): String =
        when (val inspection = ProfileDiscovery.inspect(paths.profileDir(profileId))) {
            is ProfileInspection.Valid -> inspection.profile.name
            else -> profileId.take(8)
        }

    /**
     * Hands the restart to the running app rather than performing it here.
     *
     * The default process holds the Gecko runtime, the open databases and the
     * Flutter engine; only it can close them cleanly. Killing it from this
     * activity would restart onto the right profile having corrupted the one being
     * left. So this records where the relaunch should land, then asks the browser
     * to run the same switch-and-restart path the profile switcher uses.
     */
    private fun requestRestartInto(
        original: Intent,
        targetProfileId: String,
        targetName: String,
    ) {
        val now = System.currentTimeMillis()
        val paths = StartupPaths(applicationContext)
        val recorded = runCatching {
            PendingLaunchStore(paths).write(
                PendingLaunch(
                    // Written before the restart is armed, so it carries no request
                    // id to match against. The TTL is what bounds it instead.
                    requestId = "mismatch-$now",
                    intentUri = original.toUri(Intent.URI_INTENT_SCHEME),
                    targetProfileId = targetProfileId,
                    createdAtMillis = now,
                    expiresAtMillis = now + PENDING_LAUNCH_TTL_MS,
                ),
            )
        }.isSuccess

        if (!recorded) {
            // The restart would still work; it would just land on a browser with no
            // idea why. Better to say so than to silently drop the user's intent.
            Log.w(TAG, "Could not record the pending launch; not restarting")
            finish()
            return
        }

        // Issued before the intent is sent, and bound to this profile. Without it
        // the request is indistinguishable from one any other app could send to the
        // exported main activity, and Flutter will refuse it — so a failure here is
        // a reason not to send the intent at all, not something to send anyway.
        val authorization = runCatching {
            RestartAuthorizationStore(paths).issue(targetProfileId, now)
        }.getOrElse { error ->
            Log.w(TAG, "Could not authorize the restart; not restarting", error)
            finish()
            return
        }

        Log.d(TAG, "Requesting restart into $targetName ($targetProfileId)")
        startActivity(
            Intent(ACTION_RESTART_INTO_PROFILE).apply {
                setClassName(this@IntentReceiverActivity, MAIN_ACTIVITY_CLASS)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                putExtra(EXTRA_RESTART_PROFILE_ID, targetProfileId)
                putExtra(EXTRA_RESTART_AUTHORIZATION, authorization)
            },
        )
        finish()
    }

    /**
     * Launches the PWA with the specified context ID for storage isolation.
     */
    private fun launchPwaWithContext(
        url: String,
        contextId: String?,
        profileUuid: String,
        token: String?,
        installStartUrl: String?,
        allowTaskReuse: Boolean,
    ) {
        if (allowTaskReuse && bringPwaTaskToFront(url, profileUuid, contextId, token, installStartUrl)) {
            finish()
            return
        }

        if (GlobalComponents.components == null) {
            Log.e(TAG, "Components not available for PWA launch")
            handleRegularIntent(intent)
            return
        }

        coroutineScope.launch {
            try {
                val sessionId = PwaSessionCreator.create(
                    url = url,
                    contextId = contextId,
                )

                Log.d(TAG, "Created PWA session: contextId=$contextId, sessionId=$sessionId")

                val externalIntent = ExternalAppBrowserActivity.createIntent(
                    context = this@IntentReceiverActivity,
                    customTabSessionId = sessionId,
                    webAppManifestUrl = url,
                    pwaProfileUuid = profileUuid,
                    pwaContextId = contextId,
                    pwaToken = token,
                    pwaInstallStartUrl = installStartUrl ?: url,
                )
                startActivity(externalIntent)
                finish()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to launch PWA with context", e)
                handleRegularIntent(intent)
            }
        }
    }

    private fun bringPwaTaskToFront(
        url: String,
        profileUuid: String,
        contextId: String?,
        token: String?,
        installStartUrl: String?,
    ): Boolean {
        if (token.isNullOrEmpty()) {
            return false
        }

        val activityManager = getSystemService(ActivityManager::class.java) ?: return false
        val components = GlobalComponents.components

        for (appTask in activityManager.appTasks) {
            val baseIntent = runCatching { appTask.taskInfo?.baseIntent }
                .getOrElse { error ->
                    Log.w(TAG, "Failed to inspect app task", error)
                    return@getOrElse null
                } ?: continue

            if (baseIntent.component?.className != ExternalAppBrowserActivity::class.java.name) {
                continue
            }

            if (!matchesPwaTaskIntent(baseIntent, url, profileUuid, contextId, token, installStartUrl, components)) {
                continue
            }

            return try {
                appTask.moveToFront()
                Log.d(TAG, "Resumed existing PWA task for $url")
                true
            } catch (e: Exception) {
                Log.e(TAG, "Failed to move existing PWA task to front", e)
                false
            }
        }

        return false
    }

    private fun matchesPwaTaskIntent(
        baseIntent: Intent,
        url: String,
        profileUuid: String,
        contextId: String?,
        token: String,
        installStartUrl: String?,
        components: Components?,
    ): Boolean {
        val requestedContextId = contextId.orEmpty()
        val requestedInstallStartUrl = installStartUrl ?: url

        val taskToken = baseIntent.getStringExtra(PwaConstants.EXTRA_PWA_TOKEN)
        if (!taskToken.isNullOrEmpty()) {
            return taskToken == token &&
                baseIntent.getStringExtra(PwaConstants.EXTRA_PWA_PROFILE_UUID) == profileUuid &&
                baseIntent.getStringExtra(PwaConstants.EXTRA_PWA_CONTEXT_ID).orEmpty() == requestedContextId &&
                baseIntent.getStringExtra(PwaConstants.EXTRA_PWA_INSTALL_START_URL) == requestedInstallStartUrl
        }

        val taskManifestUrl = baseIntent.getStringExtra(ExternalAppBrowserActivity.EXTRA_WEB_APP_MANIFEST_URL)
        if (taskManifestUrl != requestedInstallStartUrl && taskManifestUrl != url) {
            return false
        }

        val sessionId = baseIntent.getStringExtra(ExternalAppBrowserActivity.EXTRA_CUSTOM_TAB_SESSION_ID)
            ?: return false
        val customTab = components?.core?.store?.state?.findCustomTab(sessionId) ?: return false
        val appType = customTab.config.externalAppType
        val isPwa = appType == ExternalAppType.PROGRESSIVE_WEB_APP ||
            appType == ExternalAppType.TRUSTED_WEB_ACTIVITY
        if (!isPwa) {
            return false
        }

        val manifestStartUrl = customTab.content.webAppManifest?.startUrl
        val launchUrl = manifestStartUrl ?: taskManifestUrl ?: customTab.content.url
        return customTab.contextId.orEmpty() == requestedContextId &&
            (launchUrl == requestedInstallStartUrl || launchUrl == url)
    }

    /**
     * Extracts a URL from a SEND intent.
     * First checks EXTRA_TEXT for a URL, then EXTRA_STREAM.
     * Returns null if no valid URL is found.
     */
    /**
     * Creates a custom tab session for the shared URL and launches
     * [ExternalAppBrowserActivity], which appears as a separate recents entry
     * because it uses taskAffinity="" and documentLaunchMode="always".
     */
    private fun handleShareUrlAsCustomTab(
        sourceIntent: Intent,
        url: String,
        privateBrowsingMode: Boolean,
    ) {
        // `processIntent` already bound the profile and built the components for a
        // SHARE_URL launch, so this is a consistency check rather than a second
        // initialization point — binding here would be binding twice.
        val components = GlobalComponents.components ?: run {
            Log.w(TAG, "Components not initialized, falling back to MainActivity for SHARE")
            handleRegularIntent(sourceIntent)
            return
        }

        val customTabConfig = mozilla.components.browser.state.state.CustomTabConfig()

        val tab = mozilla.components.browser.state.state.createCustomTab(
            url = url,
            config = customTabConfig,
            source = mozilla.components.browser.state.state.SessionState.Source.Internal.CustomTab,
            private = privateBrowsingMode,
        )

        components.core.store.dispatch(
            mozilla.components.browser.state.action.CustomTabListAction.AddCustomTabAction(tab)
        )

        val loadUrlFlags = mozilla.components.concept.engine.EngineSession.LoadUrlFlags.external()
        components.useCases.sessionUseCases.loadUrl(url, tab.id, loadUrlFlags)

        val externalIntent = ExternalAppBrowserActivity.createIntent(
            context = this,
            customTabSessionId = tab.id,
        )
        startActivity(externalIntent)
        finish()
    }

    private fun handleRegularIntent(intent: Intent) {
        val mainActivityIntent = Intent(intent).apply {
            setClassName(this@IntentReceiverActivity, MAIN_ACTIVITY_CLASS)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            // Preserve the original caller so the gatekeeper on the Flutter side
            // can identify which app triggered this intent (getReferrer() in the
            // forwarded activity would otherwise resolve to ourselves).
            if (!hasExtra(Intent.EXTRA_REFERRER) && !hasExtra(Intent.EXTRA_REFERRER_NAME)) {
                referrer?.let { putExtra(Intent.EXTRA_REFERRER, it) }
            }
        }
        startActivity(mainActivityIntent)
        finish()
    }
}
