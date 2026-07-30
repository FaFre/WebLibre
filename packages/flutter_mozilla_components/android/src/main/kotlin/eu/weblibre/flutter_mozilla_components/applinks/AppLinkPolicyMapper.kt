/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import eu.weblibre.flutter_mozilla_components.pigeons.AppLinkPolicySnapshot
import eu.weblibre.flutter_mozilla_components.pigeons.AppLinksMode as PigeonAppLinksMode
import eu.weblibre.flutter_mozilla_components.pigeons.NativeAppLinkRule
import eu.weblibre.flutter_mozilla_components.pigeons.NativeAppLinkRuleDecision

/** Map the replicated Pigeon snapshot to the Kotlin-native classifier policy (§2.8). */
fun AppLinkPolicySnapshot.toAppLinkPolicy(): AppLinkPolicy {
    return AppLinkPolicy(
        globalMode = globalMode.toAppLinkMode(),
        rules = rules.mapValues { (_, rule) -> rule.toAppLinkRule() },
        marketplaceFallbackEnabled = marketplaceFallbackEnabled,
        protectGeneralContext = protectGeneralContext,
        protectedContextIds = protectedContextIds.toSet(),
        strictContextIds = strictContextIds.toSet(),
        protectedTargetPatterns = protectedTargetPatterns.map { pattern ->
            ProtectedTargetPattern(
                scheme = pattern.scheme,
                hostOrSuffix = pattern.hostOrSuffix,
                includeSubdomains = pattern.includeSubdomains,
                port = pattern.port?.toInt(),
            )
        },
        contextOverrides = contextOverrides.mapValues { (_, override) ->
            ContextAppLinkPolicy(
                globalMode = override.mode.toAppLinkMode(),
                rules = override.rules.mapValues { (_, rule) -> rule.toAppLinkRule() },
            )
        },
    )
}

private fun PigeonAppLinksMode.toAppLinkMode(): AppLinkMode = when (this) {
    PigeonAppLinksMode.ALWAYS -> AppLinkMode.ALWAYS
    PigeonAppLinksMode.ASK -> AppLinkMode.ASK
    PigeonAppLinksMode.NEVER -> AppLinkMode.NEVER
}

private fun NativeAppLinkRule.toAppLinkRule(): AppLinkRule = AppLinkRule(
    decision = when (decision) {
        NativeAppLinkRuleDecision.ALWAYS_OPEN -> AppLinkRuleDecision.ALWAYS_OPEN
        NativeAppLinkRuleDecision.NEVER_OPEN -> AppLinkRuleDecision.NEVER_OPEN
    },
    scope = scope,
    packageName = packageName,
)
