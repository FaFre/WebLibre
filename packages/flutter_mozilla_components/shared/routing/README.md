# Shared routing fixtures

`routing_verdicts.json` is the one description of how a routing snapshot resolves
to an answer for a context. Two implementations read it:

- `android/src/main/kotlin/.../feature/RoutingResolution.kt`, which native uses to
  decide whether a Custom Tab / PWA launch can be served at all;
- `javascript/container_proxy/src/store/Store.ts`, which is what actually enforces
  the routing on every request.

They are separate implementations because neither side can ask the other: native
has a persisted seed and a pushed snapshot to read before any extension exists,
and the extension has no channel to ask native. A launch decided by a *different*
reading of the same snapshot than the extension's is a launch that fails in a way
nothing predicted — a dead Custom Tab window — which is the bug class this
fixture exists to catch.

Both test suites load this file and assert the same verdicts:

- `android/src/test/kotlin/.../startup/LaunchRoutingTest.kt` (`RoutingResolutionTest`)
- `javascript/container_proxy/test/unit/RoutingParity.test.ts`

Gradle puts this directory on the unit-test classpath via `test.resources.srcDirs`;
the TypeScript suite reads it by relative path. Add a case here rather than to
either suite, so a rule that changes on one side fails on the other.

`UNKNOWN` is deliberately absent: it means "no snapshot", which the extension
expresses as an unready store rather than as a resolution, so the two sides have
nothing to agree about. Each suite covers it on its own.
