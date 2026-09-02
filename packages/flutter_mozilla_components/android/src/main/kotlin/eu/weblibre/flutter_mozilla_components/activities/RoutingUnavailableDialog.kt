/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.activities

import android.app.Activity
import android.content.Context
import android.net.Uri
import com.google.android.material.dialog.MaterialAlertDialogBuilder
import eu.weblibre.flutter_mozilla_components.R
import eu.weblibre.flutter_mozilla_components.startup.BootstrapFailure
import eu.weblibre.flutter_mozilla_components.startup.BootstrapStage

/**
 * What a launch that cannot be served where it was asked to be served says about
 * itself.
 *
 * Kept apart from the two things that present it — a dialog over the launcher
 * for a Custom Tab, the PWA's own window for a PWA — because the explanation is
 * the same in both and only the frame around it differs. Two copies would drift.
 *
 * Every line comes from `strings.xml`. This is the only screen some users will
 * ever see of WebLibre — a PWA that never opens the browser shows it and nothing
 * else — so it is also the last place that should be stuck in English.
 */
internal object RoutingUnavailableCopy {
    fun title(context: Context, failure: BootstrapFailure): String = context.getString(
        when (failure) {
            BootstrapFailure.ROUTE_BLOCKED -> R.string.weblibre_launch_blocked_title
            BootstrapFailure.STILL_STARTING -> R.string.weblibre_launch_slow_title
            BootstrapFailure.ENGINE_UNAVAILABLE -> R.string.weblibre_launch_failed_title
        },
    )

    /**
     * Says the same three things in the same order for every failure: what this
     * launch needs, what the state of that is, and what each option will do
     * about it.
     *
     * The last part is not padding. Opening the browser is the option that used
     * to happen silently, and the reason it is worth choosing — the browser is
     * where the prompt to start a proxy lives — is exactly what was never
     * visible.
     */
    fun message(context: Context, failure: BootstrapFailure, subject: String): String =
        context.getString(
            when (failure) {
                BootstrapFailure.ROUTE_BLOCKED -> R.string.weblibre_launch_blocked_message
                BootstrapFailure.STILL_STARTING -> R.string.weblibre_launch_slow_message
                BootstrapFailure.ENGINE_UNAVAILABLE -> R.string.weblibre_launch_failed_message
            },
            subject,
        )

    /**
     * The headline while waiting.
     *
     * Deliberately not the host. The host is what the user already knows they
     * tapped; a window showing it and a spinner says only "something is
     * happening to the thing you asked for", which is the state this screen
     * exists to stop being. What it says instead is *why* there is a wait at
     * all — the host is a line below, in the explanation, where it has a
     * sentence around it.
     */
    fun waitingTitle(context: Context): String =
        context.getString(R.string.weblibre_launch_waiting_title)

    fun waitingMessage(context: Context, launchUrl: String?): String {
        val host = hostOf(launchUrl)
            ?: return context.getString(R.string.weblibre_launch_waiting_message_generic)

        return context.getString(R.string.weblibre_launch_waiting_message, "“$host”")
    }

    /**
     * The step the app half has actually reached.
     *
     * A spinner alone cannot tell a start-up that is working from one that is
     * stuck, and this wait can honestly run for the better part of a minute on a
     * first launch after an update. Naming the step is what makes the difference
     * visible without promising a duration nothing here can predict.
     */
    fun stepMessage(context: Context, stage: BootstrapStage): String = context.getString(
        when (stage) {
            BootstrapStage.NONE, BootstrapStage.ENGINE -> R.string.weblibre_launch_step_starting
            BootstrapStage.ARBITRATING -> R.string.weblibre_launch_step_preparing
            BootstrapStage.COMPONENTS -> R.string.weblibre_launch_step_browser
            BootstrapStage.SNAPSHOT_PUSHED -> R.string.weblibre_launch_step_routing
        },
    )

    /**
     * What to call the thing being launched.
     *
     * The host, when there is one: it is the only part of a launch the user
     * recognises as the app or page they tapped. Everything else falls back to a
     * description of the kind of launch, never to the raw URL — a Custom Tab URL
     * can be arbitrarily long and would push the actual explanation off screen.
     */
    fun subject(launchUrl: String?, isStandaloneApp: Boolean): String {
        val host = hostOf(launchUrl)
        if (host != null) return "“$host”"

        return if (isStandaloneApp) "This app" else "This link"
    }

    fun hostOf(launchUrl: String?): String? = launchUrl
        ?.let { runCatching { Uri.parse(it).host }.getOrNull() }
        ?.removePrefix("www.")
        ?.takeIf { it.isNotEmpty() }
}

/**
 * Ends an unserviceable Custom Tab launch in a choice rather than a
 * substitution.
 *
 * This exists because the alternative — quietly opening the ordinary browser —
 * is indistinguishable from a bug. Someone taps a link, waits, and gets a
 * browser window: nothing on screen connects that to the proxy their container
 * routes through, and a browser they did not ask for looks like the app
 * forgetting what it was doing. The diversion is still the right *option*; it
 * was only ever wrong as a decision made for them.
 *
 * The emphasised button is whichever one gets the user what they actually asked
 * for: trying again, when the app half was merely slow and another wait would
 * plausibly finish it; the browser, when the proxy is not running and only the
 * browser can offer to start it.
 */
internal object RoutingUnavailableDialog {
    /**
     * [onTryAgain] is offered only when the failure is one more waiting could
     * fix *and* the caller can actually wait again; passing null means the caller
     * cannot, and the option is dropped rather than shown and disappointed.
     */
    fun show(
        activity: Activity,
        failure: BootstrapFailure,
        launchUrl: String?,
        isStandaloneApp: Boolean,
        onTryAgain: (() -> Unit)?,
        onOpenInBrowser: () -> Unit,
        onCancel: () -> Unit,
    ) {
        val builder = MaterialAlertDialogBuilder(activity)
            .setTitle(RoutingUnavailableCopy.title(activity, failure))
            .setMessage(
                RoutingUnavailableCopy.message(
                    activity,
                    failure,
                    RoutingUnavailableCopy.subject(launchUrl, isStandaloneApp),
                ),
            )
            .setNegativeButton(R.string.weblibre_launch_action_cancel) { _, _ -> onCancel() }
            .setOnCancelListener { onCancel() }

        val tryAgain = onTryAgain.takeIf { failure.canKeepWaiting }
        if (tryAgain != null) {
            builder
                .setPositiveButton(R.string.weblibre_launch_action_try_again) { _, _ -> tryAgain() }
                .setNeutralButton(R.string.weblibre_launch_action_open_in_browser) { _, _ ->
                    onOpenInBrowser()
                }
        } else {
            builder.setPositiveButton(R.string.weblibre_launch_action_open_in_browser) { _, _ ->
                onOpenInBrowser()
            }
        }

        builder.show()
    }
}
