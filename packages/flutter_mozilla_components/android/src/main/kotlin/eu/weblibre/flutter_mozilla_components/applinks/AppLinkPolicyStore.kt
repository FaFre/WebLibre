/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import eu.weblibre.flutter_mozilla_components.ProfileContext
import mozilla.components.support.base.log.logger.Logger
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.atomic.AtomicReference

/**
 * Process-level registry of profile-scoped [AppLinkPolicyStore] singletons
 * (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md §2.10). Keyed only by native's canonical
 * [ProfileContext.relativePath]; created on first use, torn down on profile
 * replacement. Survives `GlobalComponents.setUp()` replacing the `Components`.
 */
object AppLinkPolicyStores {
    private val stores = ConcurrentHashMap<String, AppLinkPolicyStore>()

    fun forProfile(profileContext: ProfileContext): AppLinkPolicyStore {
        return stores.getOrPut(profileContext.relativePath) {
            AppLinkPolicyStore(profileContext)
        }
    }

    /** Remove a torn-down profile's store (profile replacement/deletion). */
    fun remove(relativePath: String) {
        stores.remove(relativePath)
    }
}

/**
 * The only policy source in `ComponentsMode.EXTERNAL` and before Flutter attaches.
 * Holds the classifier [AppLinkPolicy] in an [AtomicReference] backed by a single
 * profile-scoped SharedPreferences record. Writes persist synchronously
 * (`commit()`) and publish the new reference only after durable success. There is
 * exactly one writer (the Dart replicator via `setAppLinkPolicy`).
 */
class AppLinkPolicyStore internal constructor(
    private val context: Context,
) {
    private val logger = Logger("AppLinkPolicyStore")
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
    private val reference = AtomicReference(loadOrSeed())

    val policy: AppLinkPolicy
        get() = reference.get()

    /**
     * Persist [policy] durably, then publish it. Serialised so concurrent writers
     * cannot interleave a half-written record with a published reference.
     */
    @Synchronized
    fun setPolicy(policy: AppLinkPolicy): Boolean {
        val json = encode(policy, migrated = true)
        val committed = prefs.edit().putString(KEY_SNAPSHOT, json).commit()
        if (!committed) {
            logger.error("failed to persist app-link policy; keeping previous snapshot")
            return false
        }
        reference.set(policy)
        return true
    }

    private fun loadOrSeed(): AppLinkPolicy {
        val stored = prefs.getString(KEY_SNAPSHOT, null)
        if (stored != null) {
            runCatching { return decode(stored) }
                .onFailure { logger.error("corrupt app-link policy record; reseeding", it) }
        }
        // Seed the safe default (globalMode = ASK): the seed carries no protected-context data (that
        // is computed in Dart and arrives only with the first replicated snapshot), so it must never
        // auto-launch — an `ALWAYS` seed would leak links out of proxied/strict containers and cold
        // Custom Tabs before protection is known. The legacy AC "open links in apps" preference is
        // deliberately not migrated (a de-Googled browser resets to the safe ASK default; the user
        // re-sets it in Settings), so the seed does not read it.
        val seeded = AppLinkPolicy.SAFE_DEFAULT
        val committed = prefs.edit().putString(KEY_SNAPSHOT, encode(seeded, migrated = true)).commit()
        if (!committed) {
            logger.error("failed to persist seeded app-link policy; using defaults in memory")
        }
        return seeded
    }

    private fun encode(policy: AppLinkPolicy, migrated: Boolean): String {
        val root = JSONObject()
        root.put(FIELD_MIGRATED, migrated)
        root.put(FIELD_GLOBAL_MODE, policy.globalMode.name)
        root.put(FIELD_MARKETPLACE, policy.marketplaceFallbackEnabled)
        root.put(FIELD_AUTH_EXCEPTIONS, policy.authExceptionsEnabled)
        root.put(FIELD_PROTECT_GENERAL, policy.protectGeneralContext)
        root.put(FIELD_PROTECTED_CONTEXTS, JSONArray(policy.protectedContextIds.toList()))
        root.put(FIELD_STRICT_CONTEXTS, JSONArray(policy.strictContextIds.toList()))

        root.put(FIELD_RULES, encodeRules(policy.rules))

        val overrides = JSONObject()
        for ((contextId, override) in policy.contextOverrides) {
            overrides.put(
                contextId,
                JSONObject()
                    .put(FIELD_OVERRIDE_MODE, override.globalMode.name)
                    .put(FIELD_RULES, encodeRules(override.rules)),
            )
        }
        root.put(FIELD_CONTEXT_OVERRIDES, overrides)

        val patterns = JSONArray()
        for (pattern in policy.protectedTargetPatterns) {
            patterns.put(
                JSONObject()
                    .put(FIELD_PATTERN_SCHEME, pattern.scheme)
                    .put(FIELD_PATTERN_HOST, pattern.hostOrSuffix)
                    .put(FIELD_PATTERN_SUBDOMAINS, pattern.includeSubdomains)
                    .putOpt(FIELD_PATTERN_PORT, pattern.port),
            )
        }
        root.put(FIELD_PATTERNS, patterns)
        return root.toString()
    }

    private fun encodeRules(rules: Map<String, AppLinkRule>): JSONObject {
        val obj = JSONObject()
        for ((scope, rule) in rules) {
            obj.put(
                scope,
                JSONObject()
                    .put(FIELD_RULE_DECISION, rule.decision.name)
                    .put(FIELD_RULE_SCOPE, rule.scope)
                    .putOpt(FIELD_RULE_PACKAGE, rule.packageName),
            )
        }
        return obj
    }

    private fun decode(json: String): AppLinkPolicy {
        val root = JSONObject(json)

        val rules = decodeRules(root.optJSONObject(FIELD_RULES))

        val contextOverrides = mutableMapOf<String, ContextAppLinkPolicy>()
        root.optJSONObject(FIELD_CONTEXT_OVERRIDES)?.let { obj ->
            for (contextId in obj.keys()) {
                val overrideJson = obj.getJSONObject(contextId)
                contextOverrides[contextId] = ContextAppLinkPolicy(
                    globalMode = AppLinkMode.valueOf(overrideJson.getString(FIELD_OVERRIDE_MODE)),
                    rules = decodeRules(overrideJson.optJSONObject(FIELD_RULES)),
                )
            }
        }

        val patterns = mutableListOf<ProtectedTargetPattern>()
        root.optJSONArray(FIELD_PATTERNS)?.let { arr ->
            for (i in 0 until arr.length()) {
                val p = arr.getJSONObject(i)
                patterns.add(
                    ProtectedTargetPattern(
                        scheme = p.getString(FIELD_PATTERN_SCHEME),
                        hostOrSuffix = p.getString(FIELD_PATTERN_HOST),
                        includeSubdomains = p.getBoolean(FIELD_PATTERN_SUBDOMAINS),
                        port = if (p.has(FIELD_PATTERN_PORT) && !p.isNull(FIELD_PATTERN_PORT)) {
                            p.getInt(FIELD_PATTERN_PORT)
                        } else {
                            null
                        },
                    ),
                )
            }
        }

        return AppLinkPolicy(
            globalMode = AppLinkMode.valueOf(root.getString(FIELD_GLOBAL_MODE)),
            rules = rules,
            marketplaceFallbackEnabled = root.optBoolean(FIELD_MARKETPLACE, false),
            authExceptionsEnabled = root.optBoolean(FIELD_AUTH_EXCEPTIONS, true),
            protectGeneralContext = root.optBoolean(FIELD_PROTECT_GENERAL, false),
            protectedContextIds = root.optJSONArray(FIELD_PROTECTED_CONTEXTS).toStringSet(),
            strictContextIds = root.optJSONArray(FIELD_STRICT_CONTEXTS).toStringSet(),
            protectedTargetPatterns = patterns,
            contextOverrides = contextOverrides,
        )
    }

    private fun decodeRules(obj: JSONObject?): Map<String, AppLinkRule> {
        if (obj == null) return emptyMap()
        val rules = mutableMapOf<String, AppLinkRule>()
        for (scope in obj.keys()) {
            val ruleJson = obj.getJSONObject(scope)
            rules[scope] = AppLinkRule(
                decision = AppLinkRuleDecision.valueOf(ruleJson.getString(FIELD_RULE_DECISION)),
                scope = ruleJson.getString(FIELD_RULE_SCOPE),
                packageName = ruleJson.optStringOrNull(FIELD_RULE_PACKAGE),
            )
        }
        return rules
    }

    private fun JSONObject.optStringOrNull(key: String): String? =
        if (has(key) && !isNull(key)) getString(key) else null

    private fun JSONArray?.toStringSet(): Set<String> {
        if (this == null) return emptySet()
        val out = LinkedHashSet<String>(length())
        for (i in 0 until length()) {
            out.add(getString(i))
        }
        return out
    }

    companion object {
        const val PREFS_NAME = "weblibre_app_link_policy"
        private const val KEY_SNAPSHOT = "snapshot"

        private const val FIELD_MIGRATED = "migrated"
        private const val FIELD_GLOBAL_MODE = "globalMode"
        private const val FIELD_MARKETPLACE = "marketplaceFallbackEnabled"
        private const val FIELD_AUTH_EXCEPTIONS = "authExceptionsEnabled"
        private const val FIELD_PROTECT_GENERAL = "protectGeneralContext"
        private const val FIELD_PROTECTED_CONTEXTS = "protectedContextIds"
        private const val FIELD_STRICT_CONTEXTS = "strictContextIds"
        private const val FIELD_RULES = "rules"
        private const val FIELD_RULE_DECISION = "decision"
        private const val FIELD_RULE_SCOPE = "scope"
        private const val FIELD_RULE_PACKAGE = "packageName"
        private const val FIELD_CONTEXT_OVERRIDES = "contextOverrides"
        private const val FIELD_OVERRIDE_MODE = "mode"
        private const val FIELD_PATTERNS = "protectedTargetPatterns"
        private const val FIELD_PATTERN_SCHEME = "scheme"
        private const val FIELD_PATTERN_HOST = "hostOrSuffix"
        private const val FIELD_PATTERN_SUBDOMAINS = "includeSubdomains"
        private const val FIELD_PATTERN_PORT = "port"
    }
}
