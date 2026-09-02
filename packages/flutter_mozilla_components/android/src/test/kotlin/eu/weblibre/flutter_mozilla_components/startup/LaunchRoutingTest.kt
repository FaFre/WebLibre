/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/. */

package eu.weblibre.flutter_mozilla_components.startup

import eu.weblibre.flutter_mozilla_components.feature.GENERAL_CONTEXT_ID
import eu.weblibre.flutter_mozilla_components.feature.PRIVATE_CONTEXT_ID
import eu.weblibre.flutter_mozilla_components.feature.RoutingResolution
import eu.weblibre.flutter_mozilla_components.feature.RoutingVerdict
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue
import org.json.JSONArray
import org.json.JSONObject

class RoutingResolutionTest {
    @Test
    fun aContextWithNoRelationAnywhereIsDirect() {
        assertEquals(
            RoutingVerdict.DIRECT,
            RoutingResolution.verdict(snapshot(), "work"),
        )
    }

    @Test
    fun anEmptyRelationIsAnExplicitDirectConnection() {
        val snapshot = snapshot(relations = mapOf("work" to emptyList()))

        assertEquals(RoutingVerdict.DIRECT, RoutingResolution.verdict(snapshot, "work"))
    }

    /** Mirrors `Store.getEffectiveRelation`: everything but private inherits. */
    @Test
    fun aContextWithoutARelationInheritsTheGeneralOne() {
        val snapshot = snapshot(relations = mapOf(GENERAL_CONTEXT_ID to listOf("tor")))

        assertEquals(RoutingVerdict.BLOCKED, RoutingResolution.verdict(snapshot, "work"))
    }

    @Test
    fun privateNeverInheritsTheGeneralRelation() {
        val snapshot = snapshot(relations = mapOf(GENERAL_CONTEXT_ID to listOf("tor")))

        assertEquals(
            RoutingVerdict.DIRECT,
            RoutingResolution.verdict(snapshot, PRIVATE_CONTEXT_ID),
        )
    }

    @Test
    fun aRelationWithALiveEndpointIsLive() {
        val snapshot = snapshot(
            relations = mapOf("work" to listOf("tor")),
            proxyIds = listOf("tor"),
        )

        assertEquals(RoutingVerdict.LIVE, RoutingResolution.verdict(snapshot, "work"))
    }

    @Test
    fun aRelationWhoseBackendIsStartingIsNotYetBlocked() {
        val snapshot = snapshot(
            relations = mapOf("work" to listOf("tor")),
            awaitingProxyIds = listOf("tor"),
        )

        assertEquals(RoutingVerdict.STARTING, RoutingResolution.verdict(snapshot, "work"))
    }

    /** The seed's shape: relations restored, endpoints deliberately dropped. */
    @Test
    fun aRelationWithNoEndpointAndNothingStartingIsBlocked() {
        val snapshot = snapshot(relations = mapOf("work" to listOf("tor")))

        assertEquals(RoutingVerdict.BLOCKED, RoutingResolution.verdict(snapshot, "work"))
    }

    @Test
    fun noSnapshotIsUnknownRatherThanDirect() {
        assertEquals(RoutingVerdict.UNKNOWN, RoutingResolution.verdict(null, "work"))
    }

    /**
     * The cases the proxy extension's `Store` is held to as well.
     *
     * Both sides read the same snapshots from the same file and must agree on
     * every one; see `shared/routing/README.md` for why there are two
     * implementations at all. A rule changed on one side and not the other
     * fails here rather than as a dead Custom Tab window.
     */
    @Test
    fun everySharedCaseResolvesTheWayTheExtensionResolvesIt() {
        val fixture = javaClass.getResourceAsStream("/routing_verdicts.json")
            ?.bufferedReader()
            ?.use { it.readText() }
            ?: throw AssertionError(
                "routing_verdicts.json is not on the test classpath; check " +
                    "test.resources.srcDirs in android/build.gradle",
            )

        val cases = JSONObject(fixture).getJSONArray("cases")
        assertTrue(cases.length() > 0, "the shared fixture must carry cases")

        for (index in 0 until cases.length()) {
            val case = cases.getJSONObject(index)

            assertEquals(
                RoutingVerdict.valueOf(case.getString("expected")),
                RoutingResolution.verdict(
                    case.getJSONObject("snapshot"),
                    case.getString("contextId"),
                ),
                case.getString("name"),
            )
        }
    }

    /**
     * What a launch would have to start, resolved by the same rules as the
     * verdict — a different reading of the two would demand a proxy for a
     * context the extension does not route that way.
     */
    @Test
    fun aBlockedRelationNamesWhatWouldHaveToStart() {
        val snapshot = snapshot(relations = mapOf("work" to listOf("tor")))

        assertEquals(
            listOf("tor"),
            RoutingResolution.blockedProxyIds(snapshot, "work"),
        )
    }

    @Test
    fun anInheritedBlockedRelationNamesItToo() {
        val snapshot = snapshot(relations = mapOf(GENERAL_CONTEXT_ID to listOf("tor")))

        assertEquals(
            listOf("tor"),
            RoutingResolution.blockedProxyIds(snapshot, "work"),
        )
    }

    @Test
    fun nothingHasToStartForALiveOrDirectContext() {
        val live = snapshot(
            relations = mapOf("work" to listOf("tor")),
            proxyIds = listOf("tor"),
        )

        assertEquals(emptyList(), RoutingResolution.blockedProxyIds(live, "work"))
        assertEquals(emptyList(), RoutingResolution.blockedProxyIds(snapshot(), "work"))
        assertEquals(emptyList(), RoutingResolution.blockedProxyIds(null, "work"))
        assertEquals(
            emptyList(),
            RoutingResolution.blockedProxyIds(
                snapshot(relations = mapOf(GENERAL_CONTEXT_ID to listOf("tor"))),
                PRIVATE_CONTEXT_ID,
            ),
        )
    }

    private fun snapshot(
        relations: Map<String, List<String>> = emptyMap(),
        proxyIds: List<String> = emptyList(),
        awaitingProxyIds: List<String> = emptyList(),
    ): JSONObject {
        return JSONObject().apply {
            put(
                "relations",
                JSONObject().apply {
                    relations.forEach { (contextId, ids) -> put(contextId, JSONArray(ids)) }
                },
            )
            put(
                "proxies",
                JSONArray(proxyIds.map { JSONObject().put("id", it) }),
            )
            put("awaitingProxies", JSONArray(awaitingProxyIds))
        }
    }
}

class LaunchRoutingTest {
    @Test
    fun aPrivateLaunchIsKeyedOnThePrivateContext() {
        assertEquals(
            PRIVATE_CONTEXT_ID,
            LaunchRouting.contextIdFor(pwaContextId = "work", isPrivate = true),
        )
    }

    @Test
    fun aPwaIsKeyedOnItsOwnContainer() {
        assertEquals(
            "work",
            LaunchRouting.contextIdFor(pwaContextId = "work", isPrivate = false),
        )
    }

    @Test
    fun everythingElseIsKeyedOnTheGeneralContext() {
        assertEquals(
            GENERAL_CONTEXT_ID,
            LaunchRouting.contextIdFor(pwaContextId = null, isPrivate = false),
        )
        assertEquals(
            GENERAL_CONTEXT_ID,
            LaunchRouting.contextIdFor(pwaContextId = "", isPrivate = false),
        )
    }

    /** The fast path: a context that was direct last run needs nothing started. */
    @Test
    fun aPersistedDirectRouteIsServedHeadlessly() {
        assertEquals(
            LaunchRoutingPlan.PROCEED,
            LaunchRouting.plan(RoutingVerdict.UNKNOWN, RoutingVerdict.DIRECT),
        )
    }

    @Test
    fun aPersistedProxiedRouteNeedsTheAppHalf() {
        assertEquals(
            LaunchRoutingPlan.BOOTSTRAP,
            LaunchRouting.plan(RoutingVerdict.UNKNOWN, RoutingVerdict.BLOCKED),
        )
    }

    /**
     * No record at all is not permission to run headless: the profile may well
     * route this context through a proxy and simply never have persisted a
     * snapshot.
     */
    @Test
    fun anUnknownPersistedRouteNeedsTheAppHalf() {
        assertEquals(
            LaunchRoutingPlan.BOOTSTRAP,
            LaunchRouting.plan(RoutingVerdict.UNKNOWN, RoutingVerdict.UNKNOWN),
        )
    }

    @Test
    fun installedRoutingAnswersForItself() {
        for (verdict in listOf(
            RoutingVerdict.DIRECT,
            RoutingVerdict.LIVE,
            RoutingVerdict.STARTING,
        )) {
            assertEquals(
                LaunchRoutingPlan.PROCEED,
                // Even where the persisted record disagrees: the app is here, and
                // what it installed is what the extension is actually enforcing.
                LaunchRouting.plan(verdict, RoutingVerdict.BLOCKED),
                "$verdict must serve the launch",
            )
        }
    }

    /**
     * A start that has settled without an endpoint. The launch cannot load, but
     * the browser can tell the user why and offer to start the proxy.
     */
    @Test
    fun installedRoutingThatBlocksSendsTheLaunchToTheBrowser() {
        assertEquals(
            LaunchRoutingPlan.OPEN_IN_BROWSER,
            LaunchRouting.plan(RoutingVerdict.BLOCKED, RoutingVerdict.DIRECT),
        )
    }
}
