/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

/**
 * Global app-links behaviour, Kotlin-native mirror of the Pigeon `AppLinksMode` transport enum.
 */
enum class AppLinkMode {
    ALWAYS,
    ASK,
    NEVER,
}

enum class AppLinkRuleDecision {
    ALWAYS_OPEN,
    NEVER_OPEN,
}

/** A remembered per-scope rule (Kotlin-native mirror of the persisted/Pigeon rule model). */
data class AppLinkRule(
    val decision: AppLinkRuleDecision,
    val scope: String,
    val packageName: String?,
)

/** Non-source-tab protection pattern (§2.3), matched against the navigation target. */
data class ProtectedTargetPattern(
    val scheme: String,
    val hostOrSuffix: String,
    val includeSubdomains: Boolean,
    val port: Int?,
)

/**
 * A container's self-contained app-link policy (§ container isolation). Present only for containers
 * with "isolated app link settings" enabled; when a navigation's source contextId has an entry, its
 * [globalMode] + [rules] fully *replace* the global ones for that navigation (no layering).
 */
data class ContextAppLinkPolicy(
    val globalMode: AppLinkMode,
    val rules: Map<String, AppLinkRule>,
)

/**
 * The complete policy the classifier reads. Populated from the replicated snapshot (§2.8); the
 * classifier itself holds no Android types and no I/O.
 */
data class AppLinkPolicy(
    val globalMode: AppLinkMode,
    val rules: Map<String, AppLinkRule>,
    val marketplaceFallbackEnabled: Boolean,
    val protectGeneralContext: Boolean,
    val protectedContextIds: Set<String>,
    val strictContextIds: Set<String>,
    val protectedTargetPatterns: List<ProtectedTargetPattern>,
    /**
     * Per-container overrides keyed by contextId; only isolated containers appear. A navigation whose
     * source contextId is a key uses the entry's mode + rules instead of the global ones (replace).
     */
    val contextOverrides: Map<String, ContextAppLinkPolicy> = emptyMap(),
) {
    companion object {
        val SAFE_DEFAULT = AppLinkPolicy(
            globalMode = AppLinkMode.ASK,
            rules = emptyMap(),
            marketplaceFallbackEnabled = false,
            protectGeneralContext = false,
            protectedContextIds = emptySet(),
            strictContextIds = emptySet(),
            protectedTargetPatterns = emptyList(),
            contextOverrides = emptyMap(),
        )
    }
}

/** The prompt classes of §2.2. */
enum class AppLinkPromptKind {
    /** http(s), non-modal — the page is allowed to load while the banner is up. */
    BANNER,

    /** Unsupported scheme, modal — the navigation is genuinely stalled and there is no page. */
    MODAL,
}

/**
 * A pure decision the interceptor executes. The classifier never performs side effects.
 */
sealed interface AppLinkDecision {
    /** Return `null` from the interceptor — the engine proceeds normally. */
    data object AllowEngine : AppLinkDecision

    /** Deny the load and leave the current page unchanged. */
    data object DenyKeepPage : AppLinkDecision

    /** Return `InterceptionResponse.Url(url)` — a validated http(s) fallback. */
    data class LoadFallback(val url: String) : AppLinkDecision

    /**
     * Automatic launch (global-`always` or a remembered `alwaysOpen` rule). The interceptor calls
     * the launcher and maps its outcome per §2.7's launch-failure branches.
     */
    data class AutoLaunch(val expectedPackage: String?) : AppLinkDecision

    /**
     * Create a pending prompt request. [kind] chooses banner vs modal; the page is allowed to load
     * for a banner and denied (stalled) for a modal.
     */
    data class Prompt(
        val kind: AppLinkPromptKind,
        val canRemember: Boolean,
        val isMarketplace: Boolean,
    ) : AppLinkDecision
}

/** Everything the classifier needs, all computed by the caller so the classifier stays pure. */
data class ClassifierInput(
    val resolved: ResolvedAppLink,
    val isProtected: Boolean,
    val isPrivate: Boolean,
    val isWallet: Boolean,
    val missingSession: Boolean,
    val suppressionHit: Boolean,
    val matchingRule: AppLinkRule?,
    val globalMode: AppLinkMode,
    val marketplaceFallbackEnabled: Boolean,
)

/**
 * Pure §2.4 policy precedence over the §2.2 URL-class table. Structural guards (§2.4 step 1) and
 * navigation eligibility (step 2) are handled by the interceptor before this is consulted.
 */
object AppLinkClassifier {
    fun classify(input: ClassifierInput): AppLinkDecision {
        val resolved = input.resolved

        // Step 3 — no external app resolves.
        if (!resolved.hasExternalApp) {
            resolved.fallbackUrl?.let { return AppLinkDecision.LoadFallback(it) }
            // Step 8 — marketplace, only when enabled, mode != never, and no validated fallback.
            if (input.marketplaceFallbackEnabled &&
                input.globalMode != AppLinkMode.NEVER &&
                resolved.marketplaceIntent != null
            ) {
                return AppLinkDecision.Prompt(
                    kind = AppLinkPromptKind.MODAL,
                    canRemember = false,
                    isMarketplace = true,
                )
            }
            return if (resolved.engineSupportsScheme) {
                AppLinkDecision.AllowEngine
            } else {
                AppLinkDecision.DenyKeepPage
            }
        }

        // Step 4 — missing session cannot host a prompt: fall back to the safe non-launch behaviour.
        if (input.missingSession) {
            return safeNonLaunch(resolved)
        }

        // Step 4 — forced-prompt contexts (protected/private/wallet), ignoring matching rules.
        if (input.isProtected || input.isPrivate || input.isWallet) {
            return promptFor(resolved, canRemember = false)
        }

        // Step 5 — suppression hit: never launch, never prompt.
        if (input.suppressionHit) {
            return safeNonLaunch(resolved)
        }

        // Step 6 — a matching remembered rule for this scope.
        input.matchingRule?.let { rule ->
            when (rule.decision) {
                AppLinkRuleDecision.ALWAYS_OPEN ->
                    return AppLinkDecision.AutoLaunch(expectedPackage = rule.packageName)
                AppLinkRuleDecision.NEVER_OPEN ->
                    return neverBehaviour(resolved)
            }
        }

        // Step 7 — global mode, applied uniformly (including Custom Tabs).
        return when (input.globalMode) {
            AppLinkMode.ALWAYS -> AppLinkDecision.AutoLaunch(expectedPackage = null)
            AppLinkMode.ASK -> promptFor(resolved, canRemember = canRemember(resolved))
            AppLinkMode.NEVER -> neverBehaviour(resolved)
        }
    }

    /** The `never` row of §2.2: allow an engine-supported page; otherwise deny (+ validated fallback). */
    private fun neverBehaviour(resolved: ResolvedAppLink): AppLinkDecision {
        return if (resolved.engineSupportsScheme) {
            AppLinkDecision.AllowEngine
        } else {
            resolved.fallbackUrl?.let { AppLinkDecision.LoadFallback(it) }
                ?: AppLinkDecision.DenyKeepPage
        }
    }

    /** Suppression/missing-session: allow an engine-supported URL; else deny, using only a fallback. */
    private fun safeNonLaunch(resolved: ResolvedAppLink): AppLinkDecision {
        return if (resolved.engineSupportsScheme) {
            AppLinkDecision.AllowEngine
        } else {
            resolved.fallbackUrl?.let { AppLinkDecision.LoadFallback(it) }
                ?: AppLinkDecision.DenyKeepPage
        }
    }

    private fun promptFor(resolved: ResolvedAppLink, canRemember: Boolean): AppLinkDecision {
        val kind = if (resolved.engineSupportsScheme) {
            AppLinkPromptKind.BANNER
        } else {
            AppLinkPromptKind.MODAL
        }
        return AppLinkDecision.Prompt(kind = kind, canRemember = canRemember, isMarketplace = false)
    }

    /** Ambiguous resolution can never be remembered (§2.5). */
    private fun canRemember(resolved: ResolvedAppLink): Boolean = !resolved.isAmbiguous
}
