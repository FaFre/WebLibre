/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package eu.weblibre.flutter_mozilla_components.applinks

import android.content.ComponentName
import android.content.Intent
import androidx.core.net.toUri
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers.anyBoolean
import org.mockito.ArgumentMatchers.anyString
import org.mockito.Mockito.mock
import org.mockito.Mockito.`when`
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull

/**
 * How an *unbound* launch reaches the user. Robolectric, because `Intent.createChooser` is real
 * framework code and the assertions are about the intent that actually gets started.
 */
@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE, sdk = [28])
class AppLinkLauncherChooserTest {

    private val browser = ComponentName("eu.weblibre", "eu.weblibre.MainActivity")

    private fun resolved(
        isAmbiguous: Boolean,
        component: ComponentName? = null,
        excluded: List<ComponentName> = emptyList(),
    ): ResolvedAppLink {
        val intent = Intent(Intent.ACTION_VIEW, "https://shared.example/x".toUri()).apply {
            addCategory(Intent.CATEGORY_BROWSABLE)
            this.component = component
        }
        return ResolvedAppLink(
            hasExternalApp = true,
            appIntent = intent,
            packageName = component?.packageName ?: "com.first.app",
            appName = if (isAmbiguous) null else "App",
            fallbackUrl = null,
            marketplaceIntent = null,
            isAmbiguous = isAmbiguous,
            engineSupportsScheme = true,
            scopeKey = "host:shared.example",
            originalScheme = "https",
            intentDataScheme = "https",
            excludedComponents = excluded,
            intentDataUrl = "https://shared.example/x",
        )
    }

    private fun launchAndCapture(resolved: ResolvedAppLink): Intent {
        val resolver = mock(ExternalAppResolver::class.java)
        `when`(resolver.resolve(anyString(), anyBoolean(), anyBoolean())).thenReturn(resolved)
        var started: Intent? = null
        val launcher = AppLinkLauncher(resolver, { started = it })

        assertEquals(
            AppLinkLaunchResult.LAUNCHED,
            launcher.launch("https://shared.example/x", AppLinkLaunchMode.MANUAL),
        )
        return assertNotNull(started)
    }

    @Test
    fun `an ambiguous launch goes through a chooser that excludes browsers`() {
        // Started implicitly, an unbound ACTION_VIEW on an http URL resolves like any web link and
        // lands on the default browser — which for this app's users is usually WebLibre itself, so
        // the link would reopen the browser it was trying to leave.
        val started = launchAndCapture(resolved(isAmbiguous = true, excluded = listOf(browser)))

        assertEquals(Intent.ACTION_CHOOSER, started.action)
        val excluded = started.getParcelableArrayExtra(Intent.EXTRA_EXCLUDE_COMPONENTS)
        assertEquals(listOf(browser), excluded?.toList())
        // The offer itself is unchanged underneath.
        val target = started.getParcelableExtra<Intent>(Intent.EXTRA_INTENT)
        assertEquals("https://shared.example/x", target?.data?.toString())
    }

    @Test
    fun `a bound launch is started directly`() {
        val component = ComponentName("com.only.app", "com.only.app.Main")
        val started = launchAndCapture(resolved(isAmbiguous = false, component = component))

        assertEquals(Intent.ACTION_VIEW, started.action)
        assertEquals(component, started.component)
        assertNull(started.getParcelableArrayExtra(Intent.EXTRA_EXCLUDE_COMPONENTS))
    }

    @Test
    fun `the chooser still carries the launch flags`() {
        val started = launchAndCapture(resolved(isAmbiguous = true, excluded = listOf(browser)))

        // Every launch dispatches through the process-level application context, so NEW_TASK is
        // mandatory on whatever is actually started — the chooser, here, not the target.
        assertEquals(
            Intent.FLAG_ACTIVITY_NEW_TASK,
            started.flags and Intent.FLAG_ACTIVITY_NEW_TASK,
        )
    }
}
