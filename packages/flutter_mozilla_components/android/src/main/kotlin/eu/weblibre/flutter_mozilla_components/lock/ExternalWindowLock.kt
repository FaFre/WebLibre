/*
 * Copyright (c) 2024-2026 Fabian Freund.
 *
 * This file is part of WebLibre
 * (see https://weblibre.eu).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
package eu.weblibre.flutter_mozilla_components.lock

import android.view.View
import android.view.ViewGroup
import android.view.accessibility.AccessibilityNodeInfo
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.biometric.BiometricManager.Authenticators
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.core.widget.doAfterTextChanged
import androidx.lifecycle.Lifecycle
import com.google.android.material.button.MaterialButton
import com.google.android.material.textfield.TextInputEditText
import com.google.android.material.textfield.TextInputLayout
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.pigeons.ProfilePasswordOutcome
import eu.weblibre.flutter_mozilla_components.pigeons.ProfilePasswordReply
import eu.weblibre.flutter_mozilla_components.startup.ProfileDiscovery
import eu.weblibre.flutter_mozilla_components.startup.ProfileInspection
import eu.weblibre.flutter_mozilla_components.startup.StartupArbiter
import eu.weblibre.flutter_mozilla_components.startup.StartupPaths
import kotlin.math.ceil
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import mozilla.components.support.base.log.logger.Logger

/**
 * The profile lock of a Custom Tab or PWA window.
 *
 * The browser locks a profile behind its own screen, but these windows are
 * native and never pass through it: before this, a link opened from another
 * app or a PWA icon showed the profile's pages to whoever held the phone.
 *
 * The window keeps its page underneath and covers it while the profile is
 * locked, so unlocking shows the page where it was. The checks are the
 * browser's: the system prompt for a device lock, and Dart's password check
 * (see [ProfilePasswordChecker]) for a password, with the same wrong-attempt
 * throttling. Unlocks are recorded in [ProfileUnlockRegistry], which shares
 * the timeout and until-restart ones with the browser.
 *
 * The panel covers the window's own views only. Dialogs and popups are
 * windows of their own; [onLockChanged] reports when the lock comes up or
 * lifts, so the activity can hide those (see [LockedWindowCurtain]).
 *
 * Must be created in the activity's `onCreate`: [BiometricPrompt] registers
 * with the activity's lifecycle when it is constructed.
 */
internal class ExternalWindowLock(
    private val activity: AppCompatActivity,
    private val scope: CoroutineScope,
    private val onClose: () -> Unit,
    private val onLockChanged: (locked: Boolean) -> Unit,
) {
    private val logger = Logger("ExternalWindowLock")

    private val panel: View = activity.findViewById(R.id.lock_panel)
    private val title: TextView = panel.findViewById(R.id.lock_title)
    private val profileName: TextView = panel.findViewById(R.id.lock_profile_name)
    private val passwordLayout: TextInputLayout = panel.findViewById(R.id.lock_password_layout)
    private val passwordField: TextInputEditText = panel.findViewById(R.id.lock_password)
    private val message: TextView = panel.findViewById(R.id.lock_message)
    private val unlockButton: MaterialButton = panel.findViewById(R.id.lock_unlock)
    private val closeButton: MaterialButton = panel.findViewById(R.id.lock_close)

    /**
     * What the panel covers: the page, and the launch status over it, which
     * names where the window is going and offers to open it in the browser.
     */
    private val covered = CoveredViews(
        listOfNotNull<ViewGroup>(
            activity.findViewById(R.id.container),
            activity.findViewById(R.id.launch_status),
        ),
    )

    private val devicePrompt = BiometricPrompt(
        activity,
        ContextCompat.getMainExecutor(activity),
        object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                promptShowing = false
                // Re-read: the prompt proves the device lock, which is only
                // enough while that is still the profile's lock.
                val current = currentLock() ?: return unlocked()
                if (current.second.method == ProfileLockMethod.DEVICE) {
                    unlocked()
                } else {
                    show(current.first, current.second, autoPrompt = false)
                }
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                promptShowing = false
                when (errorCode) {
                    // The person closed it; the button is right there.
                    BiometricPrompt.ERROR_USER_CANCELED,
                    BiometricPrompt.ERROR_NEGATIVE_BUTTON,
                    BiometricPrompt.ERROR_CANCELED,
                    -> Unit

                    else -> showMessage(errString)
                }
            }
        },
    )

    /** Run once the profile is open, in the order they were asked for. */
    private val pendingUnlocked = mutableListOf<() -> Unit>()

    /** The method the panel is showing, or null while it is hidden. */
    private var shownMethod: ProfileLockMethod? = null

    /** Whether the device prompt opened by itself for the current showing. */
    private var autoPrompted = false
    private var promptShowing = false
    private var check: Job? = null

    /**
     * A right password that came back while the window was paused, and the
     * departure count when its check began. Whether the pause was leaving is
     * not settled yet; see [settleHeldAcceptance].
     */
    private var heldAcceptance: Int? = null

    init {
        unlockButton.setOnClickListener {
            when (shownMethod) {
                ProfileLockMethod.PASSWORD -> submitPassword()
                ProfileLockMethod.DEVICE -> promptDevice()
                else -> Unit
            }
        }
        closeButton.setOnClickListener { onClose() }

        passwordField.doAfterTextChanged {
            passwordLayout.error = null
            updateUnlockButton()
        }
        passwordField.setOnEditorActionListener { _, actionId, _ ->
            if (actionId == EditorInfo.IME_ACTION_DONE) {
                submitPassword()
                true
            } else {
                false
            }
        }
    }

    val isShowing: Boolean
        get() = shownMethod != null

    /**
     * Runs [onUnlocked] once the profile this process serves is open: now when
     * it is, after the person unlocks it otherwise.
     *
     * [autoPrompt] opens the device prompt by itself, as the browser's lock
     * screen does. Only from a resumed window: a prompt raised during
     * `onCreate` or `onPause` would open over nothing, or over another app.
     * For the same reason it is what lets a held right password unlock (see
     * [settleHeldAcceptance]).
     */
    fun guard(autoPrompt: Boolean, onUnlocked: (() -> Unit)? = null) {
        settleHeldAcceptance(inFront = autoPrompt)

        val (profileId, settings) = currentLock() ?: run {
            // No profile is committed, so there is nothing of one to show. The
            // window's own start falls back to the browser, which owns the
            // profile question and has its own lock.
            hide()
            onUnlocked?.invoke()
            return
        }

        if (ProfileUnlockRegistry.isUnlocked(profileId, settings)) {
            hide()
            runPending()
            onUnlocked?.invoke()
            return
        }

        onUnlocked?.let(pendingUnlocked::add)
        show(profileId, settings, autoPrompt)
    }

    /**
     * Opens the window as a continuation of the browser, which only someone
     * past its lock can have been using. See
     * `ExternalAppBrowserActivity.opensFromUnlockedBrowser`.
     *
     * Only for background mode, which the browser never shares: a timeout or
     * until-restart unlock reaches the window as the browser's own shared one,
     * and a fresh grant would restart its timeout. Recorded like any unlock,
     * so it ends like one, when the person leaves the window.
     */
    fun grantForLaunch() {
        val (profileId, settings) = currentLock() ?: return
        if (!settings.isLocked || settings.autoLockMode != AutoLockMode.BACKGROUND) return

        ProfileUnlockRegistry.record(profileId, settings)
    }

    /** The committed profile and its lock as `metadata.json` says now. */
    private fun currentLock(): Pair<String, ProfileLockSettings>? {
        val profileId = StartupArbiter.committedProfileId() ?: return null
        return profileId to ProfileLockSettings.read(StartupPaths(activity), profileId)
    }

    private fun show(profileId: String, settings: ProfileLockSettings, autoPrompt: Boolean) {
        val method = settings.method
        val wasShowing = shownMethod != null
        if (shownMethod != method) {
            shownMethod = method
            autoPrompted = false

            profileName.text = profileNameOf(profileId)
            profileName.visibility = if (profileName.text.isNullOrBlank()) View.GONE else View.VISIBLE
            message.visibility = View.GONE
            passwordField.text = null
            passwordLayout.error = null
            passwordLayout.visibility =
                if (method == ProfileLockMethod.PASSWORD) View.VISIBLE else View.GONE

            panel.visibility = View.VISIBLE
            updateUnlockButton()
        }

        if (!wasShowing) {
            coverContent()
            onLockChanged(true)
        }

        if (!autoPrompt) return

        when (method) {
            ProfileLockMethod.DEVICE -> if (!autoPrompted) {
                autoPrompted = true
                promptDevice()
            }

            ProfileLockMethod.PASSWORD -> {
                // Started while the person types, so the check that follows
                // does not have to wait for the app half too.
                ProfilePasswordChecker.prepare(activity.applicationContext)
                focusPassword()
            }

            else -> Unit
        }
    }

    private fun hide() {
        if (shownMethod == null) return

        shownMethod = null
        check?.cancel()
        check = null
        heldAcceptance = null
        passwordField.text = null
        hideKeyboard()
        panel.visibility = View.GONE
        covered.uncover()
        onLockChanged(false)
    }

    /**
     * Takes what the panel covers out of reach of a screen reader and the
     * keyboard, and brings both to the panel instead.
     */
    private fun coverContent() {
        covered.cover()

        panel.requestFocus()
        // Screen reader focus too, which is apart from input focus: on the
        // title, so the lock is the first thing read.
        panel.post {
            if (shownMethod != null) {
                title.performAccessibilityAction(AccessibilityNodeInfo.ACTION_ACCESSIBILITY_FOCUS, null)
            }
        }
    }

    private fun unlocked() {
        val (profileId, settings) = currentLock() ?: run {
            hide()
            runPending()
            return
        }

        ProfileUnlockRegistry.record(profileId, settings)
        hide()
        runPending()
    }

    private fun runPending() {
        val callbacks = pendingUnlocked.toList()
        pendingUnlocked.clear()
        callbacks.forEach { it() }
    }

    private fun promptDevice() {
        if (promptShowing || check != null) return
        message.visibility = View.GONE

        // Laid out like the browser's prompt: a title, and what it is for.
        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle(activity.getString(R.string.weblibre_lock_prompt_title))
            .setDescription(activity.getString(R.string.weblibre_lock_prompt_reason))
            // What local_auth asks for in the browser: any enrolled biometric,
            // or the device PIN, pattern or password.
            .setAllowedAuthenticators(Authenticators.BIOMETRIC_WEAK or Authenticators.DEVICE_CREDENTIAL)
            .build()

        promptShowing = true
        try {
            devicePrompt.authenticate(info)
        } catch (e: Exception) {
            promptShowing = false
            logger.error("Could not show the device prompt", e)
            showMessage(activity.getString(R.string.weblibre_lock_check_failed))
        }
    }

    private fun submitPassword() {
        val password = passwordField.text?.toString().orEmpty()
        if (password.isEmpty() || check != null) return
        val profileId = StartupArbiter.committedProfileId() ?: return

        val departuresBefore = ProfileUnlockRegistry.departureCount()
        setChecking(true)

        check = scope.launch {
            val reply = try {
                ProfilePasswordChecker.check(activity.applicationContext, profileId, password)
            } finally {
                check = null
                setChecking(false)
            }

            if (activity.isFinishing || activity.isDestroyed) return@launch

            if (reply?.outcome == ProfilePasswordOutcome.ACCEPTED) {
                // Argon2 takes long enough to leave the window in the middle
                // of it. An unlock that lands while the person is away would
                // greet whoever opens the window next with the page.
                if (ProfileUnlockRegistry.departureCount() != departuresBefore) {
                    passwordFailed(activity.getString(R.string.weblibre_lock_interrupted))
                    return@launch
                }

                // Paused: on the way out, or under a dialog. Which one shows
                // when the window is back in front, or goes out of sight.
                if (!activity.lifecycle.currentState.isAtLeast(Lifecycle.State.RESUMED)) {
                    heldAcceptance = departuresBefore
                    return@launch
                }

                unlocked()
                return@launch
            }

            passwordFailed(describe(reply))
        }
    }

    /**
     * Applies a [heldAcceptance] once the pause it came back in is settled:
     * unlocks if the window is back in front without having left, and
     * reports the check as interrupted if it left. [inFront] is false for a
     * guard run while the window is not resumed, where neither has happened.
     */
    private fun settleHeldAcceptance(inFront: Boolean) {
        val departuresBefore = heldAcceptance ?: return

        if (ProfileUnlockRegistry.departureCount() != departuresBefore) {
            heldAcceptance = null
            passwordFailed(activity.getString(R.string.weblibre_lock_interrupted))
            return
        }
        if (!inFront) return

        heldAcceptance = null
        unlocked()
    }

    private fun passwordFailed(error: String) {
        passwordField.text = null
        passwordLayout.error = error
        focusPassword()
    }

    private fun describe(reply: ProfilePasswordReply?): String {
        val retry = reply?.retryAfterMs?.let(::describeRetry)
        return when (reply?.outcome) {
            ProfilePasswordOutcome.REJECTED -> if (retry == null) {
                activity.getString(R.string.weblibre_lock_wrong_password)
            } else {
                activity.getString(R.string.weblibre_lock_wrong_password_retry, retry)
            }

            ProfilePasswordOutcome.THROTTLED -> activity.getString(
                R.string.weblibre_lock_too_many_attempts,
                retry ?: describeRetry(0),
            )

            // Not a pass: a check that could not run or record its result
            // keeps the profile locked.
            else -> activity.getString(R.string.weblibre_lock_check_failed)
        }
    }

    /** The browser's `describePasswordRetryAfter`, in resources. */
    private fun describeRetry(waitMs: Long): String {
        // Rounded up: "try again in 0 seconds" for a wait still running reads
        // as a bug.
        val seconds = ceil(waitMs / 1000.0).toInt().coerceAtLeast(1)
        if (seconds < 120) {
            return activity.resources.getQuantityString(
                R.plurals.weblibre_lock_retry_seconds,
                seconds,
                seconds,
            )
        }
        val minutes = ceil(seconds / 60.0).toInt()
        return activity.resources.getQuantityString(
            R.plurals.weblibre_lock_retry_minutes,
            minutes,
            minutes,
        )
    }

    private fun setChecking(checking: Boolean) {
        passwordField.isEnabled = !checking
        closeButton.isEnabled = !checking
        unlockButton.setText(
            if (checking) R.string.weblibre_lock_unlocking else R.string.weblibre_lock_unlock,
        )
        updateUnlockButton()
    }

    private fun updateUnlockButton() {
        unlockButton.isEnabled = check == null && when (shownMethod) {
            ProfileLockMethod.PASSWORD -> !passwordField.text.isNullOrEmpty()
            ProfileLockMethod.DEVICE -> true
            else -> false
        }
    }

    private fun showMessage(text: CharSequence) {
        message.text = text
        message.visibility = View.VISIBLE
    }

    private fun focusPassword() {
        if (!passwordField.isEnabled) return
        passwordField.requestFocus()
        passwordField.post {
            activity.getSystemService(InputMethodManager::class.java)
                ?.showSoftInput(passwordField, InputMethodManager.SHOW_IMPLICIT)
        }
    }

    private fun hideKeyboard() {
        activity.getSystemService(InputMethodManager::class.java)
            ?.hideSoftInputFromWindow(passwordField.windowToken, 0)
    }

    private fun profileNameOf(profileId: String): String? {
        val directory = StartupPaths(activity).profileDir(profileId)
        return when (val inspection = ProfileDiscovery.inspect(directory)) {
            is ProfileInspection.Valid -> inspection.profile.name
            is ProfileInspection.Damaged -> null
        }
    }
}
