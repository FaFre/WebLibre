/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

/**
 * How far the app half has got, as a launch waiting on it can observe from the
 * outside.
 *
 * Ordered: every value is strictly further along than the one before it, and
 * [BootstrapPatience] relies on that to tell progress from a stall. Nothing here
 * is reported *by* the app half — these are all things about it that are already
 * observable from native, which is what keeps the wait honest even if Dart never
 * reaches the point where it could report anything.
 */
internal enum class BootstrapStage {
    /** Nothing of the app half is running. */
    NONE,

    /** The Flutter engine exists and its isolate is executing Dart. */
    ENGINE,

    /**
     * Dart's widget tree has built and its startup is talking to the profile
     * arbiter — the first thing it does that native can see.
     *
     * Load-bearing for telling two very different failures apart. Never reaching
     * it means the isolate never got as far as building anything. Reaching it
     * and going no further means the app half *started* correctly and stalled
     * somewhere in its own boot, which is a bug in that boot rather than in the
     * launch waiting on it.
     */
    ARBITRATING,

    /**
     * Dart has built the full component set, so the Gecko runtime and with it
     * the proxy extension now exist. The single longest step of a cold start,
     * and the one most likely to be mistaken for a hang.
     */
    COMPONENTS,

    /**
     * Dart has pushed a routing snapshot and is waiting for the extension to
     * confirm it. Everything after this is out of the app half's hands.
     */
    SNAPSHOT_PUSHED,
}

/** Why a launch stopped waiting for the app half. */
internal enum class BootstrapGiveUp {
    /** Nothing has moved for a while. The app half is not coming. */
    STALLED,

    /** Progress kept arriving, but the launch cannot wait forever. */
    CEILING,

    /** The engine was running and now is not — it died while we waited. */
    ENGINE_LOST,
}

/**
 * Decides how long a launch keeps waiting for the app half, from what the app
 * half has actually managed so far.
 *
 * A flat deadline cannot answer this. The work being waited on — a cold Flutter
 * start, then `GeckoRuntime.create`, then the extension install, then the first
 * routing push and its acknowledgement — takes anywhere from a couple of seconds
 * on a warm device to far longer on the first launch after an install, where ART
 * is still compiling the baseline profile in the background. A deadline generous
 * enough for the second case is one that leaves a genuinely dead bootstrap
 * hanging for the same length of time, and a deadline tight enough for the first
 * fails startups that were seconds from succeeding.
 *
 * So patience is spent on *progress* rather than on time: as long as the app
 * half keeps reaching stages, the wait continues, and it ends when nothing has
 * moved for [stallTimeoutMs]. [ceilingMs] is only a backstop for the case where
 * stages keep landing but the last one never does.
 *
 * Pure and clock-injected so the policy can be tested without a device: callers
 * pass the current time into [tick].
 */
internal class BootstrapPatience(
    private val stallTimeoutMs: Long,
    private val ceilingMs: Long,
    private val startedAtMs: Long,
) {
    /** The furthest stage observed so far. Never goes backwards — see [tick]. */
    var stage: BootstrapStage = BootstrapStage.NONE
        private set

    private var stageReachedAtMs = startedAtMs

    /**
     * Records what is observable now and answers whether to stop waiting.
     *
     * A regression to [BootstrapStage.NONE] after the engine has been seen is
     * the one observation that ends the wait immediately: the process that was
     * going to install this launch's routing has died, and no amount of further
     * waiting produces another one. Lesser regressions are ignored rather than
     * acted on — [stage] is the high-water mark — because they are the ordinary
     * shape of a component rebuild, not a failure.
     */
    fun tick(observed: BootstrapStage, nowMs: Long): BootstrapGiveUp? {
        if (stage != BootstrapStage.NONE && observed == BootstrapStage.NONE) {
            return BootstrapGiveUp.ENGINE_LOST
        }

        if (observed > stage) {
            stage = observed
            stageReachedAtMs = nowMs
        }

        if (nowMs - startedAtMs >= ceilingMs) return BootstrapGiveUp.CEILING
        if (nowMs - stageReachedAtMs >= stallTimeoutMs) return BootstrapGiveUp.STALLED

        return null
    }
}
