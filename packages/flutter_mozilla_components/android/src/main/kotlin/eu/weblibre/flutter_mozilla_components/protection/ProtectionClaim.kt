/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.protection

import org.json.JSONObject

/** Who is claiming control of a parameter. */
sealed interface ProtectionSource {
    /** The app's own settings screen. */
    data object AppSettings : ProtectionSource

    /** An installed extension, identified by its Gecko id. */
    data class Extension(val id: String) : ProtectionSource

    val label: String
        get() = when (this) {
            is AppSettings -> "settings"
            is Extension -> id
        }
}

/**
 * A declaration that one source controls one parameter.
 *
 * [value] is optional: an extension that randomises a surface per origin has no
 * single value to declare, and a null value means "this source controls it"
 * rather than "this source sets it to null". Conflicts are only reported as
 * contested when two sources declare different non-null values.
 */
data class ProtectionClaim(
    val source: ProtectionSource,
    val parameter: ProtectionParameter,
    val value: String? = null,
)

/**
 * What a protection extension declares it controls, read from the
 * `weblibre_protection` object in its manifest.
 *
 * ```json
 * "weblibre_protection": {
 *   "parameters": ["userAgent", "platform", "screen", ...],
 *   "profile": "android-chrome-pixel8"
 * }
 * ```
 *
 * The declaration is how the app learns, without guessing, which surfaces an
 * extension is going to move. An extension that declares nothing is not
 * monitored, which is the honest outcome: the app cannot infer a third-party
 * extension's intent from its code.
 */
data class ProtectionDeclaration(
    val extensionId: String,
    val parameters: Set<ProtectionParameter>,
    val profile: String?,
) {
    /** The clusters this declaration only partially covers. */
    fun incompleteClusters(): Map<Set<ProtectionParameter>, Set<ProtectionParameter>> {
        val result = mutableMapOf<Set<ProtectionParameter>, Set<ProtectionParameter>>()
        for (parameter in parameters) {
            val cluster = ProtectionCoherence.clusterOf(parameter)
            val missing = cluster - parameters
            if (missing.isNotEmpty()) {
                result[cluster] = (result[cluster] ?: emptySet()) + missing
            }
        }
        return result
    }

    companion object {
        const val MANIFEST_KEY = "weblibre_protection"

        /** Parse a declaration out of a manifest, or null if it declares none. */
        fun parse(extensionId: String, manifestJson: String): ProtectionDeclaration? {
            return try {
                val block = JSONObject(manifestJson).optJSONObject(MANIFEST_KEY)
                    ?: return null
                val array = block.optJSONArray("parameters") ?: return null

                val parameters = mutableSetOf<ProtectionParameter>()
                for (index in 0 until array.length()) {
                    ProtectionParameter.fromId(array.optString(index))?.let(parameters::add)
                }
                if (parameters.isEmpty()) return null

                ProtectionDeclaration(
                    extensionId = extensionId,
                    parameters = parameters,
                    profile = block.optString("profile").takeIf { it.isNotEmpty() },
                )
            } catch (e: Exception) {
                // A malformed declaration is not a reason to refuse the
                // extension; it just means this extension is not monitored.
                null
            }
        }
    }
}
