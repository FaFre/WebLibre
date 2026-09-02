/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

import android.content.Context
import android.os.SystemClock
import androidx.annotation.MainThread
import androidx.annotation.VisibleForTesting
import eu.weblibre.flutter_mozilla_components.FlutterEngineCoordinator
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.feature.ContainerProxyFeature
import eu.weblibre.flutter_mozilla_components.feature.RoutingDemands
import eu.weblibre.flutter_mozilla_components.feature.RoutingResolution
import eu.weblibre.flutter_mozilla_components.feature.RoutingSnapshotStore
import eu.weblibre.flutter_mozilla_components.feature.RoutingVerdict
import kotlinx.coroutines.withTimeoutOrNull
import mozilla.components.support.base.log.logger.Logger

/** Why a launch could not be served where it was asked to be served. */
enum class BootstrapFailure {
    /**
     * Routing is known and blocked: this launch needs a proxy, and nothing in
     * the app is bringing one up. Waiting longer changes nothing — only the user
     * starting that proxy does.
     */
    ROUTE_BLOCKED,

    /**
     * The app half was still coming up when the launch stopped waiting for it.
     * Nothing is wrong; it was slow, and waiting again may well succeed.
     */
    STILL_STARTING,

    /** The app half could not be started at all. */
    ENGINE_UNAVAILABLE;

    /** Whether offering the user another wait is honest rather than hopeful. */
    val canKeepWaiting: Boolean
        get() = this == STILL_STARTING
}

/**
 * What a launch should do, and — when that is not "go ahead" — what to tell the
 * user about why.
 *
 * The failure is carried rather than logged and dropped because the two
 * unserviceable cases look nothing alike to the person who tapped the icon: one
 * is a proxy they can start, the other is a cold start that needed a few more
 * seconds. Collapsing them into a single silent diversion to the browser is
 * what made this path feel arbitrary.
 */
data class BootstrapOutcome(
    val plan: LaunchRoutingPlan,
    val failure: BootstrapFailure?,
) {
    val canProceed: Boolean get() = plan == LaunchRoutingPlan.PROCEED
}

/**
 * Brings the app half up for launches that cannot be served without it.
 *
 * A Custom Tab or PWA cold start builds `ComponentsMode.EXTERNAL` components and
 * no Flutter engine. That is enough for a context that connects directly, and
 * nothing at all for one that routes through a proxy: sing-box and Tor both run
 * inside the app process and are started from Dart, so a headless process has no
 * way to bring either up — the proxy extension blocks the launch, correctly, and
 * nothing in that process can ever unblock it. The endpoint cannot be cached
 * around either: the backends die with the process that ran them, and a
 * remembered loopback port is either dead or has been taken by some other app.
 *
 * So the app half is started — the same engine `MainActivity` hosts, without its
 * window — and the launch waits for the routing only Dart can install.
 *
 * Both entry points go through here rather than through their own copy of the
 * check: `IntentReceiverActivity` decides before it creates a session, and
 * `ExternalAppBrowserActivity` decides again when the system hands it back a
 * task whose process has since been killed.
 */
object AppHalfBootstrap {
    private val logger = Logger("AppHalfBootstrap")

    /**
     * How long the app half may make no observable progress before the launch
     * stops waiting for it.
     *
     * This, not a total deadline, is what ends a hopeless wait: a bootstrap that
     * is going to fail fails by not moving, and one that is merely slow keeps
     * reaching stages. See [BootstrapPatience].
     */
    @VisibleForTesting
    internal var stallTimeoutMs = 12_000L

    /**
     * The longest a launch waits even while the app half keeps making progress.
     *
     * The budget the proxy extension itself allows an unready store
     * (`ROUTING_WAIT_MS`, 50s): a wait that outlives that is waiting for a page
     * load the extension has already given up on, and shows a spinner over a
     * request it has already answered with its emergency break.
     */
    @VisibleForTesting
    internal var ceilingMs = 50_000L

    /** How often progress is sampled while waiting. */
    @VisibleForTesting
    internal var pollIntervalMs = 250L

    @VisibleForTesting
    internal var clock: () -> Long = SystemClock::elapsedRealtime

    /**
     * How far the app half has got, sampled from things that are observable
     * whether or not Dart is in a position to report anything.
     */
    @VisibleForTesting
    internal var stageProbe: () -> BootstrapStage = ::observedStage

    private fun observedStage(): BootstrapStage {
        // First, and for all of them. Every signal below is a record of what an
        // isolate did, and every one of them outlives the isolate that did it —
        // components and a pushed snapshot are process-global and survive the
        // engine being destroyed just as Dart's own progress does. Read after
        // them, this check could never fire once the app half had got anywhere,
        // which is precisely the case [BootstrapGiveUp.ENGINE_LOST] is for: a
        // launch waiting on a process that is gone would sit out the whole
        // stall timeout instead of failing at once.
        if (!FlutterEngineCoordinator.isRunning()) return BootstrapStage.NONE

        if (ContainerProxyFeature.hasPushedSnapshot()) return BootstrapStage.SNAPSHOT_PUSHED
        if (GlobalComponents.components != null && !GlobalComponents.isExternalMode) {
            return BootstrapStage.COMPONENTS
        }

        return maxOf(BootstrapStage.ENGINE, DartStartupProgress.stage())
    }

    /** The two routing answers a launch decision is made from. */
    private data class Inputs(
        val installed: RoutingVerdict,
        val persisted: RoutingVerdict,
        /**
         * What would have to start for this launch to be serviceable, read from
         * whichever of the two answers is in force — the installed routing when
         * the app half is here, the persisted one when it is not.
         */
        val blockedProxyIds: List<String>,
    ) {
        val plan: LaunchRoutingPlan get() = LaunchRouting.plan(installed, persisted)
    }

    private fun inputs(context: Context, contextId: String): Inputs {
        val installed = ContainerProxyFeature.installedRoutingVerdict(contextId)
        // Peeked, not bound: binding here would consume the profile-changed
        // signal that the components build hands to ContainerProxyFeature,
        // and with it the drop of the outgoing profile's cached routing.
        val persistedSnapshot = RoutingSnapshotStore.peek(context)

        return Inputs(
            installed = installed,
            persisted = RoutingResolution.verdict(persistedSnapshot, contextId),
            blockedProxyIds = when (installed) {
                // The app half is here and its own routing is the only one worth
                // reading; the seed is what this profile ran through last time.
                RoutingVerdict.UNKNOWN ->
                    RoutingResolution.blockedProxyIds(persistedSnapshot, contextId)

                else -> ContainerProxyFeature.installedBlockedProxyIds(contextId)
            },
        )
    }

    /**
     * What can be done for a launch in [contextId] as things stand, without
     * starting anything.
     */
    fun plan(context: Context, contextId: String): LaunchRoutingPlan =
        inputs(context, contextId).plan

    /**
     * Starts the app half if [contextId] needs it, waits for its routing, and
     * answers what the launch should do.
     *
     * Never answers [LaunchRoutingPlan.BOOTSTRAP]: by the time this returns the
     * bootstrap has either happened or failed, and a caller that was told to
     * start something twice would start it twice.
     *
     * [onStage] is called on the main thread with the furthest stage reached so
     * far, every poll interval, so a window doing the waiting can say which step
     * it is on. Never goes backwards, and never fires after this returns. It is
     * a report, not a decision: nothing about the wait depends on anyone
     * listening, and the default caller does not.
     */
    @MainThread
    internal suspend fun ensure(
        context: Context,
        contextId: String,
        onStage: (BootstrapStage) -> Unit = {},
    ): BootstrapOutcome {
        val initial = inputs(context, contextId)
        when (initial.plan) {
            LaunchRoutingPlan.PROCEED ->
                return BootstrapOutcome(LaunchRoutingPlan.PROCEED, failure = null)

            LaunchRoutingPlan.OPEN_IN_BROWSER -> {
                // The app half is here and says this route is blocked, which
                // used to end the launch: the only thing that starts a proxy is
                // the user, in the browser. It is also the app half — so the
                // need is handed to it and the same wait as a cold start
                // follows. Nothing to hand over (a route through a backend
                // nothing here knows) is still the end of the launch.
                if (initial.blockedProxyIds.isEmpty()) {
                    logger.info(
                        "Routing for $contextId is blocked before any wait " +
                            "(installed=${initial.installed}, persisted=${initial.persisted})",
                    )
                    return BootstrapOutcome(
                        LaunchRoutingPlan.OPEN_IN_BROWSER,
                        BootstrapFailure.ROUTE_BLOCKED,
                    )
                }

                logger.debug(
                    "Routing for $contextId is blocked; asking the app half to " +
                        "start ${initial.blockedProxyIds}",
                )
            }

            LaunchRoutingPlan.BOOTSTRAP -> logger.debug(
                "Launch in $contextId needs app-owned routing " +
                    "(persisted=${initial.persisted}); starting the app half",
            )
        }

        // Recorded before the engine is started, so a cold start reads it as
        // part of deciding what it brings up rather than having to be told
        // afterwards — there is no moment in between where the app half could
        // publish routing that calls this launch's proxy a settled block.
        RoutingDemands.record(contextId, initial.blockedProxyIds)

        // Held for the whole wait: the engine this starts is the process-wide
        // one, and a MainActivity the system destroys while this runs would
        // otherwise discard it out from under the wait, which could then only
        // ever time out.
        FlutterEngineCoordinator.retainForExternalTask()
        try {
            if (!FlutterEngineCoordinator.ensureStarted(context)) {
                logger.warn("The app half could not be started for a launch in $contextId")
                return BootstrapOutcome(
                    LaunchRoutingPlan.OPEN_IN_BROWSER,
                    BootstrapFailure.ENGINE_UNAVAILABLE,
                )
            }

            return awaitOutcomeAfterStart(
                contextId = contextId,
                persisted = initial.persisted,
                demanded = initial.blockedProxyIds,
                onStage = onStage,
            )
        } finally {
            FlutterEngineCoordinator.releaseForExternalTask()
        }
    }

    /**
     * Waits for the routing the app half installs and answers what the launch
     * should do with it, handing over any need it turns out to have that nobody
     * has been asked to meet yet.
     *
     * The wait is re-entered rather than ended on a blocked verdict because the
     * verdict is often the first thing that says *what* to start. A cold start
     * with no persisted routing has nothing to demand up front — [ensure] can
     * only record what it can read, and before the app half pushes it can read
     * nothing — so the proxy carrying this context is named for the first time
     * by the block itself. Ending there would send the user to the browser to
     * start a proxy this process had just learned the name of.
     *
     * [demanded] is what has already been handed over, and the ids rather than a
     * flag because they can disagree: [ensure]'s demand comes from the persisted
     * seed, which describes what this profile routed through *last* time, and a
     * container reassigned since blocks on a proxy nobody has been asked for.
     *
     * They decide only *whether* to hand over, never what: each demand names the
     * launch's whole need, including ids already asked for. A demand is not just
     * a request to start something, it is what makes the app half claim these
     * connections, and a claim is what keeps an endpoint-less relation publishing
     * as "coming up" rather than as a settled block. Sending only the new ids
     * would leave one whose claim has since been released resolving this context
     * to a block while the rest are still starting. Restating a running id costs
     * nothing: `ProxyDemandService` counts claims, and both starts behind it are
     * additive or join what is in flight.
     *
     * The loop is bounded because [handedOver] absorbs the whole observed set, so
     * re-entering needs an id never seen before and the ids come from one finite
     * snapshot.
     */
    @VisibleForTesting
    internal suspend fun awaitOutcomeAfterStart(
        contextId: String,
        persisted: RoutingVerdict,
        demanded: List<String>,
        onStage: (BootstrapStage) -> Unit = {},
    ): BootstrapOutcome {
        // The launch's own start, so [ceilingMs] stays a bound on the launch
        // rather than on each wait separately — see [awaitInstalledRouting].
        val startedAtMs = clock()
        var handedOver = demanded.toSet()

        while (true) {
            val installed = awaitInstalledRouting(contextId, persisted, startedAtMs, onStage)
                ?: return BootstrapOutcome(
                    LaunchRoutingPlan.OPEN_IN_BROWSER,
                    BootstrapFailure.STILL_STARTING,
                )

            val plan = LaunchRouting.plan(installed, RoutingVerdict.UNKNOWN)
            if (plan == LaunchRoutingPlan.PROCEED) {
                return BootstrapOutcome(plan, failure = null)
            }

            val blockedProxyIds = ContainerProxyFeature.installedBlockedProxyIds(contextId)
            // Nothing blocked, or nothing blocked that is not already being
            // started, is the settled answer this launch acts on.
            if (!handedOver.containsAll(blockedProxyIds)) {
                logger.debug(
                    "Routing for $contextId became blocked after bootstrap; " +
                        "asking the app half to start $blockedProxyIds",
                )
                handedOver = handedOver + blockedProxyIds
                RoutingDemands.record(contextId, blockedProxyIds)
                continue
            }

            return BootstrapOutcome(
                LaunchRoutingPlan.OPEN_IN_BROWSER,
                BootstrapFailure.ROUTE_BLOCKED,
            )
        }
    }

    /**
     * Waits for routing this process installed to cover [contextId], for as long
     * as the app half keeps making progress towards installing it. Null when the
     * wait was abandoned.
     *
     * "Cover" includes a settled block, which is an answer the launch acts on —
     * but only once the app half has had its chance at any demand recorded for
     * this launch, see [RoutingDemands.isOutstanding].
     *
     * The acknowledgement is waited for rather than polled — it is the only
     * honest signal that the app half has reached the point this launch needs,
     * see [ContainerProxyFeature.installedRoutingVerdict], which deliberately
     * does not count the seed. Progress is what is sampled, and only so the wait
     * knows whether there is still something to wait *for*; it never decides the
     * launch. Re-entering the wait each interval costs nothing: the underlying
     * state flow replays its current value to every new collector.
     *
     * [launchStartedAtMs] is when the launch began waiting, which is not when
     * *this* wait began: [awaitOutcomeAfterStart] comes back here after handing
     * over a demand. The two timeouts differ on that, and deliberately. The
     * stall clock restarts, because a demand handover is new work and judging it
     * by how long the previous wait took would abandon it before the app half
     * could act. [ceilingMs] does not, because it is not this code's patience it
     * describes — it is the extension's, and a second full ceiling would leave
     * the user watching a spinner over a request already answered with the
     * emergency break.
     */
    private suspend fun awaitInstalledRouting(
        contextId: String,
        persisted: RoutingVerdict,
        launchStartedAtMs: Long,
        onStage: (BootstrapStage) -> Unit,
    ): RoutingVerdict? {
        val startedAtMs = clock()
        val patience = BootstrapPatience(
            stallTimeoutMs = stallTimeoutMs,
            ceilingMs = ceilingMs - (startedAtMs - launchStartedAtMs),
            startedAtMs = startedAtMs,
        )

        while (true) {
            val installed = withTimeoutOrNull(pollIntervalMs) {
                ContainerProxyFeature.awaitInstalledRoutingVerdict(contextId) {
                    // A block the app half published before it could act on
                    // this launch's demand describes the state the demand was
                    // recorded *about*, not an answer to it.
                    !RoutingDemands.isOutstanding(contextId)
                }
            }
            val now = clock()

            if (installed != null) {
                logger.debug(
                    "The app half installed routing for $contextId after " +
                        "${now - launchStartedAtMs}ms: $installed",
                )
                return installed
            }

            val giveUp = patience.tick(stageProbe(), now)
            // After the tick, so what is reported is the high-water mark rather
            // than a raw observation — a component rebuild dips the probe back
            // to ENGINE, and a status line that walked backwards would read as
            // the start-up losing ground.
            onStage(patience.stage)
            if (giveUp == null) continue

            // Elapsed is the launch's, not this wait's: a CEILING give-up in a
            // wait re-entered after a handover fires on time the launch spent
            // before it, and reporting only this wait's would read as premature.
            logger.warn(
                "Gave up waiting for the app half to install routing for $contextId: " +
                    "reason=$giveUp, reached=${patience.stage}, " +
                    "elapsed=${now - launchStartedAtMs}ms, persisted=$persisted",
            )
            return null
        }
    }
}
