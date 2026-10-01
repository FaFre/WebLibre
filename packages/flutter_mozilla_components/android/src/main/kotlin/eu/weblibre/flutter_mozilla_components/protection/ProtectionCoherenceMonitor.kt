/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.protection

import mozilla.components.support.base.log.logger.Logger
import org.json.JSONArray
import org.json.JSONObject
import org.mozilla.geckoview.GeckoRuntime

/**
 * Publishes what the installed protection extensions claim to control, so the
 * settings screen can tell whether it and an extension are about to fight over
 * the same fingerprint surface.
 *
 * The problem this exists for is coherence. WebLibre's protection is spread
 * across the settings screen (which sets engine prefs) and the built-in
 * extensions (which inject script). Nothing stops a privacy extension from
 * changing the User-Agent while the settings keep the screen metrics, and the
 * resulting combination — a Pixel 8 UA on a device reporting some other screen
 * — is a more identifying fingerprint than either half on its own.
 *
 * This object deliberately stops at publishing. The settings screen owns the
 * app's protection parameters and the switches, so it is the only place that
 * can decide what conflicts with what and what to do about it. It reads the
 * declarations from [PREF_DECLARATIONS] and does the rest.
 *
 * The publication is a JSON string in the Gecko pref space, which is the
 * channel the settings screen already reads, so no new bridge surface is
 * needed. Only the pref *setter* is used: this layer has no synchronous pref
 * read to depend on.
 */
object ProtectionCoherenceMonitor {

    private val logger = Logger("ProtectionCoherenceMonitor")

    /** Whether the settings screen watches for conflicts. Owned by the screen. */
    const val PREF_MONITOR = "weblibre.protection.monitor_extension_conflicts"

    /** Whether the settings screen adopts an extension's change wholesale. */
    const val PREF_FOLLOW = "weblibre.protection.follow_extension_conflicts"

    /**
     * JSON array of what each declared extension controls, one object per
     * extension:
     *
     * ```json
     * [{ "extensionId": "...",
     *    "parameters": ["userAgent", "platform", ...],
     *    "profile": "android-chrome" | null,
     *    "incompleteClusters": [
     *      { "cluster": "device-identity",
     *        "declared": ["platform"],
     *        "missing": ["screen", "devicePixelRatio", ...] } ] }]
     * ```
     *
     * `incompleteClusters` is precomputed here because the cluster definitions
     * live in [ProtectionCoherence], and the settings screen should not have to
     * duplicate them to find out that an extension moved half of a device
     * identity.
     */
    const val PREF_DECLARATIONS = "weblibre.protection.extension_declarations"

    private val declarations = mutableMapOf<String, ProtectionDeclaration>()

    // -------------------------------------------------------------------------
    // Registration
    // -------------------------------------------------------------------------

    /** Record what an extension controls. Replaces any earlier declaration. */
    fun declare(declaration: ProtectionDeclaration) {
        declarations[declaration.extensionId] = declaration
    }

    /** Forget an extension, e.g. when it is removed or disabled. */
    fun undeclare(extensionId: String) {
        declarations.remove(extensionId)
    }

    fun declarations(): List<ProtectionDeclaration> = declarations.values.toList()

    /** Test/reset hook. */
    fun reset() {
        declarations.clear()
    }

    // -------------------------------------------------------------------------
    // Publication
    // -------------------------------------------------------------------------

    /**
     * Publish the current declarations to Gecko prefs.
     *
     * Called when an extension is installed, removed, enabled or disabled.
     * Publishing is unconditional: the settings screen reads the pref to decide
     * what to show, and a stale pref would be worse than an empty one.
     */
    fun refresh(runtime: GeckoRuntime) {
        runtime.settings.setString(PREF_DECLARATIONS, toJson())

        val incomplete = declarations.values.count { it.incompleteClusters().isNotEmpty() }
        if (incomplete > 0) {
            logger.info("$incomplete protection extension(s) declare a partial cluster")
        }
    }

    private fun toJson(): String {
        val array = JSONArray()
        for (declaration in declarations.values) {
            array.put(
                JSONObject().apply {
                    put("extensionId", declaration.extensionId)
                    put("parameters", JSONArray(declaration.parameters.map { it.id }.sorted()))
                    put("profile", declaration.profile ?: JSONObject.NULL)
                    put("incompleteClusters", incompleteClustersJson(declaration))
                },
            )
        }
        return array.toString()
    }

    private fun incompleteClustersJson(declaration: ProtectionDeclaration): JSONArray {
        val array = JSONArray()
        for ((cluster, missing) in declaration.incompleteClusters()) {
            val declared = cluster.intersect(declaration.parameters)
            if (declared.isEmpty()) continue
            array.put(
                JSONObject().apply {
                    val anchor = declared.minByOrNull { it.id } ?: return@apply
                    put("cluster", ProtectionCoherence.clusterName(anchor))
                    put("declared", JSONArray(declared.map { it.id }.sorted()))
                    put("missing", JSONArray(missing.map { it.id }.sorted()))
                },
            )
        }
        return array
    }
}
