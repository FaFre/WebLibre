/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.Intent
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.mockito.Mockito.mock

class AppLinkClassifierTest {
    private fun resolved(
        hasExternalApp: Boolean = true,
        engineSupportsScheme: Boolean = false,
        fallbackUrl: String? = null,
        marketplace: Boolean = false,
        isAmbiguous: Boolean = false,
        packageName: String? = "com.example.app",
    ) = ResolvedAppLink(
        hasExternalApp = hasExternalApp,
        appIntent = null,
        packageName = if (hasExternalApp) packageName else null,
        appName = "Example",
        fallbackUrl = fallbackUrl,
        marketplaceIntent = if (marketplace) mock(Intent::class.java) else null,
        isAmbiguous = isAmbiguous,
        engineSupportsScheme = engineSupportsScheme,
        scopeKey = "host:example.com",
        originalScheme = if (engineSupportsScheme) "https" else "zoommtg",
        intentDataScheme = if (engineSupportsScheme) "https" else "zoommtg",
    )

    private fun input(
        resolved: ResolvedAppLink,
        isProtected: Boolean = false,
        isPrivate: Boolean = false,
        isWallet: Boolean = false,
        missingSession: Boolean = false,
        suppressionHit: Boolean = false,
        matchingRule: AppLinkRule? = null,
        globalMode: AppLinkMode = AppLinkMode.ASK,
        marketplaceFallbackEnabled: Boolean = false,
    ) = ClassifierInput(
        resolved = resolved,
        isProtected = isProtected,
        isPrivate = isPrivate,
        isWallet = isWallet,
        missingSession = missingSession,
        suppressionHit = suppressionHit,
        matchingRule = matchingRule,
        globalMode = globalMode,
        marketplaceFallbackEnabled = marketplaceFallbackEnabled,
    )

    // ---- §2.2 table: engine-supported (http) scheme, app resolves ----

    @Test
    fun engineSupportedAlwaysAutoLaunches() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = true), globalMode = AppLinkMode.ALWAYS),
        )
        assertEquals(AppLinkDecision.AutoLaunch(expectedPackage = null), d)
    }

    @Test
    fun engineSupportedAskShowsBanner() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = true), globalMode = AppLinkMode.ASK),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.BANNER, canRemember = true, isMarketplace = false),
            d,
        )
    }

    @Test
    fun engineSupportedNeverAllowsPage() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = true), globalMode = AppLinkMode.NEVER),
        )
        assertEquals(AppLinkDecision.AllowEngine, d)
    }

    // ---- §2.2 table: unsupported scheme, app resolves ----

    @Test
    fun unsupportedAskShowsModal() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = false), globalMode = AppLinkMode.ASK),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.MODAL, canRemember = true, isMarketplace = false),
            d,
        )
    }

    @Test
    fun unsupportedNeverWithFallbackLoadsFallback() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(engineSupportsScheme = false, fallbackUrl = "https://fallback.example"),
                globalMode = AppLinkMode.NEVER,
            ),
        )
        assertEquals(AppLinkDecision.LoadFallback("https://fallback.example"), d)
    }

    @Test
    fun unsupportedNeverWithoutFallbackKeepsPage() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = false), globalMode = AppLinkMode.NEVER),
        )
        assertEquals(AppLinkDecision.DenyKeepPage, d)
    }

    // ---- §2.2 table: no app ----

    @Test
    fun noAppWithFallbackLoadsFallback() {
        val d = AppLinkClassifier.classify(
            input(resolved(hasExternalApp = false, fallbackUrl = "https://fb.example")),
        )
        assertEquals(AppLinkDecision.LoadFallback("https://fb.example"), d)
    }

    @Test
    fun noAppNoFallbackEngineSupportedAllows() {
        val d = AppLinkClassifier.classify(
            input(resolved(hasExternalApp = false, engineSupportsScheme = true)),
        )
        assertEquals(AppLinkDecision.AllowEngine, d)
    }

    @Test
    fun noAppNoFallbackUnsupportedDenies() {
        val d = AppLinkClassifier.classify(
            input(resolved(hasExternalApp = false, engineSupportsScheme = false)),
        )
        assertEquals(AppLinkDecision.DenyKeepPage, d)
    }

    @Test
    fun noAppMarketplaceWhenEnabledAndNotNever() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(hasExternalApp = false, marketplace = true),
                globalMode = AppLinkMode.ASK,
                marketplaceFallbackEnabled = true,
            ),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.MODAL, canRemember = false, isMarketplace = true),
            d,
        )
    }

    @Test
    fun noAppMarketplaceSuppressedUnderNever() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(hasExternalApp = false, marketplace = true, engineSupportsScheme = false),
                globalMode = AppLinkMode.NEVER,
                marketplaceFallbackEnabled = true,
            ),
        )
        assertEquals(AppLinkDecision.DenyKeepPage, d)
    }

    // ---- §2.4 precedence: forced-prompt contexts override rules ----

    @Test
    fun protectedContextPromptsEvenWithAlwaysOpenRule() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(engineSupportsScheme = true),
                isProtected = true,
                matchingRule = AppLinkRule(AppLinkRuleDecision.ALWAYS_OPEN, "host:example.com", "com.example.app"),
                globalMode = AppLinkMode.ALWAYS,
            ),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.BANNER, canRemember = false, isMarketplace = false),
            d,
        )
    }

    @Test
    fun privateTabPromptsWithoutRemember() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = false), isPrivate = true, globalMode = AppLinkMode.ALWAYS),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.MODAL, canRemember = false, isMarketplace = false),
            d,
        )
    }

    @Test
    fun walletPromptsWithoutRemember() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = false), isWallet = true),
        )
        assertTrue(d is AppLinkDecision.Prompt && !d.canRemember)
    }

    // (helpers above build ResolvedAppLink/ClassifierInput.)

    @Test
    fun missingSessionNeverAutoLaunches() {
        // Engine-supported → allow the page; unsupported → deny (or fallback).
        assertEquals(
            AppLinkDecision.AllowEngine,
            AppLinkClassifier.classify(
                input(resolved(engineSupportsScheme = true), missingSession = true, globalMode = AppLinkMode.ALWAYS),
            ),
        )
        assertEquals(
            AppLinkDecision.DenyKeepPage,
            AppLinkClassifier.classify(
                input(resolved(engineSupportsScheme = false), missingSession = true, globalMode = AppLinkMode.ALWAYS),
            ),
        )
    }

    // ---- §2.4 step 5: suppression ----

    @Test
    fun suppressionHitNeverLaunchesEngineSupported() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = true), suppressionHit = true, globalMode = AppLinkMode.ALWAYS),
        )
        assertEquals(AppLinkDecision.AllowEngine, d)
    }

    @Test
    fun suppressionHitUnsupportedUsesFallbackOnly() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(engineSupportsScheme = false, fallbackUrl = "https://fb.example"),
                suppressionHit = true,
                globalMode = AppLinkMode.ALWAYS,
            ),
        )
        assertEquals(AppLinkDecision.LoadFallback("https://fb.example"), d)
    }

    // ---- §2.4 step 6: remembered rules ----

    @Test
    fun alwaysOpenRuleAutoLaunchesWithExpectedPackage() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(engineSupportsScheme = true),
                matchingRule = AppLinkRule(AppLinkRuleDecision.ALWAYS_OPEN, "host:example.com", "com.example.app"),
                globalMode = AppLinkMode.ASK,
            ),
        )
        assertEquals(AppLinkDecision.AutoLaunch(expectedPackage = "com.example.app"), d)
    }

    @Test
    fun neverOpenRuleFollowsNeverRow() {
        val d = AppLinkClassifier.classify(
            input(
                resolved(engineSupportsScheme = false),
                matchingRule = AppLinkRule(AppLinkRuleDecision.NEVER_OPEN, "host:example.com", null),
                globalMode = AppLinkMode.ALWAYS,
            ),
        )
        assertEquals(AppLinkDecision.DenyKeepPage, d)
    }

    @Test
    fun ambiguousResolutionCannotBeRemembered() {
        val d = AppLinkClassifier.classify(
            input(resolved(engineSupportsScheme = true, isAmbiguous = true), globalMode = AppLinkMode.ASK),
        )
        assertEquals(
            AppLinkDecision.Prompt(AppLinkPromptKind.BANNER, canRemember = false, isMarketplace = false),
            d,
        )
    }
}
