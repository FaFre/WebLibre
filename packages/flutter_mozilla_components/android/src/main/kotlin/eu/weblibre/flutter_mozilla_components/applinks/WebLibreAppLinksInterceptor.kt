/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.net.toUri
import eu.weblibre.flutter_mozilla_components.Components
import eu.weblibre.flutter_mozilla_components.GlobalComponents
import eu.weblibre.flutter_mozilla_components.ext.EventSequence
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPromptOwner
import mozilla.components.browser.state.selector.findTabOrCustomTab
import mozilla.components.browser.state.state.CustomTabSessionState
import mozilla.components.browser.state.state.SessionState
import mozilla.components.concept.engine.EngineSession
import mozilla.components.concept.engine.request.RequestInterceptor
import mozilla.components.support.base.log.logger.Logger
import mozilla.components.support.ktx.kotlin.tryGetHostFromUrl
import java.util.Locale

/**
 * The WebLibre-owned §2.4 interception tail (APP_LINKS_OWN_IMPLEMENTATION_PLAN.md Phase 5). Replaces
 * Mozilla AC's `AppLinksInterceptor` + `AppLinksFeature` + `AppLinksCancelRetryMiddleware` on the
 * synchronous `RequestInterceptor.onLoadRequest` path.
 *
 * Structural guards (PWA/TWA, sandbox capture, `weblibre://`, FxA) already ran in
 * [eu.weblibre.flutter_mozilla_components.interceptor.AppRequestInterceptor] before this is called;
 * this tail owns steps 2–8: navigation eligibility, resolution/sanitisation ([ExternalAppResolver]),
 * the pure [AppLinkClassifier] decision, and its execution (auto-launch, validated fallback, or a
 * pending prompt). Policy comes from the profile-scoped [AppLinkPolicyStore]; prompts land in the
 * profile-scoped [PendingAppLinkStore]. It never denies a load and re-issues the same load.
 */
class WebLibreAppLinksInterceptor(
    private val context: Context,
) {
    private val logger = Logger("WebLibreAppLinks")
    private val runtime get() = AppLinkRuntime.get(context)

    /**
     * @return the interception response, or `null` to let the engine proceed. Creating a pending
     * prompt is a side effect performed here; the return value only controls the current load.
     */
    fun onLoadRequest(
        engineSession: EngineSession,
        uri: String,
        lastUri: String?,
        hasUserGesture: Boolean,
        isRedirect: Boolean,
        isDirectNavigation: Boolean,
        isSubframeRequest: Boolean,
    ): RequestInterceptor.InterceptionResponse? {
        val components = GlobalComponents.components ?: return null

        val uriScheme = runCatching { uri.toUri().scheme }.getOrNull()
        val engineSupportsScheme = AppLinkSchemes.isEngineSupported(uriScheme)
        val session = components.core.store.state.findTabOrCustomTab(engineSession)
        val policy = AppLinkPolicyStores.forProfile(components.profileApplicationContext).policy

        // A tab an external app opened for us (Custom Tab / ActionView) may be hosting a sign-in
        // round trip. Gated on the policy so turning the carve-out off restores the plain §2.4
        // eligibility rules rather than only skipping the launch below.
        val authExceptionsAllowed = policy.authExceptionsEnabled && isPossibleAuthentication(session)
        val isSameDomainNavigation = isSameDomain(lastUri, uri)

        // Step 2 — navigation eligibility. Any hit lets the engine proceed normally.
        if (!isEligible(
                uriScheme,
                engineSupportsScheme,
                hasUserGesture,
                isRedirect,
                isDirectNavigation,
                isSubframeRequest,
                isSameDomainNavigation,
                authExceptionsAllowed,
            )
        ) {
            return null
        }

        val pendingStore = pendingStoreFor(components)

        // Fallback re-entry guard (§2.7): a fallback we issued has come back around. Keep it in the
        // browser — never let it bounce out to an app. Consulted before resolution/classification.
        if (pendingStore.isFallbackReentry(canonicalReentryKey(uri))) {
            return null
        }

        val resolved = runtime.resolver.resolve(uri, includeHttpAppLinks = true, useCache = true)

        // Container isolation (replace semantics): a container with "isolated app link settings"
        // enabled contributes an entry keyed by its contextId. When the source tab's contextId has
        // one, its mode + rules fully replace the global ones for this navigation.
        val override = session?.contextId?.let { policy.contextOverrides[it] }
        val effectiveMode = override?.globalMode ?: policy.globalMode
        val effectiveRules = override?.rules ?: policy.rules

        val isProtectedNavigation = isProtected(policy, session, uri)
        val isPrivateNavigation = session?.content?.private ?: false
        val isWalletNavigation = AppLinkSchemes.isWallet(resolved.originalScheme) ||
            AppLinkSchemes.isWallet(resolved.intentDataScheme)

        // An ambiguous resolution is never treated as a callback: with several handlers we cannot
        // show the caller *is* the target, and the launch would raise a chooser rather than return
        // to the app. AC declines here too — its package comes from the bound component, which is
        // only set for an unambiguous handler.
        val authTargetPackage = if (resolved.isAmbiguous) null else resolved.packageName
        val isAuthCallback = isAuthenticationCallback(session, authTargetPackage)

        // Re-apply the same-domain guard now that the target is known (AC parity: `AppLinksInterceptor`
        // re-checks after resolution for exactly this reason). Eligibility waived it on the mere
        // possibility of a sign-in round trip — the tab was opened by *some* app — which would
        // otherwise re-classify every ordinary in-site navigation for the whole life of a Custom Tab
        // and, under the default `ask` mode, prompt on each one. Only a navigation that really does
        // target the calling app keeps the waiver.
        if (engineSupportsScheme && isSameDomainNavigation && authExceptionsAllowed && !isAuthCallback) {
            return null
        }

        val matchingRule = effectiveRules[resolved.scopeKey]
        val fingerprint = targetFingerprint(uri, resolved)
        val suppressionHit = session != null && pendingStore.isSuppressed(session.id, fingerprint)

        // §2.4 authentication carve-out (AC parity): a tab opened *by* the app the navigation
        // targets is a sign-in round trip rather than a general app link, so it returns to its
        // caller even under `never`. The forced-prompt contexts still win — a protected container,
        // a private tab or a wallet scheme must not leak out silently, so those fall through to the
        // classifier, which prompts for them regardless of mode (§2.4 step 4). An explicit
        // `neverOpen` rule for this scope and a live suppression are the user having answered this
        // exact question already (classifier steps 5–6); the carve-out is about a mode the user set
        // for links in general, not a licence to override a specific "no".
        if (authExceptionsAllowed &&
            isAuthCallback &&
            !isProtectedNavigation && !isPrivateNavigation && !isWalletNavigation &&
            matchingRule?.decision != AppLinkRuleDecision.NEVER_OPEN &&
            !suppressionHit
        ) {
            val result = runtime.launcher.launch(
                uri,
                AppLinkLaunchMode.AUTHENTICATION,
                expectedPackage = authTargetPackage,
            )
            logger.info(
                "auth app-link callback uri=$uri tab=${session?.id} " +
                    "caller=${callerPackage(session)} package=$authTargetPackage -> $result",
            )
            return if (result == AppLinkLaunchResult.LAUNCHED) {
                RequestInterceptor.InterceptionResponse.Deny
            } else {
                safeNonLaunchResponse(pendingStore, resolved)
            }
        }

        val input = ClassifierInput(
            resolved = resolved,
            isProtected = isProtectedNavigation,
            isPrivate = isPrivateNavigation,
            isWallet = isWalletNavigation,
            missingSession = session == null,
            suppressionHit = suppressionHit,
            matchingRule = matchingRule,
            globalMode = effectiveMode,
            marketplaceFallbackEnabled = policy.marketplaceFallbackEnabled,
        )

        val decision = AppLinkClassifier.classify(input)
        logger.info(
            "classify uri=$uri tab=${session?.id} ctx=${session?.contextId} " +
                "isolated=${override != null} hasApp=${resolved.hasExternalApp} " +
                "engineScheme=${resolved.engineSupportsScheme} mode=${input.globalMode} " +
                "protected=${input.isProtected} private=${input.isPrivate} wallet=${input.isWallet} " +
                "suppressed=${input.suppressionHit} rule=${input.matchingRule?.decision} -> $decision",
        )
        return execute(decision, components, pendingStore, session, uri, lastUri, input, hasUserGesture)
    }

    private fun execute(
        decision: AppLinkDecision,
        components: Components,
        pendingStore: PendingAppLinkStore,
        session: SessionState?,
        uri: String,
        lastUri: String?,
        input: ClassifierInput,
        hasUserGesture: Boolean,
    ): RequestInterceptor.InterceptionResponse? {
        val resolved = input.resolved
        return when (decision) {
            is AppLinkDecision.AllowEngine -> null

            is AppLinkDecision.DenyKeepPage -> RequestInterceptor.InterceptionResponse.Deny

            is AppLinkDecision.LoadFallback -> {
                pendingStore.recordFallbackReentry(canonicalReentryKey(decision.url))
                RequestInterceptor.InterceptionResponse.Url(decision.url)
            }

            is AppLinkDecision.AutoLaunch -> {
                val result = runtime.launcher.launch(
                    uri,
                    AppLinkLaunchMode.AUTOMATIC,
                    decision.expectedPackage,
                )
                when (result) {
                    AppLinkLaunchResult.LAUNCHED -> RequestInterceptor.InterceptionResponse.Deny

                    // A remembered `alwaysOpen` rule whose package no longer resolves must not
                    // silently launch a different app: fall through to a prompt (§2.5). Reclassify
                    // once with the rule removed so the global mode decides.
                    AppLinkLaunchResult.PACKAGE_MISMATCH -> {
                        val withoutRule = input.copy(matchingRule = null)
                        execute(
                            AppLinkClassifier.classify(withoutRule),
                            components, pendingStore, session, uri, lastUri, withoutRule, hasUserGesture,
                        )
                    }

                    // Launch failed/cooldown: answer in the original callback (§2.7). Never deny an
                    // engine-supported original and reload it — return null so it loads once.
                    else -> when {
                        resolved.engineSupportsScheme -> null
                        resolved.fallbackUrl != null -> {
                            pendingStore.recordFallbackReentry(canonicalReentryKey(resolved.fallbackUrl))
                            RequestInterceptor.InterceptionResponse.Url(resolved.fallbackUrl)
                        }
                        else -> RequestInterceptor.InterceptionResponse.Deny
                    }
                }
            }

            is AppLinkDecision.Prompt -> {
                // A missing session cannot host a prompt; the classifier never reaches Prompt in that
                // case, so `session` is non-null here.
                val tab = session ?: return safeNonLaunchResponse(pendingStore, resolved)
                createPrompt(pendingStore, tab, uri, lastUri, input, decision, hasUserGesture)
                if (decision.kind == AppLinkPromptKind.BANNER) {
                    // Engine-supported: allow the page to load while the non-modal banner is up.
                    null
                } else {
                    // Unsupported scheme (or marketplace): the navigation is stalled, no page to show.
                    RequestInterceptor.InterceptionResponse.Deny
                }
            }
        }
    }

    private fun createPrompt(
        pendingStore: PendingAppLinkStore,
        tab: SessionState,
        uri: String,
        lastUri: String?,
        input: ClassifierInput,
        decision: AppLinkDecision.Prompt,
        hasUserGesture: Boolean,
    ) {
        val resolved = input.resolved
        val owner = if (tab is CustomTabSessionState) {
            AppLinkPromptOwner.NATIVE_EXTERNAL
        } else {
            AppLinkPromptOwner.FLUTTER_BROWSER
        }
        val urlClass = when {
            decision.isMarketplace -> AppLinkUrlClass.MARKETPLACE
            decision.kind == AppLinkPromptKind.MODAL -> AppLinkUrlClass.MODAL
            else -> AppLinkUrlClass.BANNER
        }

        val created = pendingStore.createRequest(
            NewAppLinkRequest(
                owner = owner,
                tabId = tab.id,
                contextId = tab.contextId,
                sourceUrl = lastUri,
                isPrivate = input.isPrivate,
                isWallet = input.isWallet,
                isProtectedContext = input.isProtected,
                canRemember = decision.canRemember,
                isModal = decision.kind == AppLinkPromptKind.MODAL,
                urlClass = urlClass,
                url = uri,
                // The package to enforce at launch: only meaningful for a single,
                // non-ambiguous handler. Null for an ambiguous/chooser target so the
                // open path shows the chooser instead of refusing (§2.5/§2.7).
                expectedPackage = if (resolved.isAmbiguous) null else resolved.packageName,
                fallbackUrl = resolved.fallbackUrl,
                engineSupportsScheme = resolved.engineSupportsScheme,
                isMarketplace = decision.isMarketplace,
                targetFingerprint = targetFingerprint(uri, resolved),
                appName = resolved.appName,
                packageName = resolved.packageName,
                scopeKey = resolved.scopeKey,
                isUserGesture = hasUserGesture,
            ),
        )

        logger.info(
            "createPrompt owner=$owner tab=${tab.id} class=$urlClass id=${created.requestId} " +
                "canRemember=${decision.canRemember} url=$uri",
        )

        when (owner) {
            // The Custom Tab prompt feature only queries the store at lifecycle start, so a request
            // created afterwards (this navigation, on an engine thread) needs an explicit nudge or it
            // would sit unshown until a restart. The notifier re-queries on the main thread.
            AppLinkPromptOwner.NATIVE_EXTERNAL ->
                NativeAppLinkPromptNotifier.notifyPromptAvailable(tab.id)

            // Best-effort availability nudge for the Flutter surface; the pending store + query is the
            // contract (§2.8), so a lost event (Flutter detached) is harmless — it re-queries on resume.
            AppLinkPromptOwner.FLUTTER_BROWSER ->
                GlobalComponents.appLinkEvents?.onAppLinkPromptAvailable(EventSequence.next(), owner) { _ -> }
        }
    }

    private fun safeNonLaunchResponse(
        pendingStore: PendingAppLinkStore,
        resolved: ResolvedAppLink,
    ): RequestInterceptor.InterceptionResponse? {
        return if (resolved.engineSupportsScheme) {
            null
        } else {
            resolved.fallbackUrl?.let {
                pendingStore.recordFallbackReentry(canonicalReentryKey(it))
                RequestInterceptor.InterceptionResponse.Url(it)
            } ?: RequestInterceptor.InterceptionResponse.Deny
        }
    }

    /**
     * True when [targetPackage] is the very app that opened this tab — the shape of a sign-in
     * callback. [targetPackage] must be an unambiguous resolution; pass `null` otherwise.
     */
    private fun isAuthenticationCallback(session: SessionState?, targetPackage: String?): Boolean {
        if (targetPackage.isNullOrEmpty()) return false
        return callerPackage(session) == targetPackage
    }

    /**
     * The package that launched this session, as recorded by
     * [eu.weblibre.flutter_mozilla_components.activities.addExternalCallerInformation]. Note the
     * underlying referrer is caller-supplied and can be spoofed, so this may only gate actions the
     * caller could already perform itself (here: launching its own intent).
     */
    private fun callerPackage(session: SessionState?): String? {
        return when (val source = session?.source) {
            is SessionState.Source.External.CustomTab -> source.caller?.packageId
            is SessionState.Source.External.ActionView -> source.caller?.packageId
            else -> null
        }
    }

    private fun isPossibleAuthentication(session: SessionState?): Boolean {
        return when (session?.source) {
            is SessionState.Source.External.CustomTab,
            is SessionState.Source.External.ActionView,
            -> true
            else -> false
        }
    }

    // ---- Eligibility (§2.4 step 2) ----

    private fun isEligible(
        uriScheme: String?,
        engineSupportsScheme: Boolean,
        hasUserGesture: Boolean,
        isRedirect: Boolean,
        isDirectNavigation: Boolean,
        isSubframeRequest: Boolean,
        isSameDomainNavigation: Boolean,
        authExceptionsAllowed: Boolean,
    ): Boolean {
        if (uriScheme == null) return false
        // A subframe request not triggered by the user and outside the allowlist stays in-page.
        if (!hasUserGesture && isSubframeRequest && !AppLinkSchemes.isSubframeAllowed(uriScheme)) return false

        val isAllowedRedirect = isRedirect && !isSubframeRequest
        val isIntentionalNavigation = hasUserGesture || isAllowedRedirect || isDirectNavigation
        // Unintentional engine-supported navigation continues in the browser.
        if (engineSupportsScheme && !isIntentionalNavigation) return false
        // Same-domain engine-supported navigation continues in the browser (AC subdomain stripping),
        // unless this tab could be hosting an authentication round trip whose callback is an http
        // app link on the same site. That "could be" is provisional — it only knows the tab was
        // opened by *some* app, not that this navigation targets it — so the guard is re-applied in
        // [onLoadRequest] once resolution reveals the actual target package.
        if (engineSupportsScheme && isSameDomainNavigation && !authExceptionsAllowed) return false
        // Always-denied schemes never resolve or launch externally.
        if (AppLinkSchemes.isAlwaysDenied(uriScheme)) return false
        return true
    }

    private fun isSameDomain(url1: String?, url2: String?): Boolean {
        return stripCommonSubDomains(url1?.tryGetHostFromUrl()) ==
            stripCommonSubDomains(url2?.tryGetHostFromUrl())
    }

    private fun stripCommonSubDomains(host: String?): String? {
        return when {
            host == null -> null
            host.startsWith(WWW) -> host.replaceFirst(WWW, "")
            host.startsWith(M) -> host.replaceFirst(M, "")
            host.startsWith(MOBILE) -> host.replaceFirst(MOBILE, "")
            host.startsWith(MAPS) -> host.replaceFirst(MAPS, "")
            else -> host
        }
    }

    // ---- Protection model (§2.3) ----

    private fun isProtected(policy: AppLinkPolicy, session: SessionState?, uri: String): Boolean {
        val contextId = session?.contextId
        val protectedByContext = if (contextId == null) {
            policy.protectGeneralContext
        } else {
            contextId in policy.protectedContextIds || contextId in policy.strictContextIds
        }
        if (protectedByContext) return true
        return matchesProtectedTarget(policy.protectedTargetPatterns, uri)
    }

    private fun matchesProtectedTarget(patterns: List<ProtectedTargetPattern>, uri: String): Boolean {
        if (patterns.isEmpty()) return false
        val parsed = runCatching { Uri.parse(uri) }.getOrNull() ?: return false
        val scheme = parsed.scheme?.lowercase(Locale.ROOT) ?: return false
        val host = AppLinkHostNormalizer.normalizeHost(parsed.host) ?: return false
        val effectivePort = if (parsed.port != -1) parsed.port else defaultPortForScheme(scheme)

        return patterns.any { pattern ->
            if (pattern.scheme.lowercase(Locale.ROOT) != scheme) return@any false
            val patternHost = AppLinkHostNormalizer.normalizeHost(pattern.hostOrSuffix) ?: return@any false
            if (pattern.includeSubdomains) {
                // Wildcard entries match apex + subdomains and ignore port (§2.3).
                host == patternHost || host.endsWith(".$patternHost")
            } else {
                // Exact entries compare scheme + origin including effective port.
                host == patternHost && effectivePort == (pattern.port ?: defaultPortForScheme(scheme))
            }
        }
    }

    private fun defaultPortForScheme(scheme: String): Int = when (scheme) {
        "http", "ws" -> 80
        "https", "wss" -> 443
        "ftp" -> 21
        else -> -1
    }

    // ---- Helpers ----

    /**
     * The dedupe/invalidation/suppression key: the full sanitised target, not just the rule scope,
     * so different paths sharing one policy scope never collapse into one request (§2.6).
     */
    private fun targetFingerprint(uri: String, resolved: ResolvedAppLink): String {
        val intentPayload = resolved.appIntent?.let {
            runCatching { it.toUri(Intent.URI_INTENT_SCHEME) }.getOrNull()
        }.orEmpty()
        return buildString {
            append(uri)
            append('\u0000')
            append(resolved.packageName.orEmpty())
            append('\u0000')
            append(intentPayload)
            append('\u0000')
            append(resolved.fallbackUrl.orEmpty())
        }
    }

    /** Canonical key for the fallback re-entry map — the raw URL, matched on identity round-trip. */
    private fun canonicalReentryKey(url: String): String = url

    private fun pendingStoreFor(components: Components): PendingAppLinkStore {
        return PendingAppLinkStores.forProfile(components.profileApplicationContext.relativePath)
    }

    companion object {
        private const val WWW = "www."
        private const val M = "m."
        private const val MOBILE = "mobile."
        private const val MAPS = "maps."
    }
}
