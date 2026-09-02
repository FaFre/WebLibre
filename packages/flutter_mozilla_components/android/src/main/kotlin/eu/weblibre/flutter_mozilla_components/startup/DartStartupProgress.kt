/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.startup

import android.util.Log

/**
 * How far the Dart half of a starting app has got, recorded from the calls it
 * already makes.
 *
 * A launch waiting on the app half could previously see two things: an engine
 * exists, and full components exist. Everything between them — a Dart isolate
 * running `main`, building its widget tree, arbitrating a profile, opening
 * databases, reaching `GeckoBrowserService.initialize` — was one opaque gap, and
 * a bootstrap that died anywhere inside it looked exactly like one that was
 * merely slow. That gap is most of a cold start.
 *
 * Nothing is reported for its own sake: these are calls Dart makes anyway,
 * noted as they pass. So the record stays honest even for a Dart half that never
 * gets far enough to say anything about itself, which is precisely the case
 * worth telling apart.
 *
 * Process-global and monotonic, reset only when an engine is created or
 * discarded — a new isolate starts its own cold start, and carrying the old
 * one's progress into it would report a stage that nothing has reached.
 */
internal object DartStartupProgress {
    private const val TAG = "DartStartupProgress"

    @Volatile
    private var reached: BootstrapStage = BootstrapStage.NONE

    fun record(stage: BootstrapStage) {
        if (stage <= reached) return

        reached = stage
        Log.d(TAG, "The app half reached $stage")
    }

    fun stage(): BootstrapStage = reached

    fun reset() {
        if (reached == BootstrapStage.NONE) return

        Log.d(TAG, "Forgetting app-half progress (was $reached)")
        reached = BootstrapStage.NONE
    }
}
